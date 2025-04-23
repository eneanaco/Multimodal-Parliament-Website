package Nlp;

import Models.SpeechCAS;
import org.apache.uima.cas.CAS;
import org.apache.uima.cas.impl.XmiCasSerializer;
import org.apache.uima.util.XMLSerializer;

import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;


/**
 * This class is a helper class to export pdf and xmi files
 * This was doen by Waled
 */
public class protocollExport {

    /**
     * This function takes all jcas speeches which ar to be turned into latex format
     * and attach them together to one file (works also for single speeches/protocols)
     *
     * @param speeches
     * @return
     * @throws Exception
     */
    public static String multipleCASTex(List<SpeechCAS> speeches) throws Exception {
        StringBuilder tex = new StringBuilder();
        // Latex page basic structure
        tex.append("\\documentclass{article}\n");
        tex.append("\\usepackage{graphicx}\n");
        tex.append("\\usepackage{tikz}\n");
        tex.append("\\usepackage{pgfplots}\n");
        tex.append("\\pgfplotsset{compat=1.17}\n");
        tex.append("\\usepackage{hyperref}\n");
        tex.append("\\usepackage{tocloft}\n\n");

        tex.append("\\title{Reden-Export}\n");
        tex.append("\\date{\\today}\n\n");

        tex.append("\\begin{document}\n\n");
        tex.append("\\maketitle\n\n");
        tex.append("\\tableofcontents\n\n");
        // get the filename for all speeches in that pdf
        StringBuilder filename = new StringBuilder();

        // iterate over all speeches and "concat" them together
        for (SpeechCAS speech : speeches) {
            tex.append("\\section{").append(speech.getId()).append("}\n");
            tex.append(speech.toTex2(true)); // NLP-Daten optional
            filename.append(speech.getId()).append("_");
        }

        tex.append("\\end{document}");

        // save to a file
        saveLatexCAS(filename.toString(), tex.toString());


        return tex.toString();
    }

    /**
     * This function is used save the latex file by taking the filename from the function before
     *
     * @param filename
     * @param LatexFile
     */
    // Diese Methode wird verwendet um die fertige Latex Datei abzuspeichern
    public static void saveLatexCAS(String filename, String LatexFile) {

        // get the filepath
        String targetDir = "src/main/resources/LatexSpeeches";
        Path filePath = Paths.get(targetDir, filename + ".tex");

        // write the latex-String into a file and save
        try (FileWriter writer = new FileWriter(filePath.toFile())) {
            writer.write(LatexFile);
            System.out.println("Datei erfolgreich gespeichert unter: " + filePath);
        } catch (IOException e) {
            System.err.println("Fehler beim Schreiben der Datei: " + e.getMessage());
        }
    }


    /**
     * This is the same as multipleCAS but for xmi handling
     *
     * @param speeches
     * @return
     * @throws Exception
     */
    public static String multipleXMI(List<SpeechCAS> speeches) throws Exception {
        try {

            // Get the CAS from JCas
            for (SpeechCAS speech : speeches) {
                speech.exportToXMI("src/main/resources/LatexSpeeches");

                return "";
            }
        } finally {
            return "";
        }
    }
}

