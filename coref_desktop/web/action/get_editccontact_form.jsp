<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");
    String contact_user_id = request.getParameter("contact_user_id");

    String msg = "failed";

    if(user_id == null) {
        msg = "session_expired";
    } else {
        msg = getContactDetails(contact_user_id);
    }

    out.print(msg);
%>
