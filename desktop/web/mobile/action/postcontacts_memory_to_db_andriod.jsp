<%@ page import="java.util.Date" %>
<%@ page import="org.json.simple.parser.JSONParser" %>
<%@ page import="org.json.simple.JSONArray" %>

<%@ include file="util.jsp"%>

<%
    String user_id = (String)session.getAttribute("user_id");

    String contactslist_json = (String)request.getAttribute("mobile_contactslist_json");

/*
    //TODO, find the correct way of waiting for contacts, if contacts are not available yet. safe check
    for(int i = 0; i < 5; i++) {
        if(contactslist_json == null) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            contactslist_json = (String)request.getAttribute("mobile_contactslist_json");
        } else {
            break;
        }
    }
*/

    if(contactslist_json == null) {
        out.print("could_not_find_contacts_from_android");
        return;
    }

    if(user_id == null) {
        out.print("session_expired");
        return;
    }

    final String contactslist_json_final = contactslist_json;
    final String user_id_final = user_id;

    Thread thread = new Thread(new Runnable() {
        //        @Override
        public void run() {

            try {
                JSONParser parser = new JSONParser();

                Object obj = parser.parse(contactslist_json_final);
                JSONArray array = (JSONArray)obj;
                System.out.println(new Date()+"\t postcontacts_memory_to_db_android("+user_id_final+") -> Posting "+array.size()+" contacts to db");

                if(array.size() > 0) {
                    System.out.println(new Date()+"\t Start postContactsToDB");
                    boolean res1 = postContactsToDB(user_id_final, array);
                    System.out.println(new Date()+"\t End postContactsToDB");

                    System.out.println(new Date()+"\t Start updateReadContactsStatusToDB");
                    boolean res2 = updateReadContactsStatusToDB(user_id_final);
                    System.out.println(new Date()+"\t End updateReadContactsStatusToDB");
                }
            } catch(org.json.simple.parser.ParseException pe) {
                System.out.println(new Date()+"\t "+pe);
            }
        }
    });

    thread.start();

    out.print("success");
%>
