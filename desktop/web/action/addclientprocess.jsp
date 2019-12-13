<%@include file="../util.jsp" %>

<%
    String client_name = request.getParameter("client_name");
    String client_email = request.getParameter("client_email");
    String user_id = (String)session.getAttribute("user_id");

    String loggedin_user_name = (String)session.getAttribute("name");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
        out.print(status);
        return;
    } else {
        status = addClient(client_name, client_email, user_id);
    }

    if(status != null && status.equals("already_exists")) {
        out.print("<font color='red'>Could not add client. Client already exists</font>");
        return;
    } else if(status != null && status.equals("failed")) {
        out.print("<font color='red'>Could not add client. Please try again</font>");
        return;
    } else  if(status != null) {
        try {
            String info = "Hi "+client_name+",<br><br>";
            info += "&nbsp;&nbsp;&nbsp;&nbsp;<b><font color=skyblue>"+loggedin_user_name+"</font></b> has added you as client<br><br>";
            info += "&nbsp;&nbsp;&nbsp;&nbsp;Please click on this link to register/login <a href='http://netref.co'>http://netref.co</a><br><br>";
            info += "Netref: Find trusted freelancers in your network<br>";

            String result = sendHTMLEMail(client_email, "Netref invitation", info);
        } catch (Throwable e) {
            e.printStackTrace();
        }
        out.print(status);
    }
%>
