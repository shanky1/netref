package com.cim;

import org.neo4j.driver.v1.*;
import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.util.Date;

public class CIMUtil {
    public static void cleanup_TotalGDB(Session session) {
        StatementResult result = session.run("MATCH (n) " +
                "OPTIONAL MATCH (n)-[r]-() " +
                "DELETE n,r");
    }

    public static void linSimple_ReadFiles_InsertIntoGDB_OLD(Session ses, String lin_simple_profiles_parsed_dir) {
        File folder = null;

        try {
            folder = new File(lin_simple_profiles_parsed_dir);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    linSimple_InsertIntoGDB_OLD(ses, file_path);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void linSimple_InsertIntoGDB_OLD(Session ses, String file_input) {
        try  {
            String line;
            String text = "";
            String node = "";
            int name_entity_id = -1;

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(!line.startsWith("---")) {
                    if(line.endsWith(" : ")) {
                        node = line.split(":")[0].trim();
                    } else {
                        if(!line.contains("N/A")) {
                            text += line.trim()+"===";      //adding === to represent new line
                        }
                    }
                } else {
                    if(text.length() > 0) {
                        if(node.equalsIgnoreCase("name")) {
                            name_entity_id = addEntity_ForName(ses, "PERSON", text);
                        } else {
                            addEntity_ForOthers(ses, node, text, name_entity_id);
                        }
                    }
                    text = "";                          //reset para to empty
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void linSimple_ReadFiles_InsertIntoGDB(Session ses, String lin_simple_profiles_parsed_dir, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(lin_simple_profiles_parsed_dir);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    String fileName = fileEntry.getName();

                    int pos = fileName.lastIndexOf(".");
                    if (pos > 0) {
                        fileName = fileName.substring(0, pos);
                        fileName = fileName.replaceAll("lin_","");
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    linSimple_InsertIntoGDB(ses, file_path, fileName, shankar_name_entity_id);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void linSimple_InsertIntoGDB(Session ses, String file_path, String fileName, int shankar_name_entity_id) {
        try  {
            String line;
            String text = "";
            String node = "";
            int name_entity_id = -1;

            name_entity_id = addEntity_ForName(ses, "PERSON", fileName);        //fileName, we are using as value for the PERSON entity

            mapConnectionBetween2Entities(ses, shankar_name_entity_id, name_entity_id);

            BufferedReader br = new BufferedReader(new FileReader(file_path));

            while ((line = br.readLine()) != null) {
                if(!line.startsWith("---")) {
                    if(line.endsWith(" : ")) {
                        node = line.split(":")[0].trim();
                    } else {
                        if(!line.contains("N/A")) {
                            text += line.trim()+"===";      //adding === to represent new line
                        }
                    }
                } else {
                    if(text.length() > 0) {
/*
                        if(node.equalsIgnoreCase("name")) {
                            name_entity_id = addEntity_ForName(ses, "PERSON", text);
                        } else {
                            addEntity_ForOthers(ses, node, text, name_entity_id);
                        }
*/
                        addEntity_ForOthers(ses, "SI_"+node, text, name_entity_id);
                    }
                    text = "";                          //reset para to empty
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void linNLP_ReadFiles_InsertIntoGDB(Session ses, String lin_nlp_profiles_parsed_dir, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(lin_nlp_profiles_parsed_dir);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    String fileName = fileEntry.getName();

                    int pos = fileName.lastIndexOf(".");
                    if (pos > 0) {
                        fileName = fileName.substring(0, pos);
                        fileName = fileName.replaceAll("lin_","");
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    linNLP_InsertIntoGDB(ses, file_path, fileName, shankar_name_entity_id);

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void linNLP_InsertIntoGDB(Session ses, String file_input, String fileName, int shankar_name_entity_id) {
        try  {
            String line;
            String text = "";
            String node = "";
            int name_entity_id = -1;

            name_entity_id = addEntity_ForName(ses, "PERSON", fileName);        //fileName, we are using as value for the PERSON entity

            mapConnectionBetween2Entities(ses, shankar_name_entity_id, name_entity_id);

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(!line.endsWith("O")) {
                    try {
                        String[] line_split = line.split(",");

                       /* if(line_split.length != 2) {
                            continue;
                        }*/
                        String keyword = "Entity";
                        int index = line.indexOf(keyword);
                        text = line.substring(0, index).replaceAll("word:","");
						node = line.substring(index).replaceAll("Entity Type:","");
													
                        //text = line_split[0].trim().split(":")[1].trim();
                        //node = line_split[1].trim().split(":")[1].trim();

                        System.out.println(new Date() + "\t node = " + node + ", text: "+text);

                        if(node.length() > 0 && text.length() > 0) {
                            addEntity_ForOthers(ses, node, text, name_entity_id);
                        }
                    } catch (Exception e) {
                        //TODO
                        e.printStackTrace();
                    }
                }
                text = "";                          //reset para to empty

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void fbNLP_ReadFiles_InsertIntoGDB(Session ses, String fb_nlp_profiles_parsed_dir, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(fb_nlp_profiles_parsed_dir);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    String fileName = fileEntry.getName();

                    int pos = fileName.lastIndexOf(".");
                    if (pos > 0) {
                        fileName = fileName.substring(0, pos);
                        fileName = fileName.replaceAll("fac_","");
                    }

                    //                 System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    fbNLP_InsertIntoGDB(ses, file_path, fileName, shankar_name_entity_id);

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void fbNLP_InsertIntoGDB(Session ses, String file_input, String fileName, int shankar_name_entity_id) {
        try  {
            String line;
            String text = "";
            String node = "";
            int name_entity_id = -1;

            name_entity_id = addEntity_ForName(ses, "PERSON", fileName);        //fileName, we are using as value for the PERSON entity

            mapConnectionBetween2Entities(ses, shankar_name_entity_id, name_entity_id);

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(!line.endsWith("O")) {
                    try {
                        String[] line_split = line.split(",");

                       /* if(line_split.length != 2) {
                            continue;
                        }*/
                        String keyword = "Entity";
                        int index = line.indexOf(keyword);
                        text = line.substring(0, index).replaceAll("word:","");
                        node = line.substring(index).replaceAll("Entity Type:","");

                        System.out.println(new Date() + "\t node = " + node + ", text: "+text);

                        if(node.length() > 0 && text.length() > 0) {
                            addEntity_ForOthers(ses, node, text, name_entity_id);
                        }
                    } catch (Exception e) {
                        //TODO
                        e.printStackTrace();
                    }
                }
                text = "";                          //reset para to empty

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void outlook_Inbox_ReadFiles_InsertIntoGDB(Session ses, String ol_inbox_dir_path, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(ol_inbox_dir_path);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    outlook_Inbox_InsertIntoGDB(ses, file_path, shankar_name_entity_id);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void outlook_Inbox_InsertIntoGDB(Session ses, String file_input, int shankar_name_entity_id) {
        try  {
            String line;

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(line.startsWith("Inbox item:")) {
                    try {
                        String[] split_line = line.split("\\|\\|");

                        String date = split_line[1].split(":")[1].trim();
                        String from = split_line[2].split(":")[1].trim();
                        String cc = split_line[3].split(":")[1].trim();

                        int from_start_index = from.indexOf("[");
                        int from_end_index = from.indexOf("]");

                        String from_name = from.substring(0, from_start_index).trim();
                        String from_email = (from.substring(from_start_index+1, from_end_index)).trim().toLowerCase();

                        if(from_email != null && from_email.trim().length() > 0) {
//                            System.out.println("addContactEntity -> from: "+from+" - "+shankar_name_entity_id);
                            addContactEntity(ses, "MAIL_CONTACT", from_name, from_email, shankar_name_entity_id);
                        }

                        String[] cc_split = cc.split(";");

                        for(int j = 0; j < cc_split.length; j++) {
                            try {
                                String cc_ = cc_split[j].replaceAll("<","[").replaceAll(">","]");

                                if(cc_ != null && cc_.trim().length() > 0 && cc_.contains("[") && cc_.contains("]")) {
                                    int cc_start_index = cc_.indexOf("[");
                                    int cc_end_index = cc_.indexOf("]");

                                    String cc_name = cc_.substring(0, cc_start_index).trim();
                                    String cc_email = cc_.substring(cc_start_index+1, cc_end_index).trim().toLowerCase();

                                    if(cc_email != null && cc_email.trim().length() > 0) {
//                                    System.out.println("addContactEntity -> cc_: "+cc_+" - "+shankar_name_entity_id);
                                        addContactEntity(ses, "MAIL_CONTACT", cc_name, cc_email, shankar_name_entity_id);
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void gmail_Inbox_ReadFiles_InsertIntoGDB(Session ses, String gmail_inbox_dir_path, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(gmail_inbox_dir_path);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    gmail_Inbox_InsertIntoGDB(ses, file_path, shankar_name_entity_id);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void gmail_Inbox_InsertIntoGDB(Session ses, String file_input, int shankar_name_entity_id) {
        try  {
            String line;

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                if(line.startsWith("From:")) {
                    try {
                        String[] split_line = line.split("\\|\\|");
                        String from = split_line[0].split(":")[1].trim();
                        String cc = split_line[1].split(":")[1].trim();
                        String date = split_line[2].split(":")[1].trim();

                        int from_start_index = from.indexOf("[");
                        int from_end_index = from.indexOf("]");

                        String from_name = from.substring(0, from_start_index).trim();
                        String from_email = (from.substring(from_start_index+1, from_end_index)).trim().toLowerCase();

                        if(from_email != null && from_email.trim().length() > 0) {
//                            System.out.println("addContactEntity -> from: "+from+" - "+shankar_name_entity_id);
                            addContactEntity(ses, "MAIL_CONTACT", from_name, from_email, shankar_name_entity_id);
                        }

                        String[] cc_split = cc.split(",");

                        for(int j = 0; j < cc_split.length; j++) {
                            try {
                                String cc_ = cc_split[j].replaceAll("<","[").replaceAll(">","]");

                                if(cc_ != null && cc_.trim().length() > 0 && cc_.contains("[") && cc_.contains("]")) {
                                    int cc_start_index = cc_.indexOf("[");
                                    int cc_end_index = cc_.indexOf("]");

                                    String cc_name = cc_.substring(0, cc_start_index).trim();
                                    String cc_email = (cc_.substring(cc_start_index+1, cc_end_index)).trim().toLowerCase();

                                    if(cc_email != null && cc_email.trim().length() > 0) {
//                                    System.out.println("addContactEntity -> cc_: "+cc_+" - "+shankar_name_entity_id);
                                        addContactEntity(ses, "MAIL_CONTACT", cc_name, cc_email, shankar_name_entity_id);
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void company_simple_ReadFiles_InsertIntoGDB(Session ses, String comp_nlp_profiles_parsed_dir) {
        File folder = null;

        try {
            folder = new File(comp_nlp_profiles_parsed_dir);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    String fileName = fileEntry.getName();

                    int pos = fileName.lastIndexOf(".");
                    if (pos > 0) {
                        fileName = fileName.substring(0, pos);
                        fileName = fileName.replaceAll("lin_","");
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    company_simple_InsertIntoGDB(ses, file_path, fileName);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void company_simple_InsertIntoGDB(Session ses, String file_input, String fileName) {
        try  {
            String line;
            String node = "SPECIALITIES";
            int name_entity_id = -1;

            name_entity_id = addEntity_ForName(ses, "COMPANY", fileName);        //fileName, we are using as value for the COMPANY entity

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            String specialities = "";

            while ((line = br.readLine()) != null) {
                try {
                    specialities += line.trim()+" ";
                } catch (Exception e) {
                    //TODO
                    e.printStackTrace();
                }
            }

            System.out.println("node: "+node+", specialities: "+specialities);

            if(specialities.length() > 0) {
                addEntity_ForOthers(ses, node, specialities, name_entity_id);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void netref_contacts_ReadFiles_InsertIntoGDB(Session ses, String nr_contacts_dir_path, int shankar_name_entity_id) {
        File folder = null;

        try {
            folder = new File(nr_contacts_dir_path);

            for (final File fileEntry : folder.listFiles()) {
                if (fileEntry.isDirectory()) {
                    //skip sub folder
                } else {
                    String file_path = fileEntry.getAbsolutePath();

                    if(!file_path.endsWith(".txt")) {
                        continue;
                    }

                    System.out.println("----\n"+new java.util.Date()+"\t Reading from: "+file_path);

                    netref_contacts_InsertIntoGDB(ses, file_path, shankar_name_entity_id);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void netref_contacts_InsertIntoGDB(Session ses, String file_input, int shankar_name_entity_id) {
        try  {
            String line;

            BufferedReader br = new BufferedReader(new FileReader(file_input));

            while ((line = br.readLine()) != null) {
                try {
                    String[] split_line = line.split("\\|");

                    String contact_name = split_line[0].trim();
                    String contact_num = split_line[1].trim();

                    if(contact_name != null && contact_name.trim().length() > 0) {
//                            System.out.println("addContactEntity -> from: "+from+" - "+shankar_name_entity_id);
                        addNRContactEntity(ses, "NR_CONTACT", contact_name, contact_num, shankar_name_entity_id);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static int addEntity_ForName(Session ses, String node, String text) {
        int shankar_name_entity_id = -1;
        node = node.replaceAll(" ","");
        text = text.trim();

        ses.run("MERGE (" + node + ":" + node + " {value: {value}})", Values.parameters("value", text));

        StatementResult result = ses.run( "MATCH (a:"+node+" {value: {value}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "value", text) );

        while (result.hasNext() ) {
            Record record = result.next();
            shankar_name_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ shankar_name_entity_id+", node: "+node+", value: "+ record.get( "value" ).asString());
        }

        System.out.println(new java.util.Date()+"\t Successfully created the Entity for: "+node+", id: "+shankar_name_entity_id);

        return shankar_name_entity_id;
    }

    static void addEntity_ForOthers(Session ses, String node, String para, int name_entity_id) {
        int other_entity_id = -1;
        node = node.replaceAll(" ","");
        para = para.trim();

        ses.run("MERGE (" + node + ":" + node + " {value: {para}})", Values.parameters("para", para));

        StatementResult result = ses.run( "MATCH (a:"+node+" {value: {para}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "para", para) );

        while (result.hasNext() ) {
            Record record = result.next();
            other_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ other_entity_id+", node: "+node+", value: "+ record.get( "value" ).asString());
        }

        System.out.println(new java.util.Date()+"\t Successfully created the Entity for: "+node+", parent_id: "+name_entity_id+", id: "+other_entity_id);

        result = ses.run( "MATCH (a), (b) " +
                "WHERE ID(a) = "+name_entity_id+" AND ID(b) = "+other_entity_id+" " +
                "CREATE UNIQUE (a)-[:"+node+"]->(b)" );
    }

    static void addContactEntity(Session ses, String node, String from_or_cc_name, String from_or_cc_email, int name_entity_id) {
        int other_entity_id = -1;
        node = node.replaceAll(" ","");
        from_or_cc_email = from_or_cc_email.trim();

        StatementResult match_email = ses.run("MATCH (a:" + node + " {value: {from_or_cc}}) RETURN ID(a) AS id", Values.parameters("from_or_cc", from_or_cc_email));

        if(!match_email.hasNext()) {
            System.out.println("match_email does not exists: "+from_or_cc_email+". Creating entity...");
            ses.run("CREATE (" + node + ":" + node + " {value: {from_or_cc_email}, name: {from_or_cc_name}})", Values.parameters("from_or_cc_email", from_or_cc_email, "from_or_cc_name", from_or_cc_name));
        } else {
            System.out.println("match_email exists: "+from_or_cc_email+". Do not re-create entity...");
        }

        StatementResult result = ses.run( "MATCH (a:"+node+" {value: {from_or_cc_email}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "from_or_cc_email", from_or_cc_email));

        while (result.hasNext() ) {
            Record record = result.next();
            other_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ other_entity_id+", node: "+node+", value: "+ record.get( "value" ).asString());
        }

//        System.out.println(new java.util.Date()+"\t Successfully created the E&R for: "+from_or_cc_email+", parent_id: "+name_entity_id+", id: "+other_entity_id);

        String query = "MATCH (a), (b) " +
                "WHERE ID(a) = "+name_entity_id+" AND ID(b) = "+other_entity_id+" " +
                "CREATE UNIQUE (a)-[:"+node+"]->(b)";

        System.out.println("query: "+query);

        result = ses.run(query);
    }

    static void addNRContactEntity(Session ses, String node, String contact_name, String contact_num, int name_entity_id) {
        int other_entity_id = -1;
        node = node.replaceAll(" ","");
        contact_name = contact_name.trim();
        contact_num = contact_num.trim();

        StatementResult match_email = ses.run("MATCH (a:" + node + " {value: {contact_name}}) RETURN ID(a) AS id",
                Values.parameters("contact_name", contact_name));

        if(!match_email.hasNext()) {
            System.out.println("NR_CONTACT does not exists: "+contact_name+". Creating entity...");
            ses.run("CREATE (" + node + ":" + node + " {number: {contact_num}, value: {contact_name}})", Values.parameters("contact_name", contact_name, "contact_num", contact_num));
        } else {
            System.out.println("NR_CONTACT exists: "+contact_name+". Do not re-create entity...");
        }

        StatementResult result = ses.run( "MATCH (a:"+node+" {value: {contact_name}}) RETURN ID(a) AS id, a.value AS value",
                Values.parameters( "contact_name", contact_name));

        while (result.hasNext() ) {
            Record record = result.next();
            other_entity_id = record.get( "id" ).asInt();
//            System.out.println("Id: "+ other_entity_id+", node: "+node+", value: "+ record.get( "value" ).asString());
        }

//        System.out.println(new java.util.Date()+"\t Successfully created the E&R for: "+from_or_cc_email+", parent_id: "+name_entity_id+", id: "+other_entity_id);

        String query = "MATCH (a), (b) " +
                "WHERE ID(a) = "+name_entity_id+" AND ID(b) = "+other_entity_id+" " +
                "CREATE UNIQUE (a)-[:"+node+"]->(b)";

//        System.out.println("query: "+query);

        result = ses.run(query);
    }

    static void mapConnectionBetween2Entities(Session ses, int name_entity_id1, int name_entity_id2) {
        StatementResult result = ses.run( "MATCH (a), (b) " +
                "WHERE ID(a) = "+name_entity_id1+" AND ID(b) = "+name_entity_id2+" " +
                "CREATE UNIQUE (a)-[:CONNECTION]->(b)" );
    }

    public static void main(String args[]) {
        String gdbDriver_url = "bolt://localhost";
        String gdbDriver_username = "neo4j";
        String gdbDriver_password = "saneo4j";

        String ol_inbox_dir_path = "F:\\satya_code\\cim\\data\\outlook\\inbox";
        String gmail_inbox_dir_path = "F:\\satya_code\\cim\\data\\gmail\\inbox";
        String lin_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_nlp_profiles_parsed";
        String fb_nlp_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\fb_nlp_profiles_parsed";
        String lin_simple_profiles_parsed_dir = "F:\\satya_code\\cim\\data\\lin_simple_profiles_parsed";

        Driver driver = GraphDatabase.driver(gdbDriver_url, AuthTokens.basic(gdbDriver_username, gdbDriver_password));
        Session ses = driver.session();

        CIMUtil.cleanup_TotalGDB(ses);
        int entity_id = CIMUtil.addEntity_ForName(ses, "PERSON", "Shankar Kondur");
        int entity_id_hc = 49014;

        CIMUtil.outlook_Inbox_ReadFiles_InsertIntoGDB(ses, ol_inbox_dir_path, entity_id);
        CIMUtil.gmail_Inbox_ReadFiles_InsertIntoGDB(ses, gmail_inbox_dir_path, entity_id);
        CIMUtil.linSimple_ReadFiles_InsertIntoGDB(ses, lin_simple_profiles_parsed_dir, entity_id);
        CIMUtil.linNLP_ReadFiles_InsertIntoGDB(ses, lin_nlp_profiles_parsed_dir, entity_id);
        CIMUtil.fbNLP_ReadFiles_InsertIntoGDB(ses, fb_nlp_profiles_parsed_dir, entity_id);

        ses.close();
        driver.close();
    }
}
