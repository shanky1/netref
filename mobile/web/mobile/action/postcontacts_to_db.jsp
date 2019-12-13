<%@ page import="org.json.simple.parser.JSONParser" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="java.util.Date" %>

<%@ include file="util.jsp"%>

<%
    String contactslist_json = request.getParameter("contactslist_json");

//    String user_id = (String)session.getAttribute("user_id");
    String user_id = request.getParameter("userId");

    if(user_id == null) {
        out.print("session_expired");
        return;
    }

//    System.out.println("***contactslist_json: "+contactslist_json);

    final String contactslist_json_final = contactslist_json;
    final String user_id_final = user_id;
    
    try {
        JSONParser parser = new JSONParser();

        Object obj = parser.parse(contactslist_json_final);
        JSONArray array = (JSONArray)obj;
        System.out.println(new Date()+"\t postcontacts_to_db("+user_id+") -> Posting "+array.size()+" contacts to db");

        boolean res = postContactsToDB(user_id_final, array);
    } catch(org.json.simple.parser.ParseException pe) {
        System.out.println(new Date()+"\t "+pe);
    }

    out.print("success");
%>
