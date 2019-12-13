<%--https://developer.yahoo.com/oauth2/guide/openid_connect/getting_started.html--%>

<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="org.apache.commons.httpclient.NameValuePair"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%@page import="org.apache.commons.httpclient.HttpClient"%>
<%@ page import="java.util.*" %>
<%@ page  contentType="text/html; charset=UTF-8"
          pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Yahoo Contacts</title>
</head>
<body>

<%!
    String clientId = "dj0yJmk9SVBYeTlReWtaT3NZJmQ9WVdrOWJXcDRWbU0yTm5VbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD0zYg--";
    String clientScrete = "b46837a96466679f54974633ac733c74614f7970";
    List<Map<String,Object>> gmailContactsList = new ArrayList<Map<String,Object>>();
%>

<%
    String code = request.getParameter("code");

    out.println("code: "+code);

    HttpClient client = new HttpClient();
    PostMethod post = new PostMethod(
            "https://api.login.yahoo.com/oauth2/get_token");
    post.addRequestHeader("Content-Type",
            "application/x-www-form-urlencoded");
    NameValuePair[] data = {
            new NameValuePair("code", code),
            new NameValuePair("client_id",
                    clientId),
            new NameValuePair("client_secret",
                    clientScrete),
            new NameValuePair("redirect_uri",
                    "http://netref.co/netref/mobile/yahoo/ydn_3auth_code_flow_auth_users_get_code.jsp"),
            new NameValuePair("grant_type", "authorization_code") };

    post.setRequestBody(data);
    client.executeMethod(post);
    BufferedReader b = new BufferedReader(new InputStreamReader(
            post.getResponseBodyAsStream()));
    StringBuilder sb = new StringBuilder();
    String str = null;
    while ((str = b.readLine()) != null) {
        sb.append(str);
    }

    out.print(str);

%>
</body>
</html>
