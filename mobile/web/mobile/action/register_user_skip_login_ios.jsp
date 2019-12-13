<%@include file="util.jsp" %>

<%
    String ipAddress = request.getHeader("X-FORWARDED-FOR");

    if (ipAddress == null) {
        ipAddress = request.getRemoteAddr();
    }

    String device_uuid = (String)session.getAttribute(ipAddress+"_uuid");

    System.out.println(new Date()+"\t register_user_skip_login_ios -> device_uuid: "+device_uuid);

    if(device_uuid != null && !device_uuid.equalsIgnoreCase("no_deviceid_found")) {
        int user_id = registerIMEIIfNotExists(device_uuid);

        HttpSession sess = request.getSession();

        if(user_id > 0) {
            sess.setAttribute("user_id", user_id+"");
            sess.setAttribute("login_type","mobile_login");
            System.out.println(new Date()+"\t Successfully verified the mobile skip for ios: "+user_id);

            out.print("success:"+user_id+":"+device_uuid);
        } else {
            out.print("no_user_found");
        }
    } else {
        out.print("no_deviceid_found");
    }
%>
