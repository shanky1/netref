<%@include file="util.jsp" %>

<%
    String from_user_id = (String)session.getAttribute("user_id");
    String lin_publicProfileUrl = (String)session.getAttribute("lin_publicProfileUrl");

    if(from_user_id == null) {
        out.print("session_expired");
    } else {
        ArrayList profile_details_al = getProfileDetails_AL(from_user_id, lin_publicProfileUrl);

        org.json.JSONArray friends_list_json = new org.json.JSONArray(profile_details_al);

        out.print(friends_list_json);
    }
%>
