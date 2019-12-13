<%@include file="util.jsp" %>

<%

    String rs_id = request.getParameter("rs_id");
    String user_id = (String)session.getAttribute("user_id");
//    System.out.println(freelancer_name+" "+freelancer_email+" "+fcm_id);

    int status = deleteConcatDetails(rs_id);

    if(status > 0) {
        session.setAttribute("updated_flag","true");
    }

    out.print(status);
%>
