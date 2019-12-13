<%@include file="util.jsp" %>

<%
    String contact_user_id = request.getParameter("contact_user_id");
    String contact_name = request.getParameter("contact_name");

    String user_id = (String)session.getAttribute("user_id");

    if(user_id == null) {
        out.print("session_expired");
    } else {
        int status = removeEmployeeForUser(user_id, contact_user_id);

        out.print(status);
    }
%>
