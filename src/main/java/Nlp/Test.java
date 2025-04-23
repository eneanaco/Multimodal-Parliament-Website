package Nlp;

import Database.MongoDatabaseHandler;
import Models.Speech;
import Models.SpeechCAS;
import de.tudarmstadt.ukp.dkpro.core.api.segmentation.type.Sentence;
import org.apache.uima.cas.*;
import org.apache.uima.cas.admin.CASFactory;
import org.apache.uima.cas.text.AnnotationFS;
import org.apache.uima.fit.factory.JCasFactory;
import org.apache.uima.fit.util.JCasUtil;
import org.apache.uima.jcas.JCas;
import org.apache.uima.resource.ResourceInitializationException;
import org.apache.uima.util.CasCopier;
import org.hucompute.textimager.uima.type.Sentiment;
import org.hucompute.textimager.uima.type.category.CategoryCoveredTagged;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * THIS IS A TEST CLASS FOR DEBUGGING PURPOSES ONLY THEREFORE THIS CAN BE REMOVED LATER ON!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 */

public class Test {
    public static void main(String[] args) throws Exception {

        MongoDatabaseHandler mongoHandler = new MongoDatabaseHandler();
//
//        Speech mySpeech = mongoHandler.getSpeechById("ID2010507300");
//
//        DUUIHandler duuiHandler = new DUUIHandler();
//
//        JCas jCas = duuiHandler.analyseAndSerializeSpeech(mySpeech);

        JCas jCas = JCasFactory.createJCas();
        JCas pCas = JCasFactory.createJCas();
        XMIIOUtil.load(jCas, "src/main/resources/serializedSpeeches/ID2019201500");
        XMIIOUtil.load(pCas, "src/main/resources/givenSpeeches/ID2010507300");

        mongoHandler.saveSpeechCAS(new SpeechCAS(jCas, "ID2019201500"));
        mongoHandler.saveSpeechCAS(new SpeechCAS(pCas, "ID2010507300"));

        SpeechCAS speechCAS1 = mongoHandler.getSpeechCASById("ID2019201500");
        SpeechCAS speechCAS2 = mongoHandler.getSpeechCASById("ID2010507300");

        speechCAS1.getTopics().forEach((key, value) -> System.out.println(key + ": " + value));
        speechCAS2.getTopics().forEach((key, value) -> System.out.println(key + ": " + value));
        System.out.println(speechCAS1.getTranscriptText());
        System.out.println(speechCAS2.getTranscriptText());

        List<SpeechCAS> speechCASList = new ArrayList<>();
        speechCASList.add(speechCAS1);
        speechCASList.add(speechCAS2);
        protocollExport.multipleCASTex(speechCASList);
        ;

//        System.out.println(jCas.getDocumentText());
//        System.out.println(jCas.getView("annotatedTranscript").getDocumentText());
//
//        Collection<CategoryCoveredTagged> categoryCoveredTaggeds = JCasUtil.select(jCas, CategoryCoveredTagged.class).stream().sorted((c1, c2) -> c1.getBegin()-c2.getBegin()).toList();
//        for(CategoryCoveredTagged categoryCoveredTagged: categoryCoveredTaggeds){
//            System.out.println(categoryCoveredTagged.getBegin() + " - " + categoryCoveredTagged.getEnd() + " " + categoryCoveredTagged.getValue() + ": " + categoryCoveredTagged.getScore());
//        }
//
//
//        JCasUtil.selectAll(jCas.getView("transcript")).stream().forEach(tAnnotation->{
//            System.out.println(tAnnotation);
//        });
//
//        JCasUtil.select(jCas.getView("annotatedTranscript"), Sentence.class).stream().forEach(sentence -> {
//            System.out.println(sentence.getBegin()+"-"+sentence.getEnd()+": "+sentence.getCoveredText());
//            System.out.println(JCasUtil.selectCovered(Sentiment.class, sentence));
//        });
//
//        System.out.println("\n HIER NORMAL JETZT--------------------------------- \n");
//
//        JCasUtil.select(jCas, Sentence.class).stream().forEach(sentence -> {
//            System.out.println(sentence.getBegin()+"-"+sentence.getEnd()+": "+sentence.getCoveredText());
//            System.out.println(JCasUtil.selectCovered(Sentiment.class, sentence));
//        });
//
//        System.out.println("\n NORMAL TEXT -------------------- \n");
//        System.out.println(jCas.getDocumentText());

    }

}
