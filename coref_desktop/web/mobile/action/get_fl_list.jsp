<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String friend_userid = request.getParameter("friend_userid");

    String msg = "";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = showFLList(friend_userid);
    }

    out.print(msg);
%>
