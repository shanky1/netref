<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String comments = request.getParameter("comments");

    String post_type = "asks";

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = postCommentsInNetwork(user_id, "-1", post_type, comments);
    }

    out.print(status);
%>
