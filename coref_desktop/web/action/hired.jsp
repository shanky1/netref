<%@include file="util.jsp" %>

<%
    String activity_id = request.getParameter("activity_id");
    String user_id = (String)session.getAttribute("user_id");

    int post_ststus = 0;

    if(user_id == null) {
        out.print("session_expired");
        return;
    } else {
        post_ststus = candidatehired(activity_id);

        String activity_numbers = getNumbers_ForActivity(activity_id);     //Get likes, dislikes and number of comments

        if(post_ststus > 0) {
            out.print(activity_numbers);
            return;
        }
    }
    out.print("falied");
%>
