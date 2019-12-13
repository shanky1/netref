<%@include file="../util.jsp" %>

<%
    String fcm_id = request.getParameter("fcm_id");
    String user_id = (String)session.getAttribute("user_id");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
        out.print(status);
        return;
    } else {
        status = deleteCLdetails(fcm_id);
    }

    if(status != null && status.equals("success")) {
        status = "<font color='blue'>Successfully deleted the client</font>";
    } else if(status != null) {
        status = "<font color='red'>Could not delete the client. Please try again</font>";
    }

    out.print(status);
%>
