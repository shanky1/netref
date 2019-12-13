<%@ page import="java.util.*" %>
<%@ page  contentType="text/html; charset=UTF-8"
          pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Yahoo Contacts</title>

    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script>
        var hash = window.location.hash;
//        console.log("window.location.hash : " + hash);

        var hash_split = hash.split("=");

        if(hash_split.length == 2) {
            var id_token = hash_split[1];

            console.log("id_token: "+id_token);

            var id_token_split = id_token.split(".");

            if(id_token_split.length == 3) {
                var jose_header = id_token_split[0];
                var payload = id_token_split[1];
                var signature = id_token_split[2];

                console.log("jose_header: "+jose_header);
                console.log("payload: "+payload);
                console.log("signature: "+signature);

                var jose_header_dec = atob(jose_header);
                var payload_dec = atob(payload);

                console.log("jose_header_dec: "+jose_header_dec);
                console.log("payload_dec: "+payload_dec);
            }
        }
    </script>
</head>
<body>

<%!
    String clientId = "dj0yJmk9SVBYeTlReWtaT3NZJmQ9WVdrOWJXcDRWbU0yTm5VbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD0zYg--";
    String clientScrete = "b46837a96466679f54974633ac733c74614f7970";
    List<Map<String,Object>> gmailContactsList = new ArrayList<Map<String,Object>>();
%>

<%
    String str=request.getRequestURL().toString();

//    out.print("str: "+str);

    Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements())
    {
        String paramName = paramNames.nextElement();
        String[] paramValues = request.getParameterValues(paramName);
        for (int i = 0; i < paramValues.length; i++)
        {
            String paramValue = paramValues[i];
            str=str + paramName + "=" + paramValue;
        }
        str=str+"&";
    }
    out.println(str.substring(0,str.length()-1));    //remove the last character from String
%>
</body>
</html>
