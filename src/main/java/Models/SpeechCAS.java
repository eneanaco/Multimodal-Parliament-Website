package Models;

import Database.MongoDatabaseHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import de.tudarmstadt.ukp.dkpro.core.api.lexmorph.type.pos.POS;
import de.tudarmstadt.ukp.dkpro.core.api.ner.type.NamedEntity;
import de.tudarmstadt.ukp.dkpro.core.api.segmentation.type.Sentence;
import io.swagger.models.auth.In;
import org.apache.uima.cas.CAS;
import org.apache.uima.cas.CASException;
import org.apache.uima.cas.CASRuntimeException;
import org.apache.uima.cas.FSIterator;
import org.apache.uima.cas.impl.XmiCasSerializer;
import org.apache.uima.cas.text.AnnotationIndex;
import org.apache.uima.fit.util.JCasUtil;
import org.apache.uima.jcas.JCas;
import org.apache.uima.jcas.tcas.Annotation;
import org.apache.uima.util.XMLSerializer;
import org.hucompute.textimager.uima.type.Sentiment;
import org.hucompute.textimager.uima.type.category.CategoryCoveredTagged;

import java.awt.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.List;
import java.util.stream.Stream;

/**
 * The type Speech cas.
 */
public class SpeechCAS implements DataModel{

    private String id;
    private String originalText;
    private String transcriptText; // Only != null if 1. a video exist and 2. the video got through the nlp-pipeline.
    private Map<String, Double> topics;
    private Map<String, Integer> pos;
    private Map<String, Double> sentiments;
    private Map<String, Map<String, Integer>> namedEntities;
    private JCas jCas;

    public SpeechCAS(JCas jCas, String id) throws CASException {
        this.id = id;
        this.jCas = jCas;

        originalText = jCas.getView(CAS.NAME_DEFAULT_SOFA).getDocumentText();

        try {
            JCas tCas = jCas.getView("transcript");
            transcriptText = tCas.getDocumentText();
        } catch (CASRuntimeException e) {
            transcriptText = null;
        }

        this.pos = new LinkedHashMap<>();

        AnnotationIndex<Annotation> idx = jCas.getAnnotationIndex(POS.type);

        for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) {
            POS pos = (POS) it.next();
            String val = pos.getPosValue();

            this.pos.put(val, this.pos.getOrDefault(val, 0) + 1);
        }

        pos = annoSorter(pos);

        namedEntities = new LinkedHashMap<>();

        idx = jCas.getAnnotationIndex(NamedEntity.type);

        for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) {
            NamedEntity ne = (NamedEntity) it.next();
            String val = ne.getValue();
            Map<String, Integer> entry = namedEntities.getOrDefault(val, new LinkedHashMap<>());
            String temp = ne.getCoveredText();
            entry.put(temp, entry.getOrDefault(temp, 0) + 1);
            entry = annoSorter(entry);
            namedEntities.put(val, entry);
        }

        sentiments = new LinkedHashMap<>();

        idx = jCas.getAnnotationIndex(Sentence.type);

        for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) {
            Sentence sen = (Sentence) it.next();
            String sentence = sen.getCoveredText();

            double val = 0.0;
            for(FSIterator<Annotation> iter = jCas.getAnnotationIndex(Sentiment.type).iterator(); iter.hasNext(); ) {
                Sentiment sentiment = (Sentiment) iter.next();
                if (sentiment.getBegin() >= sen.getBegin() && sentiment.getEnd() <= sen.getEnd()) {
                    val = sentiment.getSentiment();
                    break;
                }
            }

            sentiments.put(sentence, val);
        }

        topics = new LinkedHashMap<>();

        Collection<CategoryCoveredTagged> categoryCoveredTaggeds = JCasUtil.select(jCas, CategoryCoveredTagged.class).stream().sorted((c1, c2) -> c1.getBegin()-c2.getBegin()).toList();
        for(CategoryCoveredTagged categoryCoveredTagged: categoryCoveredTaggeds){
            topics.put(categoryCoveredTagged.getBegin() + " - " + categoryCoveredTagged.getEnd() + " " + categoryCoveredTagged.getValue(), categoryCoveredTagged.getScore());
        }

    }

    /**
     * Gets the unique identifier of the speech.
     *
     * @return The unique identifier (_id) of the speech.
    */
    @Override
    public String getId() {
        return id;
    }

    /**
     * Sets the unique identifier of the speech.
     *
     * @param id The unique identifier (_id) to set for the speech.
     */
    @Override
    public void setId(String id) {
        this.id = id;
    }

    public String getOriginalText() {
        return originalText;
    }

    public void setOriginalText(String originalText) {
        this.originalText = originalText;
    }

    public String getTranscriptText() {
        return transcriptText;
    }

    public void setTranscriptText(String transcriptText) {
        this.transcriptText = transcriptText;
    }

    public Map<String, Double> getTopics() {
        return topics;
    }

    public void setTopics(Map<String, Double> topics) {
        this.topics = topics;
    }

    public Map<String, Integer> getPos() {
        return pos;
    }

    public void setPos(Map<String, Integer> pos) {
        this.pos = pos;
    }

    public Map<String, Double> getSentiments() {
        return sentiments;
    }

    public void setSentiments(Map<String, Double> sentiments) {
        this.sentiments = sentiments;
    }

    public Map<String, Map<String, Integer>> getNamedEntities() {
        return namedEntities;
    }

    public void setNamedEntities(Map<String, Map<String, Integer>> namedEntities) {
        this.namedEntities = namedEntities;
    }

    public JCas getJCas() {
        return jCas;
    }

    public void setJcas(JCas jcas) {
        this.jCas = jcas;
    }

    private Map<String, Integer> annoSorter(Map<String, Integer> tempMap) {
        Stream<Map.Entry<String, Integer>> test = tempMap.entrySet().stream().sorted(Map.Entry.comparingByValue());
        Map res = new LinkedHashMap();
        for (Iterator<Map.Entry<String, Integer>> it = test.iterator(); it.hasNext(); ) {
            Map.Entry<String, Integer> entry = it.next();
            res.put(entry.getKey(), entry.getValue());
        }
        return res;
    }
/*
        Hier beginnt der Teil zu Aufgabe 3.2 von Waled

     */


    /**
     * To tex 2 string.
     *
     * @param includeNLP the include nlp
     * @return the string
     * @throws Exception the exception
     */
// Erstellt einzelne Rede
    public String toTex2(boolean includeNLP) throws Exception {
        StringBuilder tex = new StringBuilder();

        tex.append("\\subsection{Rede: ").append(this.id).append("}\n"); // Verwenden Sie die ID als Rednername (Platzhalter)

        // Tagesordnuspunkte
        tex.append("\\subsubsection*{Tagesordnungspunkte:}\n");
        tex.append(agendaDisplay());

        // Redebeitrag mit Annotationen
        tex.append("\\subsubsection*{Redebeitrag}\n");
        tex.append(formatTextWithAnnotationsAndComments());

        // Redner- und Topic-Übersicht (Platzhalter)
        tex.append("\\section{Redner-Übersicht}\n");
        tex.append(SpeakerData(this.id));

        // NLP Stuff

        tex.append("\\section{NLP-Daten-Übersicht}\n");

        // NLP-Informationen (optional)
        if (includeNLP) {
            tex.append(POSTex());
            tex.append(SentimentTex());
            tex.append(generateTopicsListTex());
        }



        return tex.toString();
    }


    private List<Speech.TextContent> getSpeechData(String id) throws Exception {
        // MongoDB-Verbindung herstellen
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        // Rednerdaten abrufen
        Speech speech = mongoHandler.getSpeechById(id);
        List<Speech.TextContent> speechList = speech.getTextContent();


        return speechList;
    }

    /**
     * Compile la te x.
     */
// Funktioniert noch nicht!!!
    public void compileLaTeX() {
        try {
            // Erstelle den Pfad zum PDF-Dateinamen
            String latexFilePath = "src/main/resources/LatexSpeeches/" +this.id + ".tex";
            String pdfFilePath = latexFilePath.replace(".tex", ".pdf");
            File latexDir = new File(latexFilePath).getParentFile();
// pdflatex ausführen
            ProcessBuilder pb = new ProcessBuilder("pdflatex", latexFilePath);
            pb.directory(new File(new File(latexFilePath).getParent()));
            Process p = pb.start();

            // Ausgabe verarbeiten
            try (java.util.Scanner s = new java.util.Scanner(p.getInputStream())) {
                while (s.hasNextLine()) {
                    System.out.println(s.nextLine());
                }
            }
            try (java.util.Scanner s = new java.util.Scanner(p.getErrorStream())) {
                while (s.hasNextLine()) {
                    System.err.println(s.nextLine());
                }
            }

            p.waitFor();

            System.out.println("LaTeX-Datei kompiliert.");

        } catch (IOException | InterruptedException e) {
            System.err.println("Fehler beim Kompilieren: " + e.getMessage());
        }
    }

    /**
     * Open pdf.
     */
// Funktioniert noch nicht!!!
    public void openPDF() {
        try {
            // Erstelle den Pfad zum PDF-Dateinamen
            String latexFilePath = "src/main/resources/LatexSpeeches/" +this.id + ".tex";
            String pdfFilePath = latexFilePath.replace(".tex", ".pdf");

            // Öffne das PDF mit dem Standard-Viewer
            Desktop.getDesktop().open(new File(pdfFilePath));
            System.out.println("PDF geöffnet.");
        } catch (IOException e) {
            System.err.println("Fehler beim Öffnen des PDFs: " + e.getMessage());
        }
    }





    private String SpeakerData(String id) throws Exception {
        // MongoDB-Verbindung herstellen
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        // Rednerdaten abrufen
        Speech speech = mongoHandler.getSpeechById(id);
        String speaker1 = speech.getSpeaker();
        Speaker speaker = mongoHandler.getSpeakerById(speaker1);


        String targetDir = "src/main/resources/pics"; // Updated target directory (no trailing slash)
        String imageUrl = speaker.getImage();


        String fileName = imageUrl.substring(imageUrl.lastIndexOf('/') + 1);
        Path targetFilePath = Paths.get(targetDir, fileName); // Full path: "src/main/resources/pics/.jpg"


        try {
            Files.createDirectories(targetFilePath.getParent()); // Creates entire directory tree
        } catch (IOException e) {
            System.err.println("Failed to create directory: " + e.getMessage());
            return "";
        }


        try (InputStream in = new URL(imageUrl).openStream()) {
            Files.copy(in, targetFilePath, StandardCopyOption.REPLACE_EXISTING);
            System.out.println("Image saved to: " + targetFilePath);
        } catch (IOException e) {
            System.err.println("Failed to download image: " + e.getMessage());
            return "";
        }

        StringBuilder tex = new StringBuilder();
        tex.append("\\begin{tabular}{ll}\n")
                .append("Name: & ").append(speaker.getFirstName()).append(" ").append(speaker.getName()).append(" \\\\\n")
                .append("Partei: & ").append(speaker.getParty()).append(" \\\\\n")
                .append("Geburtsdatum: & ").append(speaker.getGeburtsdatum()).append(" \\\\\n")
                .append("Beruf: & ").append(speaker.getBeruf()).append(" \\\\\n")
                .append("\\end{tabular}\n\n")
                .append("\\includegraphics[width=0.5\\textwidth]{")
                .append(targetFilePath.toString().replace("\\", "/")) // Convert Windows paths to Unix-style
                .append("}");

        return tex.toString();
    }



    private String POSTex() {
        List<String> posList = new ArrayList<>(pos.keySet());
        StringBuilder tex = new StringBuilder();
        tex.append("\\paragraph{POS-Statistiken:}\n");
        tex.append("\\begin{tabular}{ll}\n");
        tex.append("\\hline\n");
        tex.append("POS-Tag & Häufigkeit \\\\ \\hline\n");

        for (String posTag : posList) {
            if (posTag.startsWith("$")) {continue;}
            tex.append(posTag).append(" & ").append(pos.get(posTag)).append(" \\\\ \\hline\n");
        }

        tex.append("\\end{tabular}\n\n");
        return tex.toString();
    }



    /** This function displays the POS data on the Latex/PDF file
     * It calculates the avarge and displays it as a bar.
     * While also highliting the most positve and negatve texts
     * @return
     */
    private String SentimentTex() {
        StringBuilder tex = new StringBuilder();
        tex.append("\\paragraph{Stimmung:}\n");
        tex.append("\\begin{tikzpicture}\n");

        // calculate the average and create the bar
        double avgSentiment = sentiments.values().stream().mapToDouble(Double::doubleValue).average().orElse(0.0);
        double rectWidth = Math.max(0, Math.min(5, avgSentiment * 5)); // Begrenzen Sie die Breite auf 0-5 cm

        tex.append("\\draw[fill=blue!20] (0,0) rectangle (").append(rectWidth).append(",0.5);\n");

        // display the avg value
        tex.append("\\node[anchor=west] at (").append(rectWidth).append(",0.25) {Ø-Wert: ").append(String.format("%.2f", avgSentiment)).append("};\n");

        tex.append("\\end{tikzpicture}\n\n");

        // calculates the min and max sentimentvalues
        OptionalDouble maxSentiment = sentiments.values().stream().mapToDouble(Double::doubleValue).max();
        OptionalDouble minSentiment = sentiments.values().stream().mapToDouble(Double::doubleValue).min();

        String maxSentimentText = "";
        String minSentimentText = "";

        //  go through each sentiment and get the corresponding text to sentiment(max)
        if (maxSentiment.isPresent()) {
            maxSentimentText = sentiments.entrySet().stream()
                    .filter(entry -> entry.getValue().equals(maxSentiment.getAsDouble()))
                    .map(Map.Entry::getKey)
                    .findFirst()
                    .orElse("Kein Text gefunden");
        }

        //  go through each sentiment and get the corresponding text to sentiment(min)
        if (minSentiment.isPresent()) {
            minSentimentText = sentiments.entrySet().stream()
                    .filter(entry -> entry.getValue().equals(minSentiment.getAsDouble()))
                    .map(Map.Entry::getKey)
                    .findFirst()
                    .orElse("Kein Text gefunden");
        }


        // Add all max and min sentiment text and value to LATEX
        if (maxSentiment.isPresent() && minSentiment.isPresent()) {
            tex.append("\\begin{itemize}\n");
            tex.append("\\item {\\textbf{Positivster Text}: \\\\ \n");
            tex.append("\n").append(maxSentimentText).append(" (").append(String.format("%.2f", maxSentiment.getAsDouble())).append(")};\n");

            tex.append("\\item {\\textbf{Negativster Text}: \\\\ \n");
            tex.append("\n").append(minSentimentText).append(" (").append(String.format("%.2f", minSentiment.getAsDouble())).append(")};\n");
            tex.append("\\end{itemize}\n\n");
        }


        return tex.toString();


    }

    private String generateTopicsListTex() {
        StringBuilder tex = new StringBuilder();
        tex.append("\\clearpage\n"); // Springe auf die nächste Seite
        tex.append("\\paragraph{Topics:}\n");
        tex.append("\\begin{longtable}{ll}\n");
        tex.append("\\hline\n");
        tex.append("Topic & Score \\\\ \\hline\n");
        tex.append("\\endfirsthead\n"); // Kopfzeile für die erste Seite
        tex.append("\\hline\n");
        tex.append("Topic & Score \\\\ \\hline\n");
        tex.append("\\endhead\n"); // Kopfzeile für nachfolgende Seiten
        tex.append("\\hline\n");
        tex.append("\\multicolumn{2}{r}{\\textit{Fortsetzung auf nächster Seite}} \\\\ \\hline\n");
        tex.append("\\endfoot\n"); // Fußzeile für nachfolgende Seiten
        tex.append("\\hline\n");
        tex.append("\\endlastfoot\n"); // Fußzeile für die letzte Seite

        // Entries are sorted from highest to lowest score by going through each topic
        List<Map.Entry<String, Double>> sortedEntries = new ArrayList<>(topics.entrySet());
        sortedEntries.sort((e1, e2) -> e2.getValue().compareTo(e1.getValue()));

        int highlightedCount = 0; // Zähler für markierte Einträge

        // iterate all topics
        for (Map.Entry<String, Double> entry : sortedEntries) {
            String topicText = entry.getKey();
            Double score = entry.getValue();

            // Einträge mit einem Score von weniger als 0.01 werden nicht hinzugefügt
            if (score < 0.01) {
                continue;
            } else {
                // Markiere die ersten drei Einträge
                if (highlightedCount < 3) {
                    tex.append("\\textbf{").append(topicText).append("} & \\textbf{").append(String.format("%.2f", score)).append("} \\\\ \\hline\n");
                    highlightedCount++;
                } else {
                    tex.append(topicText).append(" & ").append(String.format("%.2f", score)).append(" \\\\ \\hline\n");
                }
            }
        }

        tex.append("\\end{tabular}\n");
        tex.append("}\n\n");
        return tex.toString();
    }




    // Not used yet!!
    private String formatTextWithAnnotations() throws Exception {
        StringBuilder formattedText = new StringBuilder();
        String originalText = this.originalText;
        List<Speech.TextContent> speechList = getSpeechData(this.id);
        int offset = 0;

        // Named Entities hervorheben
        AnnotationIndex<NamedEntity> neIndex = jCas.getAnnotationIndex(NamedEntity.type);
        for (FSIterator<NamedEntity> it = neIndex.iterator(); it.hasNext(); ) {
            NamedEntity ne = it.next();
            int start = ne.getBegin();
            int end = ne.getEnd();

            formattedText.append(originalText.substring(offset, start));
            formattedText.append("\\textbf{").append(originalText.substring(start, end)).append("}");
            offset = end;
        }

        // Restlichen Text hinzufügen
        formattedText.append(originalText.substring(offset));

        return formattedText.toString();
    }
    private String agendaDisplay() throws Exception {
        return "";
    }

    private String textDisplay() throws Exception {
        StringBuilder formattedText = new StringBuilder();
        List<Speech.TextContent> speechList = getSpeechData(this.id);
        for (Speech.TextContent textContent : speechList) {
            if (Objects.equals(textContent.getType(), "comment")) {
                formattedText.append("\\textcolor{red}{").append(textContent.getText()).append("}");
                formattedText.append("\n");
            }
            else{
                formattedText.append(textContent.getText());
                formattedText.append("\n");

            }

        }
        return formattedText.toString();
    }

    /**
     * Export to xmi.
     *
     * @param outputPath the output path
     */
// Export der UIMA-Annotierten Daten in XMI-Format
    //und speichern unter XMI Folder
    public void exportToXMI(String outputPath) {
        try {
            // Create parent directories if missing
            Path path = Paths.get(outputPath);
            Files.createDirectories(path.getParent());

            // Get the CAS from JCas
            CAS cas = jCas.getCas();

            // Serialize to XMI
            try (FileOutputStream out = new FileOutputStream(outputPath)) {
                XmiCasSerializer serializer = new XmiCasSerializer(cas.getTypeSystem());
                XMLSerializer xmlSerializer = new XMLSerializer(out, false);
                serializer.serialize(cas, xmlSerializer.getContentHandler());
            }

            System.out.println("XMI successfully exported to: " + outputPath);
        } catch (IOException e) {
            System.err.println("XMI export failed: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during serialization: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /** This function displays the text annotated and comments highlighted
     * @return
     * @throws Exception
     */
    private String formatTextWithAnnotationsAndComments() throws Exception {
        StringBuilder formattedText = new StringBuilder();
        String originalText = this.originalText;
        List<Speech.TextContent> speechList = getSpeechData(this.id);
        int offset = 0;

        // highlights named entities nlp
        AnnotationIndex<NamedEntity> neIndex = jCas.getAnnotationIndex(NamedEntity.type);
        // use iterator to go through each NE
        for (FSIterator<NamedEntity> it = neIndex.iterator(); it.hasNext(); ) {
            NamedEntity ne = it.next();
            int start = ne.getBegin();
            int end = ne.getEnd();

            // Check if encountered comment to highlight
            String textToFormat = originalText.substring(start, end);
            boolean isComment = false;
            for (Speech.TextContent textContent : speechList) {
                if (textContent.getType().equals("comment") && textContent.getText().contains(textToFormat)) {
                    isComment = true;
                    break;
                }
            }

            formattedText.append(originalText.substring(offset, start));
            if (isComment) {
                formattedText.append("\\textcolor{red}{\\textbf{").append(textToFormat).append("}}");
            } else {
                formattedText.append("\\textbf{").append(textToFormat).append("}");
            }
            offset = end;
        }

        // Restlichen Text hinzufügen und Kommentare markieren
        while (offset < originalText.length()) {
            boolean isComment = false;
            String remainingText = originalText.substring(offset);
            for (Speech.TextContent textContent : speechList) {
                if (textContent.getType().equals("comment") && remainingText.contains(textContent.getText())) {
                    isComment = true;
                    formattedText.append("\\textcolor{red}{").append(textContent.getText()).append("}");
                    offset += textContent.getText().length();
                    break;
                }
            }
            if (!isComment) {
                formattedText.append(remainingText);
                break;
            }
        }

        return formattedText.toString();
    }
}

