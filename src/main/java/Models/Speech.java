package Models;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a Speech object corresponding to a document in the MongoDB "Speech" collection.
 * Each Speech contains text, a speaker, and associated fields such as protocol, text content, and agenda.
 * @author Enea Naco (Implemented this class)
 */
public class Speech implements  DataModel{

    private String id;
    private String text;
    private String speaker;
    private Protocol protocol;
    private List<TextContent> textContent;
    private Agenda agenda;

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

    /**
     * Gets the text of the speech.
     *
     * @return The text of the speech.
     */
    public String getText() {
        return text;
    }

    /**
     * Sets the text of the speech.
     *
     * @param text The text to set for the speech.
     */
    public void setText(String text) {
        this.text = text;
    }

    /**
     * Gets the ID of the speaker associated with this speech.
     *
     * @return The ID of the speaker.
     */
    public String getSpeaker() {
        return speaker;
    }

    /**
     * Sets the ID of the speaker associated with this speech.
     *
     * @param speaker The speaker ID to set for the speech.
     */
    public void setSpeaker(String speaker) {
        this.speaker = speaker;
    }

    /**
     * Gets the protocol field for the speech.
     *
     * @return The protocol field.
     */
    public Protocol getProtocol() {
        return protocol;
    }

    /**
     * Sets the protocol field for the speech.
     *
     * @param protocol The protocol field to set.
     */
    public void setProtocol(Protocol protocol) {
        this.protocol = protocol;
    }

    /**
     * Gets the list of text content sections for the speech.
     *
     * @return The list of text content sections.
     */
    public List<TextContent> getTextContent() {
        if (textContent == null) {
            return new ArrayList<>();  // Falls null, gib eine leere Liste zurück
        }
        return textContent;
    }

    /**
     * Sets the list of text content sections for the speech.
     *
     * @param textContent The list of text content to set.
     */
    public void setTextContent(List<TextContent> textContent) {
        this.textContent = textContent;
    }

    /**
     * Gets the agenda field for the speech.
     *
     * @return The agenda field.
     */
    public Agenda getAgenda() {
        return agenda;
    }

    /**
     * Sets the agenda field for the speech.
     *
     * @param agenda The agenda field to set.
     */
    public void setAgenda(Agenda agenda) {
        this.agenda = agenda;
    }

    /**
     * Converts the Speech object into a String
     * @return A string that represents the Speech object
     */
    @Override
    public String toString() {
        return "Speech{" +
                "id='" + id + '\'' +
                ", text='" + text + '\'' +
                ", speaker='" + speaker + '\'' +
                ", protocol=" + protocol +
                ", textContent=" + textContent +
                ", agenda=" + agenda +
                '}';
    }

    /**
     * Represents the protocol field for a speech.
     */
    public static class Protocol {
        private long date;
        private long starttime;
        private long endtime;
        private int index;
        private String title;
        private String place;
        private int wp;

        /**
         * Gets the date of the protocol.
         *
         * @return The date of the protocol.
         */
        public long getDate() {
            return date;
        }

        /**
         * Sets the date of the protocol.
         *
         * @param date The date to set for the protocol.
         */
        public void setDate(long date) {
            this.date = date;
        }

        /**
         * Gets the start time of the protocol.
         *
         * @return The start time of the protocol.
         */
        public long getStarttime() {
            return starttime;
        }

        /**
         * Sets the start time of the protocol.
         *
         * @param starttime The start time to set for the protocol.
         */
        public void setStarttime(long starttime) {
            this.starttime = starttime;
        }

        /**
         * Gets the end time of the protocol.
         *
         * @return The end time of the protocol.
         */
        public long getEndtime() {
            return endtime;
        }

        /**
         * Sets the end time of the protocol.
         *
         * @param endtime The end time to set for the protocol.
         */
        public void setEndtime(long endtime) {
            this.endtime = endtime;
        }

        /**
         * Gets the index of the protocol.
         *
         * @return The index of the protocol.
         */
        public int getIndex() {
            return index;
        }

        /**
         * Sets the index of the protocol.
         *
         * @param index The index to set for the protocol.
         */
        public void setIndex(int index) {
            this.index = index;
        }

        /**
         * Gets the title of the protocol.
         *
         * @return The title of the protocol.
         */
        public String getTitle() {
            return title;
        }

        /**
         * Sets the title of the protocol.
         *
         * @param title The title to set for the protocol.
         */
        public void setTitle(String title) {
            this.title = title;
        }

        /**
         * Gets the place associated with the protocol.
         *
         * @return The place of the protocol.
         */
        public String getPlace() {
            return place;
        }

        /**
         * Sets the place associated with the protocol.
         *
         * @param place The place to set for the protocol.
         */
        public void setPlace(String place) {
            this.place = place;
        }

        /**
         * Gets the legislative period (wp) of the protocol.
         *
         * @return The legislative period of the protocol.
         */
        public int getWp() {
            return wp;
        }

        /**
         * Sets the legislative period (wp) of the protocol.
         *
         * @param wp The legislative period to set.
         */
        public void setWp(int wp) {
            this.wp = wp;
        }

        /**
         * Convert Protocol into a String
         * @return A string that represents the Protocol object
         */
        @Override
        public String toString() {
            return "Protocol{" +
                    "date=" + date +
                    ", starttime=" + starttime +
                    ", endtime=" + endtime +
                    ", index=" + index +
                    ", title='" + title + '\'' +
                    ", place='" + place + '\'' +
                    ", wp=" + wp +
                    '}';
        }
    }

    /**
     * Represents a section of text content within a speech.
     */
    public static class TextContent {
        private String id;
        private String speaker;
        private String text;
        private String type;

        /**
         * Gets the unique identifier of the text content.
         *
         * @return The unique identifier of the text content.
         */
        public String getId() {
            return id;
        }

        /**
         * Sets the unique identifier of the text content.
         *
         * @param id The unique identifier to set for the text content.
         */
        public void setId(String id) {
            this.id = id;
        }

        /**
         * Gets the speaker associated with this text content.
         *
         * @return The speaker of the text content.
         */
        public String getSpeaker() {
            return speaker;
        }

        /**
         * Sets the speaker associated with this text content.
         *
         * @param speaker The speaker to set for the text content.
         */
        public void setSpeaker(String speaker) {
            this.speaker = speaker;
        }

        /**
         * Gets the text content.
         *
         * @return The text content.
         */
        public String getText() {
            return text;
        }

        /**
         * Sets the text content.
         *
         * @param text The text content to set.
         */
        public void setText(String text) {
            this.text = text;
        }

        /**
         * Gets the type of the text content.
         *
         * @return The type of the text content.
         */
        public String getType() {
            return type;
        }

        /**
         * Sets the type of the text content.
         *
         * @param type The type to set for the text content.
         */
        public void setType(String type) {
            this.type = type;
        }

        /**
         * Converts TextContent into a String
         * @return A string that represents TextContent
         */
        @Override
        public String toString() {
            return "TextContent{" +
                    "id='" + id + '\'' +
                    ", speaker='" + speaker + '\'' +
                    ", text='" + text + '\'' +
                    ", type='" + type + '\'' +
                    '}';
        }
    }

    /**
     * Represents the agenda field for a speech.
     */
    public static class Agenda {
        private String index;
        private String id;
        private String title;

        /**
         * Gets the index of the agenda item.
         *
         * @return The index of the agenda item.
         */
        public String getIndex() {
            return index;
        }

        /**
         * Sets the index of the agenda item.
         *
         * @param index The index to set for the agenda item.
         */
        public void setIndex(String index) {
            this.index = index;
        }

        /**
         * Gets the unique identifier of the agenda item.
         *
         * @return The unique identifier of the agenda item.
         */
        public String getId() {
            return id;
        }

        /**
         * Sets the unique identifier of the agenda item.
         *
         * @param id The unique identifier to set for the agenda item.
         */
        public void setId(String id) {
            this.id = id;
        }

        /**
         * Gets the title of the agenda item.
         *
         * @return The title of the agenda item.
         */
        public String getTitle() {
            return title;
        }

        /**
         * Sets the title of the agenda item.
         *
         * @param title The title to set for the agenda item.
         */
        public void setTitle(String title) {
            this.title = title;
        }

        /**
         * Converts Agenda into a string
         * @return A string that represents Agenda
         */
        @Override
        public String toString() {
            return "Agenda{" +
                    "index='" + index + '\'' +
                    ", id='" + id + '\'' +
                    ", title='" + title + '\'' +
                    '}';
        }
    }

}
