$(document).ready(function() {
    var lin_profile_picture = "images/profile.jpg";

    $.ajax({
        type:         "post",
        url:         "action/get_userdetails_from_session.jsp",

        success:    function(user_details) {
            user_details = escape(user_details).replace(/%0A/g, "");
            user_details = user_details.replace(/%0D/g, "");
            user_details = unescape(user_details);

            var user_details_split = user_details.split("|");

            var client_user_id = user_details_split[0];
            var client_user_type = user_details_split[1];

            if(client_user_id == "-1") {
                window.location = "login.html";
            } else {
                if(client_user_type == "2") {       //User of type HR
                    $("#li_my_contacts").show();
                    $("#post_requirement_to_network").show();
                }

                loadLinProfileUrl();
                loadNetworkActivities();
            }
        }
    });

    window.uploadProfileSimulate = function() {
        $("#raf_profile").val("");
        $("#uploadProfileSelector").trigger('click');
    };

    window.uploadProfile = function() {
        $("#raf_profile").val("Uploading...");
        var selectedFile = document.getElementById('uploadProfileSelector').files[0];

        var xhr = new XMLHttpRequest();
        var fd = new FormData();
        xhr.open("POST", "action/upload_profile.jsp?file="+selectedFile, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                // Every thing ok, file uploaded
                console.log(xhr.responseText.trim()); // handle response.
                $("#raf_profile").val(xhr.responseText.trim());
            }
        };
//        fd.append("upload_profile", "action/upload_profile.jsp?file="+selectedFile);
        fd.append('upload_profile', selectedFile);
        xhr.send(fd);
    };

    window.loadLinProfileUrl = function() {
        var lin_profile_name = "Guest";
        var lin_profile_domain = "";
        $.ajax({
            type:         "post",
            url:         "action/lin_profile_picture_url.jsp",

            success:    function(resp) {
                resp = escape(resp).replace(/%0A/g, "");
                resp = resp.replace(/%0D/g, "");
                resp = unescape(resp);

//                console.log(resp);
                if(resp != null && resp.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                    return;
                }
                if(resp != "") {
                    var profile_details_split = resp.split("|");
                    lin_profile_picture = profile_details_split[0];
                    lin_profile_name = profile_details_split[1];
                    lin_profile_domain = profile_details_split[2];
                }

                if(lin_profile_name.trim() != "") {
                    $("#lin_profile_name").text(lin_profile_name);
                }
                if(lin_profile_domain.trim() != "") {
                    $("#lin_profile_domain").text(lin_profile_domain);
                }

                if(lin_profile_picture.trim() != "") {
                    $("#lin_profile_img").attr("src", lin_profile_picture);

                }
            }, error: function (error) {
                ajaxindicatorstop();
            }
        });
    };

    window.sendemail = function() {
      //  alert("inside email");
        $.ajax({
            type:         "post",
            url:         "action/send_status_mail_to_hr.jsp",

            success:    function(resp) {
                resp = escape(resp).replace(/%0A/g, "");
                resp = resp.replace(/%0D/g, "");
                resp = unescape(resp);

//                console.log(resp);
                //    alert(resp)
                if(resp != null && resp.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                    return;
                }

            }, error: function (error) {
            }
        });
    };



    var activities_arr = [];
    window.loadNetworkActivities = function() {
                        $("#contact_status_info").hide();
                        $("#display_post_dl").hide();
                        $("#contact_status_info").hide();
                        $("#display_requirement_post_dl").hide();
                        $("#company_feed_status_info").hide();
                        $('#myreferals').hide();
                        $('#mycontacts').hide();
                        $('#mypoints').hide();
                        $("#posts").hide();
                        $("#display_requirement_activity_results_dl").hide();
                        $("#display_my_requirement_activity_results_dl").hide();
                        $("#post_likes_dislikes_details").hide();
                        $("#hire").hide();
                        $('#myposts').show();
                        $("#display_my_activity_results_dl").show();
                        $("#display_activity_results_dl").show();
                        $("#custom-search-form").show();
                        $("#search_by_val_div").show();
 ajaxindicatorstart("Loading...");
        $.ajax({
            type:         "post",
            url:         "action/load_network_activities.jsp",

            success:    function(activities_list_json) {
                activities_list_json = escape(activities_list_json).replace(/%0A/g, "");
                activities_list_json = activities_list_json.replace(/%0D/g, "");
                activities_list_json = unescape(activities_list_json);
ajaxindicatorstop();
                if(activities_list_json != null && activities_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+activities_list_json.length+", profession_list_json: "+activities_list_json);
                activities_arr = JSON.parse(activities_list_json);
                var row_html = "";

                if(activities_arr == null || activities_arr.length <= 0) {
                    $("#display_activity_results_dl dl").remove();
                    row_html = getNoActivitiesHTML();
                    $("#display_activity_results_dl").append(row_html);
                    return;
                }

                var activities_found = false;
                console.log(new Date()+"\t Number of activities loading...: "+activities_arr.length);

               for(var cnt1 = 0; cnt1 < activities_arr.length; cnt1++) {
                    var activity_id1 = activities_arr[cnt1].activity_id;
                    $("#show_ask_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_activity_results_dl dl").remove();                      //Then, Remove all posts
                console.log(new Date()+"\t start");

                for(var cnt = 0; cnt < activities_arr.length ; cnt++) {
                    try {
                        var activity_id = activities_arr[cnt].activity_id;
                        var category = activities_arr[cnt].category;
                        var comments = activities_arr[cnt].comments;
                        var posted_on = activities_arr[cnt].posted_on;
                        var posted_on_format = activities_arr[cnt].posted_on_format;
                        var posted_by = activities_arr[cnt].posted_by;
                        var post_likes = activities_arr[cnt].post_likes;
                        var post_dislikes = activities_arr[cnt].post_dislikes;
                        var post_comments = activities_arr[cnt].post_comments;
                        var fl_name = activities_arr[cnt].fl_name;
                        var user_type = activities_arr[cnt].user_type;
                        var lin_profile_picture_url = activities_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html = getActivitiesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,user_type,lin_profile_picture_url);

                         $("#display_activity_results_dl").append(row_html);

                        activities_found = true;
                    } catch (error) {
                        continue;
                    }
                }console.log(new Date()+"\t End");
                if(activities_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }

            }, error: function (error) {

            }
        });
    };
    var post_arr = [];
    window.loadPostRequirements = function() {
        $("#display_post_dl").hide();
        $("#contact_status_info").hide();
        $("#display_requirement_post_dl").hide();
        $("#company_feed_status_info").hide();
        $('#myreferals').hide();
        $('#mycontacts').hide();
        $('#mypoints').hide();
        $("#post_likes_dislikes_details").hide();
        $('#myposts').hide();
        $("#display_my_activity_results_dl").hide();
        $("#display_activity_results_dl").hide();
        $("#hire").hide();
        $("#posts").show();
        $("#display_requirement_activity_results_dl").show();
        $("#display_my_requirement_activity_results_dl").show();
        $("#show_suggestions").hide();

        $.ajax({
            type:         "post",
            url:         "action/load_post_requirement_activities.jsp",

            success:    function(post_list_json) {
                post_list_json = escape(post_list_json).replace(/%0A/g, "");
                post_list_json = post_list_json.replace(/%0D/g, "");
                post_list_json = unescape(post_list_json);

                if(post_list_json != null && post_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+activities_list_json.length+", profession_list_json: "+activities_list_json);

                post_arr = JSON.parse(post_list_json);
                var row_html = "";

                if(post_arr == null || post_arr.length <= 0) {
                    $("#display_requirement_activity_results_dl dl").remove();

                    //No activities list found, do nothing

                    row_html = getNoActivitiesHTML();
                    $("#display_requirement_activity_results_dl").append(row_html);

                    return;
                }

                var posts_found = false;

                console.log(new Date()+"\t Number of activities loading...: "+activities_arr.length);

                /*for(var cnt1 = 0; cnt1 < post_arr.length; cnt1++) {
                    var post_id1 = post_arr[cnt1].activity_id;
                    $("#show_ask_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }*/

                $("#display_requirement_activity_results_dl dl").remove();                      //Then, Remove all posts

                for(var cnt = 0; cnt < post_arr.length; cnt++) {
                    try {
                        var activity_id = post_arr[cnt].activity_id;
                        var category = post_arr[cnt].category;
                        var comments = post_arr[cnt].comments;
                        var posted_on = post_arr[cnt].posted_on;
                        var posted_on_format = post_arr[cnt].posted_on_format;
                        var posted_by = post_arr[cnt].posted_by;
                        var post_likes = post_arr[cnt].post_likes;
                        var post_dislikes = post_arr[cnt].post_dislikes;
                        var post_comments = post_arr[cnt].post_comments;
                        var fl_name = post_arr[cnt].fl_name;
                        var suggestion = post_arr[cnt].suggestion;
                        var lin_profile_picture_url = post_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html = getpostrequirementRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,suggestion,lin_profile_picture_url);
                        $("#display_requirement_activity_results_dl").append(row_html);
                        posts_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(posts_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }

            }, error: function (error) {

            }
        });
    };

    var hired_arr = [];
    window.loadHiredCandidates = function() {
        $("#display_post_dl").hide();
        $("#contact_status_info").hide();
        $("#display_requirement_post_dl").hide();
        $("#company_feed_status_info").hide();
        $('#myreferals').hide();
        $('#mycontacts').hide();
        $('#mypoints').hide();
        $("#post_likes_dislikes_details").hide();
        $('#myposts').hide();
        $("#display_my_activity_results_dl").hide();
        $("#display_activity_results_dl").hide();
        $("#posts").hide();
        $("#display_requirement_activity_results_dl").hide();
        $("#display_my_requirement_activity_results_dl").hide();
        $("#hire").show();


        $.ajax({
            type:         "post",
            url:         "action/load_hired_candidates.jsp",

            success:    function(hired_list_json) {
                hired_list_json = escape(hired_list_json).replace(/%0A/g, "");
                hired_list_json = hired_list_json.replace(/%0D/g, "");
                hired_list_json = unescape(hired_list_json);

                if(hired_list_json != null && hired_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+activities_list_json.length+", profession_list_json: "+activities_list_json);

                hired_arr = JSON.parse(hired_list_json);
                var row_html = "";

                if(hired_arr == null || hired_arr.length <= 0) {
                    $("#display_hired_candidates_results_dl dl").remove();

                    //No activities list found, do nothing

                    row_html = getNoHiredCandidatesRowHTML();
                    $("#display_hired_candidates_results_dl").append(row_html);

                    return;
                }

                var hired_found = false;

                console.log(new Date()+"\t Number of activities loading...: "+activities_arr.length);

                $("#display_hired_candidates_results_dl dl").remove();                      //Then, Remove all posts

                for(var cnt = 0; cnt < hired_arr.length; cnt++) {
                    try {
                        var activity_id = hired_arr[cnt].activity_id;
                        var category = hired_arr[cnt].category;
                        var comments = hired_arr[cnt].comments;
                        var posted_on = hired_arr[cnt].posted_on;
                        var posted_on_format = hired_arr[cnt].posted_on_format;
                        var posted_by = hired_arr[cnt].posted_by;
                        var post_likes = hired_arr[cnt].post_likes;
                        var post_dislikes = hired_arr[cnt].post_dislikes;
                        var post_comments = hired_arr[cnt].post_comments;
                        var fl_name = hired_arr[cnt].fl_name;
                        var lin_profile_picture_url = hired_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html = getHiredCandidatesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,lin_profile_picture_url);

                        $("#display_hired_candidates_results_dl").append(row_html);

                        hired_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(posts_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }

            }, error: function (error) {

            }
        });
    };

    function getHiredCandidatesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }

        var show_header = "";
        var show_image = "";
        var post_heading = "";
        var skills_details = "";
        if(category == 'refer') {
            var refer_details = comments.split("|");
            show_header = refer_details[0];
            skills_details = refer_details[1];

            post_heading = "<h1 style='margin-bottom: 7px;font-size: 13px;margin-top:5px;margin-left:2px;margin-bottom: 0px'>Need opinion on  profile</h1>";
            show_image  =  "                                       <div class='col-xs-1 pull-left' style='margin-right: 0px'>"+
                "                                              <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>  " +
                "                                                <img class='img-circle' style='max-width:30px' src="+posted_by_photo+" class='events-object img-rounded'> " +
                "                                             </p>" +
                "                                        </div>  ";


        }else{
            skills_details = comments;
        }

        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fcfbfb;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row' style='margin-bottom:1%'>     " +
          /*  "                                        <div class='events-left col-xs-6 text-center' style='padding-left: 5px'>"+
            "                                        </div>" +*/
            "                               <div class='col-xs-7' onclick='showpost("+activity_id+")' style='cursor: pointer;'>     " +
            "                                            " +
            "<h1 style='font-size: 17px;margin-bottom: 3px;margin-top: 1px;font-family: \"Lato\",sans-serif;'> " +
            " <img class='img-circle text-center' style='max-width:45px;margin-top: 5px' src='images/hired.png' class='events-object img-rounded'>"+show_header+"<br><p style='margin-top:-10px;margin-left:45px;font-size:13px'>"+skills_details+"</p>  </h1> "+

            "                                     <div class='row'> "+
            "                                        <div class='col-xs-10 pull-left' style='margin-left: 0px'>"+
            "                                         <p align ='left' class='pull-left' style='font-size: 12px;line-height:1.0;display:inline;margin-bottom:2%;margin-top:2px;margin-left:3px'> " +
            "<h1 style='font-size: 14px;margin-bottom: 3px;margin-top: 6px;margin-left: 3px'></h1>"+
            "                                          </p> " +
            "                                      </div>  " +
            "                                    </div>  " +
            "                               </div>  " +
            "                           <div  align='center' class='event-body col-xs-5 pull-right' style='display:inline;padding:0px;margin-left:-10px;'> " +
            "                       <div class='row' style='margin-top: 2%;margin-bottom: 5px'> "+
            "                       <div class='events-right col-xs-10' style='margin-bottom:0%;margin-top: 0%;padding-right: 0px'> " +
            "                           <div align='right' > " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 15px;font-family: \"Lato\",sans-serif;'><span class='text-muted' style='font-size: 13px;display: inline;font-family: \"Lato\",sans-serif;'>"+(category == "refer" ? "Referred by: " : "Posted by: ")+"</span>"+fl_name+"   " +
            "                                </div> " +
            "                                </div> " +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       </div>  " +

            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" ;
        return row_html;
    }

    var my_activities_arr = [];

    window.loadMyActivities = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_my_activities.jsp",

            success:    function(my_activities_list_json) {
                my_activities_list_json = escape(my_activities_list_json).replace(/%0A/g, "");
                my_activities_list_json = my_activities_list_json.replace(/%0D/g, "");
                my_activities_list_json = unescape(my_activities_list_json);

                if(my_activities_list_json != null && my_activities_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+my_activities_list_json.length+", profession_list_json: "+my_activities_list_json);

                my_activities_arr = JSON.parse(my_activities_list_json);

                if(my_activities_arr == null || my_activities_arr.length <= 0) {
                    $("#display_my_activity_results_dl dl").remove();

                    //No my_activities list found, do nothing
                    return;
                }

                var my_activities_found = false;

                console.log(new Date()+"\t Number of my_activities loading...: "+my_activities_arr.length);

                for(var cnt1 = 0; cnt1 < my_activities_arr.length; cnt1++) {
                    var activity_id1 = my_activities_arr[cnt1].activity_id;
                    $("#show_mypost_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_my_activity_results_dl dl").remove();                      //Then, Remove all posts

                for(var cnt = 0; cnt < my_activities_arr.length; cnt++) {
                    try {
                        var activity_id = my_activities_arr[cnt].activity_id;
                        var category = my_activities_arr[cnt].category;
                        var comments = my_activities_arr[cnt].comments;
                        var posted_on = my_activities_arr[cnt].posted_on;
                        var posted_on_format = my_activities_arr[cnt].posted_on_format;
                        var posted_by = my_activities_arr[cnt].posted_by;
                        var post_likes = my_activities_arr[cnt].post_likes;
                        var post_dislikes = my_activities_arr[cnt].post_dislikes;
                        var post_comments = my_activities_arr[cnt].post_comments;
                        var fl_name = my_activities_arr[cnt].fl_name;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        var row_html = getMyActivitiesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name);

                        $("#display_my_activity_results_dl").append(row_html);

//                        loadMyActivityResponses(activity_id);

                        my_activities_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(my_activities_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }
            }
        });
    };

    var activity_resp_arr = [];
    window.loadActivityResponses = function(activity_id) {
        $.ajax({
            type:         "post",
            url:          "action/load_activity_responses.jsp",
            data:         "activity_id="+activity_id,

            success:    function(activity_resp_list_json) {
                activity_resp_list_json = escape(activity_resp_list_json).replace(/%0A/g, "");
                activity_resp_list_json = activity_resp_list_json.replace(/%0D/g, "");
                activity_resp_list_json = unescape(activity_resp_list_json);

                if(activity_resp_list_json != null && activity_resp_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log("activity_id("+activity_id+")"+activity_resp_list_json);

//                console.log(new Date()+"\t Got the response: "+activity_resp_list_json.length+", activity_resp_list_json: "+activity_resp_list_json);

                activity_resp_arr = JSON.parse(activity_resp_list_json);

                if(activity_resp_arr == null || activity_resp_arr.length <= 0) {
                    //No activity responses list found, do nothing
                    return;
                }

                var activity_resp_found = false;

                console.log(new Date()+"\t Number of activity responses loading for activity("+activity_id+")...: "+activity_resp_arr.length);

                var row_html = "";

                for(var cnt = 0; cnt < activity_resp_arr.length; cnt++) {
                    try {
                        var response_id = activity_resp_arr[cnt].response_id;
                        var recommended_by_name = activity_resp_arr[cnt].recommended_by_name;
                        var recommended_by_photo = activity_resp_arr[cnt].recommended_by_photo;
                        var comments = activity_resp_arr[cnt].comments;
                        var recommended_on = activity_resp_arr[cnt].recommended_on;

                        row_html += getActivityResponsesRowHTML(response_id, recommended_by_name, recommended_by_photo, comments, recommended_on);

                        activity_resp_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(activity_resp_found) {
                    $("#show_ask_responses_"+activity_id+"_dl").html(row_html);
                    $("#show_ask_responses_"+activity_id+"_dl").show();
                }
            }
        });
    };

    var my_activity_like_details_list_arr = [];
    window.loadMyActivitylike_details = function(activity_id) {

        $.ajax({
            type:         "post",
            url:          "action/load_activity_likes_details.jsp",
            data:         "activity_id="+activity_id,

            success:    function(my_activity_like_details_list_json) {
                my_activity_like_details_list_json = escape(my_activity_like_details_list_json).replace(/%0A/g, "");
                my_activity_like_details_list_json = my_activity_like_details_list_json.replace(/%0D/g, "");
                my_activity_like_details_list_json = unescape(my_activity_like_details_list_json);

                if(my_activity_like_details_list_json != null && my_activity_like_details_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }


                my_activity_like_details_list_arr = JSON.parse(my_activity_like_details_list_json);

                if(my_activity_like_details_list_arr == null || my_activity_like_details_list_arr.length <= 0) {
                    $("#likes_status").hide();
                    $("#likes_details").hide("");
                    return;
                }

                var my_activity_like_details_list_found = false;

                console.log(new Date()+"\t Number of activity responses loading for my activity("+activity_id+")...: "+mypost_activity_resp_arr.length);

                var row_html = "";

                for(var cnt = 0; cnt < my_activity_like_details_list_arr.length; cnt++) {
                    try {
                        var like_details = my_activity_like_details_list_arr[cnt].like_details;

                        row_html += getActivitylikeDetails(like_details);
                        my_activity_like_details_list_found = true;
                    } catch (error) {
                        continue;

                    }
                }
                if(my_activity_like_details_list_arr) {
                    if($('#post_likes_dislikes_details').is(':visible')) {

                    } else{
                        $("#post_likes_dislikes_details").show();
                    }
                    $("#likes_details").val("");
                    $("#likes_details").html(row_html);
                    $("#likes_details").show();
                    $("#likes_status").show();

                } else {
                    $("#likes_status").hide();
                }



            }, error: function(error) {

            }
        });
    };

    function getActivitylikeDetails(like_details) {
        var row_html =
            " <p style='display:inline;font-family: \"Lato\",sans-serif;font-size: 12px'>"+like_details+",</p> ";
        return row_html;
    }

    var my_activity_dislike_details_list_arr = [];
    window.loadMyActivitydislike_details = function(activity_id) {

        $.ajax({
            type:         "post",
            url:          "action/load_activity_dislikes_details.jsp",
            data:         "activity_id="+activity_id,

            success:    function(my_activity_dislike_details_list_json) {
                my_activity_dislike_details_list_json = escape(my_activity_dislike_details_list_json).replace(/%0A/g, "");
                my_activity_dislike_details_list_json = my_activity_dislike_details_list_json.replace(/%0D/g, "");
                my_activity_dislike_details_list_json = unescape(my_activity_dislike_details_list_json);

                if(my_activity_dislike_details_list_json != null && my_activity_dislike_details_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }


                my_activity_dislike_details_list_arr = JSON.parse(my_activity_dislike_details_list_json);

                if(my_activity_dislike_details_list_arr == null || my_activity_dislike_details_list_arr.length <= 0) {
                    $("#dislikes_status").hide();
                    $("#dislikes_details").hide("");
                    return;
                }

                var my_activity_dislike_details_list_found = false;

                console.log(new Date()+"\t Number of activity responses loading for my activitylike("+activity_id+")...: "+mypost_activity_resp_arr.length);

                var row_html = "";

                for(var cnt = 0; cnt < my_activity_dislike_details_list_arr.length; cnt++) {
                    try {
                        var dislike_details = my_activity_dislike_details_list_arr[cnt].dislike_details;
                        row_html += getActivitydislikeDetails(dislike_details);
                        my_activity_dislike_details_list_found = true;
                    } catch (error) {
                        continue;
                    }
                    console.log(new Date()+"\t DisLikes: "+row_html);

                }
                if(my_activity_dislike_details_list_found) {
                    if($('#post_likes_dislikes_details').is(':visible')) {

                    } else{
                        $("#post_likes_dislikes_details").show();
                    }
                    $("#dislikes_details").val("");
                    $("#dislikes_details").html(row_html);
                    $("#dislikes_details").show();
                    $("#dislikes_status").show();
                }
                if (my_activity_dislike_details_list_found = false) {
                    $("#dislikes_status").hide();
                }
            }, error: function(error) {

            }
        });
    };

    function getActivitydislikeDetails(dislike_details) {

        var row_html =
            " <p style='display:inline;font-family: \"Lato\",sans-serif;font-size: 12px'>"+dislike_details+",</p> ";

        return row_html;

    }

    var my_activity_resp_arr = [];
    window.loadMyActivityResponses = function(activity_id) {
        $.ajax({
            type:         "post",
            url:          "action/load_activity_responses.jsp",
            data:         "activity_id="+activity_id,

            success:    function(my_activity_resp_list_json) {
                my_activity_resp_list_json = escape(my_activity_resp_list_json).replace(/%0A/g, "");
                my_activity_resp_list_json = my_activity_resp_list_json.replace(/%0D/g, "");
                my_activity_resp_list_json = unescape(my_activity_resp_list_json);

                if(my_activity_resp_list_json != null && my_activity_resp_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log("activity_id("+activity_id+")"+my_activity_resp_list_json);

//                console.log(new Date()+"\t Got the response: "+my_activity_resp_list_json.length+", profession_list_json: "+my_activity_resp_list_json);

                my_activity_resp_arr = JSON.parse(my_activity_resp_list_json);

                if(my_activity_resp_arr == null || my_activity_resp_arr.length <= 0) {
                    //No activity responses list found, do nothing
                    return;
                }

                var my_activity_resp_found = false;

                console.log(new Date()+"\t Number of activity responses loading for my activity("+activity_id+")...: "+my_activity_resp_arr.length);

                var row_html = "";

                for(var cnt = 0; cnt < my_activity_resp_arr.length; cnt++) {
                    try {
                        var response_id = my_activity_resp_arr[cnt].response_id;
                        var recommended_by_name = my_activity_resp_arr[cnt].recommended_by_name;
                        var recommended_by_photo = my_activity_resp_arr[cnt].recommended_by_photo;
                        var comments = my_activity_resp_arr[cnt].comments;
                        var recommended_on = my_activity_resp_arr[cnt].recommended_on;
                        var lin_profile_picture_url = my_activity_resp_arr[cnt].lin_profile_picture_url;
                        row_html += getActivityResponsesRowHTML(response_id, recommended_by_name, recommended_by_photo, comments, recommended_on,lin_profile_picture_url);

                        my_activity_resp_found = true;
                    } catch (error) {
                        continue;
                    }

                }
                if(my_activity_resp_found) {
                    $("#show_mypost_responses_"+activity_id+"_dl").html(row_html);
                    $("#show_mypost_responses_"+activity_id+"_dl").show();
                }
            }, error: function(error) {

            }
        });
    };

    function getActivitiesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,user_type,lin_profile_picture_url) {
        var posted_by_photo = "";
        var user_photo = "images/profile.jpg";
        var show_header = "";
        var show_image = "";
        var post_heading = "";
        var skills_details = "";
        var hire_button ="";
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        if(category == 'refer') {
            var refer_details = comments.split("|");
            show_header = refer_details[0];
            skills_details = refer_details[1];

            post_heading = "<h1 style='margin-bottom: 7px;font-size: 13px;margin-top:5px;margin-left:2px;margin-bottom: 0px;font-family: \"Lato\",sans-serif;'>Need opinion on  profile</h1>";
            show_image  =  "                                       <div class='col-xs-1 pull-left' style='margin-right: 0px'>"+
                "                                              <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>  " +
                "                                                <img class='img-circle' style='max-width:30px' src="+user_photo+" class='events-object img-rounded'> " +
                "                                             </p>" +
                "                                        </div>  ";


        }else{
            skills_details = comments;
        }

        if(user_type == 2){
          hire_button = " <button style='display:inline;padding:1px 5px 1px 5px;background-color: #00B8D4;font-family: \"Lato\",sans-serif;' id='hire_candidate' onclick='hired("+activity_id+");event.stopPropagation();'  class='btn btn-info btn-sm'>Hire</button>";
        }else{
            hire_button = "";
        }

        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fcfbfb;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row' style='margin-bottom:1%'>     " +
            "                               <div class='col-xs-8' onclick='showpost("+activity_id+")' style='cursor: pointer;'>     " +
            "<h1 style='font-size: 17px;margin-bottom: 3px;margin-top: 1px;font-family: \"Lato\",sans-serif;'>"+show_header+" </h1>"+
            "                                     <div class='row'> "+
            show_image +
            "                                        <div class='col-xs-10 pull-left' style='margin-left: 0px'>"+
            "                                         <p align ='left' class='pull-left' style='font-size: 12px;line-height:1.0;display:inline;margin-bottom:2%;margin-top:2px;margin-left:3px'> " +

            "<h1 style='font-size: 14px;margin-bottom: 3px;margin-top: 0px;margin-left: 3px;font-family: \"Lato\",sans-serif;'>"+skills_details+" </h1>"+
            post_heading+
            "                                          </p> " +
            "                                      </div>  " +
            "                                    </div>  " +
            "                               </div>  " +
            "                           <div  align='center' class='event-body col-xs-4 pull-right' style='display:inline;padding:0px;margin-left:-10px;'> " +
            hire_button+
            "                                   <button id='like_"+activity_id+"' style='padding:0px;background-color: transparent;margin-left:5% ' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px;background-color: transparent;  display: none;margin-left:10%'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +

            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; background-color: transparent; margin-right:15px;margin-right:10%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px;background-color: transparent; margin-right:10%; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +
            "                                   <button onclick='showpost("+activity_id+");' style='padding:0px;background-color: transparent ' class='btn btn-default btn-simple btn-md ' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 17px'></i> &nbsp;&nbsp;  " +
            "                                   </button><br>" +
            "                       <div class='row' style='margin-top: 2%;margin-bottom: 5px'> "+
            "                       <div class='events-right col-xs-8' style='margin-bottom:0%;margin-top: 0%;padding-right: 0px'> " +
            "                           <div align='right' > " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 12px;font-family: \"Lato\",sans-serif;'><span class='text-muted' style='font-size: 11px;display: inline;font-family: \"Lato\",sans-serif;'>"+(category == "refer" ? "Referred by: " : "Posted by: ")+"</span>"+fl_name+"   " +
            "                                   <p class='text-right text-muted' style='font-size: 7px; margin: 0px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> </h3>" +
            "                                </div> " +
            "                                </div> " +
            "                                        <div class='events-left col-xs-4 pull-left' style='padding-left: 5px'>"+
            "                                             <img class='img-circle pull-left' style='max-width:25px;margin-top: 4px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                                        </div>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       </div>  " +

            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" ;
        return row_html;
    }

    window.hired = function(activity_id) {      //1 - Liked; 2 - Disliked; 0 - Default

        $.ajax({
            type:         "post",
            url:          "action/hired.jsp",
            data:         "&activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg != null && msg.indexOf("success") >= 0) {
                    loadNetworkActivities();
                } else {
                    //TODO, do we need to alert user?
                }
            }
        });
    };

    function getpostrequirementRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name,suggestion,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            var  posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var show_header = "";
        var show_image = "";
        var post_heading = "";
        var skills_details = "";
        var show_suggestionsbutton = "";
        if(category == 'refer') {
            var refer_details = comments.split("|");
            show_header = refer_details[0];
            skills_details = refer_details[1];

            post_heading = "<h1 style='margin-bottom: 7px;font-size: 13px;margin-top:5px;margin-left:2px;margin-bottom: 0px'>Need opinion on  profile</h1>";
            show_image  =  "                                       <div class='col-xs-1 pull-left' style='margin-right: 0px'>"+
                "                                              <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>  " +
                "                                                <img class='img-circle' style='max-width:30px' src="+posted_by_photo+" class='events-object img-rounded'> " +
                "                                             </p>" +
                "                                        </div>  ";


        }else{
            skills_details = comments;
        }
		comments = comments.replace(/\n/g, "<br />");
        if(suggestion == 1){
            show_suggestionsbutton = "<a button style='display:inline;padding:1px 5px 1px 5px;background-color: #00B8D4;font-family: \"Lato\",sans-serif;' class='btn btn-info btn-sm' onclick=\"getshowsuggestform('"+comments+"');\" data-target='modal' type='submit'>Show suggestions</a>";
        }else{
            show_suggestionsbutton = "";
        }

        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fcfbfb;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row' style='margin-bottom:1%'>     " +
            "                               <div class='col-xs-8' onclick='showpostrequrement("+activity_id+")' style='cursor: pointer;'>     " +
            "<h1 style='font-size: 17px;margin-bottom: 3px;margin-top: 1px;font-family: \"Lato\",sans-serif;'>"+show_header+" </h1>"+
            "                                     <div class='row'> "+
            show_image +
            "                                        <div class='col-xs-10 pull-left' style='margin-left: 0px'>"+
           /* "                                         <p align ='left' class='pull-left' style='font-size: 12px;line-height:1.0;display:inline;margin-bottom:2%;margin-top:2px;margin-left:3px'> " +

            "<h1 style='font-size: 14px;margin-bottom: 3px;margin-top: 6px;margin-left: 3px'>"+skills_details+" </h1>"+ */
            "<div style='font-size: 13px;margin-bottom: 3px;margin-top: 6px;margin-left: 3px;font-family: \"Lato\",sans-serif;' class='mas' >"+skills_details+"</div>"+
            post_heading+
            "                                          </p> " +
            "                                      </div>  " +
            "                                    </div>  " +
            "                               </div>  " +
            "                           <div  align='center' class='event-body col-xs-4 pull-right' style='display:inline;padding:0px;margin-left:-10px;'> " +
           /* "                                   <button id='like_"+activity_id+"' style='padding:0px;background-color: transparent;margin-left:10% ' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px;background-color: transparent;  display: none;margin-left:10%'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +

            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; background-color: transparent; margin-right:15px;margin-right:10%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px;background-color: transparent; margin-right:10%; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +*/

            show_suggestionsbutton+
            "                                   <button onclick='showpostrequrement("+activity_id+");' style='padding:0px;background-color: transparent;margin-right: 25px; ' class='btn btn-default btn-simple btn-md pull-right' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 17px'></i> &nbsp;&nbsp;  " +
            "                                   </button><br>" +
            "                       <div class='row' style='margin-top: 2%;margin-bottom: 5px'> "+
            "                       <div class='events-right col-xs-8' style='margin-bottom:0%;margin-top: 0%;padding-right: 0px'> " +
            "                           <div align='right' > " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 12px;font-family: \"Lato\",sans-serif;'><span class='text-muted' style='font-size: 11px;display: inline;font-family: \"Lato\",sans-serif;'>"+(category == "refer" ? "Referred by: " : "Posted by: ")+"</span>"+fl_name+"   " +
            "                                   <p class='text-right text-muted' style='font-size: 7px; margin: 0px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> </h3>" +
            "                                </div> " +
            "                                </div> " +
            "                                        <div class='events-left col-xs-4 pull-left' style='padding-left: 5px'>"+
            "                                             <img class='img-circle pull-left' style='max-width:25px;margin-top: 5px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                                        </div>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       </div>  " +

            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" ;
        return row_html;
    }

    function getMyReferalrowHTML(activity_id, category, comments, posted_on_format, post_likes,post_dislikes,post_comments,fl_name,lin_profile_picture_url) {
        var user_photo = "images/profile.jpg";

        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var show_header = "";
        var skills_details = "";

        var referal_details = comments.split("|");
        show_header = referal_details[0];
        skills_details = referal_details[1];

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fbfdfd;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7' onclick='showMypostDetails("+activity_id+");' style='cursor: pointer;'' >     " +
            "                       <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;' src="+user_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px'> " +
            "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:12%;font-family: \"Lato\" ,sans-serif;'>"+show_header+" <br> "+ skills_details+" </p> "+
            "                               </p> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
            "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_myReferals("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referrals' style='font-family: \"Lato\" ,sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referrals' style='font-family: \"Lato\" ,sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_myReferals("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referrals' style='font-family: \"Lato\" ,sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button>&nbsp;&nbsp;  " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referrals' style='font-family: \"Lato\" ,sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +
            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;' class='btn btn-default btn-simple btn-md ' title='delete post' data-original-title='delete post' type='button' data-toggle='modal' onclick=\"getPostDetailsToDelete('"+activity_id+"');\" >" +
            "                                       <i class='fa fa-times' style='color:#ff6666;font-size: 17px;'></i>" +
            "                                   </button>&nbsp;&nbsp;" +

            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' title='number of comments' onclick=\"showMypostDetails('"+activity_id+"');\" data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_my_referrals' style='font-family: \"Lato\" ,sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 17px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:1%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 8px;' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px;font-family: \"Lato\" ,sans-serif;'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;font-family: \"Lato\" ,sans-serif;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>";
        return row_html;
    }

    function getActivityResponsesRowHTML(response_id, recommended_by_name, recommended_by_photo, comments, recommended_on,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var row_html = "" +
            "<dl style='padding: 0px;display:inline;margin-bottom:1%;'> "+
            "   <dd class='pos-left clearfix' style='padding: 0px'> "+
            "       <div class='events' style='background-color:#f9f8f8;padding: 5px 5px 0'> "+
            "           <div class='row'>"+
            "            <div class='col-xs-8'>"+
            "              <div class='events-body'>  "+
            "                 <div align='left' class='dont-break-out' style='line-height: 1.25;margin-bottom:4px;padding-left:5px'>  "+
            "                   <p class='example' style='font-size: 12px;text-align: justify;text-justify: inter-word;font-family: \"Lato\",sans-serif;'>"+comments+"</p><br>  "+
            "                 </div>  "+
            "               </div>   "+
            "             </div> "+
            "            <div class='col-xs-4'>"+
            "                    <div class='row'>"+
            "                          <div class='col-xs-9' style='padding-right: 0px'>"+
                    "                       <h5 class='events-heading text-right dont-break-out' style='font-size:12px;word-wrap: break-word;margin-left: 5px;margin-bottom: 0px;font-family: \"Lato\",sans-serif;'>"+recommended_by_name+"</h5> "+
            "                              <span class='text-muted pull-right' style='font-size: 9px;font-family: \"Lato\",sans-serif;'>"+recommended_on+"</span><br> "+
            "                             </div> "+
            "                          <div class='col-xs-3 ' style='padding-left: 0px'>"+
            "                            <img class='img-circle' style='max-width:30px;margin-left: 5px;margin-top: 8px' src='"+posted_by_photo+"'> "+
            "                         </div> "+
            "                 </div> "+
            "            </div>   "+
            "         </div>" +
            "       </div>   "+
            "   </dd>    "+
            "</dl>";

        return row_html;
    }

    window.showCommentTextBoxForActivity = function(activity_id) {
        $("#show_response_status_"+activity_id).html("");
        $("#show_response_status_"+activity_id).hide();

        $("#comment_textbox_for_activity_"+activity_id+"").show();
        $("#post_comment_in_network_"+activity_id).focus();
        $("#show_comment_textbox_"+activity_id+"").hide();
        $("#hide_comment_textbox_"+activity_id+"").show();
    };

    window.hideCommentTextBoxForActivity = function(activity_id) {
        $("#show_response_status_"+activity_id).html("");
        $("#show_response_status_"+activity_id).hide();
        $("#post_comment_in_network_"+activity_id).val("");

        $("#comment_textbox_for_activity_"+activity_id+"").hide();
        $("#hide_comment_textbox_"+activity_id+"").hide();
        $("#show_comment_textbox_"+activity_id+"").show();
    };



    window.insertAsk_post = function(post_comments,suggestion_status) {
            $.ajax({
                type:         "post",
                url:          "action/ask_in_network.jsp",
                data:         "comments="+encodeURIComponent(post_comments)+
                              "&suggestion_status="+encodeURIComponent(suggestion_status),

                success:    function(msg) {
                    msg = escape(msg).replace(/%0A/g, "");
                    msg = msg.replace(/%0D/g, "");
                    msg = unescape(msg);

                    if(msg != null && msg.indexOf("session_expired") >= 0) {
                        window.location = "login.html";
                    } else if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                        $("#company_feed_status_info").html("<div class='alert alert-danger'><span style='font-size: 15px'>Please set your profile name to submit post</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                        $("#company_feed_status_info").show();
                    } else if(msg != null && msg.indexOf("success") >= 0) {
                         $('#ask_in_network').val('');
                         loadPostRequirements();
                    } else {
                        $("#ask_in_network_status").html("<font color=red>Failed to post</font>");
                    }
                }
            });
    };

    window.goBackToProfilesDiscussion = function() {
        $("#display_post_dl").hide();
        $("#post_likes_dislikes_details").hide();
        $("#display_activity_results_dl").show();
        $("#custom-search-form").show();
        $("#search_by_val_div").show();
    };

    var loadpost_arr = [];
    window.showpost = function (activity_id) {
          $("#custom-search-form").hide();
          $("#search_by_val_div").hide();
          $("#post_likes_dislikes_details").hide();
        $.ajax({
            type:         "post",
            url:         "action/load_post.jsp",
            data:         "activity_id="+activity_id,

            success:    function(loadPost_list_json) {
                loadPost_list_json = escape(loadPost_list_json).replace(/%0A/g, "");
                loadPost_list_json = loadPost_list_json.replace(/%0D/g, "");
                loadPost_list_json = unescape(loadPost_list_json);

                if(loadPost_list_json != null && loadPost_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

                //              console.log(new Date()+"\t Got the response: "+loadPost_list_json.length+", loadPost_list_json: "+loadPost_list_json);

                loadpost_arr = JSON.parse(loadPost_list_json);

                if(loadpost_arr == null || loadpost_arr.length <= 0) {
                    $("#display_post_dl dl").remove();

                    //No loadpost list found, do nothing
                    return;
                }

                var loadpost_found = false;

                console.log(new Date()+"\t Number of loadpost loading...: "+loadpost_arr.length);

                for(var cnt1 = 0; cnt1 < loadpost_arr.length; cnt1++) {
                    var activity_id1 = loadpost_arr[cnt1].activity_id;
                    $("#show_mypost_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_post_dl dl").remove();                      //Then, Remove all posts
                $("#comment_textbox_for_mypost_activity").remove();                    //Then, Remove all posts
                $("#go_back_to_profiles_discussion").remove();                         //Remove go_back_to_profiles_discussion button

                var row_html = "";

                for(var cnt = 0; cnt < loadpost_arr.length; cnt++) {
                    if(cnt == 0) {
                        row_html += "<a onclick='goBackToProfilesDiscussion();' id='go_back_to_profiles_discussion' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }

                    try {
                        var activity_id = loadpost_arr[cnt].activity_id;
                        var category = loadpost_arr[cnt].category;
                        var comments = loadpost_arr[cnt].comments;
                        var posted_on = loadpost_arr[cnt].posted_on;
                        var posted_on_format = loadpost_arr[cnt].posted_on_format;
                        var posted_by = loadpost_arr[cnt].posted_by;
                        var post_likes = loadpost_arr[cnt].post_likes;
                        var post_dislikes = loadpost_arr[cnt].post_dislikes;
                        var post_comments = loadpost_arr[cnt].post_comments;
                        var fl_name = loadpost_arr[cnt].fl_name;
                        var lin_profile_picture_url = loadpost_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html += getloadPostHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url);
                        $("#display_my_activity_results_dl").hide();
                        $("#display_activity_results_dl").hide();
                        $("#display_post_dl").show();
                        loadMyActivitylike_details(activity_id);
                        loadMyActivitydislike_details(activity_id);

                        loadMyActivityResponses(activity_id);

                        $("#display_post_dl").append(row_html);


                        loadpost_found = true;
                    } catch (error) {
                        continue;
                    }

                }
                if(loadpost_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }
            }
        });
    };

    window.showpostrequrement = function (activity_id) {
        $("#post_requirement_to_network").hide();
        $.ajax({
            type:         "post",
            url:         "action/load_post.jsp",
            data:         "activity_id="+activity_id,

            success:    function(loadPost_list_json) {
                loadPost_list_json = escape(loadPost_list_json).replace(/%0A/g, "");
                loadPost_list_json = loadPost_list_json.replace(/%0D/g, "");
                loadPost_list_json = unescape(loadPost_list_json);

                if(loadPost_list_json != null && loadPost_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

                //              console.log(new Date()+"\t Got the response: "+loadPost_list_json.length+", loadPost_list_json: "+loadPost_list_json);

                loadpost_arr = JSON.parse(loadPost_list_json);

                if(loadpost_arr == null || loadpost_arr.length <= 0) {
                    $("#display_requirement_post_dl dl").remove();

                    //No loadpost list found, do nothing
                    return;
                }

                var loadpost_found = false;

                console.log(new Date()+"\t Number of loadpost loading...: "+loadpost_arr.length);

                for(var cnt1 = 0; cnt1 < loadpost_arr.length; cnt1++) {
                    var activity_id1 = loadpost_arr[cnt1].activity_id;
                    $("#show_mypost_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_requirement_post_dl dl").remove();                      //Then, Remove all posts
                $("#comment_textbox_for_mypost_activity").remove();                    //Then, Remove all posts
                $("#go_back_to_posts_discussion").remove();                         //Remove go_back_to_profiles_discussion button
                $("#show_suggestions dl").remove();
                $("#go_back_to_askPost").remove();                         //Remove go_back_to_profiles_discussion button

                var row_html = "";

                for(var cnt = 0; cnt < loadpost_arr.length; cnt++) {
                    if(cnt == 0) {
                        row_html += "<a onclick='goBackToPostsDiscussion();' id='go_back_to_posts_discussion' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }

                    try {
                        var activity_id = loadpost_arr[cnt].activity_id;
                        var category = loadpost_arr[cnt].category;
                        var comments = loadpost_arr[cnt].comments;
                        var posted_on = loadpost_arr[cnt].posted_on;
                        var posted_on_format = loadpost_arr[cnt].posted_on_format;
                        var posted_by = loadpost_arr[cnt].posted_by;
                        var post_likes = loadpost_arr[cnt].post_likes;
                        var post_dislikes = loadpost_arr[cnt].post_dislikes;
                        var post_comments = loadpost_arr[cnt].post_comments;
                        var fl_name = loadpost_arr[cnt].fl_name;
                        var lin_profile_picture_url = loadpost_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html += getloadPostreqHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url);
                        $("#display_requirement_activity_results_dl").hide();
                        $("#display_my_requirement_activity_results_dl").hide();
                        $("#show_suggestions").hide();
                        $("#display_requirement_post_dl").show();


                        $("#display_requirement_post_dl").append(row_html);

                        loadMyActivityResponses(activity_id);
                        loadpost_found = true;
                    } catch (error) {
                        continue;
                    }

                }
                if(loadpost_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }
            }
        });
    };
    window.goBackToPostsDiscussion = function() {
        $("#display_requirement_post_dl").hide();
        $("#show_suggestions").hide();
        $("#display_requirement_activity_results_dl").show();
        $("#display_my_requirement_activity_results_dl").show();
        $("#post_requirement_to_network").show();
    };

    window.go_back_to_mypost_discussion = function() {
        $("#display_myreferals_dl").hide();

        $("#load_referrals").show();
    };


    window.showMypostDetails = function (activity_id) {
        $.ajax({
            type:         "post",
            url:         "action/load_post.jsp",
            data:         "activity_id="+activity_id,

            success:    function(loadPost_list_json) {
                loadPost_list_json = escape(loadPost_list_json).replace(/%0A/g, "");
                loadPost_list_json = loadPost_list_json.replace(/%0D/g, "");
                loadPost_list_json = unescape(loadPost_list_json);

                if(loadPost_list_json != null && loadPost_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

                //              console.log(new Date()+"\t Got the response: "+loadPost_list_json.length+", loadPost_list_json: "+loadPost_list_json);

                loadpost_arr = JSON.parse(loadPost_list_json);

                if(loadpost_arr == null || loadpost_arr.length <= 0) {
                    $("#display_post_dl dl").remove();

                    //No loadpost list found, do nothing
                    return;
                }

                var loadpost_found = false;

                console.log(new Date()+"\t Number of loadpost loading...: "+loadpost_arr.length);

                for(var cnt1 = 0; cnt1 < loadpost_arr.length; cnt1++) {
                    var activity_id1 = loadpost_arr[cnt1].activity_id;
                    $("#show_mypost_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_myreferals_dl dl").remove();                      //Then, Remove all posts
                $("#comment_textbox_for_mypost_activity").remove();                      //Then, Remove all posts
                $("#go_back_to_mypost_discussion").remove();                     //Then, Remove all posts

                var row_html = "";

                for(var cnt = 0; cnt < loadpost_arr.length; cnt++) {

                    if(cnt == 0) {
                        row_html += "<a onclick='go_back_to_mypost_discussion();' id='go_back_to_mypost_discussion' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }

                    try {
                        var activity_id = loadpost_arr[cnt].activity_id;
                        var category = loadpost_arr[cnt].category;
                        var comments = loadpost_arr[cnt].comments;
                        var posted_on = loadpost_arr[cnt].posted_on;
                        var posted_on_format = loadpost_arr[cnt].posted_on_format;
                        var posted_by = loadpost_arr[cnt].posted_by;
                        var post_likes = loadpost_arr[cnt].post_likes;
                        var post_dislikes = loadpost_arr[cnt].post_dislikes;
                        var post_comments = loadpost_arr[cnt].post_comments;
                        var fl_name = loadpost_arr[cnt].fl_name;
                        var lin_profile_picture_url = loadpost_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html += getMyPostHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url);
                        $("#load_referrals").hide();
                        $("#display_myreferals_dl").show();
                        $("#display_myreferals_dl").append(row_html);

                        loadMypostResponses(activity_id);

                        loadpost_found = true;
                    } catch (error) {
                        continue;
                    }

                }
                if(loadpost_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }
            }
        });
    };

    var mypost_activity_resp_arr = [];
    window.loadMypostResponses = function(activity_id) {
        $.ajax({
            type:         "post",
            url:          "action/load_activity_responses.jsp",
            data:         "activity_id="+activity_id,

            success:    function(my_activity_resp_list_json) {
                my_activity_resp_list_json = escape(my_activity_resp_list_json).replace(/%0A/g, "");
                my_activity_resp_list_json = my_activity_resp_list_json.replace(/%0D/g, "");
                my_activity_resp_list_json = unescape(my_activity_resp_list_json);

                if(my_activity_resp_list_json != null && my_activity_resp_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log("activity_id("+activity_id+")"+my_activity_resp_list_json);

//                console.log(new Date()+"\t Got the response: "+my_activity_resp_list_json.length+", profession_list_json: "+my_activity_resp_list_json);

                mypost_activity_resp_arr = JSON.parse(my_activity_resp_list_json);

                if(mypost_activity_resp_arr == null || mypost_activity_resp_arr.length <= 0) {
                    //No activity responses list found, do nothing
                    return;
                }

                var my_activity_resp_found = false;

                console.log(new Date()+"\t Number of activity responses loading for my activity("+activity_id+")...: "+mypost_activity_resp_arr.length);

                var row_html = "";

                for(var cnt = 0; cnt < mypost_activity_resp_arr.length; cnt++) {
                    try {
                        var response_id = mypost_activity_resp_arr[cnt].response_id;
                        var recommended_by_name = mypost_activity_resp_arr[cnt].recommended_by_name;
                        var recommended_by_photo = mypost_activity_resp_arr[cnt].recommended_by_photo;
                        var comments = mypost_activity_resp_arr[cnt].comments;
                        var recommended_on = mypost_activity_resp_arr[cnt].recommended_on;
                        var lin_profile_picture_url = mypost_activity_resp_arr[cnt].lin_profile_picture_url;
                        row_html += getmypostResponsesRowHTML(response_id, recommended_by_name, recommended_by_photo, comments, recommended_on,lin_profile_picture_url);

                        my_activity_resp_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(my_activity_resp_found) {
                    $("#show_mypost_responses_"+activity_id+"_dl").html(row_html);
                    $("#show_mypost_responses_"+activity_id+"_dl").show();
                }
            }, error: function(error) {

            }
        });
    };


    function getmypostResponsesRowHTML(response_id, recommended_by_name, recommended_by_photo, comments, recommended_on,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var row_html = "" +
            "<dl style='padding: 0px;display:inline;margin-bottom:1%;'> "+
            "   <dd class='pos-left clearfix' style='padding: 0px'> "+
            "       <div class='events' style='background-color:#f9f8f8;padding: 5px 5px 0'> "+
            "           <div class='row'>"+
            "            <div class='col-xs-8'>"+
            "              <div class='events-body'>  "+
            "                 <div align='left' class='dont-break-out' style='line-height: 1.25;margin-bottom:4px'>  "+
            "                   <span style='font-size: 12px;word-wrap: break-word;margin-left: 5px;font-family: \"Lato\",sans-serif;'>"+comments+"</span><br>  "+
            "                 </div>  "+
            "               </div>   "+
            "             </div> "+
            "            <div class='col-xs-4'>"+
            "                    <div class='row'>"+
            "                          <div class='col-xs-9' style='padding-right: 0px'>"+
            "                       <h5 class='events-heading text-right dont-break-out' style='font-size:12px;word-wrap: break-word;margin-left: 5px;margin-bottom: 0px;font-family: \"Lato\",sans-serif;'>"+recommended_by_name+"</h5> "+
            "                              <span class='text-muted pull-right' style='font-size: 9px;font-family: \"Lato\",sans-serif;'>"+recommended_on+"</span><br> "+
            "                             </div> "+
            "                          <div class='col-xs-3 ' style='padding-left: 0px'>"+
            "                            <img class='img-circle' style='max-width:30px;margin-left: 5px;margin-top: 5px' src='"+posted_by_photo+"'> "+
            "                         </div> "+
            "                 </div> "+
            "            </div>   "+
            "         </div>" +
            "       </div>   "+
            "   </dd>    "+
            "</dl>";

        return row_html;
    }

    function getloadPostreqHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by,  fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var my_post_header = "";
        var my_post_skills_details = "";
        var my_post_comments_refer = "";


        var my_post_details = comments.split("|");
        my_post_header = my_post_details[0];
        my_post_skills_details = my_post_details[1];
        if (my_post_skills_details != null){
            my_post_comments  = "<div style='font-size: 13px;margin-bottom: 3px;margin-top: 6px;margin-left: 3px;font-family: \"Lato\",sans-serif;' class='mas'>"+my_post_header+" <br> "+ my_post_skills_details+" </div> ";
        } else{
            my_post_comments  = comments;
        }

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#f9f8f8;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7'>     " +
            "                               <div style='font-size: 13px;margin-bottom: 3px;margin-top: 6px;margin-left: 3px;font-family: \"Lato\",sans-serif;' class='mas'> " +
            my_post_comments+

            "                               </div> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
          /*  "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_FromComments("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"_for_comments'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"_for_comments'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_FromComments("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_for_comments'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button>  " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_for_comments'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button> &nbsp;&nbsp;&nbsp;" + */
            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px; cursor: default' class='btn btn-default btn-simple btn-md pull-right' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 20px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:1%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 8px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px;font-family: \"Lato\",sans-serif;'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +

            "                   <div style='display:none;' id='show_response_status_"+activity_id+"'>" +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" +

            "           <div id='show_mypost_responses_"+activity_id+"_dl' class='text-left' style='max-width: 98%;margin-bottom: 0%;overflow-x: hidden; display: none;margin-left:20px'>" +
            "           </div>"+
            "           <div class='row'  id='comment_textbox_for_mypost_activity'>" +
            "               <div class='col-xs-9 text-left' style='margin-top: 1%;width:78%;padding:0px'>" +
            "                   <textarea type='text' class='form-control' style='height:35px;margin-left:6%;width: 95%;font-family: \"Lato\",sans-serif;' placeholder='Comment' name='post_comment_in_network_"+activity_id+"' id='post_comment_in_network_"+activity_id+"'></textarea>" +
            "               </div>" +
            "               <div class='col-xs-2 text-left' style='margin-top: 1.2%; padding:0px; margin-left:10px'>" +
            "                   <button class='btn  btn-info btn-md' style='background-color: #00B8D4;font-family: \"Lato\",sans-serif;' onclick=postResponseToAsk("+activity_id+"); return false;>Post</button>" +
            "               </div>" +
            "           </div>";

        return row_html;
    }

    function getloadPostHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by,  fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var my_post_header = "";
        var my_post_skills_details = "";
        var my_post_comments_refer = "";


        var my_post_details = comments.split("|");
        my_post_header = my_post_details[0];
        my_post_skills_details = my_post_details[1];
        if (my_post_skills_details != null){
            my_post_comments  = "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:2%;font-family: \"Lato\",sans-serif;'>"+my_post_header+" <br> "+ my_post_skills_details+" </p> ";
        } else{
            my_post_comments  = comments;
        }

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#f9f8f8;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7'>     " +
            "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px;font-family: \"Lato\",sans-serif;'> " +
            my_post_comments+

            "                               </p> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
             "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_FromComments("+activity_id+", 1);'> " +
             "                                       <span id='no_like_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
             "                                   </button>  " +
             "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
             "                                       <span id='no_like_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
             "                                   </button>  " +
             "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_FromComments("+activity_id+", 2);'>   " +
             "                                       <span id='no_dislike_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 20px'></i>  " +
             "                                   </button>  " +
             "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
             "                                       <span id='no_dislike_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 20px'></i>  " +
             "                                   </button> &nbsp;&nbsp;&nbsp;" +
            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px; cursor: default' class='btn btn-default btn-simple btn-md' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_for_comments' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 20px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:1%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 5px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px;font-family: \"Lato\",sans-serif;'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +

            "                   <div style='display:none;' id='show_response_status_"+activity_id+"'>" +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" +

            "           <div id='show_mypost_responses_"+activity_id+"_dl' class='text-left' style='max-width: 98%;margin-bottom: 0%;overflow-x: hidden; display: none;margin-left:20px'>" +
            "           </div>"+
            "           <div class='row'  id='comment_textbox_for_mypost_activity'>" +
            "               <div class='col-xs-9 text-left' style='margin-top: 1%;width:78%;padding:0px'>" +
            "                   <textarea type='text' class='form-control' style='height:35px;margin-left:6%;width: 95%;font-family: \"Lato\",sans-serif;' placeholder='Comment' name='post_comment_in_network_"+activity_id+"' id='post_comment_in_network_"+activity_id+"'></textarea>" +
            "               </div>" +
            "               <div class='col-xs-2 text-left' style='margin-top: 1.2%; padding:0px; margin-left:10px'>" +
            "                   <button class='btn  btn-info btn-md' style='background-color: #00B8D4;font-family: \"Lato\",sans-serif;' onclick=postResponseToAsk("+activity_id+"); return false;>Post</button>" +
            "               </div>" +
            "           </div>";

        return row_html;
    }

    function getMyPostHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by,  fl_name,post_likes, post_dislikes, post_comments,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var show_header = "";
        var skills_details = "";

        var referal_details = comments.split("|");
        show_header = referal_details[0];
        skills_details = referal_details[1];

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fbfdfd;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7'>     " +
            "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px;font-family: \"Lato\",sans-serif;'> " +
            "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:2%;font-family: \"Lato\",sans-serif;'>"+show_header+" <br> "+ skills_details+" </p> "+
            "                               </p> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
            "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_myReferralComments("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referral_comments' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;' rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referral_comments' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#00B8D4; font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_myReferralComments("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referral_comments' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button>  " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;' rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referral_comments' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button> &nbsp;&nbsp;&nbsp;" +
            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px; cursor: default' class='btn btn-default btn-simple btn-md' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_my_referral_comments' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 20px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:1%;margin-bottom: 0px;font-family: \"Lato\",sans-serif;'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 8px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px;font-family: \"Lato\",sans-serif;'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +

            "                   <div style='display:none;' id='show_response_status_"+activity_id+"'>" +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" +
            "           <div id='show_mypost_responses_"+activity_id+"_dl' class='text-left' style='max-width: 98%;margin-bottom: 0%;overflow-x: hidden; display: none;margin-left:20px'>" +
            "           </div>"+
            "<div class='row'  id='comment_textbox_for_mypost_activity'>" +
            "                                    <div class='col-xs-9 text-left' style='margin-top: 1%;width:78%;padding:0px'>" +
            "                                        <textarea type='text' class='form-control' style='height:35px;margin-left:6%;width: 95%;font-family: \"Lato\",sans-serif;' placeholder='Comment' name='post_comment_in_network_"+activity_id+"' id='post_comment_in_network_"+activity_id+"'></textarea>" +
            "                                    </div>" +
            "                                <div class='col-xs-2 text-left' style='margin-top: 1.2%; padding:0px; margin-left:10px'>" +
            "                                    <button class='btn btn-info btn-md' style='background-color: #00B8D4;font-family: \"Lato\",sans-serif;' onclick=responsesToMyPost("+activity_id+"); return false;>Post</button>" +
            "                                </div>" +
            "                                </div>";

        return row_html;
    }


    window.postResponseToAsk = function(activity_id) {
        var comments = $("#post_comment_in_network_"+activity_id).val();

        $("#show_response_status_"+activity_id).html("");
        $("#show_response_status_"+activity_id).hide();
        $("#post_comment_in_network_"+activity_id).val("");
        $.ajax({
            type:         "post",
            url:          "action/post_response_to_ask.jsp",
            data:         "activity_id="+activity_id+"&comments="+comments,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                } else if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                    $("#company_feed_status_info").html("<div class='alert alert-danger'><span style='font-size: 15px'>Please set your profile name to submit comments</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#company_feed_status_info").show();
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $("#show_response_status_"+activity_id).html("<font color=#00B8D4>Successfully posted</font><br>");
                    $("#show_response_status_"+activity_id).show();

                    //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id).text(no_of_likes);
                    $("#no_like_"+activity_id+"_for_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id).text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_for_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id).text(no_of_comments);
                    $("#no_comments_"+activity_id+"_for_comments").text(no_of_comments);

                    loadMyActivityResponses(activity_id);                               //TODO, refresh the list automatically
                } else {
                    $("#show_response_status_"+activity_id).html("<font color=red>Failed to post</font><br>");
                }
            }
        });
    };

    window.responsesToMyPost = function(activity_id) {
        var comments = $("#post_comment_in_network_"+activity_id).val();

        $("#show_response_status_"+activity_id).html("");
        $("#show_response_status_"+activity_id).hide();

        $.ajax({
            type:         "post",
            url:          "action/post_response_to_ask.jsp",
            data:         "activity_id="+activity_id+"&comments="+comments,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                } else if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                    $("#company_feed_status_info").html("<div class='alert alert-danger'><span style='font-size: 15px'>Please set your profile name to submit comments</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#company_feed_status_info").show();
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $("#show_response_status_"+activity_id).html("<font color=#00B8D4>Successfully posted</font><br>");
                    $("#show_response_status_"+activity_id).show();
                    $("#post_comment_in_network_"+activity_id).val("");
                    //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id+"_my_referrals").text(no_of_likes);
                    $("#no_like_"+activity_id+"_my_referral_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id+"_my_referrals").text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_my_referral_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id+"_my_referrals").text(no_of_comments);
                    $("#no_comments_"+activity_id+"_my_referral_comments").text(no_of_comments);

                    loadMypostResponses(activity_id);                               //TODO, refresh the list automatically
                } else {
                    $("#show_response_status_"+activity_id).html("<font color=red>Failed to post</font><br>");
                }
            }
        });
    };

    window.postLikeStatus = function(activity_id, like_status) {      //1 - Liked; 2 - Disliked; 0 - Default
        $.ajax({
            type:         "post",
            url:          "action/post_like_status.jsp",
            data:         "&activity_id="+activity_id+"&like_status="+like_status,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg != null && msg.indexOf("success") >= 0) {                                           //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id).text(no_of_likes);
                    $("#no_like_"+activity_id+"_for_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id).text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_for_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id).text(no_of_comments);
                    $("#no_comments_"+activity_id+"_for_comments").text(no_of_comments);
                } else {
                    //TODO, do we need to alert user?
                }
            }
        });
    };

    window.postLikeStatus_FromComments = function(activity_id, like_status) {      //1 - Liked; 2 - Disliked; 0 - Default
        $.ajax({
            type:         "post",
            url:          "action/post_like_status.jsp",
            data:         "&activity_id="+activity_id+"&like_status="+like_status,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg != null && msg.indexOf("success") >= 0) {                                          //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id).text(no_of_likes);
                    $("#no_like_"+activity_id+"_for_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id).text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_for_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id).text(no_of_comments);
                    $("#no_comments_"+activity_id+"_for_comments").text(no_of_comments);

                } else {
                    //TODO, do we need to alert user?
                }
                loadMyActivitylike_details(activity_id);
                loadMyActivitydislike_details(activity_id)
            }
        });
    };

    window.postLikeStatus_myReferals = function(activity_id, like_status) {      //1 - Liked; 2 - Disliked; 0 - Default
        $.ajax({
            type:         "post",
            url:          "action/post_like_status.jsp",
            data:         "&activity_id="+activity_id+"&like_status="+like_status,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "failed") {
                    //TODO, do we need to alert user?
                } else {                                            //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id+"_my_referrals").text(no_of_likes);
                    $("#no_like_"+activity_id+"_my_referral_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id+"_my_referrals").text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_my_referral_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id+"_my_referrals").text(no_of_comments);
                    $("#no_comments_"+activity_id+"_my_referral_comments").text(no_of_comments);
                }
            }
        });
    };

    window.postLikeStatus_myReferralComments = function(activity_id, like_status) {      //1 - Liked; 2 - Disliked; 0 - Default
        $.ajax({
            type:         "post",
            url:          "action/post_like_status.jsp",
            data:         "&activity_id="+activity_id+"&like_status="+like_status,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "failed") {
                    //TODO, do we need to alert user?
                } else {                                            //update the likes, dislikes and comments count inline without refreshing the page
                    var split_activity_details = msg.split("|");
                    var status = split_activity_details[0];
                    var no_of_likes = split_activity_details[1];
                    var no_of_dislikes = split_activity_details[2];
                    var no_of_comments = split_activity_details[3];

                    $("#no_like_"+activity_id+"_my_referrals").text(no_of_likes);
                    $("#no_like_"+activity_id+"_my_referral_comments").text(no_of_likes);
                    $("#no_dislike_"+activity_id+"_my_referrals").text(no_of_dislikes);
                    $("#no_dislike_"+activity_id+"_my_referral_comments").text(no_of_dislikes);
                    $("#no_comments_"+activity_id+"_my_referrals").text(no_of_comments);
                    $("#no_comments_"+activity_id+"_my_referral_comments").text(no_of_comments);
                }
            }
        });
    };

    window.getPostDetailsToDelete = function(activity_id) {
        var post_url = "action/delete_postdetails_confirmation.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("Delete Post") >= 0) {
                    $("#delete_post_form").html(msg);
                } else {
                    //TODO, alert user
                }
                $("#click_to_display_deletepost_form").click();
            }
        });
    };

    window.DeletePost = function(activity_id) {
        $.ajax({
            type:         "post",
            url:          "action/deletepost.jsp",
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $("#deletepost_status_success").show();
                   loadMyReferals();
                } else {
                    //DO NOTHING
                }
            }
        });
    };

    $("#signoutAll").click(function(e) {

        $.ajax({
            type:         "post",
            url:         "action/remove_session.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("success") >= 0) {
                    IN.User.logout(function() {
                        window.location = "login.html";
                    });
                }
            }
        });

    });

    window.insertDomainName = function() {
        var domain_name = $('#domain_name').val().trim();
        if(domain_name == null || domain_name == "") {
            $("#domain_name_status").show();
            $("#domain_name").focus();
            return false;
        }

        $.ajax({
            type:         "post",
            url:         "action/add_domain_name.jsp",
            data:        "domain_name="+domain_name,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg == "success") {
                    window.location = "add_team_members.html";
                } else if(msg != null && msg == "company_already_exists") {
                    $("#domain_name_status").html("Company already exists <br>Please try with another name or contact company admin to join");
                    $("#domain_name_status").show();
                } else {
                    $("#domain_name_status").html("Failed to create company <br>Please try again or contact support");
                    $("#domain_name_status").show();
                }
            }
        });
    };

    window.addTeamMembers = function(invite) {              //invite - 0 | 1
        $("#email_address_alert").hide();
        $("#email_address_add_success").hide();

        var email_address = $('#contact_email').val().trim();
        if(email_address == null || email_address == "") {
            $("#email_address_alert").show();
            $("#contact_email").focus();
            return false;
        }

        email_address = email_address.replace(";",",");

        var res = validateEmails(email_address);

        if(res == false) {
            $("#email_address_alert").show();
            return;
        }

        $.ajax({
            type:        "post",
            url:         "action/add_team_members.jsp",
            data:        "email_address="+email_address+"&invite="+invite,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                } else if(msg != null && msg.indexOf("Success") >= 0) {
                    $("#skip_next_btn").text("Next");
                    $("#email_address_add_success").html(msg);
                    $("#email_address_add_success").show();
                } else {
                    $("#email_address_alert").html(msg);
                    $("#email_address_alert").show();
                }
            }, error: function(error) {

            }
        });
    };

    function validateEmails(emailaddresses) {

        if(emailaddresses == null || emailaddresses == "") {
            return false;
        }

        var regex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,10})?$/;
        var result = emailaddresses.replace(/\s/g, "").split(/,/);
        for(var i = 0;i < result.length;i++) {
            if(!regex.test(result[i])) {
                return false;
            }
        }
        return true;
    }

    var mycontacts_arr = [];
    window.loadMycontacts = function() {
         $("#contact_status_info").hide();
		        $("#load_teammeber_referals").hide();
		        $("#display_teammember_referaldetails").hide();
		        $("#contact_status_info").hide();
		        $("#company_feed_status_info").hide();
		        $('#myreferals').hide();
		        $('#myposts').hide();
		        $('#mypoints').hide();
		        $("#posts").hide();
		        $("#hire").hide();
		        $("#display_requirement_activity_results_dl").hide();
		        $("#display_my_requirement_activity_results_dl").hide();
		        $('#mycontacts').show();
		        $('#contacts_display').show();
		        $('#display_contacts').show();



        $.ajax({
            type:         "post",
            url:          "action/load_mycontacts.jsp",

            success:    function(mycontacts_list_json) {
                mycontacts_list_json = escape(mycontacts_list_json).replace(/%0A/g, "");
                mycontacts_list_json = mycontacts_list_json.replace(/%0D/g, "");
                mycontacts_list_json = unescape(mycontacts_list_json);

                if(mycontacts_list_json != null && mycontacts_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t mycontacts_list_json: "+mycontacts_list_json);

                mycontacts_arr = JSON.parse(mycontacts_list_json);

                var row_html = "";

                if(mycontacts_arr == null || mycontacts_arr.length <= 0) {
                    //No contacts found, do nothing
                    $("#mycontacts_menu").hide();
                    row_html = getNoContactsRowHTML();
                    $("#display_contacts").html(row_html);
                    return;
                }

                var mycontacts_found = false;

                console.log(new Date()+"\t Number of contacts loading: "+mycontacts_arr.length);
                $("#load_teammeber_referals dl").remove();

                for(var cnt = 0; cnt < mycontacts_arr.length; cnt++) {
                    try {
                        var email = mycontacts_arr[cnt].email;
                        var contact_user_id = mycontacts_arr[cnt].contact_user_id;
                        var lin_profile_picture_url = mycontacts_arr[cnt].lin_profile_picture_url;

                        row_html += getMyContactsRowHTML(contact_user_id, email,lin_profile_picture_url);

                        mycontacts_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(mycontacts_found) {
                    $("#mycontacts_menu").show();
                } else {
                    $("#mycontacts_menu").hide();
                }
                $("#display_contacts").html(row_html);
            }, error: function(error) {
            }
        });
    };

    function getMyContactsRowHTML(contact_user_id, email,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var row_html =  "<tbody>"+
            "   <tr style='height: 40px' id="+contact_user_id+"> "+
                        "       <td style='padding: 2px;'> "+
                        "           <label class='radio-inline' style='margin-left: 20px'> "+
                        "               <input name='radioGroup' class='radio' id='radio1' value="+contact_user_id+" type='radio'>  "+
                        "           </label> " +
                        "       </td> "+
                        "       <td style='padding: 2px;cursor:pointer' onclick=\"loadTeamMemberreferals("+contact_user_id+"); window.event.stopPropagation();\">"+
                        "           <h5 style='font-family: \"Lato\",sans-serif;'>"+email+"</h5> "+
                        "       </td> "+
                        "       <td style='padding: 2px; width: 60px;cursor:pointer' onclick=\"loadTeamMemberreferals("+contact_user_id+"); window.event.stopPropagation();\">"+
                        "           <div class='pull-left' > "+
                        "               <img id='contact_profile_image' class='img-circle' style='max-width:30px; margin-top: 5px; margin-left: 5px;' src='"+posted_by_photo+"' class='events-object img-rounded'> "+
                        "           </div>"+
                        "       </td> "+
                        "   </tr>"+
                        "</tbody>";

        return row_html;
    }

    window.go_back_to_teammember_referal = function() {
        $("#load_teammeber_referals").hide();
        $("#display_contacts").show();
        $("#contacts_display").show();
    };


    var teammember_referral_arr = [];
    window.loadTeamMemberreferals = function(contact_user_id) {
        $("#load_teammeber_referals").hide();
        $("#display_teammember_referaldetails").hide();
        $("#contact_status_info").hide();
        $("#company_feed_status_info").hide();
        $('#myreferals').hide();
        $('#myposts').hide();
        $('#mypoints').hide();
        $('#display_contacts').hide();
        $('#mycontacts').show();
        $('#load_teammeber_referals').show();
        $.ajax({
            type:         "post",
            url:         "action/teammember_referrals.jsp",
            data:        "contact_user_id="+contact_user_id,

            success:    function(teammember_referral_list_json) {
                teammember_referral_list_json = escape(teammember_referral_list_json).replace(/%0A/g, "");
                teammember_referral_list_json = teammember_referral_list_json.replace(/%0D/g, "");
                teammember_referral_list_json = unescape(teammember_referral_list_json);

                if(teammember_referral_list_json != null && teammember_referral_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+referral_list_json.length+", profession_list_json: "+referral_list_json);

                teammember_referral_arr = JSON.parse(teammember_referral_list_json);
                $("#load_teammeber_referals dl").remove();
                $("#go_back_to_teammember_referal").remove();

                var row_html = "";
                for(var cnt = 0; cnt < teammember_referral_arr.length; cnt++) {
                    if(cnt == 0) {
                        row_html += "<a onclick='go_back_to_teammember_referal();' id='go_back_to_teammember_referal' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }
                    try {
                        var activity_id = teammember_referral_arr[cnt].activity_id;
                        var category = teammember_referral_arr[cnt].category;
                        var comments = teammember_referral_arr[cnt].comments;
                        var posted_on_format = teammember_referral_arr[cnt].posted_on_format;
                        var post_likes = teammember_referral_arr[cnt].post_likes;
                        var post_dislikes = teammember_referral_arr[cnt].post_dislikes;
                        var post_comments = teammember_referral_arr[cnt].post_comments;
                        var fl_name = teammember_referral_arr[cnt].fl_name;
                        var lin_profile_picture_url = teammember_referral_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                         row_html += getTeamMemberReferalrowHTML(activity_id, category, comments, posted_on_format, post_likes,post_dislikes,post_comments,fl_name,lin_profile_picture_url);
                        $("#load_teammeber_referals").append(row_html);
                        $("#contacts_display").hide();
                        $("#display_contacts").hide();


                        referral_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {

            }
        });

    };


    function getTeamMemberReferalrowHTML(activity_id, category, comments, posted_on_format, post_likes,post_dislikes,post_comments,fl_name,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
           var  posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var user_photo =  "images/profile.jpg";
        var teammembereferal_header = "";
        var teammembereferal_skills_details = "";

        var teammembereferal_details = comments.split("|");
        teammembereferal_header = teammembereferal_details[0];
        teammembereferal_skills_details = teammembereferal_details[1];

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fbfdfd;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7' onclick='showTeamReferalDetails("+activity_id+");' style='cursor: pointer;'' >     " +
            "                       <p class='pull-left' style='margin-left:2%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px' src="+user_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px'> " +
            "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:12%;font-family: \"Lato\",sans-serif;'>"+teammembereferal_header+" <br> "+ teammembereferal_skills_details+" </p> "+
            "                               </p> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
            "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_myReferals("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referrals' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#5bc0de;font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referrals' style='font-family: \"Lato\",sans-serif;'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#5bc0de;font-size: 17px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_myReferals("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referrals' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button>&nbsp;&nbsp;  " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referrals' style='font-family: \"Lato\",sans-serif;'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 17px'></i>  " +
            "                                   </button> " +

            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' title='number of comments' onclick=\"showTeamReferalDetails('"+activity_id+"');\" data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_my_referrals' style='font-family: \"Lato\",sans-serif;'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 17px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:1%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 8px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px;font-family: \"Lato\",sans-serif;'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;font-family: \"Lato\",sans-serif;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>";
        return row_html;
    }

    window.go_back_to_teammember_discussion = function() {
        $("#display_contacts").hide();
        $("#display_teammember_referaldetails").hide();

        $("#load_teammeber_referals").show();
    };

    window.showTeamReferalDetails = function (activity_id) {
        $.ajax({
            type:         "post",
            url:         "action/load_post.jsp",
            data:         "activity_id="+activity_id,

            success:    function(loadPost_list_json) {
                loadPost_list_json = escape(loadPost_list_json).replace(/%0A/g, "");
                loadPost_list_json = loadPost_list_json.replace(/%0D/g, "");
                loadPost_list_json = unescape(loadPost_list_json);

                if(loadPost_list_json != null && loadPost_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

                //              console.log(new Date()+"\t Got the response: "+loadPost_list_json.length+", loadPost_list_json: "+loadPost_list_json);

                loadpost_arr = JSON.parse(loadPost_list_json);

                if(loadpost_arr == null || loadpost_arr.length <= 0) {
                    $("#display_post_dl dl").remove();

                    //No loadpost list found, do nothing
                    return;
                }

                var loadpost_found = false;

                console.log(new Date()+"\t Number of loadpost loading...: "+loadpost_arr.length);

                for(var cnt1 = 0; cnt1 < loadpost_arr.length; cnt1++) {
                    var activity_id1 = loadpost_arr[cnt1].activity_id;
                    $("#show_mypost_responses_"+activity_id1+"_dl").remove();          //First, Remove all responses for the activity before removing posts
                }

                $("#display_teammember_referaldetails dl").remove();                      //Then, Remove all posts
                $("#comment_textbox_for_teammember_activity").remove();                      //Then, Remove all posts
                $("#go_back_to_teammember_discussion").remove();                     //Then, Remove all posts

                var row_html = "";

                for(var cnt = 0; cnt < loadpost_arr.length; cnt++) {

                    if(cnt == 0) {
                        row_html += "<a onclick='go_back_to_teammember_discussion();' id='go_back_to_teammember_discussion' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }

                    try {
                        var activity_id = loadpost_arr[cnt].activity_id;
                        var category = loadpost_arr[cnt].category;
                        var comments = loadpost_arr[cnt].comments;
                        var posted_on = loadpost_arr[cnt].posted_on;
                        var posted_on_format = loadpost_arr[cnt].posted_on_format;
                        var posted_by = loadpost_arr[cnt].posted_by;
                        var post_likes = loadpost_arr[cnt].post_likes;
                        var post_dislikes = loadpost_arr[cnt].post_dislikes;
                        var post_comments = loadpost_arr[cnt].post_comments;
                        var fl_name = loadpost_arr[cnt].fl_name;
                        var lin_profile_picture_url = loadpost_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html += getTeamReferalDetailsHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, fl_name, post_likes, post_dislikes, post_comments,lin_profile_picture_url);
                        $("#display_contacts").hide();
                        $("#load_teammeber_referals").hide();
                        $("#display_teammember_referaldetails").show();
                        $("#display_teammember_referaldetails").append(row_html);

                        loadMypostResponses(activity_id);

                        loadpost_found = true;
                    } catch (error) {
                        continue;
                    }

                }
                if(loadpost_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }
            }
        });
    };

    function getTeamReferalDetailsHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by,  fl_name,post_likes, post_dislikes, post_comments,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
          var  posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var TeamReferal_header = "";
        var TeamReferal_skills_details = "";

        var TeamReferal_details = comments.split("|");
        TeamReferal_header = TeamReferal_details[0];
        TeamReferal_skills_details = TeamReferal_details[1];

        var row_html = " <dl style='margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fbfdfd;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-7'>     " +
            "                               <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px'> " +
            "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:2%'>"+TeamReferal_header+" <br> "+ TeamReferal_skills_details+" </p> "+
            "                               </p> " +
            "                           </div>  " +
            "                           <div  align='center' class='event-body col-xs-5  pull-right' style='display:inline'> " +
            "                                   <button id='like_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-left:25%' class='btn btn-default btn-simple btn-md ' rel='tooltip' title='like' data-original-title='like' type='button' data-toggle='modal' onclick='postLikeStatus_myReferralComments("+activity_id+", 1);'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referral_comments'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-o-up' style='color:#5bc0de;font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='liked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px;  display: none;'  rel='tooltip' title='liked' data-original-title='liked' data-toggle='modal'> " +
            "                                       <span id='no_like_"+activity_id+"_my_referral_comments'>"+post_likes+"</span>&nbsp;<i class='fa fa-thumbs-up' style='color:#5bc0de;font-size: 20px'></i> &nbsp;&nbsp;&nbsp;  " +
            "                                   </button>  " +
            "                                   <button id='dislike_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px' class='btn btn-default btn-simple btn-md' rel='tooltip' title='dislike' data-original-title='dislike' type='button' data-toggle='modal' onclick='postLikeStatus_myReferralComments("+activity_id+", 2);'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referral_comments'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-o-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button>  " +
            "                                   <button id='disliked_"+activity_id+"' style='padding:0px; margin-top: 5px;background-color: transparent; margin-right:5px; display: none;'  rel='tooltip' title='disliked' data-original-title='disliked' data-toggle='modal'>   " +
            "                                       <span id='no_dislike_"+activity_id+"_my_referral_comments'>"+post_dislikes+"</span>&nbsp;<i class='fa fa-thumbs-down' style='color:#fa8072;font-size: 20px'></i>  " +
            "                                   </button> &nbsp;&nbsp;&nbsp;" +
            "                                   <button style='padding:0px; margin-top: 5px;background-color: transparent;margin-right:5px; cursor: default' class='btn btn-default btn-simple btn-md' title='number of comments' data-original-title='number of comments' >  " +
            "                                       <span id='no_comments_"+activity_id+"_my_referral_comments'>"+post_comments+"</span>&nbsp;<i class='fa fa-commenting-o' style='color:#F6BB42;font-size: 20px'></i> &nbsp;&nbsp;  " +
            "                                   </button>" +
            "                               </div>" +
            "                           </div>"+
            "                       </div>  " +
            "                       <p class='pull-right' style='margin-left:2%;margin-bottom: 0px'>  " +
            "                           <img class='img-circle' style='max-width:30px;margin-top: 8px' src="+posted_by_photo+" class='events-object img-rounded'> " +
            "                       </p>" +
            "                       <div class='events-right' style='margin-bottom:0%;margin-top: 1%'> " +
            "                           <div align='right' style='margin-left:9px'> " +
            "                               <h3 class='events-heading text-right' style='display: inline;font-size: 14px'> "+fl_name+"  </h3> " +
            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;'>"+posted_on_format+"</p> " +
            "                               </div>" +
            "                           </div> " +

            "                       </div> " +
            "                   </div> " +

            "                   <div style='display:none;' id='show_response_status_"+activity_id+"'>" +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" +
            "           <div id='show_mypost_responses_"+activity_id+"_dl' class='text-left' style='max-width: 98%;margin-bottom: 0%;overflow-x:hidden; display: none;margin-left:20px'>" +
            "           </div>"+
            "<div class='row'  id='comment_textbox_for_teammember_activity'>" +
            "                                    <div class='col-xs-9 text-left' style='margin-top: 1%;width:78%;padding:0px'>" +
            "                                        <textarea type='text' class='form-control' style='height:35px;margin-left:6%;width: 95%;' placeholder='Comment' name='post_comment_in_network_"+activity_id+"' id='post_comment_in_network_"+activity_id+"'></textarea>" +
            "                                    </div>" +
            "                                <div class='col-xs-2 text-left' style='max-width:100%;margin-top:1.5%;padding:0px;width:20%;margin-left:10px'>" +
            "                                    <button class='btn btn-sm btn-fill btn-info' style='margin-top: 1%;width:40px;margin-bottom: 5%;padding:3px' onclick=responsesToMyPost("+activity_id+"); return false;>Post</button>" +
            "                                </div>" +
            "                                </div>";

        return row_html;
    }

    function getNoActivitiesHTML() {
        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#fcfbfb;padding-right: 7px; box-shadow: 0.01em 0.01em 0.01em 0.01em #d5d5d5;> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row' style='margin-bottom:1%' align='center'>     " +
            "                               No records found" +
            "                           </div> " +
            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" ;
        return row_html;
    }
    function getNoHiredCandidatesRowHTML() {
        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#f2dede;padding-right: 7px; box-shadow: 0.01em 0.01em 0.01em 0.01em #d5d5d5;> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row' style='margin-bottom:1%' align='center'>     " +
            "                               <p style='color:#a94442;font-size:13px'>No candidate(s) are hired yet</p>" +
            "                           </div> " +
            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl>" ;
        return row_html;
    }

    function getNoContactsRowHTML() {
        var row_html =  "<tbody>"+
                        "   <tr style='height:50px' id='no_contacts'> "+
                        "       <td align='center'>"+
                        "           <h4>No records found</h4> "+
                        "       </td> "+
                        "   </tr>"+
                        "</tbody>";

        return row_html;
    }

    function getNoReferralsHTML() {
        var row_html =  "<center><tbody>"+
                        "   <tr style='height:50px; background-color: #f9f9f9;'> "+
                        "       <td align='center' style='padding: 8px; line-height: 1.42857143; vertical-align: top; border-top: 1px solid #ddd;'>"+
                        "           <h4>No records found</h4>"+
                        "       </td> "+
                        "   </tr>"+
                        "</tbody></center>";

        return row_html;
    }

    window.saveContactProfileDetailsAndRefer = function(contact_user_id) {
        var contactprofile_linkedin = $('#contactprofile_linkedin').val().trim();
        var contactprofile_skills = $('#contactprofile_skills').val().trim();
        var contactprofile_name = $('#contactprofile_name').val().trim();

        if (contactprofile_name == null || contactprofile_name == "") {
            $("#contactprofile_details_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Please enter contact name&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#contactprofile_details_status_failed").show();
            $('#contactprofile_name').css({
                "border-color": "red"
            });
            $("#contactprofile_name").focus();

            return false;
        }

        if(contactprofile_linkedin == null || contactprofile_linkedin == "") {
            if (contactprofile_skills == null || contactprofile_skills == "") {
                $("#contactprofile_details_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Please enter linkedin or skills&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                $("#contactprofile_details_status_failed").show();
                $('#contactprofile_linkedin').css({
                    "border-color": "red"
                });
                $('#contactprofile_skills').css({
                    "border-color": "red"
                });
                $("#contactprofile_linkedin").focus();

                return false;
            }
        }

        $("#contactprofile_details_status_success").hide();
        $("#contactprofile_details_status_failed").hide();

        //Save in the employee_details table

        $.ajax({
            type:         "post",
            url:          "action/save_contactprofile_details_and_refer.jsp",
            data:         "contactprofile_linkedin="+encodeURIComponent(contactprofile_linkedin)+"&contactprofile_skills="+encodeURIComponent(contactprofile_skills)+"&contact_user_id="+contact_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
                    insertIntoActivities(contact_user_id, contactprofile_linkedin, contactprofile_name, contactprofile_skills);
                    $("#contactprofile_details_status_failed").html("");
                    $("#contactprofile_details_status_failed").hide();

                    $("#contactprofile_details_status_success").html("<div class='alert alert-success' style='padding: 20px 0px 10px 10px;'>Successfully saved and referred&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#contactprofile_details_status_success").show();

                    //reset the border color to none
                    $('#contactprofile_linkedin').attr("style","border-color: none;");
                    $('#contactprofile_fb').attr("style","border-color: none;");
                    $('#contactprofile_skills').attr("style","border-color: none;");
                } else {
                    $("#contactprofile_details_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Could not save the details&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#contactprofile_details_status_failed").show();
                }
            }
        });
    };

    //insert into the activities table to display in the posts UI
    function insertIntoActivities(contact_user_id, contactprofile_linkedin, contactprofile_name, contactprofile_skills) {
        $.ajax({
            type:         "post",
            url:          "action/insert_into_activities.jsp",
            data:         "contactprofile_linkedin="+encodeURIComponent(contactprofile_linkedin)+"&contactprofile_name="+encodeURIComponent(contactprofile_name)+"&contact_user_id="+contact_user_id+"&contactprofile_skills="+contactprofile_skills,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("") > 0) {

                } else {
                    //DO NOTHING
                }
            }
        });
    }

    window.openContactEditForm = function() {
        $("#contact_status_info").hide();
        var contact_user_id = $('.radio:checked').val();
         if(contact_user_id == null || contact_user_id == ""){
             $("#contact_status_info").html("<div class='alert alert-danger' ><span style='font-size: 15px'>Please select team member</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 15px; padding: 5px 10px 5px 10px;'></i></a>");
             $("#contact_status_info").show();
             return;
         }
        var post_url = "action/get_editccontact_form.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "contact_user_id="+contact_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("Name") >= 0) {
                    $("#edit_contact_form").html(msg);
                } else {
                    //           alert(msg);
                }
            }
        });
        $("#click_to_display_edit_contact_form").click();
    };

    window.updateContactdetails = function(contact_user_id) {
        $("#edit_contact_status").hide();

        var contact_name = $('#edit_contact_name').val().trim();
        var contact_email = $('#edit_contact_email').val().trim();
        var edit_contact_status_msg = $('#edit_contact_status_msg').val().trim();

        if(contact_name == null || contact_name == "") {
            $("#edit_contact_status").html("Contact name name cannot be empty");
            $("#edit_contact_status").show();
            $("#edit_contact_name").focus();
            return false;
        }

        if(contact_email == null || contact_email == "") {
            $("#edit_contact_status").html("Contact email cannot be empty");
            $("#edit_contact_status").show();
            $("#edit_contact_email").focus();
            return false;
        }

        $.ajax({
            type:         "post",
            url:          "action/update_contactdetails.jsp",
            data:         "contact_name="+encodeURIComponent(contact_name)+
                "&contact_email="+encodeURIComponent(contact_email)+
                "&contact_user_id="+encodeURIComponent(contact_user_id),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "register.html";
                } else if(msg != null) {
                    $("#edit_contact_status_msg").show();
                } else {
                    //DO NOTHING
                }
            }
        });
    };

    window.getContactDetailsToDelete = function() {
        $("#contact_status_info").hide();
        var contact_user_id = $('.radio:checked').val();
        if(contact_user_id == null || contact_user_id == ""){
            $("#contact_status_info").html("<div class='alert alert-danger'><span style='font-size: 15px'>Please select team member</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 15px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#contact_status_info").show();
            return;
        }
        var msg = "<div class='modal-dialog'>" +
            "            <div class='modal-content' style='max-width: 550px'>" +
            "               <div class='modal-header' style='background-color:#d9534f;border-radius: 5px 5px 0px 0px; padding: 10px;'>" +
            "                   <button type='button' class='close' data-dismiss='modal' style='opacity: 0.8; color: white;' aria-hidden='true'>&times;</button>" +
            "                   <h5 class='modal-title text-center' style='margin-bottom: 0px;height:5px;color: white;text-align: center' >Delete team member</h5></br>" +
            "               </div>" +
            "                <div class='modal-body'> " +
            "                   <p align='center' style='margin-bottom: 0px'>Are you sure you wish to delete this team member?</p>" +
            "                   <div id='add_cledit_status' align='center' style='display:none'></div>" +
            "                   <div class='modal-footer' style='margin-top:-2%;display:inline'>" +
            "                       <center>" +
            "                           <button id='fcm_id' class='btn btn-info'  style='background-color:#d9534f'  data-toggle='button' type='submit' onclick=\"deleteContact("+contact_user_id+");\">Yes, Delete</button>&nbsp;&nbsp;" +
            "                           <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
            "                       </center>" +
            " <div class='row'>" +
            "                <div id='delete_contact_details_status_success' class='alert alert-success' align='center' style='display: none;margin-top: 8px;margin-bottom: 0px'><span style='font-size: 15px'>Successfully deleted</span></div>" +
            "            </div>"+
            "                   </div>" +
            "               </div>" +
            "            </div>" +
            "       </div>";
        $("#delete_contact_form").html(msg);
        $("#click_to_display_delete_form").click();
    };

    window.deleteContact = function(contact_user_id) {
        $.ajax({
            type:         "post",
            url:          "action/delete_contact_details.jsp",
            data:         "contact_user_id="+encodeURIComponent(contact_user_id),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg > 0) {
                    loadMycontacts();
                    $("#delete_contact_details_status_success").show();
                } else {
                    //DO NOTHING
                }
            }
        });
    };

    var referral_arr = [];
    window.loadMyReferals = function() {
        $("#company_feed_status_info").hide();
        $("#contact_status_info").hide();
        $('#myposts').hide();
        $('#mycontacts').hide();
        $('#mypoints').hide();
        $('#display_myreferals_dl').hide();
        $("#post_likes_dislikes_details").hide();
        $("#posts").hide();
        $("#display_requirement_activity_results_dl").hide();
        $("#display_my_requirement_activity_results_dl").hide();
        $("#hire").hide();
        $('#myreferals').show();
        $('#load_referrals').show();

        $.ajax({
            type:         "post",
            url:         "action/load_referrals.jsp",

            success:    function(referral_list_json) {
                referral_list_json = escape(referral_list_json).replace(/%0A/g, "");
                referral_list_json = referral_list_json.replace(/%0D/g, "");
                referral_list_json = unescape(referral_list_json);

                if(referral_list_json != null && referral_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+referral_list_json.length+", profession_list_json: "+referral_list_json);

                referral_arr = JSON.parse(referral_list_json);

                var row_html = "";
                $("#load_referrals dl").remove();

                if(referral_arr == null || referral_arr.length <= 0) {
                    //No referrals found, do nothing
                    row_html = getNoReferralsHTML();
                    $("#load_referrals").html(row_html);
                    return;
                }

                var referral_table_html = "";
                var referral_found = false;
                $("#load_referrals dl").remove();
                for(var cnt = 0; cnt < referral_arr.length; cnt++) {
                    try {
                        var activity_id = referral_arr[cnt].activity_id;
                        var category = referral_arr[cnt].category;
                        var comments = referral_arr[cnt].comments;
                        var posted_on_format = referral_arr[cnt].posted_on_format;
                        var post_likes = referral_arr[cnt].post_likes;
                        var post_dislikes = referral_arr[cnt].post_dislikes;
                        var post_comments = referral_arr[cnt].post_comments;
                        var fl_name = referral_arr[cnt].fl_name;
                        var lin_profile_picture_url = referral_arr[cnt].lin_profile_picture_url;

                        if(post_likes === undefined) {
                            post_likes = 0;
                        }
                        if(post_dislikes === undefined) {
                            post_dislikes = 0;
                        }
                        if(post_comments === undefined) {
                            post_comments = 0;
                        }
                        if(fl_name === undefined) {
                            fl_name = "N/A";
                        }

                        row_html = getMyReferalrowHTML(activity_id, category, comments, posted_on_format, post_likes,post_dislikes,post_comments,fl_name,lin_profile_picture_url);

                        $("#load_referrals").append(row_html);

                        referral_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {

            }
        });
    };

    function getReferralRowHTML(referral_userid, referral_name, expertise, linkedin, facebook) {

        var linkedin_str1 = "<a class='btn btn-block btn-social btn-linkedin' onclick=\"window.open('"+linkedin+"', '_blank')\" style='width: 160px;margin-top:10px;cursor: pointer;'> "+
            "              <i class='fa fa-linkedin'></i>LinkedIn profile  "+
            "          </a>";

        var linkedin_str = (linkedin != null && linkedin.trim().length > 0 ? linkedin_str1 : "");

        var row_html = "<tbody> "+
            "<tr style='height:50px'> "+
            " <td style='width: 60px'> "+
            "     <div class='pull-left' > "+
            "           <img  class='img-circle' style='max-width:40px;margin-top: 4px;margin-bottom: 4px' src='images/profile.jpg' class='events-object img-rounded'>"+
            "          </div> "+
            "      </td>   "+
            "       <td>  "+
            "           <h4>"+referral_name+"</h4>  "+
            "       </td>  "+
            "      <td>   "+
            "              "+linkedin_str1+"  "+
            "       </td>     "+
            "      <td>     "+
            "           <h5 class='text-center'>"+expertise+"</h5>   "+
            "      </td>      "+
            "   </tr>     "+
            "   </tbody>";
        return row_html;
    }

    window.openProfilePage = function() {
        getProfileDetails();

        $("#myprofile_page").show();
        $("#click_to_my_profile_form").click();

        if (lin_publicProfileUrl != null){
            $("#profile_image").attr("src", lin_publicProfileUrl);
        }
    };

    window.getProfileDetails = function() {
        var post_url = "action/get_profile_details.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,

            success:    function(profile_details_json) {
                profile_details_json = escape(profile_details_json).replace(/%0A/g, "");
                profile_details_json = profile_details_json.replace(/%0D/g, "");
                profile_details_json = unescape(profile_details_json);

                if(profile_details_json != null && profile_details_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

                var profile_details_arr = JSON.parse(profile_details_json);

                if(profile_details_arr == null || profile_details_arr.length <= 0) {
                    return;
                }

                for(var cnt = 0; cnt < profile_details_arr.length; cnt++) {
                    try {
                        var from_user_id = profile_details_arr[cnt].from_user_id;
                        var profile_name = profile_details_arr[cnt].profile_name;
                        var profile_expertise = profile_details_arr[cnt].profile_expertise;
                        var profile_linkedin = profile_details_arr[cnt].profile_linkedin;
                        var lin_publicProfileUrl = profile_details_arr[cnt].lin_publicProfileUrl;
                        var user_type = profile_details_arr[cnt].user_type;
                        var hr_consent = profile_details_arr[cnt].hr_consent;
                        var domain_name = profile_details_arr[cnt].domain_name;

                        console.log("user_type: "+user_type+", hr_consent: "+hr_consent+", profile_name: "+profile_name+", profile_linkedin: "+profile_linkedin);

                        $("#profile_name").text(profile_name);
                        $("#profile_expertise").val(profile_expertise);
                        $("#profile_linkedin").val(profile_linkedin);
                        $("#my_domain_name").val(domain_name);

                        if(profile_linkedin == null || profile_linkedin.trim() == "") {
                            $("#profile_linkedin").val(lin_publicProfileUrl);
                        } else {
                            $("#profile_linkedin").val(profile_linkedin);
                        }

/*
                        if(hr_consent == "1" && user_type == "1") {
                            $("#hr_consent_label").html("<input id='hr_consent' type='checkbox' style='max-width: 300px' name='hr_consent'> I am responsible for hiring <br><font color='red'> (Approval pending...)</font>");
                            $("#hr_consent").attr("checked", "checked");
                        } else if(hr_consent == "1") {
                            $("#hr_consent").attr("checked", "checked");
                        }
*/
                    } catch (error) {
                        continue;
                    }
                }
            }
        });
    };

    window.saveProfileDetails = function() {
        $("#profile_details_status_failed").hide();
        $("#profile_details_status_success").hide();

        var profile_name = $('#profile_name').text().trim();
        var profile_expertise = $('#profile_expertise').val().trim();
        var profile_linkedin = $('#profile_linkedin').val().trim();
        var hr_consent = 0;

        if($("#hr_consent").is(':checked')) {
            hr_consent = 1;
        }

        if(hr_consent == 1) {
            if(profile_linkedin == null || profile_linkedin == "") {
                $("#profile_details_status_failed").html("<font color='red'>LinkedIn profile is required for people responsible for hiring</font>");
                $("#profile_details_status_failed").show();
                $("#profile_linkedin").focus();
                return false;
            }
        }

        $("#profile_details_status_success").hide();
        $("#profile_details_status_failed").hide();

        $.ajax({
            type:         "post",
            url:         "action/save_profile_details.jsp",
            data:         "profile_name="+encodeURIComponent(profile_name)+
                "&profile_expertise="+encodeURIComponent(profile_expertise)+
                "&profile_linkedin="+encodeURIComponent(profile_linkedin)+
                "&hr_consent="+encodeURIComponent(hr_consent),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
//                    $("#profile_details_status_success").html("Successfully saved");
                    $("#profile_details_status_success").html("<div class='alert alert-success'><span style='font-size: 15px'>Successfully saved</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 15px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#profile_details_status_success").show();

                    $('#profile_name').css({
                        "border-color": ""
                    });

/*
                    if(hr_consent == "0") {
                        $("#hr_consent_label").html("<input id='hr_consent' type='checkbox' style='max-width: 300px' name='hr_consent'> I am responsible for hiring</font>");
                    }
*/
                } else {
                    $("#profile_details_status_failed").html("<font color='red'>Could not save the data</font>");
                    $("#profile_details_status_failed").show();
                }
            }
        });
    };

    var gamification_arr = [];
    window.gamification = function() {
        $("#company_feed_status_info").hide();
        $("#contact_status_info").hide();
        $('#myreferals').hide();
        $('#myposts').hide();
        $('#mycontacts').hide();
        $("#posts").hide();
        $("#post_likes_dislikes_details").hide();
        $("#display_requirement_activity_results_dl").hide();
        $("#display_my_requirement_activity_results_dl").hide();
        $("#hire").hide();
        $('#mypoints').show();

        $.ajax({
            type:         "post",
            url:         "action/gamification.jsp",

            success:    function(gamification_list_json) {
                gamification_list_json = escape(gamification_list_json).replace(/%0A/g, "");
                gamification_list_json = gamification_list_json.replace(/%0D/g, "");
                gamification_list_json = unescape(gamification_list_json);

                if(gamification_list_json != null && gamification_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+gamification_list_json.length+", profession_list_json: "+gamification_list_json);

                gamification_arr = JSON.parse(gamification_list_json);


                var gamification_table_html = "";
                var gamification_found = false;
                $("#load_gamifications div").remove();
                for(var cnt = 0; cnt < gamification_arr.length; cnt++) {
                    try {
                        var referals = gamification_arr[cnt].referals;
                        var name = gamification_arr[cnt].name;
                        var points = gamification_arr[cnt].points;
                        var level1 = gamification_arr[cnt].level1;
                        var level2 = gamification_arr[cnt].level2;
                        var level3 = gamification_arr[cnt].level3;
                        var level4 = gamification_arr[cnt].level4;
                        var level5 = gamification_arr[cnt].level5;
                        var progress = gamification_arr[cnt].progress;

                        var row_html = getgamificationRowHTML(referals, name, points,level1,level2,level3,level4,level5,progress);

                        $("#load_gamifications").append(row_html);
                        topreferals();
                        gamification_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {

            }
        });

    };

    function getgamificationRowHTML(referals, name, points,level1,level2,level3,level4,level5,progress) {


        var row_html = "<div class='row'>" +
            "                                <div class='col-lg-4 col-lg-offset-2'>" +
            "                                    <div class='panel panel-green'>" +
            "                                        <div class='panel-heading'>" +
            "                                            <div class='row'>" +
            "                                                <div class='col-xs-3'>" +
            "                                                    <i class='fa fa fa-link fa-5x'></i>" +
            "                                                </div>" +
            "                                                <div class='col-xs-9 text-right'>" +
            "                                                    <div class='huge' style='font-family: \"Lato\",sans-serif'>"+referals+"</div>" +
            "                                                    <div style='font-family: \"Lato\",sans-serif'>Referrals</div>" +
            "                                                </div>" +
            "                                            </div>" +
            "                                        </div>" +
            "                                    </div>" +
            "                                </div>" +
            "                                <div class='col-lg-4'>" +
            "                                    <div class='panel panel-primary'>" +
            "                                        <div class='panel-heading'>" +
            "                                            <div class='row'>" +
            "                                                <div class='col-xs-3'>" +
            "                                                    <i class='glyphicon glyphicon-star fa-5x'></i>" +
            "                                                </div>" +
            "                                                <div class='col-xs-9 text-right'>" +
            "                                                    <div class='huge' style='font-family: \"Lato\",sans-serif'>"+points+"</div>" +
            "                                                    <div style='font-family: \"Lato\",sans-serif'>Points</div>" +
            "                                                </div>" +
            "                                            </div>" +
            "                                        </div>" +
            "                                    </div>" +
            "                                </div>" +
            "                            </div>" +
            "                            <div class='row'>" +
            "                                <div class='col-lg-2' style='idth: 11%;'>" +
            "                                </div>" +
            "                                <div class='col-lg-2 col-lg-offset-2' style='width: 14%;margin-left: 4%'>" +
            level1+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            level2+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            level3+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            level4+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            level5+" " +
            "                                </div>" +
            "                            </div>" +
            "                            <div class='row'>" +
            "                                <div class='col-md-10' style='padding: 5px 5px 5px 5px; width: 60%;margin-left: 26%;'>" +
            progress+" " +
            "                                </div>" +
            "    </div> ";
        return row_html;

    }

    var rainmaker_arr = [];
    window.showrainmaker = function() {


        $.ajax({
            type:         "post",
            url:         "action/rainmaker.jsp",

            success:    function(rainmaker_list_json) {
                rainmaker_list_json = escape(rainmaker_list_json).replace(/%0A/g, "");
                rainmaker_list_json = rainmaker_list_json.replace(/%0D/g, "");
                rainmaker_list_json = unescape(rainmaker_list_json);

                if(rainmaker_list_json != null && rainmaker_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+rainmaker_list_json.length+", profession_list_json: "+rainmaker_list_json);

                rainmaker_arr = JSON.parse(rainmaker_list_json);

                var rainmaker_table_html = "";
                var rainmaker_found = false;
                $("#load_rainmaker div").remove();
                for(var cnt = 0; cnt < rainmaker_arr.length; cnt++) {
                    try {
                        var referals = rainmaker_arr[cnt].referals;
                        var name = rainmaker_arr[cnt].name;
                        var user_id = rainmaker_arr[cnt].user_id;
                        var points = rainmaker_arr[cnt].points;
                        var topreferal_level1 = rainmaker_arr[cnt].topreferal_level1;
                        var topreferal_level2 = rainmaker_arr[cnt].topreferal_level2;
                        var topreferal_level3 = rainmaker_arr[cnt].topreferal_level3;
                        var topreferal_level4 = rainmaker_arr[cnt].topreferal_level4;
                        var topreferal_level5 = rainmaker_arr[cnt].topreferal_level5;
                        var topreferal_progress = rainmaker_arr[cnt].topreferal_progress;
                        var lin_profile_picture_url = rainmaker_arr[cnt].lin_profile_picture_url;

                        var row_html = getrainmakerRowHTML(referals, name,user_id, points,topreferal_level1,topreferal_level2,topreferal_level3,topreferal_level4,topreferal_level5,topreferal_progress,lin_profile_picture_url);
                        $('#top').removeClass('active');
                        $('#top').addClass('disabled');
                        $('#rain').removeClass('disabled');
                        $('#rain').addClass('active');
                        $('#analytics').removeClass('active');
                        $('#topreferals').hide();
                        $('#analytics_graph').hide();
                        $('#rain_maker_of_the_week').show();
                        $("#load_rainmaker").append(row_html);
                        rainmaker_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {

            }
        });
    };

    function getrainmakerRowHTML(referals, name,user_id, points,topreferal_level1,topreferal_level2,topreferal_level3,topreferal_level4,topreferal_level5,topreferal_progress,lin_profile_picture_url) {
        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var row_html =
        "<div class='panel-heading'>   " +

        "    <b class='text-center'>Rainmaker of the week</b>   " +
        "    <p title='Popularidade Alta'><i class='fa fa-tint fa-4x pull-right'></i></p>   " +
        "<p></p>  " +
        " </div>  " +
        " <div class='panel-body'>  " +
        "   <p class='text-center'><img class='image-circle text-center' style='margin-left: 45px;margin-bottom: 0px' src='"+posted_by_photo+"'></p>  " +
        "       <h2 class='text-center' style='margin-top: 0px;margin-bottom: 0px;font-family: \"Lato\" ,sans-serif;'>"+name+"</h2>  " +
        "    </div>   " +
        "    <div class='row'></div>   " +
        "    <div class='panel-heading'>  " +
        "        <div class='row'>  " +
        "            <div class='col-xs-2 col-md-2' title='Ganhe Certificado'>   " +

        "            </div>    " +
        "            <div class='col-lg-4'>   " +
        "                <div class='panel panel-green'>   " +
        "                    <div class='panel-heading'>   " +
        "                        <div class='row'>   " +
        "                            <div class='col-xs-3'>   " +
        "                                <i class='fa fa fa-link fa-2x'></i>   " +
        "                            </div>   " +
        "                            <div class='col-xs-9 text-right'>  " +
        "                                <div class='huge' style='font-size: 15px;font-family: \"Lato\" ,sans-serif;'>"+referals+"</div>  " +
        "                                <div>Referrals</div>    " +
        "                            </div>   " +
        "                        </div>   " +
        "                    </div>    " +
        "                </div>  " +
        "            </div>   " +
        "           <div class='col-lg-4'>    " +
        "               <div class='panel panel-primary'>   " +
        "                   <div class='panel-heading'>    " +
        "                       <div class='row'>   " +
        "                           <div class='col-xs-3'>   " +
        "                               <i class='glyphicon glyphicon-star fa-2x'></i>   " +
        "                           </div>     " +
        "                           <div class='col-xs-9 text-right'>   " +
        "                               <div class='huge' style='font-size: 15px;font-family: \"Lato\" ,sans-serif;'>"+points+"</div>  " +
        "                               <div>Points</div>    " +
        "                           </div>    " +
        "                       </div>    " +
        "                   </div>   " +
        "               </div>   " +
        "           </div>   " +
        "       </div>    " +
        "       <div class='row'>    " +
        "           <div class='col-lg-2 col-lg-offset-2' style='width: 14%;margin-left:11%'>   " +
        topreferal_level1+" " +
        "               </div>    " +
        "               <div class='col-xs-2' style='width: 14%;'>  " +
        topreferal_level2+" " +
        "                   </div>     " +
        "                   <div class='col-xs-2' style='width: 14%;'>   " +
        topreferal_level3+" " +
        "                       </div>   " +
        "                       <div class='col-xs-2' style='width: 14%;'>   " +
        topreferal_level4+" " +
        "                           </div>   " +
        "                           <div class='col-xs-2' style='width: 14%;'>   " +
        topreferal_level5+" " +
        "                               </div>   " +
        "                           </div>   " +
        "                           <div class='row'>   " +
        "                               <div class='col-md-10' style='padding: 5px 5px 5px 5px; width: 60%;margin-left: 20%;'>   " +
        topreferal_progress+" " +
        "                               </div> " +
        "                           </div> <br>  " +
        "                       </div>  " +
        "                      </div> ";
        return row_html;
    }

    var topreferals_arr = [];
    window.topreferals = function() {

        $.ajax({
            type:         "post",
            url:         "action/top_referals.jsp",

            success:    function(topreferals_list_json) {
                topreferals_list_json = escape(topreferals_list_json).replace(/%0A/g, "");
                topreferals_list_json = topreferals_list_json.replace(/%0D/g, "");
                topreferals_list_json = unescape(topreferals_list_json);

                if(topreferals_list_json != null && topreferals_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }

//                console.log(new Date()+"\t Got the response: "+topreferals_list_json.length+", profession_list_json: "+topreferals_list_json);

                topreferals_arr = JSON.parse(topreferals_list_json);

                var topreferals_table_html = "";
                var topreferals_found = false;
                $("#load_topreferals div").remove();
                for(var cnt = 0; cnt < topreferals_arr.length; cnt++) {
                    try {
                        var referals = topreferals_arr[cnt].referals;
                        var name = topreferals_arr[cnt].name;
                        var user_id = topreferals_arr[cnt].user_id;
                        var points = topreferals_arr[cnt].points;
                        var topreferal_level1 = topreferals_arr[cnt].topreferal_level1;
                        var topreferal_level2 = topreferals_arr[cnt].topreferal_level2;
                        var topreferal_level3 = topreferals_arr[cnt].topreferal_level3;
                        var topreferal_level4 = topreferals_arr[cnt].topreferal_level4;
                        var topreferal_level5 = topreferals_arr[cnt].topreferal_level5;
                        var topreferal_progress = topreferals_arr[cnt].topreferal_progress;
                        var lin_profile_picture_url = topreferals_arr[cnt].lin_profile_picture_url;

                        var row_html = gettopreferalsRowHTML(referals, name,user_id, points,topreferal_level1,topreferal_level2,topreferal_level3,topreferal_level4,topreferal_level5,topreferal_progress,lin_profile_picture_url);
                        $("#load_topreferals").append(row_html);
                        topreferals_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {

            }
        });
    };

    function gettopreferalsRowHTML(referals, name,user_id, points,topreferal_level1,topreferal_level2,topreferal_level3,topreferal_level4,topreferal_level5,topreferal_progress,lin_profile_picture_url) {

        if(lin_profile_picture_url == null || lin_profile_picture_url== "")  {
            var posted_by_photo = "images/profile.jpg";
        }else{
            posted_by_photo = lin_profile_picture_url;
        }
        var row_html = "<div id='accordion' role='tablist' aria-multiselectable='true'>   " +
            "<div class='card'>  " +
            "    <div class='card-header' role='tab' id='headingOne'>   " +
            "        <h5 class='mb-0'> " +
            "            <a data-toggle='collapse' data-parent='#accordion' href='#"+user_id+"' aria-expanded='true' aria-controls='collapseOne'> " +
            "            <div class='row' >" +
            "           <div class='col-lg-5'>" +
            "              <h4 style='font-family: \"Lato\" ,sans-serif;'><img class='img-circle' style='max-width:30px' src="+posted_by_photo+" class='events-object img-rounded'> "+name+"</h4> " +
            "           </div>  " +
            "           <div class='col-lg-5'>" +
            "              <span class='badge' style='background-color: #00B8D4;font-size: 15px;font-family: \"Lato\" ,sans-serif;'>"+referals+"</span>  " +
            "           </div>  " +
            "            </a>  " +
            "        </h5> " +
            "    </div> " +

            "    <div id='"+user_id+"' class='collapse' role='tabpanel' aria-labelledby='headingOne'>   " +
            "    <div class='card-block' style='background-color:#f2f2f2;padding-top:15px'>  " +
            "<div class='row'>" +
            "                                <div class='col-lg-3 col-lg-offset-2'>" +
            "                                    <div class='panel panel-green'>" +
            "                                        <div class='panel-heading'>" +
            "                                            <div class='row'>" +
            "                                                <div class='col-xs-3'>" +
            "                                                    <i class='fa fa fa-link fa-3x'></i>" +
            "                                                </div>" +
            "                                                <div class='col-xs-9 text-right'>" +
            "                                                    <div class='huge'>"+referals+"</div>" +
            "                                                    <div>Referrals</div>" +
            "                                                </div>" +
            "                                            </div>" +
            "                                        </div>" +
            "                                    </div>" +
            "                                </div>" +
            "                                <div class='col-lg-3'>" +
            "                                    <div class='panel panel-primary'>" +
            "                                        <div class='panel-heading'>" +
            "                                            <div class='row'>" +
            "                                                <div class='col-xs-3'>" +
            "                                                    <i class='glyphicon glyphicon-star fa-3x'></i>" +
            "                                                </div>" +
            "                                                <div class='col-xs-9 text-right'>" +
            "                                                    <div class='huge'>"+points+"</div>" +
            "                                                    <div>Points</div>" +
            "                                                </div>" +
            "                                            </div>" +
            "                                        </div>" +
            "                                    </div>" +
            "                                </div>" +
            "                            </div>" +
            "                            <div class='row'>" +
            "                                <div class='col-lg-1' style='idth: 2%;'>" +
            "                                </div>" +
            "                                <div class='col-lg-2 col-lg-offset-2' style='width: 14%;margin-left: 4%'>" +
            topreferal_level1+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            topreferal_level2+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            topreferal_level3+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            topreferal_level4+" " +
            "                                </div>" +
            "                                <div class='col-xs-2' style='width: 14%;'>" +
            topreferal_level5+" " +
            "                                </div>" +
            "                            </div>" +
            "                            <div class='row'>" +
            "                                <div class='col-md-10' style='padding: 5px 5px 5px 5px; width: 58%;margin-left: 18%;'>" +
            topreferal_progress+" " +
            "                                 </div>" +
            "    </div> "+
            "    </div> " +
            " </div>" +
            "    </div> ";
        return row_html;
    }

    window.getContactProfileDetails = function() {
        $("#contact_status_info").hide();
        var contact_user_id = $('.radio:checked').val();
        if(contact_user_id == null || contact_user_id == ""){
            $("#contact_status_info").html("<div class='alert alert-danger'><span style='font-size: 15px'>Please select team member</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 15px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#contact_status_info").show();
            return;
        }
        $.ajax({
            type:        "post",
            url:         "action/get_contactprofile_details.jsp",
            data:         "contact_user_id="+contact_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null) {
                    $("#contacts_details").html(msg);
                    $("#click_to_display_profile_form").click();
                }
            }
        });
    };

    window.getReferAFriendForm = function() {
		$("#raf_status_success").val("");
        $.ajax({
            type:        "post",
            url:         "action/get_refer_a_friend_form.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null) {
                    $("#refer_a_friend_details").html(msg);
                    $("#click_to_display_refer_a_friend_form").click();
                }
            }
        });
    };


    var checkSuggestions_arr= [];
    window.askInYourNetwork = function() {
        var post_comments = $("#ask_in_network").val();
        if(post_comments == null || post_comments.trim().length <= 0) {
            $("#ask_in_network").focus();
        } else {
            $.ajax({
                type:         "post",
                url:          "action/check_suggestions_for_ask.jsp",
                data:         "comments="+post_comments,

                success:    function(checkSuggestions_forAsk_list_json) {
                    checkSuggestions_forAsk_list_json = escape(checkSuggestions_forAsk_list_json).replace(/%0A/g, "");
                    checkSuggestions_forAsk_list_json = checkSuggestions_forAsk_list_json.replace(/%0D/g, "");
                    checkSuggestions_forAsk_list_json = unescape(checkSuggestions_forAsk_list_json);

                    if(checkSuggestions_forAsk_list_json != null && checkSuggestions_forAsk_list_json.indexOf("session_expired") >= 0) {
                        window.location = "login.html";
                    }

                    checkSuggestions_arr = JSON.parse(checkSuggestions_forAsk_list_json);
                    var suggestion_status = "";

                    if(checkSuggestions_arr == null || checkSuggestions_arr.length <= 0) {
                        suggestion_status = 0;
                    }else{
                        suggestion_status = 1;
                    }
                    insertAsk_post(post_comments,suggestion_status)
                }, error: function (error) {

                }
            });
        };
    };
    var suggestions_arr= [];
    window.getshowsuggestform = function(comments) {
        $("#post_requirement_to_network").hide();
        $.ajax({
            type:         "post",
            url:          "action/get_suggestions_for_ask.jsp",
            data:         "comments="+encodeURIComponent(comments),

            success:    function(getSuggestions_forAsk_list_json) {
                getSuggestions_forAsk_list_json = escape(getSuggestions_forAsk_list_json).replace(/%0A/g, "");
                getSuggestions_forAsk_list_json = getSuggestions_forAsk_list_json.replace(/%0D/g, "");
                getSuggestions_forAsk_list_json = unescape(getSuggestions_forAsk_list_json);

                if(getSuggestions_forAsk_list_json != null && getSuggestions_forAsk_list_json.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                }
                var suggestions_found = false;
                console.log(new Date()+"\t Got the response: "+getSuggestions_forAsk_list_json.length+", getSuggestions_forAsk_json: "+getSuggestions_forAsk_list_json);

                suggestions_arr = JSON.parse(getSuggestions_forAsk_list_json);

                if(suggestions_arr == null || suggestions_arr.length <= 0) {
                    $("#show_suggestions dl").remove();

                    return;
                }
                $("#show_suggestions dl").remove();
                $("#display_requirement_post_dl dl").remove();                      //Then, Remove all posts
                $("#comment_textbox_for_mypost_activity").remove();                    //Then, Remove all posts
                $("#go_back_to_posts_discussion").remove();
                $("#go_back_to_askPost").remove();


                var row_html = "";

                for(var cnt = 0; cnt < suggestions_arr.length; cnt++) {
                    if(cnt == 0) {
                        row_html += "<a onclick='goBackToPostsDiscussion();' id='go_back_to_askPost' type='button'>" +
                            "   <i class='fa fa-arrow-left' style='color: #00B8D4; font-size: 18px;'></i>" +
                            "</a>";
                    } else {
                        row_html = "";
                    }
                    try {
                        var name = suggestions_arr[cnt].name;
                        var suggested_comments = suggestions_arr[cnt].suggested_comments;

                        row_html += getsuggestionsforpostRowHTML(name, suggested_comments);
                        //alert(row_html);
                        $("#display_requirement_activity_results_dl").hide();
                        $("#display_my_requirement_activity_results_dl").hide();
                        $("#display_requirement_post_dl").hide();
                        $("#show_suggestions").show();
                        $("#show_suggestions").append(row_html);

                        suggestions_found = true;
                    } catch (error) {
                        continue;
                    }
                }
                if(suggestions_found) {
                    //TODO, loadActivityResponses once after completion of load all activities. Is this better way?
                }

            }, error: function (error) {

            }
        });
    };

    function getsuggestionsforpostRowHTML(name, suggested_comments) {
        var posted_by_photo = "images/profile.jpg";
        var my_post_header = "";
        var my_post_skills_details = "";
        var my_post_comments_refer = "";


        var my_post_details = suggested_comments.split("|");
        my_post_header = my_post_details[0];
        my_post_skills_details = my_post_details[1];
        if (my_post_skills_details != null){
            my_post_comments  = "<P style='font-size: 14px;line-height: 1.3;margin-top: -1px;margin-left:2%;font-family: \"Lato\",sans-serif;'>"+my_post_header+" <br> <img class='img-circle' style='max-width:30px' src='images/profile.jpg'>  "+ my_post_skills_details+" </p> ";
        } else{
            my_post_comments  = suggested_comments;
        }

        var row_html = " <dl style='margin-bottom:-2px;margin-top:5px;padding:0px;background-color: #fcfbfb'> " +
            "               <dd class='pos-left clearfix' > " +
            "                   <div class='events' style='margin-top:0px;display:inline;background-color:#f9f8f8;padding-right: 7px; box-shadow: 0.09em 0.09em 0.09em 0.05em #cccccc;'> " +
            "                       <div class='events-body' style='line-height:1.2'>" +
            "                           <div class='row'>     " +
            "                               <div class='col-xs-8'>     " +
            "                                    <p align ='left' class='pull-left' style='font-size: 14px;line-height:1.3;display:inline;margin-bottom:0px;margin-top:2px;margin-left:3px;font-family: \"Lato\",sans-serif;'> " +
            my_post_comments+
            "                                    </p> " +
            "                                </div>  " +
            "                               <div class='event-body col-xs-3 pull-left' style='display:inline;padding:0px;margin-left:15px;' align='center'> "+
            "                                  <div class='row' style='margin-top: 5%;margin-bottom: 5px'>  " +
           // "                                    <div class='events-right col-xs-8' style='margin-bottom:0%;margin-top: 0%;padding-right: 0px'> " +
            "                                     <div class='col-xs-10 text-center'>" +
            "                                         <h3 class='events-heading text-right' style='display: inline;font-size: 13px;font-family: \"Lato\",sans-serif;'>" +
            "                                              <span class='text-muted' style='font-size: 11px;display: inline;font-family: \"Lato\",sans-serif;'>Referred by:<br> </span>"+name+" " +
           // "                                               <p class='text-right text-muted' style='font-size: 7px; margin: 0px;'>2017-04-29&nbsp;&nbsp;<i class='fa fa-clock-o'></i> 2:25 PM</p>" +
            "                                         </h3>"+
            "                                     </div> " +
           /* "                                       <div align='right' style='margin-left:9px'> " +
            "                                            <h3 class='events-heading text-right' style='display: inline;font-size: 14px'> "+name+"  </h3> " +
//            "                                   <p class='text-right text-muted' style='font-size: 10px; margin: 0 0 5px;'>"+posted_on_format+"</p> " +
            "                                        </div>" +*/
            "                                  </div> " +
            "                                </div>"+
            "                          </div>  " +
            "                       </div> " +
            "                   </div> " +
            "               </dd> " +
            "           </dl> ";
        return row_html;
    }

    window.referAFriend = function() {
        var raf_name = $('#raf_name').val().trim();
        var raf_email = $('#raf_email').val().trim();
        var raf_linkedin = $('#raf_linkedin').val().trim();
        var raf_profile = $('#raf_profile').val().trim();
        var raf_skills = $('#raf_skills').val().trim();

        $("#raf_status_success").hide();
        $("#raf_status_failed").hide();

        if (raf_name == null || raf_name == "") {
            $("#raf_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px; width: 65%;'><span style='font-size: 15px'>Please enter name</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#raf_status_failed").show();
            $("#raf_name").focus();

            return false;
        }

        var res = validateEmails(raf_email);

        if(res == false) {
            $("#raf_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px; width: 65%;'><span style='font-size: 15px'>Please enter valid email</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#raf_status_failed").show();
            $("#raf_email").focus();

            return false;
        }

        if(raf_linkedin == null || raf_linkedin == "") {
            if (raf_profile == null || raf_profile == "") {
                $("#raf_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px; width: 65%;'><span style='font-size: 15px'>Please enter linkedin or upload profile</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                $("#raf_status_failed").show();
                $("#raf_linkedin").focus();

                return false;
            }
        }

        if (raf_skills == null || raf_skills == "") {
            $("#raf_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px; width: 65%;'>Please enter skills&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
            $("#raf_status_failed").show();
            $("#raf_skills").focus();

            return false;
        }

        //1. Register user, if not exists
        //2. get the user_id
        //3. Save Linkedin and skill details in the employee_details table
        //4. insert entry into the activities table
        //5. Refresh the My referals page

        $.ajax({
            type:         "post",
            url:          "action/refer_a_friend.jsp",
            data:         "raf_name="+encodeURIComponent(raf_name)+
                          "&raf_email="+encodeURIComponent(raf_email)+
                          "&raf_linkedin="+encodeURIComponent(raf_linkedin)+
                          "&raf_skills="+encodeURIComponent(raf_skills),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "login.html";
                    return;
                } else if(msg == "success") {
                    loadMyReferals();
                    $("#raf_status_success").html("<div class='alert alert-success' style='padding: 20px 0px 10px 10px; width: 65%;'><span style='font-size: 15px'>Successfully referred</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#raf_status_success").show();
                } else {
                    $("#raf_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px; width: 65%;'><span style='font-size: 15px'>Could not refer</span>&nbsp;&nbsp;<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'><i class='fa fa-close' style='color:#5bc0de;font-size: 14px; padding: 5px 10px 5px 10px;'></i></a>");
                    $("#raf_status_failed").show();
                }
            }
        });
    };

    $.fn.delayKeyup = function(callback, ms){
        var timer = 0;
        var el = $(this);
        $(this).keyup(function(){
            clearTimeout (timer);
            timer = setTimeout(function(){
                callback(el)
            }, ms);
        });
        return $(this);
    };
    $('#search_by_val').delayKeyup(function(el) {
        get_search_results_fn();

    }, 20);

    window.get_search_results_fn = function() {
        var typed_string = $("#search_by_val").val();

        var activities_table_html = "";
        var activities_found = false;

        if(activities_arr == null || activities_arr === undefined) {
            //No professionals found, do nothing...
            console.log("No professionals found for: "+typed_string);
        } else {
            for(var cnt = 0; cnt < activities_arr.length; cnt++) {
                try {
                    var activity_id = activities_arr[cnt].activity_id;
                    var category = activities_arr[cnt].category;
                    var comments = activities_arr[cnt].comments;
                    var posted_on = activities_arr[cnt].posted_on;
                    var posted_on_format = activities_arr[cnt].posted_on_format;
                    var posted_by = activities_arr[cnt].posted_by;
                    var post_likes = activities_arr[cnt].post_likes;
                    var post_dislikes = activities_arr[cnt].post_dislikes;
                    var post_comments = activities_arr[cnt].post_comments;
                    var fl_name = activities_arr[cnt].fl_name;

                    if(post_likes === undefined) {
                        post_likes = 0;
                    }
                    if(post_dislikes === undefined) {
                        post_dislikes = 0;
                    }
                    if(post_comments === undefined) {
                        post_comments = 0;
                    }
                    if(fl_name === undefined) {
                        fl_name = "N/A";
                    }

                    if(fl_name.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0 ||
                        comments.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0 ) {
                        var row_html = getActivitiesRowHTML(activity_id, category, comments, posted_on, posted_on_format, posted_by, post_likes, post_dislikes, post_comments, fl_name);
                        activities_table_html += row_html+"";

                        activities_found = true;
                    }
                } catch (error) {
                    console.log(error);
                    continue;
                }
            }
        }
        if(activities_found == false) {
            $("#display_activity_results_dl dl").remove();
            var no_pros_html = getNoProfessionalsHTML();
            $("#display_activity_results_dl").append(no_pros_html);
        } else {
            $("#display_activity_results_dl dl").remove();
            $("#display_activity_results_dl").append(activities_table_html);
        }
    }

    window.getAutoSuggestedKeywords = function(){
        $.ajax({
            type:         "post",
            url:         "action/get_suggested_keywords.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg == null || msg.length <= 0){
                    // DO NOTHING
                } else {
                    availableTags = JSON.parse(msg);
                }
            }
        });
    };

    window.autoSuggestKeywords = function() {
        $( "#search_by_val").autocomplete({
            minLength: 0,
            source: availableTags,
            //autoFocus:true,
            focus: function( event, ui ) {
                $( "#search_by_val" ).val( ui.item.label);
                return false;
            },
            select: function( event, ui ) {
                $( "#search_by_val" ).val( ui.item.label);
                get_search_results_fn();
                return false;
            }
        })
            .data("ui-autocomplete" )._renderItem = function(ul, item) {
            return $( "<li>" )
                .append( "<a>" + item.label + "</a>" )
                .appendTo( ul );
        };
    };

    function getNoProfessionalsHTML() {
        var no_pros_html = "<dl id='no_pros_id' style='padding:2px'>  " +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
            "           <div class='events-body'>" +
            "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
            "                   <center>No results found</center>" +
            "               </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";

        return no_pros_html;
    }

    var divID;
    var prevclicked;
    var call_time = "";
    var array;

    var availableTags;
    window.autoSuggestProfession = function() {
        $.ajax({
            type:         "post",
            url:         "action/get_suggested_professions.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg == null || msg.length <= 0){
                    // DO NOTHING
                } else {
                    availableTags = JSON.parse(msg);

                    $( "#contactprofile_profession").autocomplete({
                        minLength: 0,
                        source: availableTags,
                        //autoFocus:true,
                        focus: function( event, ui ) {
                            $("#contactprofile_profession" ).val( ui.item.label);
                            return false;
                        },
                        select: function( event, ui ) {
                            $( "#contactprofile_profession" ).val( ui.item.label);
                            return false;
                        }
                    })
                        .data("ui-autocomplete" )._renderItem = function(ul, item) {
                        return $( "<li>" )
                            .append( "<a>" + item.label + "</a>" )
                            .appendTo( ul );
                    };
                }
            }
        });
    };

});
