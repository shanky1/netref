<%@ page import="org.neo4j.driver.v1.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.util.*" %>
<%@ include file="ner_util.jsp"%>

<%
    String gdbDriver_url = "bolt://localhost";
    String gdbDriver_username = "neo4j";
    String gdbDriver_password = "saneo4j";

    String fb_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\fb_nlp_profiles_parsed";

    String lin_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_nlp_profiles_parsed";
//    String lin_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\lin_nlp_profiles_parsed\\lin_extracted_304";
//    String lin_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_nlp_profiles_parsed\\lin_extracted_empty";

    String lin_simple_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_simple_profiles_parsed";
//    String lin_simple_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_simple_profiles_parsed\\lin_extracted_304";
//    String lin_simple_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_simple_profiles_parsed\\lin_extracted_empty";

    String ol_inbox_dir_path = "F:\\satya_code\\cim\\data\\outlook\\inbox";
    String gmail_inbox_dir_path = "F:\\satya_code\\cim\\data\\gmail\\inbox";
    String nr_contacts_dir_path = "F:\\satya_code\\cim\\data\\netref_contacts";
    
    String comp_simple_profiles_dir = "F:\\satya_code\\cim\\data\\company_specialities";

    int shankar_name_entity_id = 14946;
%>

<%!
    ArrayList<String> entity_black_list = new ArrayList<String>();

    public ArrayList<LinkedHashMap<String, String>> searchByQuery(Session sess, String search_for, CRFClassifier<CoreLabel> classifier) {
        search_for = removeStopWords(search_for);

        System.out.println(new Date()+"\t search_for: "+search_for);

        search_for = search_for.replaceAll(","," ").replaceAll(";"," ");

        String[] search_for_split = search_for.split(" ");

        ArrayList<LinkedHashMap<String, String>> search_results_contacts_al = new ArrayList<LinkedHashMap<String, String>>();
        ArrayList<Integer> search_results_others_al = new ArrayList<Integer>();
        LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();

        String search_for_str = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

        String query_for_contacts = "MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ") " +
                "AND (TYPE(r) =~ '.*(?i)MAIL_CONTACT*.') " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.name as child_name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER BY value ASC";

//        System.out.println("query_for_contacts: "+query_for_contacts);

        StatementResult query_for_contacts_result = sess.run(query_for_contacts);

        String name = "";
        String child_name = "";
        String value = "";
        String prev_keyword = "";

        while (query_for_contacts_result.hasNext() ) {
            Record record = query_for_contacts_result.next();
            name = record.get( "name" ).asString();
            child_name = record.get( "child_name" ).asString();
            value += child_name+" ["+record.get( "value" ).asString().trim()+"]"+"<br>";
        }

        if(value != null && value.trim().length() > 0) {
            hm.put(name+" contact(s)", value.trim());
            search_results_contacts_al.add(hm);
        }

        for(int i = 0; i < search_for_split.length; i++) {
            System.out.println("prev_keyword: "+prev_keyword);

            if(search_for_split[i].equalsIgnoreCase("not")) {
                prev_keyword = search_for_split[i];
                continue;
            }

            ArrayList<Integer> res = getSearchResultsByKeyword(sess, search_for_split[i], classifier);

//            if(search_results_others_al.size() == 0) {
            if(i == 0) {
                search_results_others_al = union(search_results_others_al, res);
            } else if(prev_keyword.equalsIgnoreCase("not")) {
                search_results_others_al = not(search_results_others_al, res);
            } else {
                search_results_others_al = intersection(search_results_others_al, res);
            }

//            System.out.println("search_results_others_al["+i+"].size(): "+search_results_others_al.size());
        }

        Iterator iterator = search_results_others_al.iterator();

        while (iterator.hasNext()) {
            String res = "";

            int node_id = (Integer)iterator.next();

            res = getPersonDetailsByNodeID(sess, node_id, "short");

//            System.out.println("res: "+res);

            String[] res_split = res.split("\\|\\|");

            if(res_split.length == 2) {
                name = res_split[0];
                String details = res_split[1];

                hm = new LinkedHashMap<String, String>();
                hm.put(name, details);
                search_results_contacts_al.add(hm);
            }
        }
        return search_results_contacts_al;
    }

    public ArrayList<LinkedHashMap<String, String>> searchContacts(Session sess, String search_for, CRFClassifier<CoreLabel> classifier) {
        search_for = removeStopWords(search_for);

        System.out.println(new Date()+"\t searchBySpecialities -> search_for: "+search_for);

        search_for = search_for.replaceAll(","," ").replaceAll(";"," ");

        String[] search_for_split = search_for.split(" ");

        ArrayList<LinkedHashMap<String, String>> all_contacts_al = new ArrayList<LinkedHashMap<String, String>>();

        //Get contacts from netref, gmail, outlook, yahoo
        LinkedHashMap<String, String> contacts_hm = searchInContacts(sess, search_for_split);

        if(contacts_hm.size() > 0) {
            all_contacts_al.add(contacts_hm);
        }

        //Get connections/contacts from linkedin, facebook
        ArrayList<Integer> search_profiles_kw_al = new ArrayList<Integer>();
        ArrayList<Integer> search_profiles_spec_al = new ArrayList<Integer>();
        ArrayList<Integer> search_profiles_al = new ArrayList<Integer>();
        String prev_keyword = "";
        String name = "";

        for(int i = 0; i < search_for_split.length; i++) {
            System.out.println("prev_keyword: "+prev_keyword);

            if(search_for_split[i].equalsIgnoreCase("not")) {
                prev_keyword = search_for_split[i];
                continue;
            }

            //Get connections/contacts directly from linkedin, facebook
            ArrayList<Integer> res_kw = getSearchResultsByKeyword(sess, search_for_split[i], classifier);

//            if(search_profiles_kw_al.size() == 0) {
            if(i == 0) {
                search_profiles_kw_al = union(search_profiles_kw_al, res_kw);
//                search_profiles_kw_al = intersection(search_profiles_kw_al, res_kw);
            } else if(prev_keyword.equalsIgnoreCase("not")) {
                search_profiles_kw_al = not(search_profiles_kw_al, res_kw);
            } else {
                search_profiles_kw_al = intersection(search_profiles_kw_al, res_kw);
            }

            System.out.println("search_profiles_kw_al["+i+"].size(): "+search_profiles_kw_al.size());

            //Get connections/contacts by company specialities from linkedin, facebook
            ArrayList<Integer> res_spec = getSearchResultsBySpecialities(sess, search_for_split[i]);

//            if(search_profiles_spec_al.size() == 0) {
            if(i == 0) {
                search_profiles_spec_al = union(search_profiles_spec_al, res_spec);
            } else if(prev_keyword.equalsIgnoreCase("not")) {
                search_profiles_spec_al = not(search_profiles_spec_al, res_spec);
            } else {
                search_profiles_spec_al = intersection(search_profiles_spec_al, res_spec);
            }

            System.out.println("search_profiles_spec_al["+i+"].size(): "+search_profiles_spec_al.size());

            prev_keyword = search_for_split[i];
        }

        search_profiles_al = union(search_profiles_kw_al, search_profiles_spec_al);

        System.out.println("search_profiles_al.size(): "+search_profiles_al.size());

        LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();
        Iterator iterator = search_profiles_al.iterator();

        while (iterator.hasNext()) {
            String res = "";

            int node_id = (Integer)iterator.next();

            res = getPersonDetailsByNodeID(sess, node_id, "complete");

//            System.out.println("res: "+res);

            String[] res_split = res.split("\\|\\|");

            if(res_split.length == 2) {
                name = res_split[0];
                String details = res_split[1];

                hm = new LinkedHashMap<String, String>();
                hm.put(name, details);
                all_contacts_al.add(hm);
            }
        }
        return all_contacts_al;
    }

    public LinkedHashMap<String, String> searchInContacts(Session sess, String[] search_for_split) {
        LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();

        String search_for_str = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

        String query_for_contacts = "MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ") " +
                "AND ((TYPE(r) =~ '.*(?i)MAIL_CONTACT*.') OR (TYPE(r) =~ '.*(?i)NR_CONTACT*.')) " +
                "RETURN ID(parent) AS parent_id, parent.value as parent_name, child.name as child_name, child.value as value, child.number as number, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER BY value ASC";

        System.out.println("query_for_contacts: "+query_for_contacts);

        StatementResult query_for_contacts_result = sess.run(query_for_contacts);

        String parent_name = "";
        String child_name = "";
        String child_value = "";
        String child_number = "";
        String ret = "";

        while (query_for_contacts_result.hasNext() ) {
            Record record = query_for_contacts_result.next();
            parent_name = record.get( "parent_name" ).asString().trim();
            child_name = record.get( "child_name" ).asString().trim();
            child_number = record.get( "number" ).asString().trim();
            child_value = record.get( "value" ).asString().trim();
            ret += (child_name != null && !child_name.equalsIgnoreCase("null") ? child_name+"; " : "") +
                    (child_value != null && !child_value.equalsIgnoreCase("null") ? child_value+"; " : "") +
                    (child_number != null && !child_number.equalsIgnoreCase("null") ? child_number+"; " : "") + "<br>";
        }

        if(ret != null && ret.trim().length() > 0) {
            hm.put(parent_name + " contact(s)", ret.trim());
        }
        return hm;
    }

    public ArrayList<Integer> getSearchResultsBySpecialities(Session sess, String child_value) {
        ArrayList<Integer> res = new ArrayList<Integer>();

        //Step1: get the company list for the speciality
        String query_for_company_info = "MATCH (parent:COMPANY)-[r]->(child:SPECIALITIES) " +
                "WHERE child.value =~ '.*(?i)"+child_value+".*' " +
                "RETURN LOWER(parent.value) as company_name, child.value as specialities";

        System.out.println("getSearchResultsBySpecialities -> query_for_company_info: "+query_for_company_info);

        StatementResult query_for_company_info_result = sess.run(query_for_company_info);

        ArrayList<String> company_list = new ArrayList<String>();

        while (query_for_company_info_result.hasNext() ) {
            Record record = query_for_company_info_result.next();
            String company_name = record.get( "company_name" ).asString();

            company_list.add("\""+company_name+"\"");
        }
        System.out.println("company_list: "+company_list);

        //Step2: get the profile details for the list of companies from Step1
        String query_for_profile_info = "MATCH (parent:PERSON)-[r]->(child:ORGANIZATION) " +
                "WHERE (LOWER(child.value) IN "+company_list+") AND NOT(TYPE(r) =~ '.*(?i)COMPANY*.') " +
                "RETURN ID(parent) AS parent_id, parent.value as parent_name, child.value as child_value, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER by parent_name";

        System.out.println("getSearchResultsBySpecialities -> query_for_profile_info: "+query_for_profile_info);

        StatementResult query_for_profile_info_result = sess.run(query_for_profile_info);

        while (query_for_profile_info_result.hasNext() ) {
            Record record = query_for_profile_info_result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String parent_name = record.get( "parent_name" ).asString();

            res.add(parent_id);
        }
        System.out.println("res: "+res);

        return res;
    }

    public ArrayList<Integer> union(ArrayList<Integer> list1, ArrayList<Integer> list2) {
        Set<Integer> set = new HashSet<Integer>();

        set.addAll(list1);
        set.addAll(list2);

        return new ArrayList<Integer>(set);
    }

    public ArrayList<Integer> intersection(ArrayList<Integer> list1, ArrayList<Integer> list2) {
        ArrayList<Integer> list = new ArrayList<Integer>();

        for (Integer t : list1) {
            if(list2.contains(t)) {
                list.add(t);
            }
        }
        return list;
    }

    public ArrayList<Integer> not(ArrayList<Integer> list1, ArrayList<Integer> list2) {
        ArrayList<Integer> list = new ArrayList<Integer>();

        for (Integer t : list1) {
            if(!list2.contains(t)) {
                list.add(t);
            }
        }
        return list;
    }

    public ArrayList<Integer> getSearchResultsByKeyword(Session sess, String child_value, CRFClassifier<CoreLabel> classifier) {

        ArrayList<Integer> res = new ArrayList<Integer>();

        String query_for_others = "MATCH (parent)-[r]->(child) " +
                "WHERE (child.value =~ '.*(?i)"+child_value+".*') " +
                "AND NOT(TYPE(r) =~ '.*(?i)MAIL_CONTACT.*') AND NOT(TYPE(r) =~ '.*(?i)NR_CONTACT.*') " +
                "AND NOT(TYPE(r) =~ '.*(?i)CONNECTION.*') AND NOT(TYPE(r) =~ '.*(?i)SI_.*') " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER by name";

        String entity_type = getEntityTypeForString(child_value, classifier);

        System.out.println("***entity_type FOR "+child_value+": "+entity_type);

        if(entity_type.equalsIgnoreCase("person")) {
            query_for_others = "MATCH (parent)-[r]->(child) " +
                    "WHERE (child.value =~ '.*(?i)"+child_value+".*') " +
                    "AND NOT(TYPE(r) =~ '.*(?i)MAIL_CONTACT.*') AND NOT(TYPE(r) =~ '.*(?i)NR_CONTACT.*') " +
                    "AND (TYPE(r) =~ '.*(?i)CONNECTION.*') AND NOT(TYPE(r) =~ '.*(?i)SI_.*') " +
                    "RETURN ID(child) AS parent_id, child.value as value, TYPE(r) as relationship " +
                    "ORDER by value";
        }

        System.out.println("getSearchResultsByKeyword -> query_for_others: "+query_for_others);

        StatementResult query_for_others_result = sess.run(query_for_others);

        while (query_for_others_result.hasNext() ) {
            Record record = query_for_others_result.next();
            int parent_id = record.get( "parent_id" ).asInt();

            res.add(parent_id);
        }
        return res;
    }

    public ArrayList<LinkedHashMap<String, String>> searchByQuery_10Nov2016(Session sess, String search_for) {
        search_for = removeStopWords(search_for);

        search_for = search_for.replaceAll(",","").replaceAll(";", "");
        String[] search_for_split = search_for.split(" ");

        ArrayList<LinkedHashMap<String, String>> al = new ArrayList<LinkedHashMap<String, String>>();
        LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();
        String search_for_str = "";
        String name = "";
        String child_name = "";
        String value = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

        String query_for_contacts = "MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ") " +
                "AND (TYPE(r) =~ '.*(?i)MAIL_CONTACT*.') " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.name as child_name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER BY value ASC";

        StatementResult query_for_contacts_result = sess.run(query_for_contacts);

        while (query_for_contacts_result.hasNext() ) {
            Record record = query_for_contacts_result.next();
            name = record.get( "name" ).asString();
            child_name = record.get( "child_name" ).asString();
            value += child_name+" ["+record.get( "value" ).asString().trim()+"]"+"<br>";
        }

        if(value != null && value.trim().length() > 0) {
            hm.put(name+" contact(s)", value.trim());
            al.add(hm);
        }

        String query_for_others = "MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ") " +
                "AND NOT(TYPE(r) =~ '.*(?i)MAIL_CONTACT*.') AND NOT(TYPE(r) =~ '.*(?i)SI_.*.') " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship " +
                "ORDER BY value ASC";

        System.out.println("query_for_others: "+query_for_others);

        StatementResult query_for_others_result = sess.run(query_for_others);

        while (query_for_others_result.hasNext() ) {
            Record record = query_for_others_result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            name = record.get( "name" ).asString();
            value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();
            String connection = record.get( "relationship" ).asString();

            System.out.println("----\nparent_id: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nconnection: "+connection);

            String res = "";

            res = getPersonDetailsByNodeID(sess, parent_id, "short");

            if(res == null || res.trim().length() <= 0) {
                res = "Value: " + value + "<br>Connection: " + connection;
            }

            hm = new LinkedHashMap<String, String>();
            hm.put(name, res);

            al.add(hm);
        }

        if(al.size() <= 0) {
            System.out.println("----\nparent_id: No results found for the given criteria search_for: "+search_for);
        }
        return al;
    }

    public static String[] stopwords = {"a", "as", "able", "about", "above", "according", "accordingly", "across", "actually", "after", "afterwards", "again", "against", "aint", "all", "allow", "allows", "almost", "alone", "along", "already", "also", "although", "always", "am", "among", "amongst", "an", "and", "another", "any", "anybody", "anyhow", "anyone", "anything", "anyway", "anyways", "anywhere", "apart", "appear", "appreciate", "appropriate", "are", "arent", "around", "as", "aside", "ask", "asking", "associated", "at", "available", "away", "awfully", "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "behind", "being", "believe", "below", "beside", "besides", "best", "better", "between", "beyond", "both", "brief", "but", "by", "cmon", "cs", "came", "can", "cant", "cannot", "cant", "cause", "causes", "certain", "certainly", "changes", "clearly", "co", "com", "come", "comes", "concerning", "consequently", "consider", "considering", "contain", "containing", "contains", "corresponding", "could", "couldnt", "course", "currently", "definitely", "described", "despite", "did", "didnt", "different", "do", "does", "doesnt", "doing", "dont", "done", "down", "downwards", "during", "each", "edu", "eg", "eight", "either", "else", "elsewhere", "enough", "entirely", "especially", "et", "etc", "even", "ever", "every", "everybody", "everyone", "everything", "everywhere", "ex", "exactly", "example", "except", "far", "few", "ff", "fifth", "first", "five", "followed", "following", "follows", "for", "former", "formerly", "forth", "four", "from", "further", "furthermore", "get", "gets", "getting", "given", "gives", "go", "goes", "going", "gone", "got", "gotten", "greetings", "had", "hadnt", "happens", "hardly", "has", "hasnt", "have", "havent", "having", "he", "hes", "hello", "help", "hence", "her", "here", "heres", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "hi", "him", "himself", "his", "hither", "hopefully", "how", "howbeit", "however", "i", "id", "ill", "im", "ive", "ie", "if", "ignored", "immediate", "in", "inasmuch", "inc", "indeed", "indicate", "indicated", "indicates", "inner", "insofar", "instead", "into", "inward", "is", "isnt", "it", "itd", "itll", "its", "its", "itself", "just", "keep", "keeps", "kept", "know", "knows", "known", "last", "lately", "later", "latter", "latterly", "least", "less", "lest", "let", "lets", "like", "liked", "likely", "little", "look", "looking", "looks", "ltd", "mainly", "many", "may", "maybe", "me", "mean", "meanwhile", "merely", "might", "more", "moreover", "most", "mostly", "much", "must", "my", "myself", "name", "namely", "nd", "near", "nearly", "necessary", "need", "needs", "neither", "never", "nevertheless", "new", "next", "nine", "no", "nobody", "non", "none", "noone", "nor", "normally", "nothing", "novel", "now", "nowhere", "obviously", "of", "off", "often", "oh", "ok", "okay", "old", "on", "once", "one", "ones", "only", "onto", "or", "other", "others", "otherwise", "ought", "our", "ours", "ourselves", "out", "outside", "over", "overall", "own", "particular", "particularly", "per", "perhaps", "placed", "please", "plus", "possible", "presumably", "probably", "provides", "que", "quite", "qv", "rather", "rd", "re", "really", "reasonably", "regarding", "regardless", "regards", "relatively", "respectively", "right", "said", "same", "saw", "say", "saying", "says", "second", "secondly", "see", "seeing", "seem", "seemed", "seeming", "seems", "seen", "self", "selves", "sensible", "sent", "serious", "seriously", "seven", "several", "shall", "she", "should", "shouldnt", "since", "six", "so", "some", "somebody", "somehow", "someone", "something", "sometime", "sometimes", "somewhat", "somewhere", "soon", "sorry", "specified", "specify", "specifying", "still", "sub", "such", "sup", "sure", "ts", "take", "taken", "tell", "tends", "th", "than", "thank", "thanks", "thanx", "that", "thats", "thats", "the", "their", "theirs", "them", "themselves", "then", "thence", "there", "theres", "thereafter", "thereby", "therefore", "therein", "theres", "thereupon", "these", "they", "theyd", "theyll", "theyre", "theyve", "think", "third", "this", "thorough", "thoroughly", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "took", "toward", "towards", "tried", "tries", "truly", "try", "trying", "twice", "two", "un", "under", "unfortunately", "unless", "unlikely", "until", "unto", "up", "upon", "us", "use", "used", "useful", "uses", "using", "usually", "value", "various", "very", "via", "viz", "vs", "want", "wants", "was", "wasnt", "way", "we", "wed", "well", "were", "weve", "welcome", "well", "went", "were", "werent", "what", "whats", "whatever", "when", "whence", "whenever", "where", "wheres", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whos", "whoever", "whole", "whom", "whose", "why", "will", "willing", "wish", "with", "within", "without", "wont", "wonder", "would", "would", "wouldnt", "yes", "yet", "you", "youd", "youll", "youre", "youve", "your", "yours", "yourself", "yourselves", "zero", "show", "contact", "contacts","working"};
    public static Set<String> stopWordSet = new HashSet<String>(Arrays.asList(stopwords));

    public static String removeStopWords(String string) {
        String result = "";
        String[] words = string.split("\\s+");
        for(String word : words) {
            if(word.isEmpty()) continue;
            if(isStopword(word)) continue; //remove stopwords
            result += (word+" ");
        }
        return result;
    }

    public static boolean isStopword(String word) {
        if(word.length() < 2) return true;
        if(word.charAt(0) >= '0' && word.charAt(0) <= '9') return true;         //remove numbers, "25th", etc
        if(stopWordSet.contains(word)) return true;
        else return false;
    }

    public LinkedHashMap<String, String> getPersonDetailsByNodeName(Session sess, String name, String display_format) {
        entity_black_list.add("Languages");
        entity_black_list.add("AdditionalInfo");
        entity_black_list.add("Interests");
        entity_black_list.add("Recomendations");
        entity_black_list.add("PeopleViewed");
        entity_black_list.add("PersonalDetails");
        entity_black_list.add("AdviceforContactingRohit");

//Get the person details by person name which is retrieved by location
        StatementResult parent_node_results = sess.run("MATCH (a:PERSON {value: '"+name+"'})-[r]->(b) " +
                "RETURN ID(b) as NodeId, a.value as name, b.value as details, TYPE(r) as relation " +
                "ORDER BY ID(b) ASC");

        LinkedHashMap<String, String> hm = new LinkedHashMap<String, String>();
        String str = "";
        int NodeId = -1;

        while (parent_node_results.hasNext() ) {
            Record parent_record = parent_node_results.next();

            NodeId = parent_record.get( "NodeId" ).asInt();
            String details = parent_record.get( "details" ).asString();
            String relation = parent_record.get( "relation" ).asString();

            if(entity_black_list.contains(relation)) {
                continue;
            }

            details = details.replaceAll("==="," ");

            if(display_format.equalsIgnoreCase("short")) {
                if(details.length() > 120) {
                    details = details.substring(0, 120) + "...";
                }
            }

            str += "<b>"+relation+":</b> "+details+"<br>";
        }

        name = name.replaceAll("===","");
        hm.put(name, str);

        return hm;
    }

    public String getPersonDetailsByNodeID(Session sess, int node_id, String display_format) {
        entity_black_list.add("Languages");
        entity_black_list.add("AdditionalInfo");
        entity_black_list.add("Interests");
        entity_black_list.add("Recomendations");
        entity_black_list.add("PeopleViewed");
        entity_black_list.add("PersonalDetails");
        entity_black_list.add("AdviceforContactingRohit");
        entity_black_list.add("Summary");
        entity_black_list.add("DATE");
        entity_black_list.add("NUMBER");
        entity_black_list.add("DURATION");
        entity_black_list.add("MISC");
        entity_black_list.add("MONEY");
        entity_black_list.add("ORDINAL");
        entity_black_list.add("SET");
        entity_black_list.add("PERCENT");
        entity_black_list.add("PERSON");

        entity_black_list.add("SI_Languages");
        entity_black_list.add("SI_AdditionalInfo");
        entity_black_list.add("SI_Interests");
        entity_black_list.add("SI_Recomendations");
        entity_black_list.add("SI_PeopleViewed");
        entity_black_list.add("SI_PersonalDetails");
        entity_black_list.add("SI_AdviceforContactingRohit");
        entity_black_list.add("SI_Summary");
        entity_black_list.add("SI_Experience");

//        Get the person details by node id
        String person_details_query = "MATCH (a:PERSON)-[r]->(b) " +
                "WHERE ID(a) = " + node_id +" "+
                "RETURN ID(b) as NodeId, a.value as name, b.value as details, TYPE(r) as relation " +
                "ORDER BY ID(b) ASC";

//        System.out.println("person_details_query: "+person_details_query);

        StatementResult parent_node_results = sess.run(person_details_query);

        String str = "";
        String parent_name = "Name";

        String SI_Title = "";
        String SI_Location = "";
        String SI_Organization = "";
        String SI_Industry = "";
        String NLP_Location = "";
        String NLP_Organization = "";

        while (parent_node_results.hasNext() ) {
            Record parent_record = parent_node_results.next();
            String details = parent_record.get( "details" ).asString();
            String relation = parent_record.get( "relation" ).asString();
            parent_name = parent_record.get( "name" ).asString();

            if(entity_black_list.contains(relation)) {
                continue;
            }

/*
            if(!relation.startsWith("SI_")) {
                continue;
            }
*/

            details = details.replaceAll("==="," ");

            if(display_format.equalsIgnoreCase("short")) {
                if(details.length() > 120) {
                    details = details.substring(0, 120) + "...";
                }
            }

            if(relation.equalsIgnoreCase("SI_Title")) {
                relation = relation.replaceFirst("SI_","");
                SI_Title = "<b>"+relation+":</b> "+details+"<br>";
            } else if(relation.equalsIgnoreCase("SI_Location")) {
                relation = relation.replaceFirst("SI_","");
                SI_Location = "<b>"+relation+":</b> "+details+"<br>";
            } else if(relation.equalsIgnoreCase("SI_Current")) {
                SI_Organization = "<b>Organization:</b> "+details+"<br>";
            } else if(relation.equalsIgnoreCase("SI_Industry")) {
                relation = relation.replaceFirst("SI_","");
                SI_Industry = "<b>"+relation+":</b> "+details+"<br>";
            } else if(relation.equalsIgnoreCase("LOCATION")) {
                NLP_Location += details+", ";
            } else if(relation.equalsIgnoreCase("ORGANIZATION")) {
                NLP_Organization += details+", ";
            }
        }

        NLP_Location = (NLP_Location != null && NLP_Location.trim().length() > 0 ? "<b>Location: </b>"+NLP_Location+"<br>" : "");
        NLP_Organization = (NLP_Organization != null && NLP_Organization.trim().length() > 0 ? "<b>Organization: </b>"+NLP_Organization+"<br>" : "");

        String location = (SI_Location != null && SI_Location.trim().length() > 0 ? SI_Location : NLP_Location);
        String organization = (SI_Organization != null && SI_Organization.trim().length() > 0 ? SI_Organization : NLP_Organization);

        str += SI_Title+""+location+""+organization+""+SI_Industry;
        str = parent_name+"||"+str;

        return str;
    }
%>
