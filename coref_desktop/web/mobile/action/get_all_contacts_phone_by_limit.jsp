<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
//    String message = getAllContacts_FromRelationship(user_id);

    String from_contact_str = request.getParameter("from_contact");
    String to_contact_str = request.getParameter("to_contact");

    int from_contact = 0;
    int to_contact = 0;

    if(from_contact_str != null) {
        try {
            from_contact = Integer.parseInt(from_contact_str);
        } catch (NumberFormatException nfe) {
            return;
        }
    }

    if(to_contact_str != null) {
        try {
            to_contact = Integer.parseInt(to_contact_str);
        } catch (NumberFormatException nfe) {
            return;
        }
    }

    org.json.JSONArray contact_list_json = getAllContacts_ByLimit_FromRelationship_JSON(user_id, from_contact, to_contact);

    if (contact_list_json != null) {
        out.print(contact_list_json);
    } else {
        out.print(contact_list_json);
    }
%>
