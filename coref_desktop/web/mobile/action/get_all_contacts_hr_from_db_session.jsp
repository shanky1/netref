<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String updated_flag = (String)session.getAttribute("updated_flag");

    boolean load_contacts_from_session = false;

    org.json.JSONArray contact_list_all_json;

    //IF user session expired
    if (user_id == null) {
        contact_list_all_json = new org.json.JSONArray();
        out.print(contact_list_all_json);
        return;
    }

//    System.out.println(new Date()+"\t updated_flag: "+updated_flag);

    //Get the list of contacts from session
    ArrayList contact_list_all_al = (ArrayList)session.getAttribute("contact_list_all_al_"+user_id);

    //IF contacts session cleared, reset the arraylist and max relationship id to load all contacts from database
    if((updated_flag != null && updated_flag.equalsIgnoreCase("true")) || contact_list_all_al == null) {
        load_contacts_from_session = false;
    } else {
        load_contacts_from_session = true;
    }

    if(load_contacts_from_session) {
        //Convert contacts list from session to the json format and return
        contact_list_all_json = new org.json.JSONArray(contact_list_all_al);

        System.out.println(new Date()+"\t Returning "+contact_list_all_al.size()+" contacts from session");

        out.print(contact_list_all_json);
    } else {
        session.removeAttribute("updated_flag");
        ArrayList contact_list_al = getContacts_FromRelationship_AL(user_id);

        session.setAttribute("contact_list_all_al_"+user_id, contact_list_al);

        //Convert contacts list from database to the json format and return
        contact_list_all_json = new org.json.JSONArray(contact_list_al);

        System.out.println(new Date()+"\t Returning "+contact_list_al.size()+" contacts from DB");

        out.print(contact_list_all_json);
    }
%>
