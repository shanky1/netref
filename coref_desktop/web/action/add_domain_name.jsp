<%@include file="util.jsp" %>

<%
    String user_id = (String)session.getAttribute("user_id");

    String domain_name = request.getParameter("domain_name");

    if (user_id == null) {
        out.print("session_expired");
        return;
    }

/*
    int company_id = createCompanyAndMapToUser(user_id, domain_name);

    if(company_id > 0) {
        session.setAttribute("company_id", company_id+"");
        out.print("success");
    } else {
        out.print("falied");
    }
*/

    int company_id = createCompanyIfNotExists(user_id, domain_name);           //-1 = If company already exists; 0 - failed to create company; > 0 - successfully created company

    if(company_id > 0) {
        int map_status = mapCompanyToUser(user_id, company_id);                //We are going to map user to company_id as owner
        int userType = 2;
        int update_user_type = updateUserType(user_id, userType);              //userType = 2 - hiring manager

        if(update_user_type > 0) {
            session.setAttribute("user_type", userType+"");
        }

        session.setAttribute("company_id", company_id+"");
        out.print("success");
    } else if(company_id == -1) {
        out.print("company_already_exists");
    } else {
        out.print("failed");
    }
%>
