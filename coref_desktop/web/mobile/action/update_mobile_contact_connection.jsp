<%@ include file="util.jsp" %>

<%
    String rs_id = request.getParameter("rs_id");
    String connection = request.getParameter("connection");
    String direction = request.getParameter("direction");

//    System.out.println(new Date()+"\t rs_id: "+rs_id+", connection: "+connection+"\n");

    String user_id = (String)session.getAttribute("user_id");

    String status = "failed";

    if(user_id == null) {
        status = "session_expired";
    } else {
        status = updateContactRelationship(rs_id, connection, direction);
        if(status.equalsIgnoreCase("success")) {
            session.setAttribute("updated_flag","true");
        }
    }

    out.print(status);
%>
