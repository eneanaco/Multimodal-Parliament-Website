package Models;

import java.util.Date;
import java.util.List;


/**
 * Represents a Speaker object corresponding to a document in the MongoDB "Speaker" collection.
 * Each Speaker contains personal details, memberships, and associated fields.
 * @author Enea Naco (Implemented this class)
 */
public class Speaker implements DataModel{

    private String id;
    private String name;
    private String firstName;
    private String title;
    private Date geburtsdatum;
    private String geburtsort;
    private Date sterbedatum;
    private String geschlecht;
    private String beruf;
    private String akademischertitel;
    private String familienstand;
    private String religion;
    private String vita;
    private String party;
    private List<Membership> memberships;
    private String image;

    /**
     * Represents a membership entry for the Speaker.
     */
    public static class Membership {
        private String role;
        private String member;
        private Date begin;
        private Date end;
        private String label;

        /**
         * Gets the role of the membership.
         *
         * @return The membership role.
         */
        public String getRole() {
            return role;
        }

        /**
         * Sets the role of the membership.
         *
         * @param role The role to set.
         */
        public void setRole(String role) {
            this.role = role;
        }

        /**
         * Gets the member associated with the membership.
         *
         * @return The member associated with the membership.
         */
        public String getMember() {
            return member;
        }

        /**
         * Sets the member associated with the membership.
         *
         * @param member The member to set.
         */
        public void setMember(String member) {
            this.member = member;
        }

        /**
         * Gets the start date of the membership.
         *
         * @return The start date of the membership.
         */
        public Date getBegin() {
            return begin;
        }

        /**
         * Sets the start date of the membership.
         *
         * @param begin The start date to set.
         */
        public void setBegin(Date begin) {
            this.begin = begin;
        }

        /**
         * Gets the end date of the membership.
         *
         * @return The end date of the membership.
         */
        public Date getEnd() {
            return end;
        }

        /**
         * Sets the end date of the membership.
         *
         * @param end The end date to set.
         */
        public void setEnd(Date end) {
            this.end = end;
        }

        /**
         * Gets the label of the membership.
         *
         * @return The membership label.
         */
        public String getLabel() {
            return label;
        }

        /**
         * Sets the label of the membership.
         *
         * @param label The label to set.
         */
        public void setLabel(String label) {
            this.label = label;
        }

        /**
         * Converts Memberships to a String
         * @return A String version of the Membership object
         */
        @Override
        public String toString() {
            return "Membership{" +
                    "role='" + role + '\'' +
                    ", member='" + member + '\'' +
                    ", begin=" + begin +
                    ", end=" + end +
                    ", label='" + label + '\'' +
                    '}';
        }
    }

    /**
     * Gets the unique identifier of the speaker.
     *
     * @return The unique identifier (_id) of the speaker.
     */
    @Override
    public String getId() {
        return id;
    }

    /**
     * Sets the unique identifier of the speaker.
     *
     * @param id The unique identifier (_id) to set for the speaker.
     */
    @Override
    public void setId(String id) {
        this.id = id;
    }

    /**
     * Gets the name of the speaker.
     *
     * @return The name of the speaker.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name of the speaker.
     *
     * @param name The name to set for the speaker.
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Gets the first name of the speaker.
     *
     * @return The first name of the speaker.
     */
    public String getFirstName() {
        return firstName;
    }

    /**
     * Sets the first name of the speaker.
     *
     * @param firstName The first name to set for the speaker.
     */
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    /**
     * Gets the title of the speaker.
     *
     * @return The title of the speaker.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Sets the title of the speaker.
     *
     * @param title The title to set for the speaker.
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Gets the birth date of the speaker.
     *
     * @return The birth date of the speaker.
     */
    public Date getGeburtsdatum() {
        return geburtsdatum;
    }

    /**
     * Sets the birth date of the speaker.
     *
     * @param geburtsdatum The birth date to set for the speaker.
     */
    public void setGeburtsdatum(Date geburtsdatum) {
        this.geburtsdatum = geburtsdatum;
    }

    /**
     * Gets the birthplace of the speaker.
     *
     * @return The birthplace of the speaker.
     */
    public String getGeburtsort() {
        return geburtsort;
    }

    /**
     * Sets the birthplace of the speaker.
     *
     * @param geburtsort The birthplace to set for the speaker.
     */
    public void setGeburtsort(String geburtsort) {
        this.geburtsort = geburtsort;
    }

    /**
     * Gets the date of death of the speaker.
     *
     * @return The date of death of the speaker.
     */
    public Date getSterbedatum() {
        return sterbedatum;
    }

    /**
     * Sets the date of death of the speaker.
     *
     * @param sterbedatum The date of death to set for the speaker.
     */
    public void setSterbedatum(Date sterbedatum) {
        this.sterbedatum = sterbedatum;
    }

    /**
     * Gets the gender of the speaker.
     *
     * @return The gender of the speaker.
     */
    public String getGeschlecht() {
        return geschlecht;
    }

    /**
     * Sets the gender of the speaker.
     *
     * @param geschlecht The gender to set for the speaker.
     */
    public void setGeschlecht(String geschlecht) {
        this.geschlecht = geschlecht;
    }

    /**
     * Gets the profession of the speaker.
     *
     * @return The profession of the speaker.
     */
    public String getBeruf() {
        return beruf;
    }

    /**
     * Sets the profession of the speaker.
     *
     * @param beruf The profession to set for the speaker.
     */
    public void setBeruf(String beruf) {
        this.beruf = beruf;
    }

    /**
     * Gets the academic title of the speaker.
     *
     * @return The academic title of the speaker.
     */
    public String getAkademischertitel() {
        return akademischertitel;
    }

    /**
     * Sets the academic title of the speaker.
     *
     * @param akademischertitel The academic title to set for the speaker.
     */
    public void setAkademischertitel(String akademischertitel) {
        this.akademischertitel = akademischertitel;
    }

    /**
     * Gets the marital status of the speaker.
     *
     * @return The marital status of the speaker.
     */
    public String getFamilienstand() {
        return familienstand;
    }

    /**
     * Sets the marital status of the speaker.
     *
     * @param familienstand The marital status to set for the speaker.
     */
    public void setFamilienstand(String familienstand) {
        this.familienstand = familienstand;
    }

    /**
     * Gets the religion of the speaker.
     *
     * @return The religion of the speaker.
     */
    public String getReligion() {
        return religion;
    }

    /**
     * Sets the religion of the speaker.
     *
     * @param religion The religion to set for the speaker.
     */
    public void setReligion(String religion) {
        this.religion = religion;
    }

    /**
     * Gets the biography of the speaker.
     *
     * @return The biography (vita) of the speaker.
     */
    public String getVita() {
        return vita;
    }

    /**
     * Sets the biography of the speaker.
     *
     * @param vita The biography to set for the speaker.
     */
    public void setVita(String vita) {
        this.vita = vita;
    }

    /**
     * Gets the political party of the speaker.
     *
     * @return The political party of the speaker.
     */
    public String getParty() {
        return party;
    }

    /**
     * Sets the political party of the speaker.
     *
     * @param party The political party to set for the speaker.
     */
    public void setParty(String party) {
        this.party = party;
    }

    /**
     * Gets the list of memberships of the speaker.
     *
     * @return The list of memberships.
     */
    public List<Membership> getMemberships() {
        return memberships;
    }

    /**
     * Sets the list of memberships of the speaker.
     *
     * @param memberships The list of memberships to set.
     */
    public void setMemberships(List<Membership> memberships) {
        this.memberships = memberships;
    }

    /**
     * Gets the image URL of the speaker.
     *
     * @return The image URL of the speaker.
     */
    public String getImage() {
        return image;
    }

    /**
     * Sets the image URL of the speaker.
     *
     * @param image The image URL to set for the speaker.
     */
    public void setImage(String image) {
        this.image = image;
    }

    /**
     * Converts the Speaker object to a string, used for visualisation and testing purposes
     * @return The Speaker in a text-formatted String
     */
    @Override
    public String toString() {
        return "Speaker Information: {" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", firstName='" + firstName + '\'' +
                ", title='" + title + '\'' +
                ", geburtsdatum=" + geburtsdatum +
                ", geburtsort='" + geburtsort + '\'' +
                ", sterbedatum=" + sterbedatum +
                ", geschlecht='" + geschlecht + '\'' +
                ", beruf='" + beruf + '\'' +
                ", akademischertitel='" + akademischertitel + '\'' +
                ", familienstand='" + familienstand + '\'' +
                ", religion='" + religion + '\'' +
                ", vita='" + vita + '\'' +
                ", party='" + party + '\'' +
                ", memberships=" + memberships +
                ", image='" + image + '\'' +
                '}';
    }
}

