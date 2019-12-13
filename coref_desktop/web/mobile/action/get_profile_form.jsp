<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String from = request.getParameter("from");

    String msg = "failed";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = getProfileDetails(user_id, from);
    }

    out.print(msg);
%>
