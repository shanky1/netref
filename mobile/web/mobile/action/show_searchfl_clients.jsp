<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String fl_userid = request.getParameter("fl_userid");

    String msg = "";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = getClientsForSearchFL(fl_userid, user_id);
    }

    out.print(msg);
%>
