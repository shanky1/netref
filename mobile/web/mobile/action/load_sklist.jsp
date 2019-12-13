<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
    }   else {
        msg = loadSKFriend();
    }

    out.print(msg);
%>
