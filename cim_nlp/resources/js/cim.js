$(document).ready(function() {

    var search_result_arr = [];
    var search_person_details_arr = [];

    window.showSearchResults = function() {
        $("#ser_result_complete").hide();
        $("#ser_result_cnt").show();
        $("#ser_result_short").show();
    };

    window.loadSearchResults = function() {
        $("#ser_result_complete").hide();
        $("#ser_result_cnt").hide();

        $("#ser_result_short").text('');
        var search_for = $("#search_for").val();

        if(search_for == null || search_for.length <= 0) {
            $("#search_for").focus();
            return;
        }

        $.ajax({
            type:         "post",
            url:         "../action/search_results.jsp",
            data:         "search_for="+search_for,

            success:    function(search_result_list_json) {
                search_result_list_json = escape(search_result_list_json).replace(/%0A/g, "");
                search_result_list_json = search_result_list_json.replace(/%0D/g, "");
                search_result_list_json = unescape(search_result_list_json);

                if(search_result_list_json != null && search_result_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

//                console.log(new Date()+"\t Got the response: "+search_result_list_json.length+", profession_list_json: "+search_result_list_json);

                search_result_arr = JSON.parse(search_result_list_json);

                if(search_result_arr == null || search_result_arr.length <= 0) {
                    $("#load_data_loading").hide();

                    var no_result_html = getNoresultsHTML();
                    $("#ser_result_short").append(no_result_html);

                    //No professional list found, do nothing
                    return;
                }


                var key = "";
                var details = "";

                console.log(new Date()+"\t Number of searh results...: "+search_result_arr.length);

                $("#ser_result_cnt").html("About "+search_result_arr.length+" result(s)");
                $("#ser_result_cnt").show();

                for(var cnt = 0; cnt < search_result_arr.length; cnt++) {
                    try {
                        for(var i in search_result_arr[cnt]) {
                            if (search_result_arr[cnt].hasOwnProperty(i)) {
//                                console.log('Key is: ' + i + '. Value is: ' + search_result_arr[cnt][i]);

                                key = i;
                                details = search_result_arr[cnt][key];
                            }
                        }

                        var row_html = getSearchResultsRowHTML(key, details);

                        $("#ser_result_short").append(row_html);
                        $("#ser_result_short").show();
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                //TODO
            }
        });
    };

    window.loadPersonDetails = function(person_name) {
        $("#ser_result_short").hide();
        $("#ser_result_cnt").hide();
        $("#ser_result_complete").text("");

        if(person_name == null || person_name.length <= 0) {
            $("#search_for").focus();
            return;
        }

        $.ajax({
            type:         "post",
            url:         "../action/search_person_details.jsp",
            data:         "person_name="+person_name,

            success:    function(search_person_details_json) {
                search_person_details_json = escape(search_person_details_json).replace(/%0A/g, "");
                search_person_details_json = search_person_details_json.replace(/%0D/g, "");
                search_person_details_json = unescape(search_person_details_json);

                if(search_person_details_json != null && search_person_details_json.indexOf("session_expired") >= 0) {
                    window.location = "search.html";
                }

//                console.log(new Date()+"\t Got the response: "+search_person_details_json.length+", search_person_details_json: "+search_person_details_json);

                search_person_details_arr = JSON.parse(search_person_details_json);

                if(search_person_details_arr == null || search_person_details_arr.length <= 0) {
                    var no_result_html = getNoresultsHTML();
                    $("#ser_result_complete").append(no_result_html);
                    $("#ser_result_complete").show();

                    return;
                }

                var key = "";
                var details = "";

                for(var cnt = 0; cnt < search_person_details_arr.length; cnt++) {
                    try {
                        for(var i in search_person_details_arr[cnt]) {
                            if (search_person_details_arr[cnt].hasOwnProperty(i)) {
                                key = i;
                                details = search_person_details_arr[cnt][key];
                            }
                        }

                        var row_html = getPersonDetailsRowHTML(key, details);

                        $("#ser_result_complete").append(row_html);
                        $("#ser_result_complete").show();
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                //TODO
            }
        });
    };

    $("#search_for").enterKey(function () {
        loadSearchResults();
    });

    function getSearchResultsRowHTML(person, details) {
//        var row_html = "<h3 style='margin-top:20px; padding-bottom:4px;'> "+(person != null && person.trim().length > 0 ? "<a href='javascript: void(0);' onclick='loadPersonDetails(\""+person+"\");'>"+person+"</a>"  : "N/A")+"</h3> "+
        var row_html = "<h3 style='margin-top:20px; padding-bottom:4px; color: #0000ff;'> "+(person != null && person.trim().length > 0 ? person : "N/A")+"</h3> "+
            "<p style='font-size: 13px; text-align: justify;'>"+(details != null && details.trim().length > 0 ? details  : "N/A")+"</p> ";
        return row_html;
    }

    function getPersonDetailsRowHTML(person, details) {
        var row_html = "<a href='javascript: void(0)' onclick='showSearchResults();'> <span class='glyphicon glyphicon-arrow-left' style='padding: 10px 20px 10px 0px; font-size: 25px;'></span> </a>" +
            "<h3 style='margin-top:20px; padding-bottom:4px; color: #0000ff;'> "+(person != null && person.trim().length > 0 ? person+" - details" : "N/A")+"</h3>"+
            "<p style='font-size: 13px; text-align: justify;'>"+(details != null && details.trim().length > 0 ? details  : "N/A")+"</p> ";
        return row_html;
    }

    function getNoresultsHTML() {
        $("#ser_result_cnt").html("");
        var no_result_html = "<dl id='no_res_id' style='padding:2px'>  " +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #D3D3D3; color: #ffffff;'>" +
            "           <div class='events-body'>" +
            "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
            "                   <center>No results found</center>" +
            "               </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";

        return no_result_html;
    }
});

$.fn.enterKey = function (fnc) {
    return this.each(function () {
        $(this).keypress(function (ev) {
            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
            if (keycode == '13') {
                fnc.call(this, ev);
            }
        })
    })
};
