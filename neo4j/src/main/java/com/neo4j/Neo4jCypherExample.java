package com.neo4j;

import org.neo4j.driver.v1.*;
import org.neo4j.driver.v1.exceptions.ClientException;
import org.neo4j.driver.v1.summary.Notification;
import org.neo4j.driver.v1.summary.ResultSummary;
import org.neo4j.driver.v1.types.Node;
import org.neo4j.driver.v1.types.Relationship;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by ds-i7-2 on 10/10/2016.
 * http://localhost:7474/browser/
 * http://neo4j.com/docs/developer-manual/current/drivers/
 * https://neo4j.com/docs/java-reference/current/
 */

public class Neo4jCypherExample {
    public static void main(String args[]) {

//        A driver is used to connect to a Neo4j server. It provides sessions that are used to execute statements and retrieve results.
//        If no port is provided in the URL, the default port 7687 is used

        Driver driver = GraphDatabase.driver( "bolt://localhost", AuthTokens.basic( "neo4j", "saneo4j" ) );
        Session session = driver.session();

//        Cleanup all existing nodes and their relationship entries
        StatementResult result = session.run("MATCH (n) " +
                "OPTIONAL MATCH (n)-[r]-() " +
                "DELETE n,r");

//        session.run( "CREATE (a:Person {name:'Arthur', title:'King'})" );

        result = session.run( "MATCH (a:Person) WHERE a.name = 'Arthur' RETURN a.name AS name, a.title AS title" );
        while ( result.hasNext() )
        {
            Record record = result.next();
            System.out.println("Title: "+ record.get( "title" ).asString() + ", Name: " + record.get("name").asString() );
        }

        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "GUN" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Sword" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Bomb" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Materia Blade" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Sweep Blade" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Pearl Blade" ));
        result = session.run( "CREATE (weapon:Weapon {name: {name}})", Values.parameters( "name", "Venus Blade" ));

//        Results returned from Neo4j are presented as a stream of records.

        String searchTerm = "Blade";
        result = session.run( "MATCH (weapon:Weapon) WHERE weapon.name CONTAINS {term} RETURN weapon.name",
                Values.parameters( "term", searchTerm ) );

        System.out.println("List of weapons called " + searchTerm + ":");
        while ( result.hasNext() )
        {
            Record record = result.next();
            System.out.println(record.get("weapon.name").asString());
        }

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner1", "name", "name1", "material", "material1", "size", "size1" ));

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner2", "name", "name2", "material", "material2", "size", "size2" ));

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner3", "name", "name3", "material", "material3", "size", "size3" ));

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner2", "name", "name4", "material", "material4", "size", "size4" ));

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner1", "name", "name5", "material", "material5", "size", "size5" ));

        result = session.run( "CREATE (weapon2:Weapon2 {owner: {owner}, name: {name}, material: {material}, size: {size}})",
                Values.parameters( "owner", "owner2", "name", "name6", "material", "material6", "size", "size6" ));

//        A record provides an immutable view of a part of a result. It is an ordered map of keys and values. These key-value pairs are called fields

        searchTerm = "owner2";
        result = session.run( "MATCH (weapon2:Weapon2) WHERE weapon2.owner CONTAINS {term} RETURN weapon2.name, weapon2.material, weapon2.size",
                Values.parameters( "term", searchTerm ) );

        System.out.println("List of weapons owned by " + searchTerm + ":");
        while ( result.hasNext() )
        {
            Record record = result.next();
            List<String> sword = new ArrayList<>();
            for ( String key : record.keys() )
            {
                sword.add( key + ": " + record.get(key) );
            }
            System.out.println(sword);
        }

//        Retaining Results

        List<Record> records;
        System.out.println("Retaining Results: ");

        result = session.run(
                "MATCH (knight:Person:Knight) WHERE knight.castle = {castle} RETURN knight.name AS name",
                Values.parameters("castle", "Camelot"));

        records = result.list();

        for ( Record record : records )
        {
            System.out.println( record.get( "name" ).asString() + " is a knight of Camelot" );
        }

//        Use results in a new query

        System.out.println("Use results in a new query: ");

        result = session.run( "MATCH (knight:Person:Knight) WHERE knight.castle = {castle} RETURN id(knight) AS knight_id",
                Values.parameters( "castle", "Camelot" ) );

        for ( Record record : result.list() )
        {
            session.run("MATCH (knight) WHERE id(knight) = {id} " +
                            "MATCH (king:Person) WHERE king.name = {king} " +
                            "CREATE (knight)-[:DEFENDS]->(king)",
                    Values.parameters("id", record.get("knight_id"), "king", "Arthur"));
        }

//        Result summary

        System.out.println("Result summary: ");

        result = session.run( "PROFILE MATCH (p:Person { name: {name} }) RETURN id(p)",
                Values.parameters( "name", "Arthur" ) );

        ResultSummary summary = result.consume();

        System.out.println( summary.statementType() );
        System.out.println( summary.profile() );

//        Explain query and print notifications

        System.out.println("Explain query and print notifications: ");

        summary = session.run( "EXPLAIN MATCH (king), (queen) RETURN king, queen" ).consume();

        for ( Notification notification : summary.notifications() )
        {
            System.out.println( notification );
        }

//        Errors

        System.out.println("Errors: ");

/*
        try
        {
            session.run( "This will cause a syntax error" ).consume();
        }
        catch ( ClientException e )
        {
            throw new RuntimeException("Something really bad has happened!");
        }
*/

//        Cypher's CREATE clause to generate some nodes representing users and aliases

        result = session.run("CREATE (alice:User {username:'Alice'}), " +
                "(bob:User {username:'Bob'}), " +
                "(charlie:User {username:'Charlie'}), " +
                "(davina:User {username:'Davina'}), " +
                "(edward:User {username:'Edward'}), " +
                "(alice)-[:ALIAS_OF]->(bob)");

        result = session.run("MATCH  (bob:User {username:'Bob'}), " +
                "(charlie:User {username:'Charlie'}), " +
                "(davina:User {username:'Davina'}), " +
                "(edward:User {username:'Edward'}) " +
                "CREATE (bob)-[:EMAILED]->(charlie), " +
                "(bob)-[:CC]->(davina), " +
                "(bob)-[:BCC]->(edward)");

        result = session.run("CREATE (email_1:Email {id:'1', content:'Hi Charlie, ... Kind regards, Bob'})," +
                "(bob)-[:SENT]->(email_1)," +
                "(email_1)-[:TO]->(charlie)," +
                "(email_1)-[:CC]->(davina)," +
                "(email_1)-[:CC]->(alice)," +
                "(email_1)-[:BCC]->(edward)");

        result = session.run("CREATE (email_2:Email {id:'2', content:'Hi Davina, ... Kind regards, Bob'})," +
                "(bob)-[:SENT]->(email_2)," +
                "(email_2)-[:TO]->(davina)," +
                "(email_2)-[:BCC]->(edward);");

        result = session.run("CREATE (email_3:Email {id:'3', content:'Hi Bob, ... Kind regards, Davina'})," +
                "(davina)-[:SENT]->(email_3)," +
                "(email_3)-[:TO]->(bob)," +
                "(email_3)-[:CC]->(edward);");

        result = session.run("CREATE (email_4:Email {id:'4', content:'Hi Bob, ... Kind regards, Charlie'})," +
                "(charlie)-[:SENT]->(email_4)," +
                "(email_4)-[:TO]->(bob)," +
                "(email_4)-[:TO]->(davina)," +
                "(email_4)-[:TO]->(edward);");

        result = session.run("CREATE (email_5:Email {id:'5', content:'Hi Alice, ... Kind regards, Davina'})," +
                "(davina)-[:SENT]->(email_5)," +
                "(email_5)-[:TO]->(alice)," +
                "(email_5)-[:BCC]->(bob)," +
                "(email_5)-[:BCC]->(edward);");

        result = session.run( "MATCH (n) RETURN n" );

        //read from the nlp file and add connection
        String nlp_input = "...\\profiles_extracted\\zia-eqbali-eqbali-6891174a_NLP.txt";

//        result = session.run("CREATE (linkedinname:User {name:'zia-eqbali-eqbali-6891174a')");

        String linkedinname = "zia";

        String result_str = "CREATE ("+linkedinname+":User {linkedinname:'zia-eqbali-eqbali-6891174a'})";

        try (BufferedReader br = new BufferedReader(new FileReader(nlp_input))) {
            String line;
            while ((line = br.readLine()) != null) {
                if(!line.endsWith("ne:O") && !line.contains("ne:DATE") && !line.contains("ne:DURATION")) {
                    int word_index = line.indexOf("word: ");
                    int pos_index = line.indexOf("pos: ");
                    int ne_index = line.indexOf("ne:");

//                    System.out.println(line+" -> "+word_index+" : "+pos_index+" : "+ne_index);

                    String word = line.substring(word_index+6, pos_index-1);
                    String connection = line.substring(ne_index+3);

                    System.out.println("word: "+word+"; connection: "+connection);

                    result_str += ", ("+word+":Word {name:'"+word+"'})";
                    result_str += ", ("+linkedinname+")-[:"+connection+"]->("+word+")";
                }

                result = session.run(result_str);

//                System.out.println("result_str: "+result_str);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

//        session.run("DELETE a:Person");
//        session.run("DELETE weapon:Weapon");

        session.close();
        driver.close();
    }
}
