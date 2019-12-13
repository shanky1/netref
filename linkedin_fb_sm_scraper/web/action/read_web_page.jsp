<script type="text/javascript">
    var urlString = "https://linkedin.com/in/sudipta-bhaumik-53a062a8";
    loadXMLDoc(urlString);

    function loadXMLDoc(theURL)
    {
        console.log("I am called");
        if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari, SeaMonkey
            xmlhttp=new XMLHttpRequest();
        }
        else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange=function()
        {
            if (xmlhttp.readyState==4 && xmlhttp.status==200)
            {
                console.log(xmlhttp.responseText);
            }
        }
        xmlhttp.open("GET", theURL, false);
        xmlhttp.send();
    }
</script>
