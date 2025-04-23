package Controllers;// Add these imports
import Database.MongoDatabaseHandler;
import Models.SpeechCAS;
import Nlp.protocollExport;
import io.javalin.Javalin;
import io.javalin.http.Context;
import io.javalin.http.NotFoundResponse;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;


/**
 * This class helps the handling of exporting with iterations over
 * the CAS Files to convert them to different formats and export
 * reasons.
 * @author Waled
 */
public class ExportHandler {


    /* WEG????
    public static void showExportPage(io.javalin.http.Context ctx) {
        ctx.render("export.ftl");
    }

    private static void handlePdfExport(io.javalin.http.Context ctx, List<SpeechCAS> speeches) throws Exception {
        String latexContent = protocollExport.multipleCASTex(speeches);
        ctx.result("PDF export initiated!\n" + latexContent);
    }

    private static void handleXmiExport(io.javalin.http.Context ctx, List<SpeechCAS> speeches) {
        StringBuilder result = new StringBuilder("XMI Files Exported:\n");
        for (SpeechCAS speech : speeches) {
            speech.exportToXMI();
            result.append("- ").append(speech.getId()).append(".xmi\n");
        }
        ctx.result(result.toString());
    }

     */

    /** This function gets all Names and Ids for the redner
     * page of exporting
     * @param ctx
     * @return
     * @throws Exception
     */
    public static Map<String, String> getMapNameId(Context ctx) throws Exception {
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();
        Map<String, String> result = mongoHandler.getAllSpeakerIds();

        if (result == null || result.isEmpty()) {
            throw new NotFoundResponse("Keine Sprecherdaten gefunden");
        }
        return result;
    }


    /** This function iterates through the mongodb and retrieves
     * all CASIds for selection on the pages einzeln and mehrere
     * for further exporting.
     * @param ctx
     * @return
     * @throws Exception
     */
    public static List<String> getAllCASIds(Context ctx) throws Exception {
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();
        List<String> result = mongoHandler.fetchAllCASIds();

        if (result == null || result.isEmpty()) {
            throw new NotFoundResponse("Keine Sprecherdaten gefunden");
        }
        return result;
    }

    /**
     * This function gets data from the einzeln webpage to export
     * multiple speeches based on a list of IDs
     * @param ctx The Javalin context
     * @param exportType The type of export (pdf or xmi)
     * @param quantity The quantity of speeches to export (not used in this method, but kept for consistency)
     * @param ids A list of speech IDs to export
     * @throws Exception
     */
    static void handleExportRequestMultiple(io.javalin.http.Context ctx, String exportType, String quantity, List<String> ids) throws Exception {
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        // Get the specific SpeechCAS objects
        List<SpeechCAS> multipleCAS = new ArrayList<>();
        for (String id : ids) {
            SpeechCAS speechCAS = mongoHandler.getSpeechCASById(id);
            if (speechCAS != null) {
                multipleCAS.add(speechCAS);
            }
        }

        // Apply the exporting-functions based on the format-type
        switch (exportType) {
            case "pdf":
                protocollExport.multipleCASTex(multipleCAS);
                // Apply and compile the latex
                // Note: You might want to adjust this part to handle multiple PDFs
                // compileAndOfferPdf(ctx, speeches.get(0));
                break;
            case "xmi":
                protocollExport.multipleXMI(multipleCAS);
                break;
            default:
                ctx.status(400).result("Invalid export type");
        }
    }



    /** This function gets data from the einzeln webpage to export
     * a single speech
     * @param ctx
     * @param exportType
     * @param quantity
     * @param id
     * @throws Exception
     */
    static void handleExportRequestSolo(io.javalin.http.Context ctx,String exportType, String quantity, String id) throws Exception {
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        // Get the specific SpeechCAS
        SpeechCAS soloCAS = mongoHandler.getSpeechCASById(id);
        List<SpeechCAS> oneCAS = new ArrayList<>();
        oneCAS.add(soloCAS);

        // Apply the exporting-functions based of the format-type
        switch (exportType) {


            case "pdf":
                protocollExport.multipleCASTex(oneCAS);
                // Apply and compile the latex
                //compileAndOfferPdf(ctx, speeches.get(0)); // Compile first speech
                break;
            case "xmi":
                protocollExport.multipleXMI(oneCAS);
                break;
            default:
                ctx.status(400).result("Invalid export type");
        }
    };


    /** This is supposed to do the same but for
     * the option of all speeches
     * But because it takes to long to retrieve all CASSpeeches
     * it does not work (yet).
     * @param ctx
     * @param exportType
     * @param quantity
     * @throws Exception
     */
    public static void handleExportRequest(io.javalin.http.Context ctx,String exportType, String quantity) throws Exception {
        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        if (quantity == "alle") {
            List<SpeechCAS> allCas = mongoHandler.getSpeechCASAll();

            switch (exportType) {

                case "pdf":
                    protocollExport.multipleCASTex(allCas);
                    // Apply and compile the latex
                    //compileAndOfferPdf(ctx, speeches.get(0)); // Compile first speech
                    break;
                case "xmi":
                    protocollExport.multipleXMI(allCas);
                    break;
                default:
                    ctx.status(400).result("Invalid export type");
            }
        };
    }}