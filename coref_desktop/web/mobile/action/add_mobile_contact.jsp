<%@include file="util.jsp" %>

<%
    String contact_name = request.getParameter("contact_name");
    String contact_number = request.getParameter("contact_number");
    String contact_mail = request.getParameter("contact_mail");
    String connection = request.getParameter("connection");

//    System.out.println(new Date()+"\t contact_name: "+contact_name+", contact_number: "+contact_number+", contact_mail: "+contact_mail+", connection: "+connection+"\n");

    String user_id = (String)session.getAttribute("user_id");

    org.json.JSONArray add_contact_list_al_json;

    if(user_id == null) {
        out.print("session_expired");
    } else {
//        status = addMobileContact(user_id, contact_name, contact_number, contact_mail, connection);
        ArrayList add_contact_list_al = addMobileContact_JSON(user_id, contact_name, contact_number, contact_mail, connection);
        add_contact_list_al_json = new org.json.JSONArray(add_contact_list_al);

//        System.out.print(add_contact_list_al_json.toString());
        out.print(add_contact_list_al_json);

        session.setAttribute("updated_flag","true");
    }
%>
