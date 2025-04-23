import Database.BundestagDataFinder;
import Database.MongoDatabaseHandler;
import Database.SpeakerImageUpdater;
import Models.Speaker;
import Models.Speech;
import Models.SpeechCAS;

public class Main {
    public static void main(String[] args) throws Exception {

        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();

        // code to update speaker images (already ran the code, images are updated)
//        SpeakerImageUpdater updater = new SpeakerImageUpdater(mongoHandler.getDatabase());
//        updater.updateSpeakerImages();

        try {

            // Start the BundestagDataFinder
            BundestagDataFinder finder = new BundestagDataFinder(mongoHandler);

            // Will work once we have a Javalin app that does not allow the main method to terminate
            finder.startScheduler();

        } catch (Exception e) {
            System.err.println("error: " + e.getMessage());
        }

        // Examples for the usage of database methods
//        Speaker mySpeaker = mongoHandler.getSpeakerById("11005268");
//        System.out.println(mySpeaker.getFirstName() + " " + mySpeaker.getName());
//
//        System.out.println("-".repeat(100));
//
//        Speech mySpeech = mongoHandler.getSpeechById("ID2015300100");
//        System.out.println(mySpeech.getText());

//
//        //NLP snippet
//
//        SpeechCAS speechCAS1 = mongoHandler.getSpeechCASById("ID2019201500"); // Video exist and Nlp was done.
//        SpeechCAS speechCAS2 = mongoHandler.getSpeechCASById("ID2010507300"); // No Video just the given .xmi file
//
//        System.out.println(speechCAS1.getTranscriptText());
//        System.out.println(speechCAS2.getTranscriptText()); // should be null

    }
}