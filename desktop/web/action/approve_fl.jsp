<%@include file="../util.jsp" %>

<%
    String fcm_id = request.getParameter("fcm_id");
    String user_id = (String)session.getAttribute("user_id");

    String msg = "failed";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = approveFL(fcm_id);
    }

    out.print(msg);
%>
