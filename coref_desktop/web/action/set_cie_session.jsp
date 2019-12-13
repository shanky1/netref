<%@ page import="java.util.Date" %>
<%@include file="encryption_util.jsp" %>

<%
    String company_id_enc = request.getParameter("cie");

    if(session.getAttribute("company_id") != null) {
        session.removeAttribute("company_id");
    }

    try {
        String comapany_id = decode(company_id_enc);

        if(Integer.parseInt(comapany_id) > 0)  {
//            System.out.println(new Date()+"\t set_cie_session.jsp -> company_id from url: "+comapany_id);
            session.setAttribute("company_id", comapany_id);
            out.print("success");
        } else {
            out.print("invalid_cie");
        }
    } catch (Exception e) {
        out.print("malformed_cie");
    }
%>
