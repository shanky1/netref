<%@include file="util.jsp" %>

<%
    String raf_name = request.getParameter("raf_name");
    String raf_email = request.getParameter("raf_email");
    String raf_linkedin = request.getParameter("raf_linkedin");
    String raf_skills = request.getParameter("raf_skills");

    String from_user_id = (String)session.getAttribute("user_id");

    String profile_doc = "";
    String profile_doc_uploaded_time = "";

    if (from_user_id == null) {
        out.print("session_expired");
        return;
    }

    if(session.getAttribute("profile_doc") != null) {
        profile_doc = (String)session.getAttribute("profile_doc");
    }
    if(session.getAttribute("profile_doc_uploaded_time") != null) {
        profile_doc_uploaded_time = (String)session.getAttribute("profile_doc_uploaded_time");
    }
    //    http:// - false && true
//    https:// - true && false
//    linkedin.com - true & true
    if(raf_linkedin == null || raf_linkedin.trim().length() <= 0) {
        raf_linkedin = "";
    } else if (!raf_linkedin.startsWith("http://") && !raf_linkedin.startsWith("https://")) {
        raf_linkedin = "https://"+raf_linkedin;
    }

    int friend_user_id = insertFriendIfNotExists(raf_name, raf_email, raf_linkedin, raf_skills, profile_doc, profile_doc_uploaded_time);

    session.removeAttribute("profile_doc");
    session.removeAttribute("profile_doc_uploaded_time");

    if(friend_user_id > 0) {
        int status_save = addOrUpdateContactProfileDetails(friend_user_id+"", raf_linkedin, "", raf_skills);

        if(status_save > 0) {
            int status_suggest = referTeamMember(from_user_id, friend_user_id+"", raf_linkedin, raf_name, raf_skills, profile_doc, profile_doc_uploaded_time, "refer");

            if(status_suggest > 0) {
                out.print("success");
                return;
            } else {
                out.print("falied");
                return;
            }
        }
    }
    out.print("falied");
%>
