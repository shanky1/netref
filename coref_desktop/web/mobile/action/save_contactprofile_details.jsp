<%@include file="util.jsp" %>

<%
    String contactprofile_linkedin = request.getParameter("contactprofile_linkedin");
    String contactprofile_fb = request.getParameter("contactprofile_fb");
    String contactprofile_skills = request.getParameter("contactprofile_skills");
    String contact_user_id = request.getParameter("contact_user_id");

    String from_user_id = (String)session.getAttribute("user_id");

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    int status = addOrUpdateContactProfession(contact_user_id, contactprofile_linkedin,contactprofile_fb,contactprofile_skills);

    if(status > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }
%>
