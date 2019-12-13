<%@include file="util.jsp" %>
<HTML>
<head>
<link href="./resources/css/bootstrap.css" rel="stylesheet">
<link href="./resources/css/gsdk-min.css" rel="stylesheet">
<link href="./resources/css/demo-min.css" rel="stylesheet">


<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<script src="./resources/js/jquery-1.10.2.js"></script>
<script src="./resources/js/jquery-ui.js"></script>
<script src="./resources/js/bootstrap.js" type="text/javascript"></script>

<style>
#header {
    background-color:orange;
    color:white;
    text-align:center;
    padding:5px;
}
#nav {
    line-height:30px;
    background-color:yellowgreen;
    height:500px;
    width:150px;
    float:left;
    padding:5px; 
}
#section {
    width:350px;
    float:left;
    padding:10px; 
}
#footer {
    background-color:orange;
    color:white;
    clear:both;
    text-align:center;
    padding:5px; 
}
</style>
</head>
<body>
    <div style="height: 630px;">

    <div id="header">
<h2>Register</h2>
</div>

<div id="nav">
    <marquee>Register</marquee>
</div>

    <div style="padding-top: 30px;" class="center"  >
    <form action="registerProcess.jsp" method="post" >
	<table align="center">
            <tr><td><label>Email<span style="color: red; "> *&nbsp;</label></td><td><input class="form-group form-control" type="email" name="email"></td></tr>
        <tr><td><label>Password<span style="color: red; "> *&nbsp;</label></td><td><input class="form-group form-control" type="password" name="pass"></td></tr>
    	<tr><td><label>Re-PassWord<span style="color: red; "> *&nbsp;</label></td><td><input class="form-group form-control" type="password" ></td></tr>
        <tr><td><label>Role<span style="color: red; "> *&nbsp;</label></td><td style="line-height: 40px;"><input  type="radio" name="role" value="Manager">Manager
								      <input  type="radio" name="role" value="Developer">Developer    
                                             </td></tr>
        <tr><td><label>Date Of Join <font color = red> *&nbsp;</label></td><td><input class="form-group form-control" type="date" name="doj"></td></tr>
        <tr><td><input class="btn btn-primary"  type="submit" value="Register"></td><td><input class="btn btn-success" type="reset" value="Cancle"></td></tr>
    </table>

    </form>

</div>
    </div>

<div id="footer">
Copyright © 
</div>

</body>
</HTML>
