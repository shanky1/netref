<%@include file="util.jsp" %>

<%
    String activity_id = request.getParameter("activity_id");
    String like_status = "1";

    System.out.println("123");
    String user_id = (String)session.getAttribute("user_id");

    int post_ststus = post_like_insert(user_id, activity_id, like_status);

    if(post_ststus > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }
%>
