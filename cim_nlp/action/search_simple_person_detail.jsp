<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.neo4j.driver.v1.AuthTokens" %>
<%@ page import="org.neo4j.driver.v1.GraphDatabase" %>
<%@ page import="org.neo4j.driver.v1.Driver" %>
<%@ page import="org.neo4j.driver.v1.Session" %>
<%@ include file="util.jsp"%>

<%
//    String search_for = "san francisco, london washington; Chicago Manchester, cambridge Boston";
    String node_id_str = request.getParameter("node_id");
    int node_id = -1;

    if(node_id_str != null) {
        node_id = Integer.parseInt(node_id_str);

    }

    //    A driver is used to connect to a Neo4j server. It provides sessions that are used to execute statements and retrieve results.
    //    If no port is provided in the URL, the default port 7687 is used

    Driver driver = GraphDatabase.driver(gdbDriver_url, AuthTokens.basic(gdbDriver_username, gdbDriver_password));
    Session ses = driver.session();

    String load_searchresult_str = getPersonDetailsByNodeID(ses, node_id, "complete");
    LinkedHashMap load_searchresult_hm = new LinkedHashMap();

    load_searchresult_hm.put("name", load_searchresult_str);

//    System.out.println(new Date()+"\t load_searchresult_hm: "+load_searchresult_hm);

    ArrayList<LinkedHashMap<String, String>> load_searchresult_al = new ArrayList<LinkedHashMap<String, String>>();
    load_searchresult_al.add(load_searchresult_hm);

    org.json.JSONArray search_result_list_json = new org.json.JSONArray(load_searchresult_al);

    out.print(search_result_list_json);

    ses.close();
    driver.close();
%>
