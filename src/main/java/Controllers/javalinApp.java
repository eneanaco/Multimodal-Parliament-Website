package Controllers;
import Database.BundestagDataFinder;
import Database.MongoDatabaseHandler;
import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import io.javalin.Javalin;
import io.javalin.http.ContentType;
import io.javalin.config.JavalinConfig;
import io.javalin.http.staticfiles.Location;
import io.javalin.rendering.FileRenderer;
import io.javalin.rendering.template.JavalinFreemarker;

import java.util.List;
import java.util.Map;

/**
 * Main application class to configure and start the Javalin server
 */
public class javalinApp {
    private static final int PORT = 7000;

    public static void main(String[] args) {
        // search the website for speeches
//        try {
//            MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();
//
//            // Start the BundestagDataFinder
//            BundestagDataFinder finder = new BundestagDataFinder(mongoHandler);
//
//            // Will work once we have a Javalin app that does not allow the main method to terminate
//            finder.startScheduler();
//
//        } catch (Exception e) {
//            System.err.println("error: " + e.getMessage());
//        }
        Javalin app = Javalin.create(config -> {
            configureJavalin(config);
        }).start(PORT);
        // Register routes
        registerRoutes(app);
        app.get("/", ctx -> {
            ctx.render("index.ftl");

        });
        /*app.get("/visualisierungen/pos", POSController::getPosVisualizationPage);*/
        //speches of speaker
        app.get("/redeportal/speaker/{id}", ctx -> RedeportalController.getSpeakerSpeechesPage(ctx));
        // all speakers which are present in database
        app.get("/redenportal", ctx -> RedeportalController.getAllSpeakersPage(ctx));
        //one speech
        app.get("/redeportal/speech/{id}", ctx -> SpeechController.getSpeechDetailPage(ctx));
        //api for pos-positions of speech
        app.get("/api/speech/{id}/pos", ctx -> SpeechController.getPosData(ctx));
        //api for all speakers
        app.get("/api/redeportal/speakers", RedeportalController::getAllSpeakersApi);
        //api for short previews of speeches
        app.get("/api/redeportal/speakers/{id}/speeches", ctx -> RedeportalController.getSpeakerSpeechesApi(ctx));
        //api for speech cas text
        app.get("/api/speech/{id}/text", SpeechController::getSpeechText);
        //all entites from speech
        app.get("/api/speech/{id}/entities", SpeechController::getNamedEntityData);
        //all sentiments from speech
        app.get("/api/speech/{id}/sentiments", SpeechController::getSentimentData);
        //speech from collection speech
        app.get("/api/speech/{id}/textContent", SpeechController::getSpeechTextContent);

        // Visualization pages
        app.get("/visualisierungen", VisualizationController::getVisualizationsPage);

        // API endpoints for visualization data
        app.get("/visualisierungen/pos", VisualizationController::getPosVisualizationPage);
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
        // TEST
        // export options for 3.2 by Waled
        // front - page for all exports
        app.get("/export", ctx -> ctx.render("export.ftl"));

        // page for exporting all speeches
        app.get("/alle", ctx -> ctx.render("alle.ftl"));

        // This javalin renders for the selection of speakers to export their speeches
        app.get("/redner", ctx -> {
            Map<String, String> speakerMap = ExportHandler.getMapNameId(ctx);
            ctx.render("rednerEx.ftl", Map.of("speakerMap", speakerMap));
        });
        // This javalin renders for the selection of one speech to export
        // from a list which contains all SpeechCAS
        app.get("/einzelne", ctx -> {
            List<String> CASIds = ExportHandler.getAllCASIds(ctx);
            if (CASIds == null) {
                CASIds = List.of();
            }
            ctx.render("einzeln.ftl", Map.of(
                    "speechList", CASIds,
                    "formatType", "pdf",
                    "selectedId", "ID2019201500"
            ));
        });


        // This javalin renders for the selection of multiple speeches to export
        // from a list which contains all SpeechCAS.
        app.get("/mehrere", ctx -> {
            List<String> CASIds = ExportHandler.getAllCASIds(ctx);
            if (CASIds == null) {
                CASIds = List.of(); // Handle null case
            }
            ctx.render("mehrere.ftl", Map.of("speechList", CASIds));
        });

        // Route for all xmi speech export
        app.post("/alle/xmi", ctx -> {
            ExportHandler.handleExportRequest(ctx, "xmi", "alle"); // Diese Methode sollte den Export   durchführen
            ctx.status(200).result("XMI-Export erfolgreich");
        });

        // Route for all pdf speech export
        app.post("/alle/pdf", ctx -> {
            ExportHandler.handleExportRequest(ctx,"pdf", "alle"); // Diese Methode sollte den Export durchführen
            ctx.status(200).result("PDF-Export erfolgreich");
        });

        // Route for single xmi and pdf speech export
        // by using the parameters from the url and ftl-file
        app.get("/einzeln/{format}/{id}", ctx -> {
            String format = ctx.pathParam("format");
            String id = ctx.pathParam("id");

            if ("pdf".equals(format) || "xmi".equals(format)) {
                ExportHandler.handleExportRequestSolo(ctx, format, "einzeln", id);
                ctx.status(200).result(format.toUpperCase() + "-Export erfolgreich");
            } else {
                ctx.status(400).result("Ungültiges Exportformat");
            }
        });


    }

    /**
     * Configure the Javalin instance
     * @param config JavalinConfig instance
     */
    private static void configureJavalin(JavalinConfig config) {
        Configuration freemarkerConfig = new Configuration(Configuration.VERSION_2_3_32);
        freemarkerConfig.setClassForTemplateLoading(javalinApp.class, "/templates");
        freemarkerConfig.setDefaultEncoding("UTF-8");
        freemarkerConfig.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

        config.staticFiles.add(staticConfig -> {
            staticConfig.directory = "static";
            staticConfig.location = Location.CLASSPATH;
            staticConfig.hostedPath = "/static";
        });
        FileRenderer freemarkerRenderer = new JavalinFreemarker(freemarkerConfig);
        config.fileRenderer(freemarkerRenderer);// делаем доступным по URL /static
    }

    /**
     * Register all route handlers
     * @param app Javalin app instance
     */
    private static void registerRoutes(Javalin app) {
        app.get("/api/", ctx -> {
            ctx.contentType(ContentType.TEXT_HTML);
        });
    }
}


