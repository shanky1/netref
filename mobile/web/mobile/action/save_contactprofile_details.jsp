<%@include file="util.jsp" %>

<%
    String contactprofile_profession = request.getParameter("contactprofile_profession");
    String contact_user_id = request.getParameter("contact_user_id");

    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    int status = addOrUpdateContactProfession(contact_user_id, contactprofile_profession);

    if(status > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }
%>
