package Database;

import Models.Speech;
import Models.SpeechCAS;
import org.apache.uima.cas.CASException;
import org.apache.uima.fit.factory.JCasFactory;
import org.apache.uima.resource.ResourceInitializationException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * This class checks the website of the Parliament to see if there are any new speeches or protocols found. In that
 * case it parses the respective xml files and saves the new data in the database. It repeats the process every 6 hours
 * by using a timer.
 * @author Enea Naco
 */
public class BundestagDataFinder {

    private static final long INTERVAL = 6 * 60 * 60 * 1000; // 6 hours converted to Miliiseconds
    private static final String API_URL = "https://search.dip.bundestag.de/api/v1/plenarprotokoll";
    private static final String API_KEY = "I9FKdCn.hbfefNWCY336dL6x62vfwNKpoN2RZ1gp21";
    private final MongoDatabaseHandler databaseHandler;
    public BundestagDataFinder(MongoDatabaseHandler databaseHandler) {
        this.databaseHandler = databaseHandler;
    }

    /**
     * Starts the process of looking for new speeches every 6 hours.
     * @author Enea Naco
     */
    public void startScheduler() {
        Timer timer = new Timer(true);
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                System.out.println("Checking the Parliament website for new data.");
                findAndStoreSpeeches();
            }
        }, 0, INTERVAL);
    }


    /**
     * Retrieves parliamentary speeches from the Parliament website.The method makes API requests to find XML
     * files containing speeches, stores them in a list and calls a method to process each XML file.
     * A maximum of 1000 API calls are allowed so that we don't end up in an infinite loop. Errors are logged and the
     * method stops if it encounters an error.
     * @author Enea Naco
     */
    public void findAndStoreSpeeches() {
        try {
            String cursor = null;
            List<String> xmlUrls = new ArrayList<>();

            // Add counter to limit the number of iterations
            int count = 0;

            do {
                if (count++ > 1000) {
                    System.err.println("Maximum number of iterations is reached.");
                    break;
                }

                // Building the API url
                String fullUrl = API_URL + "?f.zuordnung=BT&f.wahlperiode=20&apikey=" + API_KEY;
                if (cursor != null) {
                    // Add cursor if it exists
                    fullUrl += "&cursor=" + cursor;
                }

                // HTTP connection to the API
                HttpURLConnection connection = (HttpURLConnection) new URL(fullUrl).openConnection();
                connection.setRequestMethod("GET");
                connection.setRequestProperty("Accept", "application/json");

                // Check if the request was successful
                if (connection.getResponseCode() != 200) {
                    System.err.println("API request returned an error: " + connection.getResponseCode());
                    break;
                }

                // API response
                BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder response = new StringBuilder();
                String input;
                while ((input = in.readLine()) != null) {
                    response.append(input);
                }

                in.close();

                // Parse JSON
                JSONObject jsonResponse = new JSONObject(response.toString());
                JSONArray documents = jsonResponse.getJSONArray("documents");

                // Break the loop if no files are found
                if (documents.isEmpty()) {
                    System.out.println("No documents found.");
                    break;
                }

                // Take the XML urls from the response
                for (int i = 0; i < documents.length(); i++) {
                    JSONObject doc = documents.getJSONObject(i);
                    if (doc.has("fundstelle") && doc.getJSONObject("fundstelle").has("pdf_url")) {
                        String xmlUrl = doc.getJSONObject("fundstelle").getString("pdf_url").replace(".pdf", ".xml");
                        xmlUrls.add(xmlUrl);
                        System.out.println("Following xml file was found: " + xmlUrl);
                    }
                }

                // update cursor for the next api request
                cursor = jsonResponse.has("cursor") ? jsonResponse.optString("cursor", null) : null;

            } while (cursor != null);

            System.out.println(xmlUrls.size() + " XML files were found.");

            if (!xmlUrls.isEmpty()) {
                xmlUrls.remove(0);
            }

            // Process the xml files
            for (String xmlUrl : xmlUrls) {
                processXmlFile(xmlUrl);
            }

        } catch (Exception e) {
            System.err.println("API request returned an error: " + e.getMessage());
        }
    }


    /**
     * Parses an XML file and stores the data in the database, in case it wasn't already stored
     * @param xmlUrl The URL of the XML file.
     * @author Enea Naco
     * @modified by Lawan Mai - Added the Nlp-Pipline to store a SpeechCAS for newly stored Speech.
     */
    private void processXmlFile(String xmlUrl) {
        try {
            System.out.println("Processing file: " + xmlUrl);
            Document xmlDoc = Jsoup.connect(xmlUrl).get();
            Elements tagesordnungspunkte = xmlDoc.select("sitzungsverlauf tagesordnungspunkt");

            for (Element topElement : tagesordnungspunkte) {
                Element kopfElement = topElement.selectFirst("kopf");
                String agendaTitle = (kopfElement != null) ? kopfElement.text() : "title";

                Elements speeches = topElement.select("rede");

                for (Element speechElement : speeches) {
                    String speechId = speechElement.attr("id");

                    // Extract Speaker ID
                    Element speakerElement = speechElement.selectFirst("redner");
                    String speakerId = (speakerElement != null) ? speakerElement.attr("id") : "";

                    // Extract speech text from <p> elements
                    StringBuilder textBuilder = new StringBuilder();
                    Elements textElements = speechElement.select("p");
                    for (Element p : textElements) {
                        textBuilder.append(p.text()).append(" ");
                    }
                    String text = textBuilder.toString().trim();

                    // Check if a speech exists in the Database
                    if (!databaseHandler.speechExists(speechId)) {
                        Speech speech = new Speech();
                        speech.setId(speechId);
                        speech.setText(text);
                        speech.setSpeaker(speakerId);

                        // Extract Protocol Info
                        Speech.Protocol protocol = new Speech.Protocol();

                        // find and set the date
                        String dateStr = xmlDoc.selectFirst("datum").attr("date");
                        protocol.setDate(parseDateToMillis(dateStr));

                        // find and set starttime and endtime
                        String starttimeStr = xmlDoc.selectFirst("sitzungsbeginn").attr("sitzung-start-uhrzeit");
                        String endtimeStr = xmlDoc.selectFirst("sitzungsende").attr("sitzung-ende-uhrzeit");
                        protocol.setStarttime(parseTimeToMillis(starttimeStr, dateStr));
                        protocol.setEndtime(parseTimeToMillis(endtimeStr, dateStr));

                        // Extract index correctly by removing all non-numeric characters as there are
                        // cases where the number doesn't stand alone in the tag
                        String indexStr = xmlDoc.selectFirst("sitzungsnr").text().replaceAll("\\D+", "");
                        protocol.setIndex(Integer.parseInt(indexStr));


                        // Set the title
                        protocol.setTitle("Plenarprotokoll 20/" + indexStr);

                        protocol.setPlace("Berlin");
                        protocol.setWp(20);
                        speech.setProtocol(protocol);

                        // Extract TextContent
                        List<Speech.TextContent> textContentList = new ArrayList<>();
                        for (Element p : textElements) {
                            Speech.TextContent textContent = new Speech.TextContent();
                            textContent.setId(speechId);
                            textContent.setSpeaker(speakerId);
                            textContent.setText(p.text());
                            textContent.setType("text");
                            textContentList.add(textContent);
                        }
                        speech.setTextContent(textContentList);

                        // Set Agenda
                        Speech.Agenda agenda = new Speech.Agenda();
                        agenda.setId(speechId);
                        String agendaIndex = topElement.attr("top-id");
                        agenda.setIndex(agendaIndex);
                        agenda.setTitle(agendaTitle);
                        speech.setAgenda(agenda);

                        // Save data in the database
                        databaseHandler.saveSpeech(speech);

                        // Push speech through NLP-pipline and save results in the database.
                        SpeechCAS speechCAS = new SpeechCAS(JCasFactory.createText(speech.getText()), speech.getId());
                        databaseHandler.saveSpeechCAS(speechCAS);

                        System.out.println("Speech saved: " + speechId);
                    } else {
                        System.out.println("Speech already exists: " + speechId);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Failed to process " + xmlUrl + ": " + e.getMessage());
        } catch (ResourceInitializationException e) {
            throw new RuntimeException(e);
        } catch (CASException e) {
            throw new RuntimeException(e);
        }
    }


    /**
     * Converts a date string in the format "dd.MM.yyyy" to Unix time.
     *
     * @param dateStr The date string to be converted.
     * @return The date in milliseconds, or 0 if parsing fails.
     * @author Enea Naco
     */
    private long parseDateToMillis(String dateStr) {
        try {
            // Define date format
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd.MM.yyyy");

            // Parse the date string into a Date object
            Date date = simpleDateFormat.parse(dateStr);

            // Convert and return
            return date.getTime();
        } catch (ParseException e) {
            // Log an error if parsing fails
            System.err.println("Failed to parse date: " + dateStr);
            return 0L;
        }
    }

    /**
     * Converts a date and time string in the format "dd.MM.yyyy HH:mm" to milliseconds since epoch.
     *
     * @param timeStr The time string in "HH:mm" format.
     * @param dateStr The date string in "dd.MM.yyyy" format.
     * @return The timestamp in milliseconds, or 0 if parsing fails.
     * @author Enea Naco
     */
    private long parseTimeToMillis(String timeStr, String dateStr) {
        try {
            // Define date and time format
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm");

            // Parse the combined date and time string into a Date object
            Date dateTime = simpleDateFormat.parse(dateStr + " " + timeStr);

            // Convert and return
            return dateTime.getTime();
        } catch (ParseException e) {
            // Log an error if parsing fails
            System.err.println("Failed to parse time: " + timeStr);
            return 0L;
        }
    }


}
