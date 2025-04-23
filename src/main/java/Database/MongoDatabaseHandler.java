package Database;

import Models.Comment;
import Models.Speaker;
import Models.Speech;
import Models.SpeechCAS;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Projections;
import com.mongodb.client.model.ReplaceOptions;
import com.mongodb.client.model.UpdateOptions;
import org.apache.uima.cas.CAS;
import org.apache.uima.cas.CASException;
import org.apache.uima.cas.SerialFormat;
import org.apache.uima.fit.factory.CasFactory;
import org.apache.uima.resource.ResourceInitializationException;
import org.apache.uima.util.CasIOUtils;
import org.bson.Document;
import org.bson.types.Binary;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 * Handles communication with MongoDB for performing CRUD operations, aggregation, and counting.
 * @author Enea Naco
 */
public class MongoDatabaseHandler {
    private final MongoClient mongoClient;
    private final MongoDatabase database;

    /**
     * Initializes the MongoDB connection using the configuration file.
     * @author Enea Naco
     */
    public MongoDatabaseHandler() throws Exception {
        // Load the configuration file
        Properties properties = new Properties();
        try (InputStream input = MongoDatabaseHandler.class.getClassLoader().getResourceAsStream("config.properties")) {
            properties.load(input);
        }
        MongoConfig mongoConfig = new MongoConfig(
                properties.getProperty("mongo.connection.string"),
                properties.getProperty("mongo.database.name"));


        // Initialize MongoDB client and database
        this.mongoClient = MongoClients.create(mongoConfig.getConnectionString());
        this.database = mongoClient.getDatabase(mongoConfig.getDatabaseName());
    }


    /**
     * Retrieves all Speaker documents from the MongoDB collection and maps them to a list of Speaker objects.
     *
     * @return A list of all Speaker objects in the database.
     * @author Enea Naco
     */
    public List<Speaker> getAllSpeakers() {

        MongoCollection<Document> collection = database.getCollection("speaker");
        List<Speaker> speakers = new ArrayList<>();

        for (Document doc : collection.find()) {
            Speaker speaker = new Speaker();
            speaker.setId(doc.getString("_id"));
            speaker.setName(doc.getString("name"));
            speaker.setFirstName(doc.getString("firstName"));
            speaker.setTitle(doc.getString("title"));
            speaker.setGeburtsdatum(doc.getDate("geburtsdatum"));
            speaker.setGeburtsort(doc.getString("geburtsort"));
            speaker.setSterbedatum(doc.getDate("sterbedatum"));
            speaker.setGeschlecht(doc.getString("geschlecht"));
            speaker.setBeruf(doc.getString("beruf"));
            speaker.setAkademischertitel(doc.getString("akademischertitel"));
            speaker.setFamilienstand(doc.getString("familienstand"));
            speaker.setReligion(doc.getString("religion"));
            speaker.setVita(doc.getString("vita"));
            speaker.setParty(doc.getString("party"));

            String image = doc.getString("image");
            speaker.setImage(image != null ? image : "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg");

            List<Document> membershipDocuments = doc.getList("memberships", Document.class);
            List<Speaker.Membership> memberships = new ArrayList<>();
            if (membershipDocuments != null) {
                for (Document membershipDoc : membershipDocuments) {
                    Speaker.Membership membership = new Speaker.Membership();
                    membership.setRole(membershipDoc.getString("role"));
                    membership.setMember(membershipDoc.getString("member"));
                    membership.setBegin(membershipDoc.getDate("begin"));
                    membership.setEnd(membershipDoc.getDate("end"));
                    membership.setLabel(membershipDoc.getString("label"));
                    memberships.add(membership);
                }
            }
            speaker.setMemberships(memberships);

            speakers.add(speaker);
        }
        return speakers;
    }

    /**
     * Retrieves a Speaker Object from the database by its id.
     * @param id : The id of the Speaker to be retrieved.
     * @return A Speaker object.
     * @author Enea Naco
     */
    public Speaker getSpeakerById(String id) {
        MongoCollection<Document> collection = database.getCollection("speaker");
        Document query = new Document("_id", id);
        Document doc = collection.find(query).first();

        if (doc != null) {
            Speaker speaker = new Speaker();
            speaker.setId(doc.getString("_id"));
            speaker.setName(doc.getString("name"));
            speaker.setFirstName(doc.getString("firstName"));
            speaker.setTitle(doc.getString("title"));
            speaker.setGeburtsdatum(doc.getDate("geburtsdatum"));
            speaker.setGeburtsort(doc.getString("geburtsort"));
            speaker.setSterbedatum(doc.getDate("sterbedatum"));
            speaker.setGeschlecht(doc.getString("geschlecht"));
            speaker.setBeruf(doc.getString("beruf"));
            speaker.setAkademischertitel(doc.getString("akademischertitel"));
            speaker.setFamilienstand(doc.getString("familienstand"));
            speaker.setReligion(doc.getString("religion"));
            speaker.setVita(doc.getString("vita"));
            speaker.setParty(doc.getString("party"));

            String image = doc.getString("image");
            speaker.setImage(image != null ? image : "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg");

            List<Document> membershipDocuments = doc.getList("memberships", Document.class);
            List<Speaker.Membership> memberships = new ArrayList<>();
            if (membershipDocuments != null) {
                for (Document membershipDoc : membershipDocuments) {
                    Speaker.Membership membership = new Speaker.Membership();
                    membership.setRole(membershipDoc.getString("role"));
                    membership.setMember(membershipDoc.getString("member"));
                    membership.setBegin(membershipDoc.getDate("begin"));
                    membership.setEnd(membershipDoc.getDate("end"));
                    membership.setLabel(membershipDoc.getString("label"));
                    memberships.add(membership);
                }
            }
            speaker.setMemberships(memberships);

            return speaker;
        } else {
            return null;
        }
    }


    /**
     * Updates a Speaker's image in the database.
     *
     * @param speakerId The ID of the speaker.
     * @param imageUrl The new image URL.
     * @author Enea Naco
     */
    public void updateSpeakerImage(String speakerId, String imageUrl) {
        MongoCollection<Document> collection = database.getCollection("speaker");
        Document query = new Document("_id", speakerId);
        Document update = new Document("$set", new Document("image", imageUrl));

        collection.updateOne(query, update, new UpdateOptions().upsert(false));
    }


    /**
     * Retrieves all Speeches form the database and maps them into a List of Speech objects.
     * @return A list of Speech objects.
     * @author Enea Naco
     */
    public List<Speech> getAllSpeeches() {
        MongoCollection<Document> collection = database.getCollection("speech");
        List<Speech> speeches = new ArrayList<>();

        // Iterate over all documents in the collection
        for (Document document : collection.find()) {
            Speech speech = new Speech();
            speech.setId(document.getString("_id"));
            speech.setText(document.getString("text"));
            speech.setSpeaker(document.getString("speaker"));

            // Map the Protocol field
            Document protocolDoc = document.get("protocol", Document.class);
            if (protocolDoc != null) {
                Speech.Protocol protocol = new Speech.Protocol();
                protocol.setDate(protocolDoc.getLong("date"));
                protocol.setStarttime(protocolDoc.getLong("starttime"));
                protocol.setEndtime(protocolDoc.getLong("endtime"));
                protocol.setIndex(protocolDoc.getInteger("index"));
                protocol.setTitle(protocolDoc.getString("title"));
                protocol.setPlace(protocolDoc.getString("place"));
                protocol.setWp(protocolDoc.getInteger("wp"));
                speech.setProtocol(protocol);
            }

            // Map the TextContent list
            List<Document> textContentDocs = document.getList("textContent", Document.class);
            if (textContentDocs != null) {
                List<Speech.TextContent> textContents = new ArrayList<>();
                for (Document textContentDoc : textContentDocs) {
                    Speech.TextContent textContent = new Speech.TextContent();
                    textContent.setId(textContentDoc.getString("id"));
                    textContent.setSpeaker(textContentDoc.getString("speaker"));
                    textContent.setText(textContentDoc.getString("text"));
                    textContent.setType(textContentDoc.getString("type"));
                    textContents.add(textContent);
                }
                speech.setTextContent(textContents);
            }

            // Map the Agenda field
            Document agendaDoc = document.get("agenda", Document.class);
            if (agendaDoc != null) {
                Speech.Agenda agenda = new Speech.Agenda();
                agenda.setIndex(agendaDoc.getString("index"));
                agenda.setId(agendaDoc.getString("id"));
                agenda.setTitle(agendaDoc.getString("title"));
                speech.setAgenda(agenda);
            }

            speeches.add(speech);
        }

        return speeches;
    }

    /**
     * Retrieves a single speech from the database from its id.
     * @param id : The id of the speech to be retrieved
     * @return The Speech object corresponding to the id
     * @author Enea Naco
     */
    public Speech getSpeechById(String id) {
        MongoCollection<Document> collection = database.getCollection("speech");

        // Get the speech document with the given ID
        Document document = collection.find(Filters.eq("_id", id)).first();

        // If the document is found, map it to the Speech object
        if (document != null) {
            Speech speech = new Speech();
            speech.setId(document.getString("_id"));
            speech.setText(document.getString("text"));
            speech.setSpeaker(document.getString("speaker"));

            // Map the Protocol field
            Document protocolDoc = document.get("protocol", Document.class);
            if (protocolDoc != null) {
                Speech.Protocol protocol = new Speech.Protocol();
                protocol.setDate(protocolDoc.getLong("date"));
                protocol.setStarttime(protocolDoc.getLong("starttime"));
                protocol.setEndtime(protocolDoc.getLong("endtime"));
                protocol.setIndex(protocolDoc.getInteger("index"));
                protocol.setTitle(protocolDoc.getString("title"));
                protocol.setPlace(protocolDoc.getString("place"));
                protocol.setWp(protocolDoc.getInteger("wp"));
                speech.setProtocol(protocol);
            }

            // Map the TextContent list
            List<Document> textContentDocs = document.getList("textContent", Document.class);
            if (textContentDocs != null) {
                List<Speech.TextContent> textContents = new ArrayList<>();
                for (Document textContentDoc : textContentDocs) {
                    Speech.TextContent textContent = new Speech.TextContent();
                    textContent.setId(textContentDoc.getString("id"));
                    textContent.setSpeaker(textContentDoc.getString("speaker"));
                    textContent.setText(textContentDoc.getString("text"));
                    textContent.setType(textContentDoc.getString("type"));
                    textContents.add(textContent);
                }
                speech.setTextContent(textContents);
            }

            // Map the Agenda field
            Document agendaDoc = document.get("agenda", Document.class);
            if (agendaDoc != null) {
                Speech.Agenda agenda = new Speech.Agenda();
                agenda.setIndex(agendaDoc.getString("index"));
                agenda.setId(agendaDoc.getString("id"));
                agenda.setTitle(agendaDoc.getString("title"));
                speech.setAgenda(agenda);
            }

            return speech;
        }
        return null;
        // Return null if no speech is found
    }


    /**
     * Saves a speech object in the collection 'speech' of the database.
     * @author Enea Naco
     */
    public void saveSpeech(Speech speech) {
        MongoCollection<Document> collection = database.getCollection("speech");

        List<Document> textContentDocs = new ArrayList<>();
        for (Speech.TextContent textContent : speech.getTextContent()) {
            Document textDoc = new Document()
                    .append("id", textContent.getId())
                    .append("speaker", textContent.getSpeaker())
                    .append("text", textContent.getText())
                    .append("type", textContent.getType());
            textContentDocs.add(textDoc);
        }

        Document doc = new Document("_id", speech.getId())
                .append("text", speech.getText())
                .append("speaker", speech.getSpeaker())
                .append("protocol", new Document()
                        .append("date", speech.getProtocol().getDate())
                        .append("starttime", speech.getProtocol().getStarttime())
                        .append("endtime", speech.getProtocol().getEndtime())
                        .append("index", speech.getProtocol().getIndex())
                        .append("title", speech.getProtocol().getTitle())
                        .append("place", speech.getProtocol().getPlace())
                        .append("wp", speech.getProtocol().getWp()))
                .append("textContent", textContentDocs)
                .append("agenda", new Document()
                        .append("index", speech.getAgenda().getIndex())
                        .append("id", speech.getAgenda().getId())
                        .append("title", speech.getAgenda().getTitle()));

        collection.insertOne(doc);
    }


    /**
     * Checks if a speech with a given ID already exists in the database
     * @param speechId The id of the speech that we are looking for
     * @return True if a speech with the given ID exists, false otherwise
     * @author Enea Naco
     */
    public boolean speechExists(String speechId) {
        MongoCollection<Document> collection = database.getCollection("speech");
        Document query = new Document("_id", speechId);
        // Check if there is a speech with the given ID in the query and return a Boolean accordingly
        return collection.find(query).first() != null;
    }


    /**
     * Retrieves all Comments from the database and maps them into a List of Comment objects.
     * @return A list of all Comment objects.
     * @author Enea Naco
     */
    public List<Comment> getAllComments() {
        MongoCollection<Document> collection = database.getCollection("comment");
        List<Comment> comments = new ArrayList<>();

        // Iterate over all documents in the collection
        for (Document document : collection.find()) {
            Comment comment = new Comment();
            comment.setId(document.getString("_id"));
            comment.setText(document.getString("text"));
            comment.setSpeaker(document.getString("speaker"));
            comment.setSpeech(document.getString("speech"));
            comments.add(comment);
        }

        return comments;
    }

    /**
     * Retrieves a single Comment from the database from its id.
     * @param id : The id of the Comment to be retrieved.
     * @return The Comment corresponding to the id
     * @author Enea Naco
     */
    public Comment getCommentById(String id) {
        MongoCollection<Document> collection = database.getCollection("comment");

        // Get the comment document with the given id
        Document document = collection.find(Filters.eq("_id", id)).first();

        // If the document is found, map it to the Comment object
        if (document != null) {
            Comment comment = new Comment();
            comment.setId(document.getString("_id"));
            comment.setText(document.getString("text"));
            comment.setSpeaker(document.getString("speaker"));
            comment.setSpeech(document.getString("speech"));
            return comment;
        }

        return null;
        // Return null if no comment is found
    }

    /**
     * Saves a single SpeechCAS in the database.
     * @param speechCAS : SpeechCAS to be saved
     * @throws IOException
     * @author Lawan Mai
     */
    public void saveSpeechCAS(SpeechCAS speechCAS) throws IOException {

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        CasIOUtils.save(speechCAS.getJCas().getCas(), out, SerialFormat.BINARY_TSI);

        Document speechCasDoc = null;
        speechCasDoc = new Document()
                .append("_id", speechCAS.getId())
                .append("jCas", out.toByteArray());

        database.getCollection("speechCas")
                .replaceOne(Filters.eq("_id", speechCAS.getId()), speechCasDoc, new ReplaceOptions()
                        .upsert(true));

    }

    /**
     * Retrieves a single SpeechCAS from the database based on the given id.
     * @param id : the given speech-id.
     * @return a instansiated SpeechCAS.
     * @throws ResourceInitializationException
     * @throws IOException
     * @throws CASException
     * @author Lawan Mai
     */
    public SpeechCAS getSpeechCASById(String id) throws ResourceInitializationException, IOException, CASException {
        MongoCollection<Document> collection = database.getCollection("speechCas");
        Document query = new Document("_id", id);
        Document doc = collection.find(query).first();

        if (doc != null) {
            Binary speechJCas = doc.get("jCas", Binary.class);
            byte[] data = speechJCas.getData();
            CAS cas = CasFactory.createCas();
            CasIOUtils.load(new ByteArrayInputStream(data), cas);
            return new SpeechCAS(cas.getJCas(), id);
        } else {
            return null;
        }
    }

    /**
     * Retrieves all Speaker IDs and name from the MongoDB collection
     * and maps them to a map of string, string for use in the export
     * of a sppecific speaker-speeches.
     *
     * @return A list of all Speaker-ids
     * @author Waled
     */
    public Map<String,String> getAllSpeakerIds() {

        MongoCollection<Document> collection = database.getCollection("speaker");
        Map<String,String>  speakers = new HashMap<>();

        for (Document doc : collection.find()) {
            speakers.put(doc.get("_id").toString(),doc.getString("name"));

        }
        return speakers;
    }

    /**
     * This function fetches all ids of cas speeches to use as
     * selection option on the website, by iterating through each
     * document. NOTE: i use batchsizte of 1000 because there are
     * too many documents
     * @throws ResourceInitializationException
     * @throws IOException
     * @throws CASException
     * @author Waled
     */
    public List<String> fetchAllCASIds() throws ResourceInitializationException, IOException, CASException {
        MongoCollection<Document> collection = database.getCollection("speechCas");
        List<String> CASIds = new ArrayList<>();

        FindIterable<Document> iterable = collection.find()
                .projection(Projections.include("_id"))
                .batchSize(1000);

        for (Document doc : iterable) {
            CASIds.add(doc.getString("_id"));
        }

        return CASIds;
    }

    /**
     * This function works the same a s the one before
     * but gets back all cas for further use
     * @throws ResourceInitializationException
     * @throws IOException
     * @throws CASException
     * @author Waled
     */
    public List<SpeechCAS> getSpeechCASAll() throws ResourceInitializationException, IOException, CASException {
        MongoCollection<Document> collection = database.getCollection("speechCas");
        FindIterable<Document> documents = collection.find();

        List<SpeechCAS> speechCASList = new ArrayList<>();

        for (Document doc : documents) {
            Binary speechJCas = doc.get("jCas", Binary.class);
            if (speechJCas != null) {
                byte[] data = speechJCas.getData();
                CAS cas = CasFactory.createCas();
                CasIOUtils.load(new ByteArrayInputStream(data), cas);
                String id = doc.get("_id").toString(); // Annahme: _id ist der ID-Wert
                speechCASList.add(new SpeechCAS(cas.getJCas(), id));
            }
        }

        return speechCASList;
    }

    /**
     * Provides access to the database for external classes.
     * @return The MongoDatabase instance.
     * @author Enea Naco
     */
    public MongoDatabase getDatabase() {
        return database;
    }

    /**
     * Retrieves all speeches by a specific speaker ID.
     * @param speakerId ID of the speaker
     * @return List of Speech objects by the specified speaker
     * @author Mariia Isaeva
     */
    public List<Speech> getSpeechesBySpeakerId(String speakerId) {
        MongoCollection<Document> collection = database.getCollection("speech");
        List<Speech> speeches = new ArrayList<>();

        // Query speeches by speaker ID
        FindIterable<Document> documents = collection.find(Filters.eq("speaker", speakerId));

        // Iterate over all documents and map them to Speech objects
        for (Document document : documents) {
            Speech speech = new Speech();
            speech.setId(document.getString("_id"));
            speech.setText(document.getString("text"));
            speech.setSpeaker(document.getString("speaker"));

            // Map the Protocol field
            Document protocolDoc = document.get("protocol", Document.class);
            if (protocolDoc != null) {
                Speech.Protocol protocol = new Speech.Protocol();
                protocol.setDate(protocolDoc.getLong("date"));
                protocol.setStarttime(protocolDoc.getLong("starttime"));
                protocol.setEndtime(protocolDoc.getLong("endtime"));
                protocol.setIndex(protocolDoc.getInteger("index"));
                protocol.setTitle(protocolDoc.getString("title"));
                protocol.setPlace(protocolDoc.getString("place"));
                protocol.setWp(protocolDoc.getInteger("wp"));
                speech.setProtocol(protocol);
            }

            // Map the TextContent list
            List<Document> textContentDocs = document.getList("textContent", Document.class);
            if (textContentDocs != null) {
                List<Speech.TextContent> textContents = new ArrayList<>();
                for (Document textContentDoc : textContentDocs) {
                    Speech.TextContent textContent = new Speech.TextContent();
                    textContent.setId(textContentDoc.getString("id"));
                    textContent.setSpeaker(textContentDoc.getString("speaker"));
                    textContent.setText(textContentDoc.getString("text"));
                    textContent.setType(textContentDoc.getString("type"));
                    textContents.add(textContent);
                }
                speech.setTextContent(textContents);
            }

            // Map the Agenda field
            Document agendaDoc = document.get("agenda", Document.class);
            if (agendaDoc != null) {
                Speech.Agenda agenda = new Speech.Agenda();
                agenda.setIndex(agendaDoc.getString("index"));
                agenda.setId(agendaDoc.getString("id"));
                agenda.setTitle(agendaDoc.getString("title"));
                speech.setAgenda(agenda);
            }
            speeches.add(speech);
        }

        return speeches;
    }
}