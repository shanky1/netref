<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String activity_id = request.getParameter("activity_id");

    String msg = "failed";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = deletepost(user_id,activity_id);
    }

    out.print(msg);
%>
