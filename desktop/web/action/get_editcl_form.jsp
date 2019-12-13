<%@include file="../util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String fcm_id = request.getParameter("fcm_id");

    String msg = "failed";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = getCLdeetails(user_id,fcm_id);
    }

    out.print(msg);
%>
