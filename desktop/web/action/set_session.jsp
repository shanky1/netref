<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@include file="../util/funcs_util.jsp"%>

<%
    String test_unique_code = request.getParameter("test_unique_code");
    String course_unique_code = request.getParameter("course_unique_code");
    String test_unique_code_for_reports = request.getParameter("test_unique_code_for_reports");

    if(test_unique_code != null) {
        session.setAttribute("test_unique_code",test_unique_code);
    }
    if(course_unique_code != null) {
        session.setAttribute("course_unique_code",course_unique_code);
    }
    if(test_unique_code_for_reports != null) {
        session.setAttribute("test_unique_code_for_reports",test_unique_code_for_reports);
    }
%>
