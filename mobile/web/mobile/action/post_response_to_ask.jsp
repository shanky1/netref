<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");
    String pros_userid = request.getParameter("pros_userid");
    String comments = request.getParameter("comments");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = postResponseToAsk(user_id, pros_userid, activity_id, comments);
    }

    out.print(status);
%>
