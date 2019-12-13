<%@ page import="java.util.Date" %>

<%@ include file="util.jsp"%>

<%
    String profile_image_str = request.getParameter("profile_image_str");
    String timeNow = request.getParameter("timeNow");
    String from_user_id = request.getParameter("userId");

    if(profile_image_str == null) {
        out.print("no_profile_image");
        return;
    }

    if(from_user_id == null) {
        out.print("session_expired");
        return;
    }

    byte[] profile_image = null;

    try {
        if(profile_image_str.length() > 0) {
            profile_image = Base64.decode(profile_image_str);

            if(profile_image != null && profile_image.length > 0) {
                String res = saveProfileImageToFileSystem(from_user_id, profile_image, timeNow);

                out.print(res);
            }
        }
    } catch(Exception ex) {
        System.out.println(new Date()+"\t "+ex);
        out.print("failed");
        return;
    }
%>
