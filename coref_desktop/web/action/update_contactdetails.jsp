<%@include file="util.jsp" %>

<%
    String contact_name = request.getParameter("contact_name");
    String contact_email = request.getParameter("contact_email");
    String contact_user_id = request.getParameter("contact_user_id");
    String user_id = (String)session.getAttribute("user_id");
    String status_msg = request.getParameter("status_msg");
    String status = "";

    if(user_id == null) {
        status = "session_expired";
        out.print(status);
        return;
    } else {
        status = updateContactdetails(contact_name, contact_email, contact_user_id, user_id);
    }

    if (status == null) {
        out.print("<font color='red'>Could not update contact details. Please try again</font>");
        return;
    } else if (status.startsWith("success:")) {

        out.print("success");
    }
%>
