<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = "0";

    ArrayList<HashMap> contact_list_al = getContacts_FromRelationship_AL(user_id);

    HashMap contacts;

    Iterator<HashMap> iterator = contact_list_al.iterator();
    while (iterator.hasNext()) {
        contacts = iterator.next();
        String contact_name = (String)contacts.get("dec_name");
        String mobile_num = (String)contacts.get("dec_mobile");
        out.println(contact_name+"|"+mobile_num+"<br>");
    }
%>
