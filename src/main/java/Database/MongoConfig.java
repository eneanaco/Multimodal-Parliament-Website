package Database;

/**
 * Represents the configuration data required to connect to a MongoDB instance.
 * @author Enea Naco (implemented the class)
 */
public class MongoConfig {
    private final String connectionString;
    private final String databaseName;

    /**
     * Initializes a new MongoConfig instance.
     *
     * @param connectionString The MongoDB connection string (e.g., "mongodb://localhost:27017").
     * @param databaseName     The name of the database to connect to.
     */
    public MongoConfig(String connectionString, String databaseName) {
        this.connectionString = connectionString;
        this.databaseName = databaseName;
    }

    /**
     * Returns the MongoDB connection string.
     *
     * @return The connection string.
     */
    public String getConnectionString() {
        return connectionString;
    }

    /**
     * Returns the name of the database.
     *
     * @return The database name.
     */
    public String getDatabaseName() {
        return databaseName;
    }
}