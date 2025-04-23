package Models;

/**
 * Represents a Comment object corresponding to a document in the MongoDB "Comment" collection.
 * Each Comment is linked to a specific speech and optionally to a speaker.
 * @author Enea Naco (Implemented this class)
 */
public class Comment implements DataModel {

    private String id;
    private String text;
    private String speaker;
    private String speech;

    /**
     * Gets the unique identifier of the comment.
     *
     * @return The unique identifier (_id) of the comment.
     */
    @Override
    public String getId() {
        return id;
    }

    /**
     * Sets the unique identifier of the comment.
     *
     * @param id The unique identifier (_id) to set for the comment.
     */
    @Override
    public void setId(String id) {
        this.id = id;
    }

    /**
     * Gets the text content of the comment.
     *
     * @return The text content of the comment.
     */
    public String getText() {
        return text;
    }

    /**
     * Sets the text content of the comment.
     *
     * @param text The text content to set for the comment.
     */
    public void setText(String text) {
        this.text = text;
    }

    /**
     * Gets the ID of the speaker associated with this comment.
     *
     * @return The ID of the associated speaker.
     */
    public String getSpeaker() {
        return speaker;
    }

    /**
     * Sets the ID of the speaker associated with this comment.
     *
     * @param speaker The speaker ID to set for the comment.
     */
    public void setSpeaker(String speaker) {
        this.speaker = speaker;
    }

    /**
     * Gets the ID of the speech associated with this comment.
     *
     * @return The ID of the associated speech.
     */
    public String getSpeech() {
        return speech;
    }

    /**
     * Sets the ID of the speech associated with this comment.
     *
     * @param speech The speech ID to set for the comment.
     */
    public void setSpeech(String speech) {
        this.speech = speech;
    }

    /**
     * Converts Comment into a string
     * @return A string that represent a Comment object
     */
    @Override
    public String toString() {
        return "Comment{" +
                "id='" + id + '\'' +
                ", text='" + text + '\'' +
                ", speaker='" + speaker + '\'' +
                ", speech='" + speech + '\'' +
                '}';
    }
}
