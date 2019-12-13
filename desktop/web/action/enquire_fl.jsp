<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../util.jsp" %>

<%
    String emailid = (String)session.getAttribute("email");
    String user_id = (String)session.getAttribute("user_id");

    String fl_userid = request.getParameter("fl_userid");

    String comments = "Has anyone in your network used this freelancer? Do you recommend?";

    String post_type = "enquire";

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = postEnquiriesInNetwork(user_id, fl_userid, post_type, comments);
    }

    out.print(status);
%>
