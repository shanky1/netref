<%@include file="util.jsp" %>

<%
    String deviceIMEI = request.getParameter("deviceIMEI");

    System.out.println(new Date()+"\t register_user_skip_phone -> deviceIMEI: "+deviceIMEI);

    if(deviceIMEI != null && !deviceIMEI.equalsIgnoreCase("no_deviceid_found")) {
        int user_id = registerIMEIIfNotExists(deviceIMEI);

        HttpSession sess = request.getSession();

        if(user_id > 0) {
            sess.setAttribute("user_id", user_id+"");
            sess.setAttribute("login_type","mobile_login");
//            System.out.println(new Date()+"\t Successfully verified the mobile skip for: "+user_id);

            out.print("success:"+user_id+":"+deviceIMEI);
        } else {
            out.print("no_user_found");
        }
    } else {
        out.print("no_deviceid_found");
    }
%>
