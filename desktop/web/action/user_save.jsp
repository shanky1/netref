<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@include file="../util.jsp" %>

<%
    String f_name= (String)session.getAttribute("f_name");
    String l_name= (String)session.getAttribute("l_name");
    String email= (String)session.getAttribute("email");
    String token= String.valueOf(session.getAttribute("token"));
    ResultSet rs=null;
    Connection conn=null;
    PreparedStatement ps=null;
//    PreparedStatement ps_checkEmail = null;
//    ResultSet rsEmail=null;
    String id1="0";

    try {
        conn = getConnection();

//        Check and insert if the email_id doesn't exists

//        String sql_checkEmail = "select * from users where email = ?";

//        ps_checkEmail = conn.prepareStatement(sql_checkEmail);
//        ps_checkEmail.setString(1, email);
//        rsEmail = ps_checkEmail.executeQuery();

//        if (rsEmail.next()) {
//            id1 = rsEmail.getString(1);
//        } else {
        String insertQuery = "insert into users(email,first_name,last_name,access_token,date_joined)values(?,?,?,?,SYSDATE())";
        ps = (PreparedStatement)conn.prepareStatement(insertQuery,Statement.RETURN_GENERATED_KEYS);
        ps.setString(1,email);
        ps.setString(2,f_name);
        ps.setString(3,l_name);
        ps.setString(4,token);
        int id=ps.executeUpdate();
        if(id==1)
        {
            rs=ps.getGeneratedKeys();
            if(rs.next())id1=rs.getString(1);
        }
//        }

        session.setAttribute("user_id", id1);
        response.sendRedirect("../new.html");
    } catch (Throwable t) {
        t.printStackTrace();
    } finally {
        try {
            if (ps != null) ps.close();
            if (rs != null) rs.close();

//            if (ps_checkEmail != null) ps_checkEmail.close();
//            if (rsEmail != null) rsEmail.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        if(conn != null)
            closeConnection( conn);
        //session.invalidate();


//           Cookie[] cookies = request.getCookies();
//
//    if (cookies != null) {
//        for (Cookie cookie : cookies) {
//            System.out.print("cookie---"+cookie.getName()+"cookie.getMaxAge()"+cookie.getMaxAge()+"cookie.getValue()"+cookie.getValue());
//           // if (Long.valueOf(cookie.getValue()).equals(instance.getId())) {
//               
//                //cookie.setPath(theSamePathAsYouUsedBeforeIfAny);
//                response.addCookie(cookie);
//            //}
//        }
//    }
    }
%>
