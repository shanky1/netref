<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>
<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");
    String msg = "";

    if(user_id != null) {
        msg = gamification(user_id);
    }

    out.print(msg);
%>
