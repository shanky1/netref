<%@include file="util.jsp" %>

<%

    String user_id = (String)session.getAttribute("user_id");

    String domain_name = request.getParameter("domain_name");

    if (user_id == null) {
        out.print("session_expired");
        return;
    }
    int status_map = insert_domain_name(user_id, domain_name);


    if(status_map > 0) {
        out.print("success");
    } else {
        out.print("falied");
    }

%>
