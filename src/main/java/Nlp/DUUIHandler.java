package Nlp;

import Models.Speech;
import org.apache.commons.compress.compressors.CompressorException;
import org.apache.commons.io.FileUtils;
import org.apache.uima.UIMAException;
import org.apache.uima.cas.CAS;
import org.apache.uima.cas.CASException;
import org.apache.uima.fit.factory.JCasFactory;
import org.apache.uima.jcas.JCas;

import org.apache.uima.resource.ResourceInitializationException;
import org.apache.uima.util.CasCopier;
import org.apache.uima.util.InvalidXMLException;
import org.texttechnologylab.DockerUnifiedUIMAInterface.DUUIComposer;
import org.texttechnologylab.DockerUnifiedUIMAInterface.driver.DUUIDockerDriver;
import org.texttechnologylab.DockerUnifiedUIMAInterface.driver.DUUIRemoteDriver;
import org.texttechnologylab.DockerUnifiedUIMAInterface.driver.DUUIUIMADriver;
import org.texttechnologylab.DockerUnifiedUIMAInterface.lua.DUUILuaContext;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Base64;

/**
 * This class handles everything nlp related
 * @author Lawan Mai
 */
public class DUUIHandler {

    public DUUIComposer pComposer = null;
    public int iWorkers = 1;

    /**
     * Constructor to initialize all requiered components for DUUI to work.
     * @throws IOException
     * @throws URISyntaxException
     * @throws UIMAException
     * @throws SAXException
     * @author Lawan
     */
    public DUUIHandler() throws Exception {

        init();
    }

    /**
     * init() from the given Example.java
     * @throws IOException
     * @throws URISyntaxException
     * @throws UIMAException
     * @throws SAXException
     * @author Lawan Mai
     */
    public void init() throws Exception {
        DUUILuaContext ctx = new DUUILuaContext().withJsonLibrary();

        pComposer = new DUUIComposer()
                .withSkipVerification(true)
                .withLuaContext(ctx)
                .withWorkers(iWorkers);

        DUUIUIMADriver uima_driver = new DUUIUIMADriver();
        DUUIRemoteDriver remoteDriver = new DUUIRemoteDriver();
        DUUIDockerDriver dockerDriver = new DUUIDockerDriver();

        pComposer.addDriver(uima_driver, remoteDriver, dockerDriver);
    }

    /**
     * Mandatory Method to reuse the pipeline with different Composer components.
     * @throws Exception
     * @author Lawan Mai
     */
    public void restart() throws Exception {
        pComposer.shutdown();
        init();
    }

    /**
     * Methode to start the pipeline.
     * @param jCas is the object to annotate.
     * @throws Exception
     * @author Lawan Mai
     */
    void run(JCas jCas, String srcView, String trgView) throws Exception {
        pComposer.resetPipeline();

        spaCyHelper(srcView, trgView);
        parlBertHelper(srcView, trgView);
        gerVaderHelper(srcView, trgView);

        pComposer.run(jCas);
    }

    /**
     * Methode to start the pipeline if a video exists.
     * @param jCas is the object to annotate.
     * @param fVideo is the URL of the video
     * @throws Exception
     * @author Lawan Mai
     */
    void runVideo(JCas jCas, URL fVideo) throws Exception {
        restart(); // Mandatory after working with other components!

        whisperXHelper();

        File fFile = new File(fVideo.getPath());
        byte[] bFile = FileUtils.readFileToByteArray(fFile);
        String encodedString = Base64.getEncoder().encodeToString(bFile);
        String pMimeType = Files.probeContentType(Path.of(fVideo.getPath()));

        JCas videoCas = jCas.createView("video");
        videoCas.setSofaDataString(encodedString, pMimeType);
        videoCas.setDocumentLanguage("de");

        JCas transcriptCas = jCas.createView("transcript");

        pComposer.run(jCas);

        restart(); // Mandatory to work with following components!

        JCas annotatedTranscript = jCas.createView("annotatedTranscript");
        annotatedTranscript.setDocumentText(transcriptCas.getDocumentText());
        run(jCas, "annotatedTranscript", "annotatedTranscript");
    }

    /**
     * Helper to analyse with spaCy.
     * @param srcView
     * @param trgView
     * @throws URISyntaxException
     * @throws IOException
     * @throws CompressorException
     * @throws InvalidXMLException
     * @throws SAXException
     * @author Lawan Mai
     */
    private void spaCyHelper(String srcView, String trgView) throws URISyntaxException, IOException, CompressorException, InvalidXMLException, SAXException {

        pComposer.add(new DUUIDockerDriver.Component("docker.texttechnologylab.org/textimager-duui-spacy-single-de_core_news_sm:latest")
                .withImageFetching()
                .withSourceView(srcView)
                .withTargetView(trgView)
                .withScale(iWorkers)
                .build());
    }

    /**
     * Helper to analyse with parlBert.
     * @param srcView
     * @param trgView
     * @throws Exception
     * @author Lawan Mai
     */
    private void parlBertHelper(String srcView, String trgView) throws Exception {

        pComposer.add(new DUUIDockerDriver.Component("docker.texttechnologylab.org/parlbert-topic-german:latest")
                .withImageFetching()
                .withSourceView(srcView)
                .withTargetView(trgView)
                .withScale(iWorkers)
                .build());
    }

    /**
     * Helper to analyse with gerVader.
     * @param srcView
     * @param trgView
     * @throws Exception
     * @author Lawan Mai
     */
    private void gerVaderHelper(String srcView, String trgView) throws Exception {

        pComposer.add(new DUUIDockerDriver.Component("docker.texttechnologylab.org/gervader_duui:latest")
                .withParameter("selection", "text")
                .withImageFetching()
                .withSourceView(srcView)
                .withTargetView(trgView)
                .withScale(iWorkers)
                .build());
    }

    /**
     * Helper to analyse with whisperX.
     * @throws Exception
     * @author Lawan Mai
     */
    private void whisperXHelper() throws Exception {

        pComposer.add(new DUUIRemoteDriver.Component("http://whisperx.lehre.texttechnologylab.org")
                .withScale(iWorkers)
                .withSourceView("video")
                .withTargetView("transcript")
                .build());
    }

    /**
     * Methode to analyse a Speech and serialze the nlp results.
     * @param speech is a given Speech
     * @return a annotated JCas of the speech
     * @throws Exception
     * @author Lawan Mai
     */
    public JCas analyseAndSerializeSpeech(Speech speech) throws Exception {

        JCas jCas = JCasFactory.createText(speech.getText());
        run(jCas, CAS.NAME_DEFAULT_SOFA, CAS.NAME_DEFAULT_SOFA);

        ClassLoader classLoader = DUUIHandler.class.getClassLoader();
        URL fVideo = classLoader.getResource("videos/" + speech.getId() + ".mp4");

        if((fVideo != null) && (new File(fVideo.getPath())).exists()) {
            runVideo(jCas, fVideo);
            jCas = jCasPrepper(jCas);
        }

        String filePath = "src/main/resources/serializedSpeeches/" + speech.getId();
        XMIIOUtil.save(jCas, filePath);

        return jCas;
    }

    /**
     * multiple of analyseAndSerializeSpeech
     * @param speeches a given List of Speeches
     * @return a annotated JCas list of the speeches
     * @throws Exception
     * @author Lawan Mai
     */
    public ArrayList<JCas> analyseAndSerializeSpeeches(ArrayList<Speech> speeches) throws Exception {
        ArrayList<JCas> res = new ArrayList<>();
        for(Speech speech : speeches){
            res.add(analyseAndSerializeSpeech(speech));
        }

        return res;
    }

    /**
     * This prepper removes the video View to save storage when saving later on.
     * @param srcJcas the source JCas.
     * @return a JCas without the "video" view.
     * @throws ResourceInitializationException
     * @throws CASException
     * @author Lawan Mai
     */
    public JCas jCasPrepper(JCas srcJcas) throws ResourceInitializationException, CASException {
        CAS srcCas = srcJcas.getCas();
        CAS trgCas = JCasFactory.createJCas().getCas();

        CasCopier copier = new CasCopier(srcCas, trgCas);
        copier.copyCasView(CAS.NAME_DEFAULT_SOFA, true);
        copier.copyCasView("transcript", true);
        copier.copyCasView("annotatedTranscript", true);
        return trgCas.getJCas();
    }

}
