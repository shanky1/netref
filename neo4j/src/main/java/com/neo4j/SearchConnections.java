package com.neo4j;

import org.neo4j.driver.v1.*;

import java.util.ArrayList;
import java.util.LinkedHashMap;

public class SearchConnections {

    public static void main(String args[]) {
//        A driver is used to connect to a Neo4j server. It provides sessions that are used to execute statements and retrieve results.
//        If no port is provided in the URL, the default port 7687 is used

        Driver driver = GraphDatabase.driver("bolt://localhost", AuthTokens.basic("neo4j", "saneo4j"));
        Session session = driver.session();

//        Specific relationship in WHERE
        String search_for = "san francisco, london washington; Chicago Manchester, cambridge Boston";
        String search_in = "Location";
        searchByRelationship(session, search_for, search_in);

        session.close();
        driver.close();
    }

    public static ArrayList<LinkedHashMap<String, String>> searchByRelationship(Session session, String search_for, String search_in) {
        search_for = search_for.replaceAll(",","").replaceAll(";","");
        String[] search_for_split = search_for.split(" ");

        String search_for_str = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

        //Get the person name by location
        StatementResult result = session.run("MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ")" +
                "AND TYPE(r) =~ '.*(?i)"+search_in+"*.' " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship");

        ArrayList<LinkedHashMap<String, String>> al = new ArrayList<>();

        while (result.hasNext() ) {
            Record record = result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String name = record.get( "name" ).asString();
            String value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();
            String relationship = record.get( "relationship" ).asString();

//            System.out.println("----\nparent_id: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nrelationship: "+relationship);

            //Get the person details by person name which is retrieved by location
            StatementResult parent_node_results = session.run("MATCH (a:PERSON {value: '"+name+"'})-[r]->(b) " +
                    "RETURN ID(b) as NodeId, a.value as name, b.value as details, TYPE(r) as relation " +
                    "ORDER BY ID(b) ASC");

            LinkedHashMap<String, String> hm = new LinkedHashMap<>();
            String str = "";

            while (parent_node_results.hasNext() ) {
                Record parent_record = parent_node_results.next();
                String details = parent_record.get( "details" ).asString();
                String relation = parent_record.get( "relation" ).asString();

                str += relation+": "+details.replaceAll("==="," ")+"<br>";
            }
            name = name.replaceAll("===","");
            hm.put(name, str);

            System.out.println("hm: " + hm);

            al.add(hm);
        }

        if(al.size() <= 0) {
            System.out.println("----\nparent_id: No results found for the given criteria search_for: "+search_for+", search_in: "+search_in);
        }
        return al;
    }

    private static ArrayList<LinkedHashMap<String, String>> searchByRelationship_OLD(Session session, String search_for, String search_in) {
        search_for = search_for.replaceAll(",","").replaceAll(";","");
        String[] search_for_split = search_for.split(" ");

        String search_for_str = "";

        for(int i = 0; i < search_for_split.length; i++) {
            if(i == search_for_split.length-1) {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' ";
            } else {
                search_for_str += "child.value =~ '.*(?i)"+search_for_split[i]+".*' OR ";
            }
        }

        //Get the person name by location
        StatementResult result = session.run("MATCH (parent)-[r]->(child) " +
                "WHERE (" + search_for_str + ")" +
                "AND TYPE(r) =~ '.*(?i)"+search_in+"*.' " +
                "RETURN ID(parent) AS parent_id, parent.value as name, child.value as value, ID(child) AS child_id, TYPE(r) as relationship");

        ArrayList<LinkedHashMap<String, String>> al = new ArrayList<>();

        while (result.hasNext() ) {
            Record record = result.next();
            int parent_id = record.get( "parent_id" ).asInt();
            String name = record.get( "name" ).asString();
            String value = record.get( "value" ).asString();
            int child_id = record.get( "child_id" ).asInt();
            String relationship = record.get( "relationship" ).asString();

//            System.out.println("----\nparent_id: "+ parent_id+"\nchild_id: "+child_id+"\nname: "+name+"\nvalue: "+value+"\nrelationship: "+relationship);

            //Get the person details by person name which is retrieved by location
            StatementResult parent_node_results = session.run("MATCH (a:PERSON {value: '"+name+"'})-[r]->(b) " +
                    "RETURN ID(b) as NodeId, a.value as name, b.value as details, TYPE(r) as relation " +
                    "ORDER BY ID(b) ASC");

            LinkedHashMap<String, String> hm = new LinkedHashMap<>();
            hm.put("Person", name);

            while (parent_node_results.hasNext() ) {
                Record parent_record = parent_node_results.next();
                String details = parent_record.get( "details" ).asString();
                String relation = parent_record.get( "relation" ).asString();

                hm.put(relation, details);

//                System.out.println("relation: "+ relation+"; details: "+details);
            }
            al.add(hm);

            System.out.println("hm: " + hm);
        }

        if(al.size() <= 0) {
            System.out.println("----\nparent_id: No results found for the given criteria search_for: "+search_for+", search_in: "+search_in);
        }
        return al;
    }
}
