package Controllers;

import Database.MongoDatabaseHandler;
import Models.Speaker;
import Models.Speech;
import io.javalin.Javalin;
import io.javalin.http.Context;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Controller for Redeportal related endpoints.
 * @author Mariia Isaeva
 */
public class RedeportalController {
    private static MongoDatabaseHandler mongoHandler;

    static {
        try {
            mongoHandler = new MongoDatabaseHandler();
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
    }

    /**
     * Registers all routes
     * @param app The Javalin app
     */

    public static void registerRoutes(Javalin app) {
        // API endpoints
        app.get("/api/redeportal/speakers", RedeportalController::getAllSpeakersApi);
        app.get("/api/redeportal/speakers/{id}/speeches", RedeportalController::getSpeakerSpeechesApi);
    }

    /**
     * Serves the main Redeportal page with all speakers
     * @param ctx The Javalin context
     */
    public static void getAllSpeakersPage(Context ctx) {
        try {
            List<Speaker> speakers = mongoHandler.getAllSpeakers();
            speakers.sort(  // Sorting speakers in alph order
                    Comparator.comparing(Speaker::getFirstName, String.CASE_INSENSITIVE_ORDER)
                            .thenComparing(Speaker::getName, String.CASE_INSENSITIVE_ORDER)
            );
            Map<String, Object> model = new HashMap<>();
            model.put("speakers", speakers);
            ctx.render("redeportal.ftl", model);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).result("Failed to load speakers: " + e.getMessage());
        }
    }

    /**
     * Api endpoint to get all speakers
     * @param ctx The Javalin context
     */
    public static void getAllSpeakersApi(Context ctx) {
        try {
            List<Speaker> speakers = mongoHandler.getAllSpeakers();
            List<Map<String, Object>> speakersData = speakers.stream()
                    .map(RedeportalController::speakerApi)
                    .collect(Collectors.toList());
            ctx.json(speakersData);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    /**
     * Transforms a Speech object into a simplified map representation suitable for JSON API responses.
     *
     * @param speech The Speech object to transform
     * @return A map containing key information from the speech
     */
    private static Map<String, Object> speechApi(Speech speech) {
        Map<String, Object> speechData = new HashMap<>();
        speechData.put("id", speech.getId());
        String previewText = speech.getText();
        if (previewText != null && previewText.length() > 150) {
            previewText = previewText.substring(0, 150) + "...";// Extract a preview
        }
        speechData.put("previewText", previewText);
        if (speech.getProtocol() != null) {
            speechData.put("date", new Date(speech.getProtocol().getDate()));
            speechData.put("title", speech.getProtocol().getTitle());
            speechData.put("place", speech.getProtocol().getPlace());
        }
        // agenda information
        if (speech.getAgenda() != null) {
            speechData.put("agendaTitle", speech.getAgenda().getTitle());
            speechData.put("agendaIndex", speech.getAgenda().getIndex());
        }
        return speechData;
    }
    /**
     * API endpoint to get all speeches by a specific speaker.
     * Fetches speeches by speaker ID and returns them as JSON.
     *
     * @param ctx The Javalin context containing the speaker ID in path parameters
     */
    public static void getSpeakerSpeechesApi(Context ctx) {
        String speakerId = ctx.pathParam("id");
        try {
            List<Speech> speeches = mongoHandler.getSpeechesBySpeakerId(speakerId);
            List<Map<String, Object>> speechesData = speeches.stream()
                    .map(RedeportalController::speechApi)
                    .collect(Collectors.toList());

            ctx.json(speechesData);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(e.getMessage());
        }
    }
    /**
     * Serves the page showing a speaker's profile and their speeches.
     * Fetches the speaker and their speeches, sorts them by date,
     * and renders them using the redner_reden.ftl template.
     *
     * @param ctx The Javalin context containing the speaker ID in path parameters
     */
    public static void getSpeakerSpeechesPage(Context ctx) {
        String speakerId = ctx.pathParam("id");

        try {
            Speaker speaker = mongoHandler.getSpeakerById(speakerId);
            if (speaker == null) {
                ctx.status(404).result();
                return;
            }
            List<Speech> speeches = mongoHandler.getSpeechesBySpeakerId(speakerId);//all speeches by this speaker
            speeches.sort((s1, s2) -> { // Sort speeches by date
                if (s1.getProtocol() == null || s2.getProtocol() == null) {
                    return 0;
                }
                return Long.compare(s2.getProtocol().getDate(), s1.getProtocol().getDate());
            });
            Map<String, Object> model = new HashMap<>();
            model.put("speaker", speaker);
            model.put("speeches", speeches);
            ctx.render("redner_reden.ftl", model);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).result(e.getMessage());
        }
    }
    /**
     * Transforms a Speaker object into a simplified map representation suitable for JSON API responses.
     *
     * @param speaker The Speaker object to transform
     * @return A map containing key information from the speaker (ID, name, party, etc.)
     */
    private static Map<String, Object> speakerApi(Speaker speaker) {
        Map<String, Object> speakerData = new HashMap<>();
        speakerData.put("id", speaker.getId());
        speakerData.put("name", speaker.getName());
        speakerData.put("firstName", speaker.getFirstName());
        speakerData.put("title", speaker.getTitle());
        speakerData.put("party", speaker.getParty());
        speakerData.put("image", speaker.getImage());
        if (speaker.getGeburtsdatum() != null) {
            speakerData.put("birthDate", speaker.getGeburtsdatum());
        }
        if (speaker.getBeruf() != null) {
            speakerData.put("profession", speaker.getBeruf());
        }
        return speakerData;
    }
}