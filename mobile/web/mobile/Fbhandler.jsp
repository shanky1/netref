<%-- 
    Document   : Fbhnadler
    Created on : May 30, 2015, 8:41:06 AM
    Author     : kundan
--%> 

<%@ page import="javax.json.JsonObject"%>
<%@ page import="javax.json.JsonReader"%>
<%@ page import="javax.json.Json"%>
<%@ page import="java.io.ByteArrayInputStream"%>
<%@ page import="org.scribe.model.Response"%>
<%@ page import="org.scribe.model.Verb"%>
<%@ page import="org.scribe.model.OAuthRequest"%>
<%@ page import="org.scribe.model.Verifier"%>
<%@ page import="org.scribe.model.Token"%>
<%@ page import="org.scribe.oauth.OAuthService"%>
<%@ page import="com.restfb.DefaultFacebookClient" %>
<%@ page import="com.restfb.FacebookClient" %>
<%@ page import="com.restfb.types.User" %>
<%@ page import="com.restfb.exception.FacebookException" %>
<%@ page import="java.util.List" %>

<%@ include file="action/util.jsp"%>

<head>
    <script type="text/javascript">
        function redirectToRegisterPage(redirectURL) {
            window.location = redirectURL;
        }

        function setCookieForFBLoginAndRedirect(netref_cookie_login_val, redirectURL) {
            var cookie_name = "netref_cookie_login";
            var cookie_value = netref_cookie_login_val;
            var days = 365;

            var date = new Date();
            var time = date.getTime()+(days*24*60*60*1000);
            date.setTime(time);
            var expires = "; expires="+date.toGMTString();

            var cookie_set = cookie_name+"="+cookie_value+expires+"; path=/";

            document.cookie = cookie_set;

            window.location = redirectURL;
        }

        function setCookieForFBLoginAndOpenContactsList(netref_cookie_login_val, userId, redirectURL) {
            var cookie_name = "netref_cookie_login";
            var cookie_value = netref_cookie_login_val;
            var days = 365;

            var date = new Date();
            var time = date.getTime()+(days*24*60*60*1000);
            date.setTime(time);
            var expires = "; expires="+date.toGMTString();

            var cookie_set = cookie_name+"="+cookie_value+expires+"; path=/";

            document.cookie = cookie_set;

            try {
                webapp.openContactsView(userId);
            } catch (err) {
                if(err.toString().indexOf("webapp") >= 0) {
                    setCookieForFBLoginAndRedirect(netref_cookie_login_val, redirectURL);
                }
            }
        }
    </script>
</head>

<%
    String FPROTECTED_RESOURCE_URL = "https://graph.facebook.com/me?fields=id,name,first_name,last_name,email,gender,birthday,picture{url}";

    // Check error code
    String code = request.getParameter("code");
    if(code == null || code.trim().equals("")) {
        HttpSession sess = request.getSession();
        sess.invalidate();
        response.sendRedirect(request.getContextPath());
        return;
    }
    // User is authenticated. Get details to insert into database

    HttpSession sess = request.getSession();
    OAuthService service = (OAuthService)sess.getAttribute("fboauth2Service");

    if(service == null) {
        out.println("<br><br><center>Session is expired. Please <a href='mobileregister.html'>re-login</a> and try again or contact support.</center>");
        return;
    }

    //END

//    Construct the access token
//    Token token = service.getAccessToken(Token.empty(), new Verifier(code));

    Token token;

    try {
        token = service.getAccessToken(Token.empty(), new Verifier(code));
    } catch(Exception e) {
        System.out.println(new Date()+"\t "+e.getMessage());
        e.printStackTrace();
%>

<script type="text/javascript">
    redirectToRegisterPage('mobileregister.html');
</script >

<%
        return;
    }

    //Save the token for the duration of the session
    sess.setAttribute("token", token);

//      //Perform a proxy login
//      try {
//         request.login("fred", "fredfred");
//         
//      } catch (ServletException e) {
//         //Handle error - should not happen
//      }

    //Now do something with it - get the user's G+ profile
    OAuthRequest oReq = new OAuthRequest(Verb.GET,FPROTECTED_RESOURCE_URL);

    service.signRequest(token, oReq);
    Response oResp = oReq.send();

    //Read the result

    JsonReader reader = Json.createReader(new ByteArrayInputStream(oResp.getBody().getBytes()));
    JsonObject profile = reader.readObject();

    System.out.println("--------");
    System.out.println(new Date()+"\t logged in user profile: "+profile);
    System.out.println("--------");

//  Get friend details
    FacebookClient facebookClient = new DefaultFacebookClient(token.getToken());
    com.restfb.Connection<User> friends1 = null;

    try {
        friends1 = facebookClient.fetchConnection("me/friends", User.class);
    } catch (FacebookException e) {
        System.out.println(new Date()+"\t "+e.getMessage());
        e.printStackTrace();
    }

    List<User> friendsList1 = friends1.getData();

    String fb_user_id = "";
    String first_name = "";
    String last_name = "";
    String email = "";
    String gender = "";

    if(profile.containsKey("id")) {
        fb_user_id = profile.getString("id");
    } else {
        out.println("<br><br><center>Could not login. Please <a href='mobileregister.html'>re-login</a> and try again or contact support.</center>");
        return;
    }

    if(profile.containsKey("first_name")) {
        first_name = profile.getString("first_name");
    }

    if(profile.containsKey("last_name")) {
        last_name = profile.getString("last_name");
    }

    if(profile.containsKey("email")) {
        email = profile.getString("email");
    }

    if(profile.containsKey("gender")) {
        gender = profile.getString("gender");
    }

    if(gender.equalsIgnoreCase("male")) {
        gender = "M";
    } else if(gender.equalsIgnoreCase("female")) {
        gender = "F";
    }

    String name = (first_name != null ? first_name : "")+" "+(last_name != null ? last_name : "");

    String fb_photo_path = parsePictureURL(profile.toString());

    sess.setAttribute("email",email);

    boolean iu = insertFBUserIfNotExist(email, name, gender, fb_photo_path, fb_user_id);

    String redirectURL = "mobileregister.html";

    long userId = -1;

    if(iu) {
        userId = getUserId(email);
        boolean insert_fb_friends = insertUserFBFriendsIfNotExist(userId+"", fb_user_id, friendsList1);
        sess.setAttribute("user_id",userId+"");
        sess.setAttribute("fb_photo_path",fb_photo_path);
        sess.setAttribute("name",name);
        sess.setAttribute("first_name",first_name);
        sess.setAttribute("last_name",last_name);
        sess.setAttribute("login_type","fb_login");

        redirectURL = "mobilefriend.html";
    }
%>

<script type="text/javascript">
    <%--setCookieForFBLoginAndRedirect('<%=email%>','<%=redirectURL%>');--%>
    setCookieForFBLoginAndOpenContactsList('<%=email%>', '<%=userId%>','<%=redirectURL%>');
</script >

<%!
    private String parsePictureURL(String profile) {

        //TODO, Unable to get the picture from the JSon object directly. So parsing in the kludgy way

        String picURL = "";

        int index_start = profile.indexOf("https://");

        int index_end = profile.indexOf("\"", index_start);

        picURL = profile.substring(index_start, index_end);

        return picURL;
    }
%>
