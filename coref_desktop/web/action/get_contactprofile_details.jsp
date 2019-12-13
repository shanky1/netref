<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");
    String contact_user_id = request.getParameter("contact_user_id");
    String message = "";

    if(from_user_id == null) {
        out.print("session_expired");
        return;
    }

    message = getProfileDetails(contact_user_id);

    if (message != null) {
        out.print(message);
    } else {
        out.print(message);
    }
%>
