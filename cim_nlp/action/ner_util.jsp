<%@ page import=" edu.stanford.nlp.ie.crf.CRFClassifier" %>
<%@ page import=" edu.stanford.nlp.ling.CoreAnnotations" %>
<%@ page import=" edu.stanford.nlp.ling.CoreLabel" %>
<%@ page import=" java.util.Date" %>
<%@ page import=" java.util.LinkedHashMap" %>
<%@ page import=" java.util.LinkedHashSet" %>
<%@ page import=" java.util.List" %>

<%
    String classifierDir = "F:\\satya_code\\cim\\WEB-INF\\lib\\classifiers\\";

    String serializedClassifier1 = classifierDir+"english.all.3class.distsim.crf.ser.gz";
    String serializedClassifier1_2 = classifierDir+"english.all.3class.caseless.distsim.crf.ser.gz";
    String serializedClassifier1_3 = classifierDir+"english.nowiki.3class.caseless.distsim.crf.ser.gz";
    String serializedClassifier2 = classifierDir+"english.conll.4class.distsim.crf.ser.gz";
    String serializedClassifier3 = classifierDir+"english.muc.7class.distsim.crf.ser.gz";
    String serializedClassifier4 = classifierDir+"english.muc.7class.caseless.distsim.crf.ser.gz";
    String serializedClassifier5 = classifierDir+"english.nowiki.3class.distsim.crf.ser.gz";
    String serializedClassifier6 = classifierDir+"ner-satya.ser.gz";

    String serializedClassifier = serializedClassifier1;

    System.out.println(serializedClassifier);

    CRFClassifier<CoreLabel> classifier = CRFClassifier.getClassifierNoExceptions(serializedClassifier);
%>

<%!
    public static LinkedHashMap <String,LinkedHashSet<String>> identifyNER(String text, CRFClassifier<CoreLabel> classifier) {

        LinkedHashMap <String,LinkedHashSet<String>> map = new LinkedHashMap<String,LinkedHashSet<String>>();

        List<List<CoreLabel>> classify = classifier.classify(text);

        for (List<CoreLabel> coreLabels : classify) {
            for (CoreLabel coreLabel : coreLabels) {
                String word = coreLabel.word();
                String category = coreLabel.get(CoreAnnotations.AnswerAnnotation.class);

                if(!"O".equals(category)) {
                    if(map.containsKey(category)) {
                        // key is already their just insert in arraylist
                        map.get(category).add(word);
                    }
                    else {
                        LinkedHashSet<String> temp = new LinkedHashSet<String>();
                        temp.add(word);
                        map.put(category, temp);
                    }
//                    System.out.println(word+":"+category);
                }
            }
        }
        return map;
    }

    public static String getEntityTypeForString(String text, CRFClassifier<CoreLabel> classifier) {
        List<List<CoreLabel>> classify = classifier.classify(text);
        String category = "O";

        for (List<CoreLabel> coreLabels : classify) {
            for (CoreLabel coreLabel : coreLabels) {
                String word = coreLabel.word();
                category = coreLabel.get(CoreAnnotations.AnswerAnnotation.class);

                System.out.println(word+" : "+category);
            }
        }
        return category;
    }
%>
