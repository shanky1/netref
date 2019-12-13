<%
    String server_name = request.getServerName();
    server_name = server_name.replaceFirst("www.","");

    int ind = server_name.indexOf("coref.co");
    
//    System.out.println(new java.util.Date()+"\t server_name: "+server_name);
    
    if(ind >= 0) {
        response.setStatus(301);
        response.setHeader("Location", "/coref/login.html" );
        response.setHeader("Connection", "close" );
    } else {
        response.setStatus(301);
        response.setHeader("Location", "/coref/login.html" );
        response.setHeader("Connection", "close" );
    }
%>
