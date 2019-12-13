<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String updated_flag = (String)session.getAttribute("updated_flag");

//    int DB_MAX_RS_ID = 0;
    boolean load_contacts_from_session = false;

    org.json.JSONArray contact_list_remaining_json;

    //IF user session expired
    if (user_id == null) {
        contact_list_remaining_json = new org.json.JSONArray();
        out.print(contact_list_remaining_json);
        return;
    }

//    System.out.println(new Date()+"\t DB_MAX_RS_ID: "+DB_MAX_RS_ID+", updated_flag: "+updated_flag);
//    System.out.println(new Date()+"\t updated_flag: "+updated_flag);

    //Get the list of contacts from session
    ArrayList contact_list_remaining_al = (ArrayList)session.getAttribute("contact_list_remaining_al_"+user_id);

    //IF contacts session cleared, reset the arraylist and max relationship id to load all contacts from database
    if((updated_flag != null && updated_flag.equalsIgnoreCase("true")) || contact_list_remaining_al == null) {
        load_contacts_from_session = false;
    } else {
        load_contacts_from_session = true;
    }

    if(load_contacts_from_session) {
        //Convert contacts list from session to the json format and return
        contact_list_remaining_json = new org.json.JSONArray(contact_list_remaining_al);

        System.out.println(new Date()+"\t Returning "+contact_list_remaining_al.size()+" contacts from session");

        out.print(contact_list_remaining_json);
    } else {
        session.removeAttribute("updated_flag");
        contact_list_remaining_al = new ArrayList();
        ArrayList contact_list_remaining = getRemainingContacts_FromRelationship_AL(user_id);

        //Append newly read contacts from database to the existing contacts retrieved from session
        contact_list_remaining_al.addAll(contact_list_remaining);

        session.setAttribute("contact_list_remaining_al_"+user_id, contact_list_remaining_al);

        //Convert contacts list from database to the json format and return
        contact_list_remaining_json = new org.json.JSONArray(contact_list_remaining);

        System.out.println(new Date()+"\t Returning "+contact_list_remaining.size()+" contacts from DB");

        out.print(contact_list_remaining_json);
    }
%>
