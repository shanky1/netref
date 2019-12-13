<%@ page import="java.util.Date" %>

<%@ include file="util.jsp"%>

<%
    String user_id = request.getParameter("userId");

    if(user_id == null) {
        out.print("session_expired");
        return;
    }

    try {
        boolean res = updateReadContactsStatusToDB(user_id);
        if(res) {
            System.out.println(new Date()+"\t updateReadContactsStatusToDB("+user_id+") -> Successfully updated the status to db");
            out.print("success");
        } else {
            out.print("failed");
        }
    } catch(Exception e) {
        System.out.println(new Date()+"\t "+e.getMessage());
    }
%>
