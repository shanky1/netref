package com.neo4j;

import org.neo4j.driver.v1.*;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class Neo4jCypherLin {
    static String dir_path = "F:\\satya_code\\neo4j\\profiles_extracted_and_parsed";
//    static String dir_path = "F:\\satya_code\\neo4j\\profiles_extracted_and_parsed\\lin_extracted_304";

    public static void main(String args[]) {

//        A driver is used to connect to a Neo4j server. It provides sessions that are used to execute statements and retrieve results.
//        If no port is provided in the URL, the default port 7687 is used

        Driver driver = GraphDatabase.driver("bolt://localhost", AuthTokens.basic("neo4j", "saneo4j"));
//        Driver driver = GraphDatabase.driver("bolt://50.16.185.228", AuthTokens.basic("neo4j", "saneo4j"));
        Session session = driver.session();

//        Cleanup all existing nodes and their relationship entries
        cleanupDB(session);

//        read from the input files and add connection
        readFilesFromInputDir(session);

//        Specific relationship in MATCH
        String search_for1 = "Cloud computing";
        String search_in1 = "Experience";
//        searchByRelationship1(session, search_for1, search_in1);

//        Generic relationship
        String search_for2 = "CEO";
//        searchByAll(session, search_for2);

//        Specific relationship in WHERE
        String search_for3 = "san francisco, london washington; Chicago Manchester, cambridge";
        String search_in3 = "Location";
        searchByRelationship2(session, search_for3, search_in3);

        session.close();
        driver.close();
    }

    private static void searchByRelationship1(Session session, String search_for1, String search_in1) {
        StatementResult result = session.run("MATCH (parent)-[:"+search_in1+"]->(child) " +
                "WHERE child.value =~ '.*(?i)"+search_for1+".*' " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id");

        boolean results_found = false;

        while (result.hasNext() ) {
            Record record = result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String name = record.get( "name" ).asString();
            String value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();

            System.out.println("----\nparent_id1: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nrelationship: "+search_in1);

            results_found = true;
        }

        if(!results_found) {
            System.out.println("----\nparent_id1: No results found for the given criteria");
        }
    }

    private static void searchByAll(Session session, String search_for2) {
        StatementResult result = session.run("MATCH (parent)-[r]->(child) " +
                "WHERE child.value =~ '.*(?i)" + search_for2 + ".*' " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship");

        boolean results_found = false;

        while (result.hasNext() ) {
            Record record = result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String name = record.get( "name" ).asString();
            String value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();
            String relationship = record.get( "relationship" ).asString();

            System.out.println("----\nparent_id2: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nrelationship: "+relationship);

            results_found = true;
        }

        if(!results_found) {
            System.out.println("----\nparent_id2: No results found for the given criteria");
        }
    }

    private static void searchByRelationship2(Session session, String search_for1, String search_in1) {
        search_for1 = search_for1.replaceAll(",","").replaceAll(";","");
        String[] search_for_split = search_for1.split(" ");

        String search_for_str = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

//        System.out.println("----\nparent_id3: search_for_str: "+search_for_str);

        StatementResult result = session.run("MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ")" +
                "AND TYPE(r) =~ '.*(?i)"+search_in1+"*.' " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship");

        boolean results_found = false;

        while (result.hasNext() ) {
            Record record = result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String name = record.get( "name" ).asString();
            String value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();
            String relationship = record.get( "relationship" ).asString();

            System.out.println("----\nparent_id3: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nrelationship: "+relationship);

            results_found = true;
        }

        if(!results_found) {
            System.out.println("----\nparent_id3: No results found for the given criteria");
        }
    }

    private static void cleanupDB(Session session) {
        StatementResult result = session.run("MATCH (n) " +
                "OPTIONAL MATCH (n)-[r]-() " +
                "DELETE n,r");
    }

    private static void readFilesFromInputDir(Session session) {
        File folder = null;

        try {
            folder = new File(dir_path);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    insertDataIntoNeo4J(session, file_path);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static void insertDataIntoNeo4J(Session session, String file_input) {
        try  {
            String line;
            String text = "";
            String key = "";
            int name_entity_id = -1;

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(!line.startsWith("---")) {
                    if(line.endsWith(" : ")) {
                        key = line.split(":")[0].trim();
                    } else {
                        if(!line.contains("N/A")) {
                            text += line.trim()+"===";      //adding === to represent new line
                        }
                    }
                } else {
                    if(text.length() > 0) {
                        if(key.equalsIgnoreCase("name")) {
                            name_entity_id = addEntity_ForName(session, "PERSON", text);
                        } else {
                            addEntity_ForOthers(session, key, text, name_entity_id);
                        }
                    }
                    text = "";                          //reset para to empty
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static int addEntity_ForName(Session session, String key, String para) {
        int name_entity_id = -1;
        key = key.replaceAll(" ","");

        session.run("CREATE (" + key + ":" + key + " {value: {value}})", Values.parameters("value", para));

        StatementResult result = session.run( "MATCH (a:"+key+" {value: {value}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "value", para) );

        while (result.hasNext() ) {
            Record record = result.next();
            name_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ name_entity_id+", key: "+key+", value: "+ record.get( "value" ).asString());
        }

        System.out.println(new java.util.Date()+"\t Successfully created the Entity for: "+key+", id: "+name_entity_id);

        return name_entity_id;
    }

    static void addEntity_ForOthers(Session session, String key, String para, int name_entity_id) {
        int other_entity_id = -1;
        key = key.replaceAll(" ","");

        session.run("CREATE (" + key + ":" + key + " {value: {value}})", Values.parameters("value", para));

        StatementResult result = session.run( "MATCH (a:"+key+" {value: {value}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "value", para) );

        while (result.hasNext() ) {
            Record record = result.next();
            other_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ other_entity_id+", key: "+key+", value: "+ record.get( "value" ).asString());
        }

        System.out.println(new java.util.Date()+"\t Successfully created the Entity for: "+key+", parent_id: "+name_entity_id+", id: "+other_entity_id);

        result = session.run( "MATCH (a), (b) " +
                "WHERE ID(a) = "+name_entity_id+" AND ID(b) = "+other_entity_id+" " +
                "CREATE (a)-[:"+key+"]->(b)" );
    }
}
