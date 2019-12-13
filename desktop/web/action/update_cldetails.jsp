<%@include file="../util.jsp" %>

<%
    String client_name = request.getParameter("client_name");
    String client_email = request.getParameter("client_email");
    String fcm_id_str = request.getParameter("fcm_id");
    String user_id = (String)session.getAttribute("user_id");
    String status_msg = request.getParameter("status_msg");
//    System.out.println("9879: "+status_msg);

    String status = "";

    if(user_id == null) {
        status = "session_expired";
        out.print(status);
        return;
    } else {
        status = updateCLdetails(client_name, client_email, fcm_id_str, user_id);
    }

    if (status == null) {
        out.print("<font color='red'>Could not update client details. Please try again</font>");
        return;
    } else if (status.startsWith("failed:")) {
        out.print("<font color='red'>"+status.replace("failed:","")+"</font>");
        return;
    } else if (status.startsWith("success:")) {
        int fcm_id = Integer.parseInt(fcm_id_str);
        String res = getStringForClients(user_id, client_name, client_email, fcm_id, status_msg);

        out.print(res);
    }
%>
