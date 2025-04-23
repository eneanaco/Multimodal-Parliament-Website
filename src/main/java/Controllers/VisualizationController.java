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
 * Controller for visualization features like POS, Sentiment, Entity, and Topic visualizations.
 * @author Your Name
 */
public class VisualizationController {

    private static MongoDatabaseHandler mongoHandler;

    static {
        try {
            mongoHandler = new MongoDatabaseHandler();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Registers all Visualization related routes
     * @param app The Javalin app
     */
    public static void registerRoutes(Javalin app) {
        // POS Visualization pages
        app.get("/visualisierungen", VisualizationController::getVisualizationsPage);
        app.get("/visualisierungen/pos", VisualizationController::getPosVisualizationPage);

        // API endpoints for visualization data
        app.get("/api/visualizations/pos/speech/{id}", VisualizationController::getPosDataForSpeech);
        app.get("/api/visualizations/pos/multiple", VisualizationController::getPosDataForMultipleSpeeches);
        app.get("/api/visualizations/entities/speech/{id}", VisualizationController::getEntityDataForSpeech);
        app.get("/api/visualizations/entities/multiple", VisualizationController::getEntityDataForMultipleSpeeches);
        app.get("/visualisierungen/sentiment", VisualizationController::getSentimentVisualizationPage);
        app.get("/api/visualizations/sentiments/speech/{id}", VisualizationController::getSentimentDataForSpeech);
        app.get("/api/visualizations/sentiments/multiple", VisualizationController::getSentimentDataForMultipleSpeeches);
        app.get("/visualisierungen/topics", VisualizationController::getTopicsVisualizationPage);
        app.get("/api/visualizations/topics/speech/{id}", VisualizationController::getTopicDataForSpeech);
        app.get("/api/visualizations/topics/multiple", VisualizationController::getTopicDataForMultipleSpeeches);


        // API endpoints for supporting data
        app.get("/api/speaker/{id}/speeches", VisualizationController::getSpeakerSpeechesApi);
    }

    /**
     * Serves the main Visualizations overview page
     * @param ctx The Javalin context
     */
    public static void getVisualizationsPage(Context ctx) {
        ctx.render("visualisierungen.ftl");
    }

    /**
     * Serves the POS visualization page
     * @param ctx The Javalin context
     */
    public static void getPosVisualizationPage(Context ctx) {
        try {
            // Get all speakers for the filter popup
            List<Speaker> speakers = mongoHandler.getAllSpeakers();

            // Sort speakers
            speakers.sort(
                    Comparator.comparing(Speaker::getFirstName, String.CASE_INSENSITIVE_ORDER)
                            .thenComparing(Speaker::getName, String.CASE_INSENSITIVE_ORDER)
            );

            Map<String, Object> model = new HashMap<>();
            model.put("speakers", speakers);
            model.put("speakerCount", speakers.size());

            // Count total speeches
            int totalSpeeches = 0;
            try {
                List<Speech> speeches = mongoHandler.getAllSpeeches();
                totalSpeeches = speeches.size();
            } catch (Exception e) {
                System.err.println( e.getMessage());
            }
            model.put("speechCount", totalSpeeches);

            ctx.render("pos_visualization.ftl", model);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).result("Failed to load visualization page: " + e.getMessage());
        }
    }

    /**
     * Serves the Entity visualization page
     * @param ctx The Javalin context
     */
    public static void getEntityVisualizationPage(Context ctx) {
        try {
            // Get all speakers for the filter popup
            List<Speaker> speakers = mongoHandler.getAllSpeakers();

            // Sort speakers
            speakers.sort(
                    Comparator.comparing(Speaker::getFirstName, String.CASE_INSENSITIVE_ORDER)
                            .thenComparing(Speaker::getName, String.CASE_INSENSITIVE_ORDER)
            );

            //statistics
            Map<String, Object> model = new HashMap<>();
            model.put("speakers", speakers);
            model.put("speakerCount", speakers.size());

            // Count total speeches
            int totalSpeeches = 0;
            try {
                List<Speech> speeches = mongoHandler.getAllSpeeches();
                totalSpeeches = speeches.size();
            } catch (Exception e) {
                System.err.println(e.getMessage());
            }
            model.put("speechCount", totalSpeeches);
            ctx.render("entity_visualization.ftl", model);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).result("Failed to load visualization page: " + e.getMessage());
        }
    }


    /**
     * API endpoint to get all speeches for a specific speaker
     * @param ctx The Javalin context
     */
    public static void getSpeakerSpeechesApi(Context ctx) {
        String speakerId = ctx.pathParam("id");

        try {
            List<Speech> speeches = mongoHandler.getSpeechesBySpeakerId(speakerId);

            // Transform to a more compact format with additional info about POS data availability
            List<Map<String, Object>> speechList = new ArrayList<>();

            for (Speech speech : speeches) {
                Map<String, Object> data = new HashMap<>();
                data.put("id", speech.getId());

                // Create a preview of the speech text
                String previewText = speech.getText();
                if (previewText != null && previewText.length() > 100) {
                    previewText = previewText.substring(0, 100) + "...";
                }
                data.put("preview", previewText);

                // Add protocol information if available
                if (speech.getProtocol() != null) {
                    data.put("date", speech.getProtocol().getDate());
                    data.put("title", speech.getProtocol().getTitle());
                }

                // Add agenda information if available
                if (speech.getAgenda() != null) {
                    data.put("agendaTitle", speech.getAgenda().getTitle());
                }

                // Check if POS data is available for this speech
                boolean posDataAvailable = false;
                boolean entityDataAvailable = false;
                boolean sentimentDataAvailable = false;
                boolean topicDataAvailable = false;
                try {
                    SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speech.getId());
                    AnnotationIndex<Annotation> posIdx = speechCAS.getJCas().getAnnotationIndex(POS.type);
                    posDataAvailable = posIdx != null && posIdx.size() > 0;

                    // Check for Named Entity annotations
                    AnnotationIndex<Annotation> neIdx = speechCAS.getJCas().getAnnotationIndex(NamedEntity.type);
                    entityDataAvailable = neIdx != null && neIdx.size() > 0;

                    Collection<Sentiment> sentimentAnnotations = JCasUtil.select(speechCAS.getJCas(), Sentiment.class);
                    sentimentDataAvailable = sentimentAnnotations != null && !sentimentAnnotations.isEmpty();

                    Map<String, Double> topics = speechCAS.getTopics();
                    topicDataAvailable = topics != null && !topics.isEmpty();
                } catch (Exception e) {
                    // Ignore errors and assume data is not available
                }
                data.put("posDataAvailable", posDataAvailable);
                data.put("entityDataAvailable", entityDataAvailable);
                data.put("sentimentDataAvailable", sentimentDataAvailable);
                data.put("topicDataAvailable", topicDataAvailable);


                speechList.add(data);
            }

            // Sort by date
            speechList.sort((a, b) -> {
                Long dateA = (Long) a.getOrDefault("date", 0L);
                Long dateB = (Long) b.getOrDefault("date", 0L);
                return dateB.compareTo(dateA);
            });

            ctx.json(speechList);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve speeches: " + e.getMessage(),
                    "speakerId", speakerId
            ));
        }
    }

    /**
     * API endpoint to get POS data for a single speech
     * @param ctx The Javalin context
     */
    public static void getPosDataForSpeech(Context ctx) {
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

            // Extract POS data from the SpeechCAS
            Map<String, Integer> posData = extractPosData(speechCAS);

            // Convert to format for visualization
            List<Map<String, Object>> items = posData.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> item = new HashMap<>();
                        item.put("tag", entry.getKey());
                        item.put("count", entry.getValue());
                        return item;
                    })
                    .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                    .collect(Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("items", items);
            result.put("count", items.size());

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve POS data: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }

    /**
     * API endpoint to get combined POS data for multiple speeches
     * @param ctx The Javalin context
     */
    public static void getPosDataForMultipleSpeeches(Context ctx) {
        String idsParam = ctx.queryParam("ids");

        if (idsParam == null || idsParam.isEmpty()) {
            ctx.status(400).json(Map.of("error", "No speech IDs provided. Use the 'ids' query parameter with comma-separated IDs."));
            return;
        }

        // Parse the comma separated list of IDs
        String[] speechIds = idsParam.split(",");

        try {
            // Collect and combine POS data from all speeches
            Map<String, Integer> combinedPosData = new HashMap<>();
            List<String> processedIds = new ArrayList<>();
            List<String> failedIds = new ArrayList<>();

            for (String speechId : speechIds) {
                try {
                    SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId.trim());

                    if (speechCAS != null) {
                        // Extract POS data and add to combined results
                        Map<String, Integer> posData = extractPosData(speechCAS);

                        for (Map.Entry<String, Integer> entry : posData.entrySet()) {
                            combinedPosData.put(
                                    entry.getKey(),
                                    combinedPosData.getOrDefault(entry.getKey(), 0) + entry.getValue()
                            );
                        }

                        processedIds.add(speechId);
                    } else {
                        failedIds.add(speechId);
                    }
                } catch (Exception e) {
                    System.err.println(e.getMessage());
                }
            }

            // Convert to format for visualization
            List<Map<String, Object>> items = combinedPosData.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> item = new HashMap<>();
                        item.put("tag", entry.getKey());
                        item.put("count", entry.getValue());
                        return item;
                    })
                    .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                    .collect(Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("items", items);
            result.put("count", items.size());
            result.put("processedSpeeches", processedIds.size());
            result.put("totalSpeeches", speechIds.length);

            if (!failedIds.isEmpty()) {
                result.put("failedSpeeches", failedIds);
            }

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve POS data: " + e.getMessage()
            ));
        }
    }

    /**
     * Helper method to extract POS data from a SpeechCAS
     * @param speechCAS The SpeechCAS object
     * @return Map of POS tag to count
     */
    private static Map<String, Integer> extractPosData(SpeechCAS speechCAS) {
        Map<String, Integer> posData = new HashMap<>();

        try {
            Map<String, Integer> storedPOS = speechCAS.getPos();

            if (storedPOS != null && !storedPOS.isEmpty()) {
                return new HashMap<>(storedPOS);
            }

            AnnotationIndex<Annotation> idx = speechCAS.getJCas().getAnnotationIndex(POS.type);

            for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) {
                POS pos = (POS) it.next();
                String tag = pos.getPosValue();
                posData.put(tag, posData.getOrDefault(tag, 0) + 1);
            }
        } catch (Exception e) {
            System.err.println(e.getMessage());
        }

        return posData;
    }

    /**
     * API endpoint to get entity data for a single speech
     * @param ctx The Javalin context
     */
    public static void getEntityDataForSpeech(Context ctx) {
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

            // Extract entity data from the SpeechCAS
            Map<String, Map<String, Integer>> entityData = extractEntityData(speechCAS);

            // Convert to format for visualization
            List<Map<String, Object>> entities = entityData.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> entity = new HashMap<>();
                        entity.put("type", entry.getKey());

                        // Transform the inner map to items list
                        List<Map<String, Object>> items = entry.getValue().entrySet().stream()
                                .map(item -> {
                                    Map<String, Object> itemMap = new HashMap<>();
                                    itemMap.put("text", item.getKey());
                                    itemMap.put("count", item.getValue());
                                    return itemMap;
                                })
                                .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                                .collect(Collectors.toList());

                        entity.put("items", items);
                        entity.put("count", items.stream().mapToInt(item -> (Integer)item.get("count")).sum());

                        return entity;
                    })
                    .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                    .collect(Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("entities", entities);
            result.put("count", entities.stream().mapToInt(entity -> (Integer)entity.get("count")).sum());

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve entity data: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }

    /**
     * API endpoint to get combined entity data for multiple speeches
     * @param ctx The Javalin context
     */
    public static void getEntityDataForMultipleSpeeches(Context ctx) {
        String idsParam = ctx.queryParam("ids");

        if (idsParam == null || idsParam.isEmpty()) {
            ctx.status(400).json(Map.of("error", "No speech IDs provided. Use the 'ids' query parameter with comma-separated IDs."));
            return;
        }

        // Parse the comma-separated list of IDs
        String[] speechIds = idsParam.split(",");

        try {
            // Collect and combine entity data from all speeches
            Map<String, Map<String, Integer>> combinedEntityData = new HashMap<>();
            List<String> processedIds = new ArrayList<>();
            List<String> failedIds = new ArrayList<>();

            for (String speechId : speechIds) {
                try {
                    SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId.trim());

                    if (speechCAS != null) {
                        // Extract entity data and add to combined results
                        Map<String, Map<String, Integer>> entityData = extractEntityData(speechCAS);

                        for (Map.Entry<String, Map<String, Integer>> typeEntry : entityData.entrySet()) {
                            String entityType = typeEntry.getKey();

                            if (!combinedEntityData.containsKey(entityType)) {
                                combinedEntityData.put(entityType, new HashMap<>());
                            }

                            for (Map.Entry<String, Integer> textEntry : typeEntry.getValue().entrySet()) {
                                String entityText = textEntry.getKey();
                                Integer count = textEntry.getValue();

                                combinedEntityData.get(entityType).put(
                                        entityText,
                                        combinedEntityData.get(entityType).getOrDefault(entityText, 0) + count
                                );
                            }
                        }

                        processedIds.add(speechId);
                    } else {
                        failedIds.add(speechId);
                    }
                } catch (Exception e) {
                    System.err.println(e.getMessage());
                }
            }

            // Convert to format for visualization
            List<Map<String, Object>> entities = combinedEntityData.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> entity = new HashMap<>();
                        entity.put("type", entry.getKey());

                        // Transform the inner map to list
                        List<Map<String, Object>> items = entry.getValue().entrySet().stream()
                                .map(item -> {
                                    Map<String, Object> itemMap = new HashMap<>();
                                    itemMap.put("text", item.getKey());
                                    itemMap.put("count", item.getValue());
                                    return itemMap;
                                })
                                .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                                .collect(Collectors.toList());

                        entity.put("items", items);
                        entity.put("count", items.stream().mapToInt(item -> (Integer)item.get("count")).sum());

                        return entity;
                    })
                    .sorted((a, b) -> ((Integer)b.get("count")).compareTo((Integer)a.get("count")))
                    .collect(Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("entities", entities);
            result.put("count", entities.stream().mapToInt(entity -> (Integer)entity.get("count")).sum());
            result.put("processedSpeeches", processedIds.size());
            result.put("totalSpeeches", speechIds.length);

            if (!failedIds.isEmpty()) {
                result.put("failedSpeeches", failedIds);
            }

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve entity data: " + e.getMessage()
            ));
        }
    }

    /**
     * Helper method to extract entity data from a SpeechCAS
     * @param speechCAS The SpeechCAS object
     * @return Map of entity type to a map of entity text to count
     */
    private static Map<String, Map<String, Integer>> extractEntityData(SpeechCAS speechCAS) {
        Map<String, Map<String, Integer>> entityData = new HashMap<>();

        try {
            Map<String, Map<String, Integer>> storedEntities = speechCAS.getNamedEntities();

            if (storedEntities != null && !storedEntities.isEmpty()) {
                return new HashMap<>(storedEntities);
            }
            AnnotationIndex<Annotation> idx = speechCAS.getJCas().getAnnotationIndex(NamedEntity.type);

            for (FSIterator<Annotation> it = idx.iterator(); it.hasNext(); ) {
                NamedEntity entity = (NamedEntity) it.next();
                String type = entity.getValue();
                String text = entity.getCoveredText();
                if (text == null || text.trim().isEmpty() || type == null || type.trim().isEmpty()) {
                    continue;
                }

                // Standardize the entity type
                if (type.equals("PER")) type = "PERSON";
                if (type.equals("LOC")) type = "LOCATION";
                if (type.equals("ORG")) type = "ORGANIZATION";

                // Group all other types under MISC
                if (!type.equals("PERSON") && !type.equals("LOCATION") && !type.equals("ORGANIZATION")) {
                    type = "MISC";
                }

                // Add to the map
                if (!entityData.containsKey(type)) {
                    entityData.put(type, new HashMap<>());
                }

                entityData.get(type).put(text, entityData.get(type).getOrDefault(text, 0) + 1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return entityData;
    }
    /**
     * Serves the Sentiment visualization page
     * @param ctx The Javalin context
     */
    public static void getSentimentVisualizationPage(Context ctx) {
        ctx.render("sentiment_visualization.ftl");
    }

    /**
     * API endpoint to get sentiment data for a single speech
     * @param ctx The Javalin context
     */
    public static void getSentimentDataForSpeech(Context ctx) {
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

            // Extract sentiment data from the SpeechCAS
            List<Map<String, Object>> sentiments = extractSentimentData(speechCAS);

            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("sentiments", sentiments);
            result.put("count", sentiments.size());

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve sentiment data: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }

    /**
     * API endpoint to get combined sentiment data for multiple speeches
     * @param ctx The Javalin context
     */
    public static void getSentimentDataForMultipleSpeeches(Context ctx) {
        String idsParam = ctx.queryParam("ids");

        if (idsParam == null || idsParam.isEmpty()) {
            ctx.status(400).json(Map.of("error", "No speech IDs provided. Use the 'ids' query parameter with comma-separated IDs."));
            return;
        }

        // Parse the comma separated list of IDs
        String[] speechIds = idsParam.split(",");

        try {
            // Collect and combine sentiment data from all speeches
            List<Map<String, Object>> allSentiments = new ArrayList<>();
            List<String> processedIds = new ArrayList<>();
            List<String> failedIds = new ArrayList<>();

            for (String speechId : speechIds) {
                try {
                    SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId.trim());

                    if (speechCAS != null) {
                        // Extract sentiment data and add to combined results
                        List<Map<String, Object>> sentiments = extractSentimentData(speechCAS);
                        allSentiments.addAll(sentiments);
                        processedIds.add(speechId);
                    } else {
                        failedIds.add(speechId);
                    }
                } catch (Exception e) {
                    System.err.println(e.getMessage());
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("sentiments", allSentiments);
            result.put("count", allSentiments.size());
            result.put("processedSpeeches", processedIds.size());
            result.put("totalSpeeches", speechIds.length);

            if (!failedIds.isEmpty()) {
                result.put("failedSpeeches", failedIds);
            }

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve sentiment data: " + e.getMessage()
            ));
        }
    }

    /**
     * Helper method to extract sentiment data from a SpeechCAS
     * @param speechCAS The SpeechCAS object
     * @return List of sentiment data objects with value and sentence info
     */
    private static List<Map<String, Object>> extractSentimentData(SpeechCAS speechCAS) {
        List<Map<String, Object>> sentimentData = new ArrayList<>();

        try {
            JCas jCas = speechCAS.getJCas();
            Collection<Sentence> sentences = JCasUtil.select(jCas, Sentence.class);

            for (Sentence sentence : sentences) {
                // Find sentiment annotations for this sentence
                Collection<Sentiment> sentimentAnnotations = JCasUtil.selectCovered(Sentiment.class, sentence);

                if (!sentimentAnnotations.isEmpty()) {
                    // Take the first sentiment annotation for this sentence
                    Sentiment sentiment = sentimentAnnotations.iterator().next();

                    Map<String, Object> sentimentInfo = new HashMap<>();
                    sentimentInfo.put("sentence", sentence.getCoveredText());
                    sentimentInfo.put("value", sentiment.getSentiment());
                    sentimentInfo.put("begin", sentence.getBegin());
                    sentimentInfo.put("end", sentence.getEnd());

                    sentimentData.add(sentimentInfo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return sentimentData;
    }

    /**
     * Serves the Topics visualization page
     * @param ctx The Javalin context
     */
    public static void getTopicsVisualizationPage(Context ctx) {
        ctx.render("topics_visualization.ftl");
    }

    /**
     * API endpoint to get topic data for a single speech
     * @param ctx The Javalin context
     */
    public static void getTopicDataForSpeech(Context ctx) {
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

            // Extract topic data from the SpeechCAS
            Map<String, Double> topics = extractTopicData(speechCAS);

            // Convert to format for visualization
            List<Map<String, Object>> topicList = topics.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> topic = new HashMap<>();
                        topic.put("name", entry.getKey());
                        topic.put("value", entry.getValue());
                        return topic;
                    })
                    .sorted((a, b) -> ((Double)b.get("value")).compareTo((Double)a.get("value")))
                    .collect(Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("speechId", speechId);
            result.put("topics", topicList);
            result.put("count", topicList.size());

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.status(500).json(Map.of(
                    "error", "Failed to retrieve topic data: " + e.getMessage(),
                    "speechId", speechId
            ));
        }
    }

    /**
     * API endpoint to get combined topic data for multiple speeches
     * @param ctx The Javalin context
     */
    public static void getTopicDataForMultipleSpeeches(Context ctx) {
        String idsParam = ctx.queryParam("ids");
        if (idsParam == null || idsParam.isEmpty()) {
            ctx.status(400).json(Map.of("error", "No speech IDs provided"));
            return;
        }

        // Parse the comma separated list of IDs
        String[] speechIds = idsParam.split(",");

        try {
            // Collect and combine topic data from all speeches
            Map<String, Double> combinedTopics = new HashMap<>();
            List<String> processedIds = new ArrayList<>();
            List<String> failedIds = new ArrayList<>();

            for (String speechId : speechIds) {
                try {
                    SpeechCAS speechCAS = mongoHandler.getSpeechCASById(speechId.trim());

                    if (speechCAS != null) {
                        // Process the raw topics data
                        Map<String, Double> rawTopics = speechCAS.getTopics();

                        if (rawTopics != null && !rawTopics.isEmpty()) {
                            // Process each topic
                            for (Map.Entry<String, Double> entry : rawTopics.entrySet()) {
                                String key = entry.getKey();
                                Double value = entry.getValue();

                                // Extract topic name
                                int lastSpaceIndex = -1;
                                for (int i = 0; i < 4; i++) {
                                    int nextSpace = key.indexOf(' ', lastSpaceIndex + 1);
                                    if (nextSpace == -1) break;
                                    lastSpaceIndex = nextSpace;
                                }

                                if (lastSpaceIndex > 0 && lastSpaceIndex < key.length() - 1) {
                                    String topicName = key.substring(lastSpaceIndex + 1);
                                    // Add or update the topic in combined results
                                    combinedTopics.put(
                                            topicName,
                                            combinedTopics.getOrDefault(topicName, 0.0) + value
                                    );
                                }
                            }
                        }

                        processedIds.add(speechId);
                    } else {
                        failedIds.add(speechId);
                    }
                } catch (Exception e) {
                    System.err.println(e.getMessage());
                    failedIds.add(speechId);
                }
            }

            // If no topics were found return message
            if (combinedTopics.isEmpty()) {
                ctx.status(404).json(Map.of(
                        "error", "No topic data found in the selected speeches",
                        "processedSpeeches", processedIds.size(),
                        "totalSpeeches", speechIds.length,
                        "failedSpeeches", failedIds
                ));
                return;
            }

            // Normalize values
            if (combinedTopics.size() > 1) {
                double total = combinedTopics.values().stream().mapToDouble(Double::doubleValue).sum();
                if (total > 0) {
                    for (String topic : combinedTopics.keySet()) {
                        combinedTopics.put(topic, combinedTopics.get(topic) / total);
                    }
                }
            }

            // Convert to format expected by visualization
            List<Map<String, Object>> topicsList = combinedTopics.entrySet().stream()
                    .map(entry -> {
                        Map<String, Object> topic = new HashMap<>();
                        topic.put("name", entry.getKey());
                        topic.put("value", entry.getValue());
                        return topic;
                    })
                    .sorted((a, b) -> ((Double)b.get("value")).compareTo((Double)a.get("value")))
                    .collect(Collectors.toList());

            // Build the response
            Map<String, Object> result = new HashMap<>();
            result.put("topics", topicsList);
            result.put("count", topicsList.size());
            result.put("processedSpeeches", processedIds.size());
            result.put("totalSpeeches", speechIds.length);

            if (!failedIds.isEmpty()) {
                result.put("failedSpeeches", failedIds);
            }

            ctx.json(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Helper method to extract and process topic data from a SpeechCAS
     * @param speechCAS The SpeechCAS object
     * @return Map of topic name to confidence value
     */
    private static Map<String, Double> extractTopicData(SpeechCAS speechCAS) {
        Map<String, Double> topicValues = new HashMap<>();

        try {
            // Get the raw topics from the SpeechCAS
            Map<String, Double> rawTopics = speechCAS.getTopics();

            if (rawTopics == null || rawTopics.isEmpty()) {
                return topicValues;
            }
            // Process each topic
            for (Map.Entry<String, Double> entry : rawTopics.entrySet()) {
                String key = entry.getKey();
                Double value = entry.getValue();
                // Parse the key format
                int lastSpaceIndex = -1;
                for (int i = 0; i < 4; i++) {
                    int nextSpace = key.indexOf(' ', lastSpaceIndex + 1);
                    if (nextSpace == -1) break;
                    lastSpaceIndex = nextSpace;
                }
                if (lastSpaceIndex > 0 && lastSpaceIndex < key.length() - 1) {
                    String topicName = key.substring(lastSpaceIndex + 1);

                    // Add or update the topic value
                    topicValues.put(
                            topicName,
                            topicValues.getOrDefault(topicName, 0.0) + value
                    );
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return topicValues;
    }
}