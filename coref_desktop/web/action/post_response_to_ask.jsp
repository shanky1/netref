<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String activity_id = request.getParameter("activity_id");
    String comments = request.getParameter("comments");

    int post_ststus = 0;

    if(user_id == null) {
        out.print("session_expired");
        return;
    } else {
        boolean ipns = isProfileNameSet(user_id);

        if(ipns) {
            post_ststus = postResponse_ForPost(user_id, activity_id, comments);

            String activity_numbers = getNumbers_ForActivity(activity_id);     //Get likes, dislikes and number of comments

            if(post_ststus > 0) {
                out.print(activity_numbers);
                return;
            }
        } else {
            out.print("profile_name_not_set");
            return;
        }
    }
    out.print("falied");
%>
