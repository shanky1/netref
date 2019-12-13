<%@ page import="java.io.PrintWriter" %>
<%@ include file="util.jsp"%>

<%
    PrintWriter output = response.getWriter();

    String country_code = request.getParameter("country_code");
    String phonenum = request.getParameter("phonenum");
    String verification_code = request.getParameter("verification_code");

    String mobilenum = country_code+""+phonenum;

    org.json.JSONArray user_details_json = new org.json.JSONArray();

//    int userId = verifyMobileCode(mobilenum, verification_code);
    ArrayList<HashMap<String, Integer>> user_details_al = verifyMobileCodeAL(mobilenum, verification_code);

    System.out.println("user_details_al: "+user_details_al);

    HttpSession sess = request.getSession();
    int userId = -1;

    if(user_details_al == null) {
        output.println("Verification code doesn't match for: "+mobilenum);
        return;
    }

    Iterator<HashMap<String, Integer>> iterator = user_details_al.iterator();
    if (iterator.hasNext()) {
        HashMap<String, Integer> hm = iterator.next();

        if(hm != null && hm.containsKey("user_id")) {
            userId = hm.get("user_id");
        }
    }

    if(userId > 0) {
        sess.setAttribute("country_code", country_code+"");
        sess.setAttribute("user_id", userId+"");
        sess.setAttribute("login_type","mobile_login");
        System.out.println(new Date()+"\t Successfully verified the mobile for: "+userId);

        //Convert contacts list from database to the json format and return
        user_details_json = new org.json.JSONArray(user_details_al);

        System.out.println(new Date()+"\t Returning "+user_details_al.size()+" contacts from DB");

        out.print(user_details_json);
    } else {
        output.println("Verification code doesn't match for: "+mobilenum);
    }
%>
