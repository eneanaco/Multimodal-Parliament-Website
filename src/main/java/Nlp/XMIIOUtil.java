package Nlp;

import org.apache.uima.cas.SerialFormat;
import org.apache.uima.jcas.JCas;
import org.apache.uima.util.CasIOUtils;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * This class is a util to load and save our nlp results. and is a direct copy of Lawan's util class from exercise 4.
 * @author Lawan Mai
 */
public class XMIIOUtil {

    /**
     * Serialize the jCas in a XMI file.
     * @param jCas annotated speech
     * @param filePath target filepath
     * @throws FileNotFoundException
     */
    public static void save(JCas jCas, String filePath) throws FileNotFoundException {

        try (FileOutputStream out = new FileOutputStream(filePath + ".xmi")) {
            CasIOUtils.save(jCas.getCas(), out, SerialFormat.XMI_PRETTY);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * De-serialize the XMI file in to a JCas
     * @param jCas an empty jCas
     * @param filePath the source filepath
     */
    public static void load(JCas jCas, String filePath) {

        try (FileInputStream in = new FileInputStream(filePath + ".xmi")) {
            CasIOUtils.load(in, jCas.getCas());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

