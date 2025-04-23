package Controllers;

import Database.MongoDatabaseHandler;
import Models.Speaker;
import Models.Speech;
import Models.SpeechCAS;
import de.tudarmstadt.ukp.dkpro.core.api.lexmorph.type.pos.POS;
import de.tudarmstadt.ukp.dkpro.core.api.ner.type.NamedEntity;
import de.tudarmstadt.ukp.dkpro.core.api.segmentation.type.Sentence;
import io.javalin.Javalin;
import io.javalin.http.Context;
import org.apache.uima.cas.text.AnnotationIndex;
import org.apache.uima.cas.FSIterator;
import org.apache.uima.fit.util.JCasUtil;
import org.apache.uima.jcas.JCas;
import org.apache.uima.jcas.tcas.Annotation;
import org.hucompute.textimager.uima.type.Sentiment;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Controller for Speech related endpoints.
 * Helps to display speech details with NLP annotations.
 */
public class SpeechController {
    private static MongoDatabaseHandler mongoHandler;
    static {
        try {
            mongoHandler = new MongoDatabaseHandler();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    /**
     * Registers all routes needed for speech content
     * @param app The Javalin app
     */
    public static void registerRoutes(Javalin app) {
        app.get("/redeportal/speech/{id}", SpeechController::getSpeechDetailPage);
        app.get("/api/speech/{id}/pos", SpeechController::getPosData);
        app.get("/api/speech/{id}/text", SpeechController::getSpeechText);
        app.get("/api/speech/{id}/entities", SpeechController::getNamedEntityData);
        app.get("/api/speech/{id}/sentiments", SpeechController::getSentimentData);
        app.get("/api/speech/{id}/textContent", SpeechController::getSpeechTextContent);


    }
    /**
     * Api endpoint to get named entity data for speech
     * @param ctx The Javalin context
     */
    public static void getNamedEntityData(Context ctx) {
        String speechId = ctx.pathParam("id");
        try {
            SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId);

            if (speechCAS == null) {
                ctx.status(404).json(Map.of(
                        "error", "SpeechCAS not found for ID: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            List<Map<String, Object>> entities = new ArrayList<>();
            Collection<NamedEntity> namedEntities = JCasUtil.select(speechCAS.getJCas(), NamedEntity.class);

            for (NamedEntity entity : namedEntities) {
                Map<String, Object> entityInfo = new HashMap<>();
                entityInfo.put("begin", entity.getBegin());
                entityInfo.put("end", entity.getEnd());
                entityInfo.put("text", entity.getCoveredText());
                entityInfo.put("type", entity.getValue());
                entities.add(entityInfo);
            }
            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("entities", entities);
            result.put("count", entities.size());

            ctx.contentType("application/json");
            ctx.json(result);
        } catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve named entity data: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }

    /**
     * Serves the detailed speech page, checking for SpeechCAS availability
     * @param ctx The Javalin context
     */
    public static void getSpeechDetailPage(Context ctx) {
        String speechId = ctx.pathParam("id");
        try {
            // First get the base Speech object for metadata
            Speech speech = mongoHandler.getSpeechById(speechId);
            if (speech == null) {
                ctx.status(404).result("Rede nicht gefunden");
                return;
            }
            boolean casAvailable = false; // Check if SpeechCAS exists this determines annotation availability
            String speechText = null;

            try {
                SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId);
                if (speechCAS != null) {
                    casAvailable = true;
                    speechText = speechCAS.getOriginalText();
                }
            } catch (Exception e) {
                System.err.println(e.getMessage());
            }
            if (speechText == null || speechText.isEmpty()) {// If SpeechCAS not available, use speechtext from speech collection.
                speechText = speech.getText();
            }
            Speaker speaker = null;
            if (speech.getSpeaker() != null) {
                try {
                    speaker = mongoHandler.getSpeakerById(speech.getSpeaker());
                } catch (Exception e) {
                    System.err.println(e.getMessage());
                }
            }

            Map<String, Object> model = new HashMap<>();
            model.put("speechId", speechId);
            model.put("speech", speech);
            model.put("speechText", speechText);
            model.put("annotationsAvailable", casAvailable);  // Flag for annotation availability

            if (speaker != null) {
                model.put("speaker", speaker);
            }

            ctx.render("speech_detail.ftl", model);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).result(e.getMessage());
        }
    }

    /**
     * API endpoint to get POS data for speech
     * @param ctx The Javalin context
     */
    public static void getPosData(Context ctx) {
        String speechId = ctx.pathParam("id");
        try {
            SpeechCAS speechCAS = null;
            try {
                speechCAS = mongoHandler.getSpeechCASById(speechId);
            } catch (Exception e) {

                e.printStackTrace();
                return;
            }
            if (speechCAS == null) {
                ctx.status(404).json(Map.of(
                        "error", "SpeechCAS not found for ID: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            // Get JCas
            if (speechCAS.getJCas() == null) {
                ctx.status(500).json(Map.of(
                        "error", "JCas is null for speech: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            List<Map<String, Object>> positions = new ArrayList<>();
            try {
                // Get POS annotations
                AnnotationIndex<Annotation> idx = speechCAS.getJCas().getAnnotationIndex(POS.type);
                if (idx.size() == 0) {
                    Speech speech = mongoHandler.getSpeechById(speechId);
                    if (speech != null && speech.getText() != null) {
                        String[] words = speech.getText().split("\\s+");
                        int position = 0;
                        for (String word : words) {
                            if (word.trim().isEmpty()) continue;
                            Map<String, Object> posInfo = new HashMap<>();
                            posInfo.put("begin", position);
                            posInfo.put("end", position + word.length());
                            posInfo.put("text", word);
                            positions.add(posInfo);
                            position += word.length() + 1; // +1 for space
                        }
                    }
                } else {
                    for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) { //extract from annotation index
                        POS pos = (POS) it.next();
                        String tag = pos.getPosValue();
                        int begin = pos.getBegin();
                        int end = pos.getEnd();
                        String text = pos.getCoveredText();

                        Map<String, Object> posInfo = new HashMap<>();
                        posInfo.put("tag", tag);
                        posInfo.put("begin", begin);
                        posInfo.put("end", end);
                        posInfo.put("text", text);
                        positions.add(posInfo);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            Map<String, Object> result = new HashMap<>();
            result.put("positions", positions);
            result.put("count", positions.size());
            result.put("speechId", speechId);
            ctx.contentType("application/json");
            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(e.getMessage()
            );
        }
    }
    /**
     * Api endpoint to get sentiment data for speech
     * @param ctx The Javalin context
     */
    public static void getSentimentData(Context ctx) {
        String speechId = ctx.pathParam("id");
        try {
            // Get SpeechCAS
            SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId);

            if (speechCAS == null) {
                ctx.status(404).json(Map.of(
                        "error", "SpeechCAS not found for ID: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            List<Map<String, Object>> sentiments = new ArrayList<>();
            JCas jCas = speechCAS.getJCas();

            // Get all sentences
            Collection<Sentence> sentences = JCasUtil.select(jCas, Sentence.class);

            for (Sentence sentence : sentences) {
                // Get sentiment annotations for this sentence
                Collection<Sentiment> sentimentAnnotations = JCasUtil.selectCovered(Sentiment.class, sentence);

                if (!sentimentAnnotations.isEmpty()) {
                    // Take the first sentiment annotation
                    Sentiment sentiment = sentimentAnnotations.iterator().next();
                    Map<String, Object> sentimentInfo = new HashMap<>();
                    sentimentInfo.put("begin", sentence.getBegin());
                    sentimentInfo.put("end", sentence.getEnd());
                    sentimentInfo.put("text", sentence.getCoveredText());
                    sentimentInfo.put("value", sentiment.getSentiment());
                    sentiments.add(sentimentInfo);
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("sentiments", sentiments);
            result.put("count", sentiments.size());

            ctx.contentType("application/json");
            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    /**
     * API endpoint to retrieve the raw text of a speech.
     * Fetches the speech text from SpeechCAS by speech ID and returns it as JSON.
     *
     * @param ctx The Javalin context containing the speech ID in path parameters
     */

    public static void getSpeechText(Context ctx) {
        String speechId = ctx.pathParam("id");
        try {
            // Get SpeechCAS
            SpeechCAS speechCAS = null;
            try {
                speechCAS = mongoHandler.getSpeechCASById(speechId);
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
            if (speechCAS == null) {
                ctx.status(404).json(Map.of(
                        "error", "SpeechCAS not found for ID: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            String speechText = speechCAS.getOriginalText();
            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("text", speechText);

            ctx.contentType("application/json");
            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * API endpoint to get the full text content array for a speech
     * @param ctx The Javalin context
     */
    public static void getSpeechTextContent(Context ctx) {
        String speechId = ctx.pathParam("id");

        try {
            Speech speech = mongoHandler.getSpeechById(speechId);

            if (speech == null) {
                ctx.status(404).json(Map.of(
                        "error", "Speech not found for ID: " + speechId,
                        "speechId", speechId
                ));
                return;
            }
            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("textContent", speech.getTextContent());

            ctx.contentType("application/json");
            ctx.json(result);
        } catch (Exception e) {
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve speech text content: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }
}