<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="util.jsp" %>

<%
    String from_country_code = (String)session.getAttribute("country_code");
    String from_user_id_str = (String)session.getAttribute("user_id");
    String source_user_id_str = request.getParameter("source_user_id");
    String dest_user_id_str = request.getParameter("dest_user_id");

    int source_user_id = 0;
    int dest_user_id = 0;

    if(from_country_code == null) {
        from_country_code = "";
    }

    if(from_user_id_str == null) {
        out.print("session_expired");
        return;
    }

    if(source_user_id_str != null && dest_user_id_str != null) {
        try {
            source_user_id = Integer.parseInt(source_user_id_str);
            dest_user_id = Integer.parseInt(dest_user_id_str);
            remindAppInvite(source_user_id, dest_user_id, from_country_code);
            out.print("success");
        } catch (Exception e) {
            System.out.println(new Date()+"\t remind_appinvite -> could not get correct source_user_id: "+source_user_id+", dest_user_id: "+dest_user_id);
        }
    } else {
        out.print("could not send the reminder");
    }
%>
