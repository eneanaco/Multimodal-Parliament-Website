package Database;

import org.bson.Document;
import org.json.JSONArray;
import org.json.JSONObject;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

/**
 * Updates the Speaker collection in MongoDB with speaker images from a JSON file.
 * @author Enea Naco
 */
public class SpeakerImageUpdater {

    private final MongoDatabase database;

    /**
     * Constructor for initializing with MongoDB connection.
     *
     * @param database The MongoDB database instance.
     * @author Enea Naco
     */
    public SpeakerImageUpdater(MongoDatabase database) {
        this.database = database;
    }

    /**
     * Reads the JSON file and updates the speaker images.
     * @author Enea Naco
     */
    public void updateSpeakerImages() {
        try {
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("mpPictures.json");
            if (inputStream == null) {
                return;
            }

            // Read the JSON file as a string
            String jsonData = new Scanner(inputStream, StandardCharsets.UTF_8).useDelimiter("\\A").next();
            JSONArray jsonArray = new JSONArray(jsonData);

            MongoCollection<Document> collection = database.getCollection("speaker");

            String placeholder = "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg";

            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject speakerEntry = jsonArray.getJSONObject(i);

                // Get the ID (it's the key of the object)
                String speakerId = speakerEntry.keys().next();

                // Get the first image (hp_picture)
                JSONArray images = speakerEntry.getJSONArray(speakerId);
                if (images.length() > 0) {
                    JSONObject firstImage = images.getJSONObject(0);
                    String hpPicture = firstImage.optString("hp_picture", placeholder); // Use placeholder if missing

                    // Update MongoDB with the image
                    Document updateQuery = new Document("_id", speakerId);
                    Document updateData = new Document("$set", new Document("image", hpPicture));
                    collection.updateOne(updateQuery, updateData);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
