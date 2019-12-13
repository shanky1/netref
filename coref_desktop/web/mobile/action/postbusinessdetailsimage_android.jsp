<%@ page import="java.util.Date" %>

<%@ include file="util.jsp"%>

<%
    String businessdetails_image_str = request.getParameter("business_details_image_str");
    String timeNow = request.getParameter("timeNow");
    String from_user_id = request.getParameter("userId");

    if(businessdetails_image_str == null) {
        out.print("no_businessdetails_image");
        return;
    }

    if(from_user_id == null) {
        out.print("session_expired");
        return;
    }

    byte[] businessdetails_image = null;

    try {
        if(businessdetails_image_str.length() > 0) {
            businessdetails_image = Base64.decode(businessdetails_image_str);

            if(businessdetails_image != null && businessdetails_image.length > 0) {
                String res = saveBusinessDetailsImageToFileSystem(from_user_id, businessdetails_image, timeNow);

                out.print(res);
            }
        }
    } catch(Exception ex) {
        System.out.println(new Date()+"\t "+ex);
        out.print("failed");
        return;
    }
%>
