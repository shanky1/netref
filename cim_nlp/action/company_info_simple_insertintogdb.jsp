<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.neo4j.driver.v1.Session" %>
<%@ page import="org.neo4j.driver.v1.*" %>
<%@ page import="com.cim.CIMUtil" %>
<%@ include file="util.jsp"%>

<%
    //    A driver is used to connect to a Neo4j server. It provides sessions that are used to execute statements and retrieve results.
    //    If no port is provided in the URL, the default port 7687 is used

    Driver driver = GraphDatabase.driver(gdbDriver_url, AuthTokens.basic(gdbDriver_username, gdbDriver_password));
    Session ses = driver.session();

//        read from the company specialities info files and insert E&R into graph database
    CIMUtil.company_simple_ReadFiles_InsertIntoGDB(ses, comp_simple_profiles_dir);
    
    out.print("<br><br><br><br><font color='blue'><center>Completed</center></font>");

    ses.close();
    driver.close();
%>