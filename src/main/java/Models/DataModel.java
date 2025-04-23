package Models;

/**
 * Defines the basic structure for data models and makes sure they all have an id.
 *
 * @author Enea Naco
 */
public interface DataModel {
    /**
     * Returns the unique id of the specific data model.
     *
     * @return String representing the id.
     */
    String getId();

    /**
     * Sets the unique id of the specific data model.
     *
     * @param id The String that will represent the id.
     */
    void setId(String id);
}
