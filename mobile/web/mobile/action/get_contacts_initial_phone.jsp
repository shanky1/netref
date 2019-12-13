<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");

    org.json.JSONArray contact_list_initial_json;

    //IF user session expired
    if (from_user_id == null) {
//        contact_list_initial_json = new org.json.JSONArray();
//        out.print(contact_list_initial_json);
        out.print("session_expired");
        return;
    }

    //Get the list of contacts from session
/*
    ArrayList contact_list_initial_al = (ArrayList)session.getAttribute("contact_list_initial_"+user_id);

    if(contact_list_initial_al != null && contact_list_initial_al.size() == SET_CONTACTS_INITIAL_LOADING_LIMIT) {
        contact_list_initial_json = new org.json.JSONArray(contact_list_initial_al);
    } else {
        contact_list_initial_al = getInitialContacts_FromRelationship_AL(user_id);
        contact_list_initial_json = new org.json.JSONArray(contact_list_initial_al);
    }
*/
    // Always get it from database
    ArrayList contact_list_initial_al = getInitialContacts_FromRelationship_AL(from_user_id);
    contact_list_initial_json = new org.json.JSONArray(contact_list_initial_al);

    if (contact_list_initial_json != null) {
        session.setAttribute("contact_list_initial_" + from_user_id, contact_list_initial_al);
    }
    out.print(contact_list_initial_json);
%>
