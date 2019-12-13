<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    int no_of_contacts = getNumberOfContacts_FromRelationship(user_id);

    out.print(no_of_contacts);
%>
