<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String from_user_id = (String)session.getAttribute("user_id");

    String fl_userid = request.getParameter("fl_userid");
    String fl_name = request.getParameter("fl_name");

    String msg = "";

    if(from_user_id == null) {
        msg = "session_expired";
    } else {
        msg = getClientsForFL(from_user_id, fl_userid, fl_name);
    }

    out.print(msg);
%>
