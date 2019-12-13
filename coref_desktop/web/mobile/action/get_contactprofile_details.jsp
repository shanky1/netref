<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");
    String contact_user_id = request.getParameter("contact_user_id");

    if(from_user_id == null) {
        out.print("session_expired");
    } else {
        ArrayList profile_details_al = getProfileDetails_AL(contact_user_id, "");

        org.json.JSONArray friends_list_json = new org.json.JSONArray(profile_details_al);

        out.print(friends_list_json);
    }
%>
