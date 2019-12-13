<%@include file="util.jsp" %>

<%
    String from_country_code = (String)session.getAttribute("country_code");
    String rs_id = request.getParameter("rs_id");
    String contact_user_id_str = request.getParameter("contact_user_id");
    String contact_name = request.getParameter("contact_name");

    String from_user_id_str = (String)session.getAttribute("user_id");

    int from_user_id = 0;
    int contact_user_id = 0;

    if(from_country_code == null) {
        from_country_code = "";
    }

    if(from_user_id_str != null) {
        try {
            from_user_id = Integer.parseInt(from_user_id_str);
        } catch (Exception e) {
            System.out.println(new Date()+"\t Could not get correct from_user_id_str: "+from_user_id_str);
        }
    }

    if(contact_user_id_str != null) {
        try {
            contact_user_id = Integer.parseInt(contact_user_id_str);
        } catch (Exception e) {
            System.out.println(new Date()+"\t Could not get correct contact_user_id_str: "+contact_user_id_str);
        }
    }

    if(from_user_id > 0) {
        boolean ipns = isProfileNameSet(from_user_id_str);

        if(ipns) {
            int status = addEmployeeForUser(from_user_id, contact_user_id, rs_id, from_country_code);

            out.print(status);
        } else {
            out.print("profile_name_not_set");
        }
    }
%>
