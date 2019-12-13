<%@ page import="java.io.PrintWriter" %>
<%@ include file="util.jsp"%>

<%
    PrintWriter output = response.getWriter();

    String country_code = request.getParameter("country_code");
    String phonenum = request.getParameter("phonenum");
    String verification_code = request.getParameter("verification_code");

    String mobilenum = country_code+""+phonenum;

    int userId = verifyMobileCode(mobilenum, verification_code);

    HttpSession sess = request.getSession();

    if(userId > 0) {
        sess.setAttribute("country_code", country_code+"");
        sess.setAttribute("user_id", userId+"");
        sess.setAttribute("login_type","mobile_login");
        System.out.println(new Date()+"\t Successfully verified the mobile for: "+userId);
        out.println("userId: "+userId);
    } else {
        output.println("Verification code doesn't match for: "+mobilenum);
    }
%>
