<%@ page import=" java.util.Date" %>
<%@ include file="ner_util.jsp"%>

<%
    out.println("START: "+new Date());
    out.println("<br>----");

    String content0 = "Sachin Ramesh Tendulkar (Listeni/ˌsətʃɪn tɛnˈduːlkər/; Marathi: "
            + " सचिन रमेश तेंडुलकर; born 24 April 1973) is an Indian former cricketer widely "
            + " acknowledged as the greatest batsman of the modern generation, popularly holds the title \"God of Cricket\" among his fans [2] He is also acknowledged as the greatest cricketer of all time.[6][7][8][9] He took up cricket at the age of eleven, made his Test debut against Pakistan at the age of sixteen, and went on to represent Mumbai domestically and India internationally for close to twenty-four years. He is the only player to have scored one hundred international centuries, the first batsman to score a Double Century in a One Day International, and the only player to complete more than 30,000 runs in international cricket.[10] In October 2013, he became the 16th player and first Indian to aggregate "
            + " 50,000 runs in all recognized cricket "
            + " First-class, List A and Twenty20 combined)";
    String content1 = "Peoples who lives in Bay Area San Francisco";
    String content2 = "All my contacts in California, who are form Google";
    String content3 = "Give me all contacts in California, who are form Google and knows JAVA";
    String content4 = "Give me all contacts in California, who are form Google and does not know JAVA";
    String content5 = "Give me all contacts in California, who are form Google and who are NOT from Stanford";
    String content6 = "Give me all contacts in California, who are form Google and who are NOT from IIT";
    String content7 = "Show me the list of ceos in London who are from India and NOT from IIT";
    String content8 = "All Contacts in London who are NOT from Google and knows Cloud Computing";
    String content9 = "People who studied in stanford living in california";
    String content10 = "People who graduated from IIT and Working in Google";
    String content11 = "marketing and Sales freelancers from California";
    String content12 = "Aravind not in Google";
    String content13 = "Arvind in GOOGLE";
    String content14 = "Mark Espinola In Gradehub";
    String content15 = "Mark Espinola in Gradehub, Satya in Devsquare";
    String content16 = "Mark in Gradehub";
    String content17 = "Aravind";
    String content18 = "Udaypal";
    String content19 = "Arvind";
    String content20 = "Proddatur";
    String content21 = "Devsquare";
    String content22 = "Indus";
    String content23 = "London";
    String content24 = "Sharma";
    String content25 = "Gary";
    String content26 = "srikanth";
    String content27 = "aravind";
    String content28 = "arvind";

/*
    out.println("<br>"+content0+": "+identifyNER(content0, classifier).toString());
    out.println("<br>"+content1+": "+identifyNER(content1, classifier).toString());
    out.println("<br>"+content2+": "+identifyNER(content2, classifier).toString());
    out.println("<br>"+content12+": "+identifyNER(content12, classifier).toString());
    out.println("<br>"+content13+": "+identifyNER(content13, classifier).toString());
    out.println("<br>"+content3+": "+identifyNER(content3, classifier).toString());
    out.println("<br>"+content4+": "+identifyNER(content4, classifier).toString());
    out.println("<br>"+content5+": "+identifyNER(content5, classifier).toString());
    out.println("<br>"+content6+": "+identifyNER(content6, classifier).toString());
    out.println("<br>"+content7+": "+identifyNER(content7, classifier).toString());
    out.println("<br>"+content8+": "+identifyNER(content8, classifier).toString());
    out.println("<br>"+content9+": "+identifyNER(content9, classifier).toString());
    out.println("<br>"+content10+": "+identifyNER(content10, classifier).toString());
    out.println("<br>"+content11+": "+identifyNER(content11, classifier).toString());
    out.println("<br>"+content14+": "+identifyNER(content14, classifier).toString());
    out.println("<br>"+content15+": "+identifyNER(content15, classifier).toString());
    out.println("<br>"+content16+": "+identifyNER(content16, classifier).toString());
    out.println("<br>"+content17+": "+getEntityTypeForString(content17, classifier));
*/
    out.println("<br>"+content18+": "+getEntityTypeForString(content18, classifier));
    out.println("<br>"+content22+": "+getEntityTypeForString(content22, classifier));
    out.println("<br>"+content20+": "+getEntityTypeForString(content20, classifier));
    out.println("<br>"+content19+": "+getEntityTypeForString(content19, classifier));
    out.println("<br>"+content21+": "+getEntityTypeForString(content21, classifier));
    out.println("<br>"+content23+": "+getEntityTypeForString(content23, classifier));
    out.println("<br>"+content24+": "+getEntityTypeForString(content24, classifier));
    out.println("<br>"+content25+": "+getEntityTypeForString(content25, classifier));
    out.println("<br>"+content26+": "+getEntityTypeForString(content26, classifier));
    out.println("<br>"+content27+": "+getEntityTypeForString(content27, classifier));
    out.println("<br>"+content28+": "+getEntityTypeForString(content28, classifier));

    out.println("<br>----");
    out.println("<br>END: "+new Date());
%>
