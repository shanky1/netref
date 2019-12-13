<%@include file="../util.jsp" %>

<%
    String freelancer_name = request.getParameter("freelancer_name");
    String freelancer_email = request.getParameter("freelancer_email");
    String fcm_id_str = request.getParameter("fcm_id");
    String user_id = (String)session.getAttribute("user_id");
    String status_msg = request.getParameter("status_msg");
//    System.out.println(freelancer_name+" "+freelancer_email+" "+fcm_id);

    String status = "";

    if(user_id == null) {
        status = "session_expired";
        out.print(status);
        return;
    } else {
        status = updateFLdetails(freelancer_name, freelancer_email, fcm_id_str, user_id);
    }

    if (status == null) {
        out.print("<font color='red'>Could not update freelancer details. Please try again</font>");
        return;
    } else if (status.startsWith("failed:")) {
        out.print("<font color='red'>"+status.replace("failed:","")+"</font>");
        return;
    } else if (status.startsWith("success:")) {
        int fcm_id = Integer.parseInt(fcm_id_str);
        String res = getStringForFLs(user_id, freelancer_name, freelancer_email, fcm_id, status_msg);

        out.print(res);
    }
%>
