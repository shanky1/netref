var uagent = navigator.userAgent.toLowerCase();

var isAndroid = uagent.indexOf("android") > -1; //&& ua.indexOf("mobile");
var isWindowsPhone = uagent.indexOf("windows phone") > -1; //&& ua.indexOf("mobile");
var isiPhone = uagent.indexOf("iphone") > -1;
var isiPad = uagent.indexOf("ipad") > -1;

var device_type = "windows";

if(isAndroid) {
    device_type = 'android';
} else if(isiPhone || isiPad) {
    device_type = 'ios';
} else if(isWindowsPhone) {
    device_type = 'windows';
}

window.fbAsyncInit = function() {
    FB.init({
        appId: '1038705946154369',
        status: true,
        cookie: true,
        xfbml: true
    });
};

// Load the SDK asynchronously
(function(d) {
    var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "//connect.facebook.net/en_US/all.js";
    ref.parentNode.insertBefore(js, ref);
}(document));

//login() is not used for now
function login() {
    FB.login(function(response) {

        // handle the response
        console.log("Response goes here!");

    }, {scope: 'public_profile,email,user_friends'});
}

function logout() {
    FB.logout(function(response) {
        console.log("Netref: user is now successfully logged out from facebook");
        // user is now logged out
    });
}

function getNoConnectionHTML() {
    var no_connection_html = "<dl id='no_pros_id' style='padding:2px'>  " +
        "   <dd class='pos-left clearfix'>" +
        "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
        "           <div class='events-body'>" +
        "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
        "                   <center>Not connected.<br>Please verify your network connection.</center>" +
        "               </div>" +
        "           </div>" +
        "       </div>" +
        "   </dd>" +
        "</dl>";

    return no_connection_html;
}

function getNoProfessionalsHTML() {
    var no_pros_html = "<dl id='no_pros_id' style='padding:2px'>  " +
        "   <dd class='pos-left clearfix'>" +
        "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
        "           <div class='events-body'>" +
        "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
        "                   <center>No professionals found</center>" +
        "               </div>" +
        "           </div>" +
        "       </div>" +
        "   </dd>" +
        "</dl>";

    return no_pros_html;
}

var contacts_arr_intial = [];
var contacts_arr_remaining = [];
var contacts_arr_all = [];
var contacts_arr_all_length;

//Script common for all pages
$(document).ready(function() {
    $("#footer_icon_pros").longclick(500, function() {
        console.log(new Date()+"\t You longclicked. Nice!");
    });

    $.ajax({
        type:         "post",
        url:         "action/get_userid_from_session.jsp",

        success:    function(client_user_id) {
            client_user_id = escape(client_user_id).replace(/%0A/g, "");
            client_user_id = client_user_id.replace(/%0D/g, "");
            client_user_id = unescape(client_user_id);

            if(client_user_id == "-1") {
                window.location = "mobileregister_nc.html";
            }
        }
    });

    window.postContactsTODB_iOS = function() {
        $.ajax({
            type:         "post",
            url:         "action/postcontacts_memory_to_db_ios.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg != "") {
                    $("#show_user_details").html(msg);
                }
            }
        });
    };

    window.getUserDetails = function() {
        var post_url = "action/get_profile_details.jsp";
        $.ajax({
            type:         "post",
            url:          post_url,

            success:    function(profile_details_json) {
                profile_details_json = escape(profile_details_json).replace(/%0A/g, "");
                profile_details_json = profile_details_json.replace(/%0D/g, "");
                profile_details_json = unescape(profile_details_json);

                if(profile_details_json != null && profile_details_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

                var profile_details_arr = JSON.parse(profile_details_json);

                if(profile_details_arr == null || profile_details_arr.length <= 0) {
                    return;
                }

                for(var cnt = 0; cnt < profile_details_arr.length; cnt++) {
                    try {
                        var from_user_id = profile_details_arr[cnt].from_user_id;
                        var profile_name = profile_details_arr[cnt].profile_name;
                        var profile_image_file_name = profile_details_arr[cnt].profile_image_file_name;

                        if(profile_image_file_name == null || profile_image_file_name == "" || profile_image_file_name == "Not Avilable") {
                            $("#profile_image_display").attr("src","profile_images/profile.jpg");
                        } else {
                            $("#profile_image_display").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
                        }

                        $("#profile_name_display").html(profile_name);
                    } catch (error) {
                        continue;
                    }

                    //TODO, check for the notification icon

                    if(profile_name == null || profile_name.length <= 0) {
                        $("#footer_icon_alert").show();
                    } else {
                        $("#footer_icon_alert").hide();
                    }
                }
            }
        });
    };

//    on body load

    window.networkFriends = function () {
        if(device_type == "ios") {
            postContactsTODB_iOS();
        } else if(device_type == "android") {
            $("#footer_icon_android_whatsapp").show();
        }

        getUserDetails();   // to display the user details in the header
        loadFLView();
        $("#contacts_page").hide();          //hiding contacts tab by default on page load, that is on body load
        $("#networkfeed_page").hide();       //hiding networkfeed tab by default on page load, that is on body load
        $("#myprofile_page").hide();     //hiding my profile tab
        $("#professionals_page").show();     //showing professionals tab by default on page load, that is on body load
    };

//    Currently not used?
    window.approveFL = function(fcm_id) {

        $("#btn_fcm_"+fcm_id).prop('disabled', true);

        $.ajax({
            type:         "post",
            url:         "action/approve_fl.jsp",
            data:        "fcm_id="+fcm_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $("#fcm_"+fcm_id).html("Approved");
                } else {
                    $("#btn_fcm_"+fcm_id).prop('disabled', false);
                    alert("failed");
                }
            }
        });
    };

    $("#signout").click(function(e) {
        $.ajax({
            type:         "post",
            url:         "action/remove_session.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("success") >= 0) {
                    document.cookie = "netref_cookie_login=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                    document.cookie = "netref_cookie_mobile=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                    document.cookie = "netref_cookie_deviceid=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";

                    //Clearing cookie from the android app data
                    if(device_type == "android") {
                        try {
                            webapp.clearCookie();
                        } catch (err) {
                            console.log("Error while clearing the login cookie: "+err);
                        }
                    }

                    window.location = "mobileregister_nc.html";
                }
            }
        });
    });

    $("#signoutAll").click(function(e) {
        $.ajax({
            type:         "post",
            url:         "action/remove_session.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("success") >= 0) {
                    javascript:logout();

                    setTimeout(function() {
                        document.cookie = "netref_cookie_login=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                        document.cookie = "netref_cookie_mobile=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                        window.location = "mobileregister_nc.html";
                    }, 200);
                }
            }
        });
    });

    window.loadProfessionals = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???
        $("#footer_icon_pros").removeAttr("src").attr("src","images/professional.png");
        $("#contacts_page").hide();                                  //hiding contacts tab
        $("#networkfeed_page").hide();                               //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab

        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        showFLView();

        $("#showFLView_btn").attr("class","option active");         //showing professionals tab
        $("#professionals_page").show();                            //showing professionals tab

        $("#contact_search_div").hide();                            //hiding search by contacts input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#search_by_val_div").show();                            //showing search by pros input
    };

    window.loadContacts = function () {
//        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts.png");
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#networkfeed_page").hide();                               //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab

        $("#profile_notification").hide();
        $("#footer_icon_pros").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        $("#contacts_table_ref dl").remove();

        $("#contacts_page").show();                                  //showing contacts tab

        if(contacts_arr_all != null && contacts_arr_all.length > 0) {
            console.log(new Date()+"\t Start calling contact_search_fn() on loadContacts() ...");
            contact_search_fn();                                                    //If array > 0, simulating the contacts loading from the js array instead of getting it from server
            console.log(new Date()+"\t End calling  contact_search_fn() on loadContacts() ...");
        } else {
            console.log(new Date()+"\t calling getMobileContacts()...");
            getMobileContacts();
        }

        $("#search_by_val_div").hide();                            //hiding search by pros input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#contact_search_div").show();                            //showing search by contacts input
    };

    window.loadNetworkFeed = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???

        $("#search_by_val_div").hide();                            //hiding search by pros input
        $("#contact_search_div").hide();                            //hiding search by contacts input

        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network.png");
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#contacts_page").hide();                                  //hiding contacts tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab

        $("#contacts_table_loading").hide();
        $("#postresponse").hide();
        $("#screen_feed").show();

        $("#footer_icon_pros").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        loadActivities();
        loadAskList();

        $('#mynetwork').show();
        $('#network').show();
        $("#networkfeed_page").show();                               //showing networkfeed tab

        $("#networkfeed_post_div").show();                            //showing network feed post input
    };

    window.showUserNotifications = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#contacts_page").hide();                                  //hiding contacts tab
        $("#postresponse").hide();                                   //hiding post response area
        $("#networkfeed_page").hide();                               //hiding network feed area
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab

        $("#footer_icon_pros").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
//        $("#footer_icon_alert").attr("class","fa fa-exclamation fa-2x");

        loadUserNotifications();

        $("#useralerts_loading").hide();                         //hiding contacts loading symbol
        $("#useralerts_page").show();                               //showing networkfeed tab
    };

    window.showReminders = function () {
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#contacts_page").hide();                                  //hiding contacts tab
        $("#postresponse").hide();                                   //hiding post response area
        $("#networkfeed_page").hide();                               //hiding network feed area
        $("#useralerts_page").hide();                                //hiding networkfeed tab
        $("#myprofile_page").hide();                                //hiding my profile tab

        $("#footer_icon_pros").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
        $("#footer_icon_contacts").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
        $("#footer_icon_networkfeed").attr("style","font-size: 2.5rem;color: #BF9069;margin-top: 5px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
        $("#footer_icon_myaccount").attr("style","color: #FF6666;margin-top: 5px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        loadReminders();

        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();                               //showing reminders tab
    };

    window.showReminders_Admin = function () {
        loadReminders_Admin();

        $("#reminders_loading").hide();                         //hiding contacts loading symbol
        $("#reminders_page").show();                               //showing reminders tab
    };

    window.checkProfileName_Cookie = function () {
        readCookieForProfileName();                 //checking the profile name for the first time, until browser cache cleared
    };

    function readCookieForProfileName() {
        var cookie_name = "netref_profile_check";
        var cookie_value = "";

        var nameEQ = cookie_name + "=";
        var ca = document.cookie.split(';');

        var cookie_found = false;

        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];

            while (c.charAt(0) == ' ')
                c = c.substring(1, c.length);

            if (c.indexOf(nameEQ) >= 0) {
                var cookie_on_success = c;
                cookie_found = true;
                break;
            }
        }

        if(cookie_found == false) {
//            alert("profile name cookie not found");
            checkProfileName();
        } else {
//            alert("profile name cookie found");
        }
    }

    window.checkProfileName = function () {
        var post_url = "action/check_profile_name.jsp";
        $.ajax({
            type:         "post",
            url:          post_url,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg == "profilename_already_set") {
//                    alert("profilename_already_set");
                } else {
                    setCookieForProfileName();
                    $("#add_profile_form").html(msg);
                    $("#click_to_display_profile_form").click();
                }
            }
        });
        $("#click_to_display_fl_details_for_client").click();
    };

    function setCookieForProfileName() {
        var cookie_name = "netref_profile_check";
        var cookie_value = "netref_profile_val";
        var days = 365;

        var date = new Date();
        var time = date.getTime()+(days*24*60*60*1000);
        date.setTime(time);
        var expires = "; expires="+date.toGMTString();

        var cookie_set = cookie_name+"="+cookie_value+expires+"; path=/";

        document.cookie = cookie_set;
    }

    window.checkTooltips_Cookie = function () {
        readCookieForTooltips();                 //checking the tooltips for the first time, until browser cache cleared
    };

    function readCookieForTooltips() {
        var cookie_name = "netref_tooltips_check";
        var cookie_value = "";

        var nameEQ = cookie_name + "=";
        var ca = document.cookie.split(';');

        var cookie_found = false;

        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];

            while (c.charAt(0) == ' ')
                c = c.substring(1, c.length);

            if (c.indexOf(nameEQ) >= 0) {
                var cookie_on_success = c;
                cookie_found = true;
                break;
            }
        }

        if(cookie_found == false) {
            console.log("tooltips cookie not found");
            $('#tooltip1').modal('show');
            setCookieForTooltips();
        } else {
            console.log("tooltips cookie found. do nothing...");
        }
    }

    function setCookieForTooltips() {
        var cookie_name = "netref_tooltips_check";
        var cookie_value = "netref_tooltips_val";
        var days = 365;

        var date = new Date();
        var time = date.getTime()+(days*24*60*60*1000);
        date.setTime(time);
        var expires = "; expires="+date.toGMTString();

        var cookie_set = cookie_name+"="+cookie_value+expires+"; path=/";

        console.log("setting tooltips cookie");

        document.cookie = cookie_set;
    }

    window.openProfileForm = function(from) {
        var post_url = "action/get_profile_form.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "from="+from,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#add_profile_form").html(msg);
                } else {
                    $("#add_profile_form_status").html(msg);
                }
            }
        });
        $("#click_to_display_profile_form").click();
        $("#profileheader").click();
    };

    window.openProfilePage = function() {
        $("#contact_search_div").hide();                            //hiding search by contacts input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#search_by_val_div").hide();                            //hiding search by pros input

        $("#profile_details_status_failed").hide();
        $("#profile_details_status_success").hide();

        $("#footer_icon_pros").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");

        $("#contacts_page").hide();                                  //hiding contacts tab
        $("#networkfeed_page").hide();                               //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab

        getProfileDetails();

        $("#myprofile_page").show();
        $("#profile").click();
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
                    window.location = "mobileregister_nc.html";
                }

                var profile_details_arr = JSON.parse(profile_details_json);

                if(profile_details_arr == null || profile_details_arr.length <= 0) {
                    return;
                }

                for(var cnt = 0; cnt < profile_details_arr.length; cnt++) {
                    try {
                        var from_user_id = profile_details_arr[cnt].from_user_id;
                        var profile_name = profile_details_arr[cnt].profile_name;
                        var profile_image_file_name = profile_details_arr[cnt].profile_image_file_name;
                        var profile_profession = profile_details_arr[cnt].profile_profession;
                        var profile_expertise = profile_details_arr[cnt].profile_expertise;
                        var profile_experience = profile_details_arr[cnt].profile_experience;
                        var profile_linkedin = profile_details_arr[cnt].profile_linkedin;
                        var profile_location = profile_details_arr[cnt].profile_location;
                        var profile_about = profile_details_arr[cnt].profile_about;

                        if(profile_image_file_name == null || profile_image_file_name == "" || profile_image_file_name == "Not Avilable") {
                            $("#profile_image_display").attr("src","profile_images/profile.jpg");
                        } else {
                            $("#profile_image_display").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
                        }

                        $("#profile_name").val(profile_name);
                        $("#profile_profession").val(profile_profession);
                        $("#profile_expertise").val(profile_expertise);
                        $("#profile_experience").val(profile_experience);
                        $("#profile_linkedin").val(profile_linkedin);
                        $("#profile_location").val(profile_location);
                        $("#profile_about").val(profile_about);
                    } catch (error) {
                        continue;
                    }
                }
            }
        });
    };

    window.refreshProfileImage_Android = function(from_user_id, profile_image_file_name) {
        if(profile_image_file_name == null) {
            //Do nothing
        } else {
            $("#profile_image").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
        }
        getUserDetails();
    };

    window.saveProfileDetails_OLD = function(from) {            //TODO, remove this, updated later
        var profile_name = $('#profile_name').val();

        if(profile_name == null || profile_name == "") {
            $("#add_profile_form_status").html("<font color='red'>Please enter name</font>");
            $("#add_profile_form_status").focus();
            return false;
        }

        $.ajax({
            type:         "post",
            url:         "action/add_profile.jsp",
            data:         "profile_name="+encodeURIComponent(profile_name),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
//                    $("#add_profile_form_status").html("<font color='blue'>Successfully saved</font>");
                    $("#addprofile").modal('hide');
                    getUserDetails();

                    if(from == "from_alert") {
                        loadUserNotifications();
                    }
                } else {
                    $("#add_profile_form_status").html("<font color='red'>Could not save the data</font>");
                }
            }
        });
    };

    window.openSkillsForm = function(from) {
        var post_url = "action/get_skills_form.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "from="+from,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#add_skills_form").html(msg);
                } else {
                    alert(msg);
                }
            }
        });
        $("#click_to_display_skills_form").click();
        $("#skillsheader").click();
    };

    window.saveProfessionDetails = function(from) {
        var profession = $('#profession').val();
        var expertise = $('#expertise').val();
        var experience = $('#experience').val();
        var linkedin = $('#linkedin').val();
        var location = $('#location').val();

        if(profession == null || profession == "") {
            $("#add_skills_form_status").html("<font color='red'>Please enter profession</font>");
            $("#profession").focus();
            return false;
        }

        if(expertise == null || expertise == "") {
            $("#add_skills_form_status").html("<font color='red'>Please enter expertise</font>");
            $("#expertise").focus();
            return false;
        }

        if(experience == null || experience == "") {
            $("#add_skills_form_status").html("<font color='red'>Please enter experience</font>");
            $("#experience").focus();
            return false;
        }

        $("#add_skills_form_status").html("<font color='blue'>Please wait...</font>");

        $.ajax({
            type:         "post",
            url:         "action/addskills_fl.jsp",
            data:         "profession="+encodeURIComponent(profession)+"&expertise="+encodeURIComponent(expertise)+"&experience="+encodeURIComponent(experience)+"&location="+encodeURIComponent(location)+"&linkedin="+encodeURIComponent(linkedin),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
//                $("#add_skills_form_status").html("<font color='blue'>Successfully saved</font>");
                    $("#addskills").modal('hide');

                    if(from == "from_alert") {
                        loadUserNotifications();
                    }
                } else {
                    $("#add_skills_form_status").html("<font color='red'>Could not save the data</font>");
                }
            }
        });
    };

    window.saveProfileDetails = function() {
        $("#profile_details_status_failed").hide();
        $("#profile_details_status_success").hide();

        var profile_name = $('#profile_name').val().trim();
        var profile_profession = $('#profile_profession').val().trim();
        var profile_expertise = $('#profile_expertise').val().trim();
        var profile_experience = $('#profile_experience').val().trim();
        var profile_linkedin = $('#profile_linkedin').val().trim();
        var profile_location = $('#profile_location').val().trim();
        var profile_about = $('#profile_about').val().trim();

        if(profile_name == null || profile_name == "") {
            $("#profile_details_status_failed").html("<div class='alert alert-danger'>Please enter profile name<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
            $("#profile_details_status_failed").show();
            $('#profile_name').css({
                "border-color": "red"
            });
            $("#profile_name").focus();

            return false;
        }

        /*
         if(profile_profession == null || profile_profession == "") {
         $("#profile_details_status_failed").html("Please enter profession");
         $("#profile_details_status_failed").show();
         $("#profile_profession").focus();
         return false;
         }

         if(profile_expertise == null || profile_expertise == "") {
         $("#profile_details_status_failed").html("Please enter expertise");
         $("#profile_details_status_failed").show();
         $("#profile_expertise").focus();
         return false;
         }

         if(profile_experience == null || profile_experience == "") {
         $("#profile_details_status_failed").html("Please enter experience");
         $("#profile_details_status_failed").show();
         $("#profile_experience").focus();
         return false;
         }
         */

        //linkedin and profile_about are not mandatory for now
        /*
         if(profile_linkedin == null || profile_linkedin == "") {
         $("#profile_details_status_failed").html("Please enter linkedin");
         $("#profile_details_status_failed").show();
         $("#profile_linkedin").focus();
         return false;
         }
         if(profile_about == null || profile_about == "") {
         $("#profile_details_status_failed").html("Please enter about yourself");
         $("#profile_details_status_failed").show();
         $("#profile_about").focus();
         return false;
         }
         */
        $("#profile_details_status_success").hide();
        $("#profile_details_status_failed").hide();

        $.ajax({
            type:         "post",
            url:         "action/save_profile_details.jsp",
            data:         "profile_name="+encodeURIComponent(profile_name)+
            "&profile_profession="+encodeURIComponent(profile_profession)+
            "&profile_expertise="+encodeURIComponent(profile_expertise)+
            "&profile_experience="+encodeURIComponent(profile_experience)+
            "&profile_linkedin="+encodeURIComponent(profile_linkedin)+
            "&profile_location="+encodeURIComponent(profile_location)+
            "&profile_about="+encodeURIComponent(profile_about),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
//                    $("#profile_details_status_success").html("Successfully saved");
                    $("#profile_details_status_success").html("<div class='alert alert-success'>Successfully saved<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#profile_details_status_success").show();
                    $('#profile_name').css({
                        "border-color": ""
                    });
                    getUserDetails();
                } else {
//                    $("#profile_details_status_failed").html("Could not save the data");
                    $("#profile_details_status_failed").html("<div class='alert alert-danger'>Could not save the data<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#profile_details_status_failed").show();
                }
            }
        });
    };
});

function getProfileImage()  {
    $("#profile_details_status_failed").hide();
    $("#profile_details_status_success").hide();

    //pick the profile image from the respective device
    if(device_type == "android") {
        try {
            webapp.getProfileImage();
        } catch (err) {
            console.log(new Date()+"\t Error while picking device image from android: "+err);
        }
    } else {
        $("#profile_details_status_failed").html("<div class='alert alert-info'>To Be Done...<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
        $("#profile_details_status_failed").show();
    }
}

function showFLclients(fl_userid, fl_name)  {
    getandShowProfessionalDetail(fl_userid);
    $.ajax({
        type:         "post",
        url:         "action/show_fl_clients.jsp",
        data:         "fl_userid="+fl_userid+"&fl_name="+encodeURIComponent(fl_name),

        success:    function(msg) {
            msg = escape(msg).replace(/%0A/g, "");
            msg = msg.replace(/%0D/g, "");
            msg = unescape(msg);

            if(msg != null && msg.indexOf("session_expired") >= 0) {
                window.location = "mobileregister_nc.html";
            } else if(msg != null) {
                $("#display_fl_clients").html(msg);
                $("#showflcl_"+fl_userid+"_search").html(msg);      //To load in the search by skills screen
            } else {
                //DO NOTHING
            }
        }
    });

    $('#prof_section_id').attr("style", "height:65vh; margin-bottom: 15px; "); //when click '>' show client button scroll will be hide
    $('#professional_list').hide();
    $('#searchresults').hide();
    $('#searchprosclients').hide();
    $('#fl_clients_prosname').html(fl_name);
    $('#prosclients').show();
    $('#fl_'+fl_userid).show();
    $('#showflcl_'+fl_userid+"_search").hide();
}

function showsearchFLclients(fl_userid)  {
    $.ajax({
        type:         "post",
        url:         "action/show_fl_clients.jsp",
        data:         "fl_userid="+fl_userid,

        success:    function(msg) {
            msg = escape(msg).replace(/%0A/g, "");
            msg = msg.replace(/%0D/g, "");
            msg = unescape(msg);

            if(msg != null && msg.indexOf("session_expired") >= 0) {
                window.location = "mobileregister_nc.html";
            } else if(msg != null) {

                $("#display_searchfl_clients").html(msg);
                $("#showflcl_"+fl_userid+"_search").html(msg);      //To load in the search by skills screen
            } else {
                //DO NOTHING
            }
        }
    });

    $('#professional_list').hide();
    $('#searchresults').hide();
    $('#searchprosclients').show();
    $('#prosclients').hide();
    $('#fl_'+fl_userid).show();
    $('#showflcl_'+fl_userid+"_search").hide();
}

function hideFLclients()  {

    $('#prof_section_id').attr("style", "height:65vh; margin-bottom: 15px; overflow-y: scroll;overflow-x: hidden; ");
    $('#professional_list').show();
    $('#searchresults').hide();
    $('#searchprosclients').hide();
    $('#prosclients').hide();
}

function hidesearchFLclients()  {
    $('#professional_list').hide();
    $('#searchresults').show();
    $('#searchprosclients').hide();
    $('#prosclients').hide();
}

function showfllist(friend_userid, friend_name) {
    $('#display_friend_pros_result').html('');
    $.ajax({
        type:         "post",
        url:         "action/get_fl_list.jsp",
        data:         "friend_userid="+friend_userid,

        success:    function(msg) {
            msg = escape(msg).replace(/%0A/g, "");
            msg = msg.replace(/%0D/g, "");
            msg = unescape(msg);

            if(msg != null && msg.indexOf("session_expired") >= 0) {
                window.location = "mobileregister_nc.html";
            }  else if(msg == 0) {
                var no_pros_html = getNoProfessionalsHTML();

                $("#display_friend_pros_result").html(no_pros_html);
            } else if(msg != null)  {
                $("#display_friend_pros_result").html(msg);
            }
        }
    });

    $('#showfriends').hide();
    $('#showskfriends').hide();
    $('#friend_name').html(friend_name);
    $('#showfriendfreelancers').show();
    $('#fl_'+friend_userid).show();
}

function friendlist()  {
    $('#showfriends').show();
    $('#showskfriends').show();
    $('#showfriendfreelancers').hide();
}

function hideFriendFLs(friend_userid)  {
    $('#fllist_'+friend_userid).hide();
    $('#hidefriends_fl_'+friend_userid).hide();
    $('#showfriends_fl_'+friend_userid).show();
    $('#fl_'+friend_userid).hide();
}

function showdetails(activity_id)  {
    $('#fldetails_'+activity_id).show();
    $('#flactions_'+activity_id).show();
}

function response(fl_userid)  {
    $('#responsedetails_'+fl_userid).show();
}

function showactions(fl_userid)  {
    $('#actions_'+fl_userid).show();
    $('#hideactions_'+fl_userid).show();
    $('#showactions_'+fl_userid).hide();
}
function hideactions(fl_userid)  {
    $('#actions_'+fl_userid).hide();
    $('#hideactions_'+fl_userid).hide();
    $('#showactions_'+fl_userid).show();
}


//script for the Professionals page

$(document).ready(function() {

    window.loadRelationshipFriends = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_friends.jsp",

            success:    function(friend_list_json) {
                friend_list_json = escape(friend_list_json).replace(/%0A/g, "");
                friend_list_json = friend_list_json.replace(/%0D/g, "");
                friend_list_json = unescape(friend_list_json);

                if(friend_list_json != null && friend_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

//                console.log(new Date()+"\t Got the response: "+friend_list_json.length+", friend_list_json: "+friend_list_json);

                var friend_arr = JSON.parse(friend_list_json);

                if(friend_arr == null || friend_arr.length <= 0) {
//                    var no_friends_html = getNoFriendsHTML();                 //not used for now
//                    $("#display_friend_results").append(no_friends_html);     //not used for now

                    //No friendlist found, do nothing
                    return;
                }

                friend_arr.sort(function(a, b) {
                    var nameA = a.friend_name.toLowerCase(), nameB = b.friend_name.toLowerCase();
                    if (nameA < nameB) //sort string ascending
                        return -1;
                    if (nameA > nameB)
                        return 1;
                    return 0; //default return value (no sorting)
                });

                var friend_table_html = "";
                var friend_found = false;

                console.log(new Date()+"\t Number of friends loading...: "+friend_arr.length);

                $("#display_friend_results dl").remove();

                for(var cnt = 0; cnt < friend_arr.length; cnt++) {
                    try {
                        var friend_userid = friend_arr[cnt].friend_userid;
                        var friend_name = friend_arr[cnt].friend_name;
                        var friend_photo_path = friend_arr[cnt].friend_photo_path;

                        var row_html = getFriendsRowHTML(friend_userid, friend_name, friend_photo_path);

                        $("#display_friend_results").append(row_html);

                        friend_found = true;
                    } catch (error) {
                        continue;
                    }
                }
            }
        });
    };

    function getNoFriendsHTML() {
        var no_pros_html = "<dl id='no_friends_id' style='padding:0px'>  " +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #ffffff;'>" +
            "           <div class='events-body'>" +
            "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
            "                   <center>No friends found</center>" +
            "               </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";

        return no_pros_html;
    }

    function getFriendsRowHTML(friend_userid, friend_name, friend_photo_path) {

        friend_photo_path = (friend_photo_path != null && friend_photo_path.trim().length() > 0 ? friend_photo_path : "images/profile.jpg");

        var row_html = "<dl style='padding:0px'  >" +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top:2px; box-shadow: 0.09em 0.09em 0.09em 0.05em  #fef7f7; padding: 5px 10px 5px 10px;' onclick='showfllist("+friend_userid+", \""+friend_name+"\");'>" +
            "           <div class='pull-left'>" +
            "               <img class='img-circle' style='max-width:45px' src='"+friend_photo_path+"' class='events-object img-rounded'>" +
            "           </div>" +
            "           <div class='events-body' >" +
            "               <div align='left' class='events' style='width:80%;display:inline-block'>" +
            "                   <h2 style='margin-top:3px;margin-bottom:3px;font-size:15px;margin-left:3px'>"+friend_name+"</h2>"+
            "               </div>" +
            "               <div align='right' class='events pull-right' style='width:10%;display:inline-block'>" +
            "               <button data-toggle='modal' type='button' id='showfriends_fl_"+friend_userid+"' class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;background-color:white;margin-top:2px;' onclick='showfllist("+friend_userid+", \""+friend_name+"\");'>" +
            "                   <i class='fa fa-angle-right' style='color:#808080;font-size: 25px;'></i>" +
            "               </button>" +
            "               <button  data-toggle='modal' type='button' id='hidefriends_fl_"+friend_userid+"'  class='btn btn-default btn-simple btn-lg' style='padding: 1px 1px;display: none;' onclick='hideFriendFLs("+friend_userid+");'>" +
            "                   <i class='fa fa-caret-down fa-lg' style='color:#22A7F0'></i>" +
            "               </button>" +
            "           </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";
        return row_html;
    }

    window.loadSKFriends = function() {
        $("#search_results").val('');
        $("#load_fls_loading").show();
        $.ajax({
            type:         "post",

            url:         "action/load_sklist.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#load_fls_loading").hide();
                    $("#display_sk_results").html(msg);
                    $("#display_friend_results").show();
                }
            },
            error: function(jqXHR, textStatus, error) {
                $("#load_fls_loading").hide();
                $("#display_friend_results").hide();
                var err = getNoConnectionHTML();
                $("#display_sk_results").html(err);
            }
        });
    };

    var professional_arr = [];

    window.loadFLView = function() {
        $("#search_results").val('');
        $("#load_fls_loading").show();
        $.ajax({
            type:         "post",
            url:         "action/load_freelancers.jsp",

            success:    function(professional_list_json) {
                professional_list_json = escape(professional_list_json).replace(/%0A/g, "");
                professional_list_json = professional_list_json.replace(/%0D/g, "");
                professional_list_json = unescape(professional_list_json);

                if(professional_list_json != null && professional_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

//                console.log(new Date()+"\t Got the response: "+professional_list_json.length+", profession_list_json: "+professional_list_json);

                professional_arr = JSON.parse(professional_list_json);

                if(professional_arr == null || professional_arr.length <= 0) {
                    $("#load_fls dl").remove();
                    $("#load_fls_loading").hide();

                    var no_pros_html = getNoProfessionalsHTML();
                    $("#load_fls").append(no_pros_html);

                    //No professional list found, do nothing
                    return;
                }

                professional_arr.sort(function(a, b) {
                    var nameA = a.fl_name.toLowerCase(), nameB = b.fl_name.toLowerCase();
                    if (nameA < nameB) //sort string ascending
                        return -1;
                    if (nameA > nameB)
                        return 1;
                    return 0; //default return value (no sorting)
                });

                var professional_table_html = "";
                var professional_found = false;

                console.log(new Date()+"\t Number of professionals loading...: "+professional_arr.length);

                $("#load_fls dl").remove();
                $("#load_fls_loading").hide();

                for(var cnt = 0; cnt < professional_arr.length; cnt++) {
                    try {
                        var fl_userid = professional_arr[cnt].fl_userid;
                        var fl_name = professional_arr[cnt].fl_name;
                        var profession = professional_arr[cnt].profession;
                        var expertise = professional_arr[cnt].expertise;
                        var experience = professional_arr[cnt].experience;
                        var linkedin = professional_arr[cnt].linkedin;
                        var fb_photo_path = professional_arr[cnt].fb_photo_path;
                        var fb_user_id = professional_arr[cnt].fb_user_id;

                        var row_html = getProfessionalRowHTML(fl_userid, fl_name, profession, expertise, experience, linkedin, fb_photo_path, fb_user_id);

                        $("#load_fls").append(row_html);

                        professional_found = true;
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                /*
                 if (jqXHR.status === 0) {
                 $("#load_fls_loading").hide();
                 $("#load_fls").html("Not connected.<br>Please verify your network connection.");
                 }
                 */

                $("#load_fls_loading").hide();
                var err = getNoConnectionHTML();
                $("#load_fls").html(err);
                /*
                 else if (jqXHR.status == 404) {
                 return ('The requested page not found. [404]');
                 } else if (jqXHR.status == 500) {
                 return ('Internal Server Error [500].');
                 } else if (exception === 'parsererror') {
                 return ('Requested JSON parse failed.');
                 } else if (exception === 'timeout') {
                 return ('Time out error.');
                 } else if (exception === 'abort') {
                 return ('Ajax request aborted.');
                 } else {
                 return ('Uncaught Error.\n' + jqXHR.responseText);
                 }
                 */
            }
        });
    };

    function getProfessionalRowHTML(fl_userid, fl_name, profession, expertise, experience, linkedin, fb_photo_path, fb_user_id) {

        fb_photo_path = (fb_photo_path != null && fb_photo_path.trim().length > 0 ? fb_photo_path : "images/profile.jpg");

        var linkedin_str1 = "<button class='btn btn-info btn-simple btn-fill btn-sm' style='cursor: pointer;padding: 0px 5px' data-original-title='Linkedin profile' type='button' title='' rel='tooltip'  onclick=\"window.open('"+linkedin+"', '_blank')\"><i class='fa fa-linkedin'></i> </button>";
        var linkedin_str = (linkedin != null && linkedin.trim().length > 0 ? linkedin_str1 : "");

        var row_html = "<dl style='word-wrap: break-word;padding:0px; width: 99%'>" +
            "           <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
            "              <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block;'>" +
            "                   <p class='pull-left' style='margin-left:-3px;margin-bottom: 0px'> <img class='img-circle' style='main-width:35px;max-width:45px;margin-bottom:10px' src="+fb_photo_path+"></p>"+
            "                      <div class='events-body ' style='margiun-right:0px;'>" +
            "                           <div align='left' class='pull-left' style='width:90%;margin-bottom:2px'>   " +
            "                               <h2 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(fl_name != null && fl_name.trim().length > 0 ? fl_name  : "N/A")+" &nbsp;"+(linkedin_str)+"</h2>"+
            "                                    <h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px' >" +
            "                                    Profession: "+(profession != null && profession.trim().length > 0 ? profession : "N/A")+"<br>" +
            (experience != null && experience.trim().length > 0 ? "Experience: "+experience+"<br>" : "" )+"" +
            (expertise != null && expertise.trim().length > 0 ? "Expertise: "+expertise+"<br>" : " ")+"" +
            "                             </div>" +
            "                            <div class='pull-right' style='width:10%;background-color:#ffffff;'>  " +
            "                               <button  data-toggle='modal' type='button' id='showworkedwith_"+fl_userid+"' class='btn btn-default btn-simple btn-lg pull-right' style='background-color:#ffffff;' onclick='showFLclients("+fl_userid+", \""+fl_name+"\");'><i class='fa fa-angle-right' style='color:#808080;font-size:25px'></i></button>" +
//            "                                <button  data-toggle='modal' type='button' id='hideworkedwith_"+fl_userid+"'  class='btn btn-default btn-simple btn-lg pull-right' style='padding: 1px 5px; display: none;background-color:#ffffff;margin-top:-18px' onclick='hideFLclients("+fl_userid+");'><i class='fa fa-caret-up fa-lg' style='color:#22A7F0'></i></button> </td>" +
            "                           </div>" +
            "                        </div>" +
            "                 </div>" +
            "</dd>" +

            "<div  id='showflcl_"+fl_userid+"' class='text-left' style='max-width: 100%;margin-top: %;display_none;background-color:#f5f5f5'></div>"+
            "</dl>";
        return row_html;
    }

    $("#get_search_results_old").click(function(e) {                //TODO, OLD. replaced by get_search_results_fn. remove later
        $('#showFriendsView_btn').attr("class","option");       //remove highlight color of the FL View button
        $('#showFLView_btn').attr("class","option");
        $("#showfriend header").show();//remove highlight color of the Friends View button
        $('#flview_table').hide();                              //hide FL View table
        $('#friendsview_table').hide();                         //hide Friends View table
        $('#friendsview_table').hide();
        $('#professional_list').hide();
        $('#searchresults').show();
        $('#searchprosclients').hide();
        $('#prosclients').hide();

        var search_by = "profession";
        var search_value = $("#search_results").val();

        $.ajax({
            type:         "post",
            url:         "action/get_search_results.jsp",
            data:        "search_by="+search_by+
                "&search_value=" + search_value,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg == null || msg.trim() == "") {
                    $("#load_fls_loading").hide();
                    $("#display_search_results").html("<br><br>No professionals found for the selected criteria");
                    $('#searchresult').show();
                } else if(msg != null) {
                    $("#load_fls_loading").hide();
                    $("#display_search_results").html(msg);
                    $('#searchresult').show();
//                    $("#search_results").focus();
                }
            }
        });
    });

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

    //Delay function to call up on every keyup. jQuery 1.7.1 or up required
    //REF: http://jsfiddle.net/Us9bu/2/
    $('#search_by_val').delayKeyup(function(el) {
        get_search_results_fn();
    }, 500);                //delay in milli seconds

    window.get_search_results_fn = function() {
        $('#prof_section_id').attr("style", "height:65vh; margin-bottom: 15px; overflow-y: scroll;overflow-x: hidden; "); // ontype in search text box scroll will show
        $('#prosclients').hide();
        $('#showFriendsView_btn').attr("class","option");       //remove highlight color of the FL View button
        $('#showFLView_btn').attr("class","option active");
        $('#friendsview_table').hide();

        var typed_string = $("#search_by_val").val();

        var professional_table_html = "";
        var professional_found = false;

        if(professional_arr == null || professional_arr === undefined) {
            //No professionals found, do nothing...
            console.log("No professionals found for: "+typed_string);
        } else {
            for(var cnt = 0; cnt < professional_arr.length; cnt++) {
                try {
                    var fl_userid = professional_arr[cnt].fl_userid;
                    var fl_name = professional_arr[cnt].fl_name;
                    var profession = professional_arr[cnt].profession;
                    var expertise = professional_arr[cnt].expertise;
                    var experience = professional_arr[cnt].experience;
                    var linkedin = professional_arr[cnt].linkedin;
                    var fb_photo_path = professional_arr[cnt].fb_photo_path;
                    var fb_user_id = professional_arr[cnt].fb_user_id;

                    if(fl_name.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0 ||
                        profession.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0 ||
                        expertise.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0) {
                        var row_html = getProfessionalRowHTML(fl_userid, fl_name, profession, expertise, experience, linkedin, fb_photo_path, fb_user_id);

                        professional_table_html += row_html+"";
                        professional_found = true;
                    }
                } catch (error) {
                    console.log(error);
                    continue;
                }
            }
        }

        if(professional_found == false) {
            $("#load_fls dl").remove();
            $("#load_fls_loading").hide();
            var no_pros_html = getNoProfessionalsHTML();
            $("#load_fls").append(no_pros_html);
        } else {
            $("#load_fls dl").remove();
            $("#load_fls_loading").hide();
            $("#load_fls").append(professional_table_html);
        }

        $('#flview_table').show();
        $('#professional_list').show();
    }

    window.showFriendsView = function() {
        $('#search_by_val').val('');
        $('#showfriendfreelancers').hide();
        $('#flview_table').hide();
        $('#searchresult').hide();
        $('#professional_list').hide();
        $('#prosclients').hide();
        $('#showFLView_btn').attr("class","option");
        $('#showFriendsView_btn').attr("class","option active");
        loadSKFriends();
        $('#friendsview_table').show();
        $('#showskfriends').show();
        loadRelationshipFriends();
        $('#showfriends').show();
    };

    window.showFLView = function() {
        $('#search_by_val').val('');
        $('#showfriendfreelancers').hide();
        $('#friendsview_table').hide();
        $('#prosclients').hide();
        $('#searchresult').hide();
        $('#showFriendsView_btn').attr("class","option");
        $('#showFLView_btn').attr("class","option active");
        loadFLView();
        $('#flview_table').show();
        $('#professional_list').show();
    };

    window.clearproscontent = function() {
        $('#prof_section_id').attr("style", "height:65vh; margin-bottom: 15px; overflow-y: scroll;overflow-x: hidden; "); // onclick on 'X' close button from search 'search by name and profession' show scroll
        $('#search_by_val').val('');
        $('#prosclients').hide();
        get_search_results_fn();
    };

    window.clearcontactsearch_old = function() {            //TODO, remove later. updated this function
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#networkfeed_page").hide();                               //hiding networkfeed tab

        /*
         $("#footer_icon_contacts").attr("style","color: #FF6666;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
         $("#footer_icon_pros").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
         $("#footer_icon_networkfeed").attr("style","font-size: 2.5rem;color: #BF9069;margin-top: 5px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
         */

        $("#contacts_table_ref dl").remove();
        getMobileContacts();
        $("#contacts_page").show();
    };

    window.clearcontactsearch = function() {
        $('#contact_search').val('');
        console.log(new Date()+"\t Start calling contact_search_fn() with in clearcontactsearch()...");
        contact_search_fn();
        console.log(new Date()+"\t End calling contact_search_fn() with in clearcontactsearch()...");
        $("#alphabet_status_id").css("display", "");
    };

    window.clearposttext = function() {
        $('#ask_in_network').val('');
    };
});

//script for the Mobile contacts page

var validate_email;
validate_email = function (field) {
    var filter = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    if (!filter.test(field)) {
        return false;
    } else {
        return true;
    }
};

$(document).ready(function() {

    $('#contact').height($(window).height() - 50);

    window.openAddContactModal = function() {
        $("#add_contact_status").hide();
        $('#contact_name').val("");
        $('#contact_number').val("");
        $('#contact_mail').val("");

        $.ajax({
            type:         "post",
            url:         "action/get_login_type_from_session.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("fb_login") >= 0) {
                    $("#click_to_display_addcontact_modal_fb").click();
                } else if(msg != null && msg.indexOf("mobile_login") >= 0) {
                    $("#click_to_display_addcontact_modal_mobile").click();
                }
            }
        });
    };

    $("#submitAddContactMobile").click(function(e) {
        $("#add_contact_status").hide();

        var contact_name = $('#contact_name_mobile').val();
        var contact_number = $('#contact_number_mobile').val();
        var contact_mail = $('#contact_mail_mobile').val();

        if(contact_name == null || contact_name == "") {
            $("#add_contact_status_mobile").html("Name cannot be empty");
            $("#add_contact_status_mobile").show();
            $("#contact_name_mobile").focus();
            return false;
        }

        if(contact_number == null || contact_number == "") {
            $("#add_contact_status_mobile").html("Mobile cannot be empty");
            $("#add_contact_status_mobile").show();
            $("#contact_number_mobile").focus();
            return false;
        }

        if (!$.isNumeric(contact_number)) {
            $("#add_contact_status_mobile").text("Please enter valid mobile number");
            $("#add_contact_status_mobile").show();
            $("#contact_number").focus();
            return false;
        }

        if(contact_mail == null || contact_mail == "") {
//                $("#add_contact_status_mobile").html("Email cannot be empty");
//                $("#add_contact_status_mobile").show();
//                $("#contact_mail_mobile").focus();
//                return false;

            //DO Nothing, making it optional for now
        } else {
            var val_email = validate_email(contact_mail).toString();

            if (val_email == 'false') {
                $("#add_contact_status_mobile").text("Please enter valid email");
                $("#add_contact_status_mobile").show();
                $("#contact_mail_mobile").focus();
                return false;
            }
        }

        var connection = 0;

        connection = $("#connection_mobile").val();

        $.ajax({
            type:         "post",
            url:         "action/add_mobile_contact.jsp",
            data:        "contact_name="+contact_name+
                "&contact_number="+encodeURIComponent(contact_number)+
                "&contact_mail="+contact_mail+
                "&connection="+connection,

            success:    function(add_contact_list_json) {
                add_contact_list_json = escape(add_contact_list_json).replace(/%0A/g, "");
                add_contact_list_json = add_contact_list_json.replace(/%0D/g, "");
                add_contact_list_json = unescape(add_contact_list_json);

                if(add_contact_list_json != null && add_contact_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(add_contact_list_json != null && add_contact_list_json.indexOf("mapping_exists") >= 0) {
                    $("#add_contact_status_mobile").html("Contact already exists.");
                    $("#add_contact_status_mobile").show();
                } else if(add_contact_list_json != null && add_contact_list_json.indexOf("failed") >= 0) {
                    $("#add_contact_status_mobile").html("Could not add contact. Please try again.");
                    $("#add_contact_status_mobile").show();
                } else if(add_contact_list_json != null) {
                    var contacts_arr_add = JSON.parse(add_contact_list_json);

                    if(contacts_arr_all === undefined) {        //if array does not exist yet
                        contacts_arr_all = [];
                    }

                    contacts_arr_all = contacts_arr_all.concat(contacts_arr_add);

                    var table_html = "";
                    var contacts_found = false;

                    console.log(new Date()+"\t Number of contacts loading initially...: "+contacts_arr_intial.length);

                    var loading_row_html = getLoadingRowHTML();

                    for(var cnt = 0; cnt < contacts_arr_add.length; cnt++, contacts_arr_all_length++) {
                        try {
                            var from_user_id = contacts_arr_add[cnt].from_user_id;
                            var contact_user_id = contacts_arr_add[cnt].contact_user_id;
                            var name = contacts_arr_add[cnt].dec_name;
                            var advanced_relation_type = contacts_arr_add[cnt].advanced_relation_type;
                            var approval_status = contacts_arr_add[cnt].approval_status;
                            var rs_id = contacts_arr_add[cnt].rs_id;
                            var direction = contacts_arr_add[cnt].direction;      //It's always in forward direction for now
                            var mobile = contacts_arr_add[cnt].dec_mobile;
                            var email = contacts_arr_add[cnt].dec_email;

                            var row_html = getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, contacts_arr_all_length);

                            table_html += row_html;

                            contacts_found = true;
                        } catch (error) {
                            continue;
                        }
                    }

                    if(contacts_found == false) {
                        $("#add_contact_status_mobile").html("Could not add contact. Please try again.");
                        $("#add_contact_status_mobile").show();
                    } else {
                        $('#no_contacts_id').hide();
                        $('#add_contact_status_mobile').hide();
                        $('#addcontact_mdl_mobile').modal('hide');
                        $("#contacts_table_ref").last().append(table_html);
                    }
                }
            }
        });
    });

    $("#submitAddContactFB").click(function(e) {
        $("#add_contact_status_fb").hide();

        var contact_name = $('#contact_name_fb').val();
        var contact_number = $('#contact_number_fb').val();
        var contact_mail = $('#contact_mail_fb').val();

        if(contact_name == null || contact_name == "") {
            $("#add_contact_status_fb").html("Name cannot be empty");
            $("#add_contact_status_fb").show();
            $("#contact_name_fb").focus();
            return false;
        }

        if(contact_mail == null || contact_mail == "") {
            $("#add_contact_status_fb").html("Email cannot be empty");
            $("#add_contact_status_fb").show();
            $("#contact_mail_fb").focus();
            return false;
        } else {
            var val_email = validate_email(contact_mail).toString();

            if (val_email == 'false') {
                $("#add_contact_status_fb").text("Please enter valid email");
                $("#add_contact_status_fb").show();
                $("#contact_mail_fb").focus();
                return false;
            }
        }

        if(contact_number == null || contact_number == "") {
//                $("#add_contact_status_fb").html("Mobile cannot be empty");
//                $("#add_contact_status_fb").show();
//                $("#contact_number_fb").focus();
//                return false;

            //DO Nothing, making it optional for now
        } else if (!$.isNumeric(contact_number)) {
            $("#add_contact_status_fb").text("Please enter valid mobile number");
            $("#add_contact_status_fb").show();
            $("#contact_number_fb").focus();
            return false;
        }

        var connection = 0;

        connection = $("#connection_fb").val();

        $.ajax({
            type:         "post",
            url:         "action/add_fb_contact.jsp",
            data:        "contact_name="+contact_name+
                "&contact_number="+contact_number+
                "&contact_mail="+contact_mail+
                "&connection="+connection,

            success:    function(add_contact_list_json) {
                add_contact_list_json = escape(add_contact_list_json).replace(/%0A/g, "");
                add_contact_list_json = add_contact_list_json.replace(/%0D/g, "");
                add_contact_list_json = unescape(add_contact_list_json);

                if(add_contact_list_json != null && add_contact_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(add_contact_list_json != null && add_contact_list_json.indexOf("mapping_exists") >= 0) {
                    $("#add_contact_status_fb").html("Contact already exists.");
                    $("#add_contact_status_fb").show();
                } else if(add_contact_list_json != null && add_contact_list_json.indexOf("failed") >= 0) {
                    $("#add_contact_status_fb").html("Could not add contact. Please try again.");
                    $("#add_contact_status_fb").show();
                } else if(add_contact_list_json != null) {
                    var contacts_arr_add = JSON.parse(add_contact_list_json);

                    if(contacts_arr_all === undefined) {        //if array does not exist yet
                        contacts_arr_all = [];
                    }

                    contacts_arr_all = contacts_arr_all.concat(contacts_arr_add);

                    var table_html = "";
                    var contacts_found = false;

                    console.log(new Date()+"\t Number of contacts loading initially...: "+contacts_arr_intial.length);

                    var loading_row_html = getLoadingRowHTML();

                    for(var cnt = 0; cnt < contacts_arr_add.length; cnt++, contacts_arr_all_length++) {
                        try {
                            var from_user_id = contacts_arr_add[cnt].from_user_id;
                            var contact_user_id = contacts_arr_add[cnt].contact_user_id;
                            var name = contacts_arr_add[cnt].dec_name;
                            var advanced_relation_type = contacts_arr_add[cnt].advanced_relation_type;
                            var approval_status = contacts_arr_add[cnt].approval_status;
                            var rs_id = contacts_arr_add[cnt].rs_id;
                            var direction = contacts_arr_add[cnt].direction;      //It's always in forward direction for now
                            var mobile = contacts_arr_add[cnt].dec_mobile;
                            var email = contacts_arr_add[cnt].dec_email;

                            var row_html = getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, contacts_arr_all_length);

                            table_html += row_html;

                            contacts_found = true;
                        } catch (error) {
                            continue;
                        }
                    }

                    if(contacts_found == false) {
                        $("#add_contact_status_fb").html("Could not add contact. Please try again.");
                        $("#add_contact_status_fb").show();
                    } else {
                        $('#no_contacts_id').hide();
                        $('#add_contact_status_fb').hide();
                        $('#addcontact_mdl_fb').modal('hide');
                        $("#contacts_table_ref").last().append(table_html);
                    }
                }
            }
        });
    });

    window.getMaxRSID = function() {
        $.ajax({
            type:         "post",
            url:          "action/get_max_rsid.jsp",

            success:    function(max_rsid) {
                max_rsid = escape(max_rsid).replace(/%0A/g, "");
                max_rsid = max_rsid.replace(/%0D/g, "");
                max_rsid = unescape(max_rsid);

                console.log(new Date()+"\t getMaxRSID: "+max_rsid);
            }
        });
    };

    var sortOn = function (arr, prop, reverse, numeric) {
        // Ensure there's a property
        if (!prop || !arr) {
            return arr
        }

        // Set up sort function
        var sort_by = function (field, rev, primer) {

            // Return the required a,b function
            return function (a, b) {

                // Reset a, b to the field
                a = primer(a[field]), b = primer(b[field]);

                // Do actual sorting, reverse as needed
                return ((a < b) ? -1 : ((a > b) ? 1 : 0)) * (rev ? -1 : 1);
            }

        }

        // Distinguish between numeric and string to prevent 100's from coming before smaller
        // e.g.
        // 1
        // 20
        // 3
        // 4000
        // 50

        if (numeric) {

            // Do sort "in place" with sort_by function
            arr.sort(sort_by(prop, reverse, function (a) {

                // - Force value to a string.
                // - Replace any non numeric characters.
                // - Parse as float to allow 0.02 values.
                return parseFloat(String(a).replace(/[^0-9.-]+/g, ''));

            }));
        } else {

            // Do sort "in place" with sort_by function
            arr.sort(sort_by(prop, reverse, function (a) {

                // - Force value to string.
                return String(a).toUpperCase();

            }));
        }
    }

    window.getMobileContacts = function() {
        $("#contact_search").val('');
        getMaxRSID();
        getMobileContacts_Initial();
    };

    window.getMobileContacts_Initial = function() {
        console.log(new Date()+"\t getMobileContacts_Initial called");
        var cnt_initial = 0;

        setTimeout(function() {
            $.ajax({
                type:         "post",
                url:          "action/get_contacts_initial_phone.jsp",

                success:    function(contacts_initial_json) {
                    console.log(new Date()+"\t getMobileContacts_Initial got the contacts_initial_json");

                    contacts_initial_json = escape(contacts_initial_json).replace(/%0A/g, "");
                    contacts_initial_json = contacts_initial_json.replace(/%0D/g, "");
                    contacts_initial_json = unescape(contacts_initial_json);

                    console.log(new Date()+"\t getMobileContacts_Initial got the contacts_initial_json after removing special chars");
                    console.log(new Date()+"\t getMobileContacts_Initial size: "+contacts_initial_json.length);

                    if(contacts_initial_json != null && contacts_initial_json.indexOf("session_expired") >= 0) {
                        window.location = "mobileregister_nc.html";
                    }

                    contacts_arr_intial = JSON.parse(contacts_initial_json);

                    console.log(new Date()+"\t getMobileContacts_Initial after JSON parsing");

                    if(contacts_arr_intial == null || contacts_arr_intial.length <= 0) {
                        $("#contacts_table_loading").hide();
                        $("#contacts_table_ref dl#loading_row_id").remove(); //remove the Loading symbol from UI

                        var no_contacts_html_1 = getNoContactsHTML();
                        $("#contacts_table_ref").last().append(no_contacts_html_1);

                        //No contact list found, do nothing
                        return;
                    }

                    console.log(new Date()+"\t contacts_arr_intial before sort");

                    contacts_arr_intial.sort(function(a, b) {
                        var nameA = a.dec_name.toLowerCase(), nameB = b.dec_name.toLowerCase();
                        if (nameA < nameB) //sort string ascending
                            return -1;
                        if (nameA > nameB)
                            return 1;
                        return 0; //default return value (no sorting)
                    });

                    console.log(new Date()+"\t contacts_arr_intial after sort");

                    var table_html = "";
                    var contacts_found = false;

                    $("#contacts_table_loading").hide();

                    console.log(new Date()+"\t Number of contacts loading initially...: "+contacts_arr_intial.length);

                    var loading_row_html = getLoadingRowHTML();

                    for(var cnt = 0; cnt < contacts_arr_intial.length; cnt++, cnt_initial++) {
                        try {
                            var from_user_id = contacts_arr_intial[cnt].from_user_id;
                            var contact_user_id = contacts_arr_intial[cnt].contact_user_id;
                            var name = contacts_arr_intial[cnt].dec_name;
                            var advanced_relation_type = contacts_arr_intial[cnt].advanced_relation_type;
                            var approval_status = contacts_arr_intial[cnt].approval_status;
                            var rs_id = contacts_arr_intial[cnt].rs_id;
                            var direction = contacts_arr_intial[cnt].direction;      //It's always in forward direction for now
                            var mobile = contacts_arr_intial[cnt].dec_mobile;
                            var email = contacts_arr_intial[cnt].dec_email;
                            var img_name_withpath = contacts_arr_intial[cnt].img_name_withpath;
                            var row_html = getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, cnt_initial, img_name_withpath);

                            table_html += row_html;

                            contacts_found = true;
                        } catch (error) {
                            continue;
                        }
                    }

                    if(contacts_found == false) {
                        $("#contacts_table_loading").hide();
                        $("#contacts_table_ref dl#loading_row_id").remove(); //remove the Loading symbol from UI
                        var no_contacts_html = getNoContactsHTML();
                        $("#contacts_table_ref").last().append(no_contacts_html);
                    } else {
                        $("#contacts_table_loading").hide();
                        $("#contacts_table_ref dl#no_contacts_id").remove(); //remove the No contacts message from UI

                        console.log(new Date()+"\t contacts_arr_intial before table_html");

                        $("#contacts_table_ref").last().append(table_html);

                        console.log(new Date()+"\t contacts_arr_intial before loading_row_html");

                        $("#contacts_table_ref").last().append(loading_row_html);

                        console.log(new Date()+"\t contacts_arr_intial after loading_row_html");

                        getMobileContacts_Remaining(cnt_initial);
                    }
//                    $(".segment-select").Segment();
                }
            });
        }, 100);
    };

    window.getMobileContacts_Remaining = function(cnt_initial) {
        console.log(new Date()+"\t getMobileContacts_Remaining called");
        setTimeout(function() {
            $.ajax({
                type:         "post",
                url:          "action/get_contacts_remaining_phone_temp1.jsp",

                success:    function(contacts_remaining_json) {
                    console.log(new Date()+"\t getMobileContacts_Remaining got the contacts_remaining_json");

                    contacts_remaining_json = escape(contacts_remaining_json).replace(/%0A/g, "");
                    contacts_remaining_json = contacts_remaining_json.replace(/%0D/g, "");
                    contacts_remaining_json = unescape(contacts_remaining_json);

                    console.log(new Date()+"\t getMobileContacts_Remaining1 size: "+contacts_remaining_json);

                    console.log(new Date()+"\t getMobileContacts_Remaining got the contacts_remaining_json after removing special chars");
                    contacts_remaining_json = "[{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917829168863\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Anitha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1840\",\"rs_id\":3922},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918548837903\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Anitha2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1841\",\"rs_id\":3923},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917760307307\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Aparna RAVI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1842\",\"rs_id\":3924},{\"advanced_relation_type\":\"3\",\"dec_mobile\":\"+918792217228\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Appu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_3925.jpg\",\"contact_user_id\":\"1843\",\"rs_id\":3925},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919490428781\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Appu NLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1844\",\"rs_id\":3926},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919620767708\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ashok SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1845\",\"rs_id\":3927},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919010939907\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1846\",\"rs_id\":3928},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918861986416\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"BDVL Jyothirmayi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1847\",\"rs_id\":3929},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918197482342\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"BP Raju\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1848\",\"rs_id\":3930},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919590530266\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Baava\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1849\",\"rs_id\":3931},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917093184967\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Babanna\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_3932.jpg\",\"contact_user_id\":\"1850\",\"rs_id\":3932},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"111\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Balance Info\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"31\",\"rs_id\":3933},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919705170772\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"BaskarANNA HYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1851\",\"rs_id\":3934},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"52222\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Best Offers\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"32\",\"rs_id\":3935},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"07204155478\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Bharath Florence\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1853\",\"rs_id\":3936},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919535508739\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Bhargav SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1854\",\"rs_id\":3937},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919885346274\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Bhaskar Siva. Myd\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1855\",\"rs_id\":3938},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986718090\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"BhaskarIT SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1856\",\"rs_id\":3939},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918722212345\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Bin2 BLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1857\",\"rs_id\":3940},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08065996599\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Brinz BIRYANI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1858\",\"rs_id\":3941},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919972226518\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"CAB Venkatesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1859\",\"rs_id\":3942},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742178394\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"CG Gangadhar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1860\",\"rs_id\":3943},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"9741273959\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"CSReddy Duthaluru\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1861\",\"rs_id\":3944},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919959377977\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chaitu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1862\",\"rs_id\":3945},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09972615259\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chalapathi Guraiah RIMS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1863\",\"rs_id\":3946},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919963403261\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chandra CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1864\",\"rs_id\":3947},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919632172874\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chikki\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1865\",\"rs_id\":3948},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919902374518\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chinna BLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1866\",\"rs_id\":3949},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919482574650\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chinna2 BLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1867\",\"rs_id\":3950},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849267966\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chinnamma\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1868\",\"rs_id\":3951},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919652797170\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Chiranjeevi CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1869\",\"rs_id\":3952},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918951092157\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ajay\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"249\",\"rs_id\":3953},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739558521\",\"from_user_id\":\"163\",\"dec_email\":\"amalpn_007@yahoo.com\",\"direction\":\"forward\",\"dec_name\":\"DS Amal\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"754\",\"rs_id\":3954},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918870071180\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ananth2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1870\",\"rs_id\":3955},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919962224356\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ananth3\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1871\",\"rs_id\":3956},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916589817\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Aravind\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1872\",\"rs_id\":3957},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918105104599\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Arun\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1873\",\"rs_id\":3958},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901383039\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS ArunNew\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1874\",\"rs_id\":3959},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919620570143\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ashok\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1875\",\"rs_id\":3960},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919483332211\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS DJ\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1876\",\"rs_id\":3961},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886033433\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Deepak\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1877\",\"rs_id\":3962},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919482739672\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Dhananjay2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1878\",\"rs_id\":3963},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742351977\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Dhanunjay\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1879\",\"rs_id\":3964},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886068531\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Dipankar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1880\",\"rs_id\":3965},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917411201787\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ganesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"71\",\"rs_id\":3966},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739461267\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Harish\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1881\",\"rs_id\":3967},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919731720699\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS HemaSundhar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1882\",\"rs_id\":3968},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918951473874\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Hemanth\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1883\",\"rs_id\":3969},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919019422179\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Javed\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1884\",\"rs_id\":3970},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919844737376\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Karthik\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"97\",\"rs_id\":3971},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742488758\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Kranthi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1885\",\"rs_id\":3972},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09035882988\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Laven\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1886\",\"rs_id\":3973},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986133217\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Lawrence\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1887\",\"rs_id\":3974},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919043942915\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Lawrence2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1888\",\"rs_id\":3975},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918012956633\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Lawrence3\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1889\",\"rs_id\":3976},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740992883\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Mahendran\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1890\",\"rs_id\":3977},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919342537884\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Mukesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"589\",\"rs_id\":3978},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919880425232\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Pawan\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1891\",\"rs_id\":3979},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919731012439\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS PradeepADMI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1892\",\"rs_id\":3980},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986473772\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Prateek\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"931\",\"rs_id\":3981},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986486470\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Praveen\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1893\",\"rs_id\":3982},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916686198\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Puskar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1894\",\"rs_id\":3983},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919844131500\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Pusparaj. CA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"625\",\"rs_id\":3984},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919791154894\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ramanan\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"426\",\"rs_id\":3985},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900600209\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ramesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1895\",\"rs_id\":3986},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919743434121\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Ravi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"943\",\"rs_id\":3987},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917760807856\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sai\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1896\",\"rs_id\":3988},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918105709064\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Saikath\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1897\",\"rs_id\":3989},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918884033456\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS SatishNew. BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1898\",\"rs_id\":3990},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740992885\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Saurabh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1899\",\"rs_id\":3991},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742413762\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Shammi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1900\",\"rs_id\":3992},{\"advanced_relation_type\":\"1\",\"dec_mobile\":\"+919980195414\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Shankar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_3993.jpg\",\"contact_user_id\":\"425\",\"rs_id\":3993},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+14084640317\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Shankar. USM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"424\",\"rs_id\":3994},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+14082127194\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Shankar. USOffic\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1901\",\"rs_id\":3995},{\"advanced_relation_type\":\"1\",\"dec_mobile\":\"+919844408661\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sreedhar\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"176\",\"rs_id\":3996},{\"advanced_relation_type\":\"3\",\"dec_mobile\":\"+918105575151\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Srikanth\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2255\",\"rs_id\":3997},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916248139\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Subhasis\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1902\",\"rs_id\":3998},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919972233251\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sudansu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1903\",\"rs_id\":3999},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919379193931\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sudipta2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1904\",\"rs_id\":4000},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916248135\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sudiptha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1905\",\"rs_id\":4001},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918971320575\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Sumant\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1906\",\"rs_id\":4002},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917411627478\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Swapnil\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1907\",\"rs_id\":4003},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918050803398\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Tanuj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"937\",\"rs_id\":4004},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"18004254250\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS TollFree\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1908\",\"rs_id\":4005},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916683099\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Vanamali\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1909\",\"rs_id\":4006},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918123533049\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS Vinod\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"939\",\"rs_id\":4007},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919826689969\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DS ZohaibNEW\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1910\",\"rs_id\":4008},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919883298038\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DSSubasis HOME\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1911\",\"rs_id\":4009},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740992900\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DSX Karthic\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1912\",\"rs_id\":4010},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986578065\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DSX Pankaj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"516\",\"rs_id\":4011},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"141\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Daily Packs\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2326\",\"rs_id\":4012},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919036283785\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Datha GOUTHAM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1914\",\"rs_id\":4013},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"789\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Deal&Discount\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2327\",\"rs_id\":4014},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919632299044\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Dhanunjay SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1916\",\"rs_id\":4015},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08060013474\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DishTV\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1917\",\"rs_id\":4016},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"18002749000\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"DishTV Tollfree\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1918\",\"rs_id\":4017},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919663600335\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Diwakar LEE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1919\",\"rs_id\":4018},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742042199\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ganesh SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1920\",\"rs_id\":4019},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849789364\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"GangiRDY SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1921\",\"rs_id\":4020},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"8970024365\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Gas Booking - IVRS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1922\",\"rs_id\":4021},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919494229483\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Giri ALG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1923\",\"rs_id\":4022},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845530800\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Giri INETFRAME\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1924\",\"rs_id\":4023},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986120226\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Girish LARA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1925\",\"rs_id\":4024},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919958511899\",\"from_user_id\":\"163\",\"dec_email\":\"basava.goud@gmail.com\",\"direction\":\"forward\",\"dec_name\":\"Gouda ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4025.jpg\",\"contact_user_id\":\"1926\",\"rs_id\":4025},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919945515460\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Goutham SR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1927\",\"rs_id\":4026},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918392260830\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Goutham SR HOME\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1928\",\"rs_id\":4027},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919035222225\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Goutham2 SR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1929\",\"rs_id\":4028},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918939659095\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Govardan BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1930\",\"rs_id\":4029},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742356527\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Govardan JR SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1931\",\"rs_id\":4030},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919502577742\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Guraiah RIMS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1932\",\"rs_id\":4031},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919743152758\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Gurrappa BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1933\",\"rs_id\":4032},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919640614371\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Gurrappa BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1934\",\"rs_id\":4033},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"9945863333\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HDFC Banking\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1935\",\"rs_id\":4034},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08061606161\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HDFC Credit Card\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1936\",\"rs_id\":4035},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919164525829\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HDFC LOAN\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1937\",\"rs_id\":4036},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919590669955\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HDFC Satish\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1938\",\"rs_id\":4037},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919490972194\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HOME2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1939\",\"rs_id\":4038},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919347253040\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1940\",\"rs_id\":4039},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919949441738\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"HYD1\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1941\",\"rs_id\":4040},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919963144886\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Hari RJP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1942\",\"rs_id\":4041},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917829169309\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Hasan BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1943\",\"rs_id\":4042},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08562325623\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Hemakka\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1944\",\"rs_id\":4043},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919341610068\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Hemakka1\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1945\",\"rs_id\":4044},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919902741045\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Hemant BLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1946\",\"rs_id\":4045},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919492410115\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Home\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4046.jpg\",\"contact_user_id\":\"1947\",\"rs_id\":4046},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919743080905\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Aisha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1948\",\"rs_id\":4047},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742263840\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Ajeesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"461\",\"rs_id\":4048},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918754570058\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I AllaBaksh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1015\",\"rs_id\":4049},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919049006663\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Alok\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1949\",\"rs_id\":4050},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919840001971\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Angelina. HR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1046\",\"rs_id\":4051},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919620272687\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Anurupa\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1950\",\"rs_id\":4052},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980573912\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Archana\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"479\",\"rs_id\":4053},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919686698098\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Arjun. HR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1951\",\"rs_id\":4054},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919791004978\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I ArunCHENNAI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1952\",\"rs_id\":4055},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919049996441\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I ArunSHARMA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1953\",\"rs_id\":4056},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919945179243\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Asha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1954\",\"rs_id\":4057},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845809224\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Aswini\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1955\",\"rs_id\":4058},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918197276638\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Bhavana. HR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1956\",\"rs_id\":4059},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986931725\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Binto\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1957\",\"rs_id\":4060},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919958700266\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I GuruCharan2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1958\",\"rs_id\":4061},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919779456060\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Gurucharn\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1959\",\"rs_id\":4062},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917022042094\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Keshav. HR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"8\",\"rs_id\":4063},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980641297\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I KrishnaCCD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1960\",\"rs_id\":4064},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845624663\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I KrisnaMurthi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1961\",\"rs_id\":4065},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986277471\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Kritika\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1051\",\"rs_id\":4066},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742287913\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Lakshmi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1778\",\"rs_id\":4067},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919831085247\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I M. Vikas\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1521\",\"rs_id\":4068},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919686698090\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Mahesh. HR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"568\",\"rs_id\":4069},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741350326\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Moses\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1783\",\"rs_id\":4070},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741930160\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Nishit\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1962\",\"rs_id\":4071},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986479870\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Pramod\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1963\",\"rs_id\":4072},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740090404\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I PramodHR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1964\",\"rs_id\":4073},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919620272085\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Priya\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1965\",\"rs_id\":4074},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919379850649\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Raghavendra\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1966\",\"rs_id\":4075},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739914907\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I RajeshCCD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1967\",\"rs_id\":4076},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740072662\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Ranjan\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1032\",\"rs_id\":4077},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919538993704\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Rengarajan\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1968\",\"rs_id\":4078},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845504813\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Reshma\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1054\",\"rs_id\":4079},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900585202\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Rithesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1969\",\"rs_id\":4080},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919011079416\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Sandip\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1970\",\"rs_id\":4081},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919538895060\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Sanjit\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1794\",\"rs_id\":4082},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919966232051\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Sasank\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1971\",\"rs_id\":4083},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919337006612\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Satya\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1972\",\"rs_id\":4084},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919985813063\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I SmithaHYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1057\",\"rs_id\":4085},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739652504\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Sneha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1973\",\"rs_id\":4086},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916277870\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Sneha2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"173\",\"rs_id\":4087},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919160017017\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I SudheerCC\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1974\",\"rs_id\":4088},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919448419970\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Suribabu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1975\",\"rs_id\":4089},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919960472645\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Vanitha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1976\",\"rs_id\":4090},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980557363\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I VenkatCCD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1977\",\"rs_id\":4091},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886693457\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"I Yuvaraj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1045\",\"rs_id\":4092},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08030309900\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"ING Toll\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1978\",\"rs_id\":4093},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"18004259900\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"ING TollFree\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1979\",\"rs_id\":4094},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845436898\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Indane\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1980\",\"rs_id\":4095},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919036809459\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Jagan NLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1981\",\"rs_id\":4096},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919874808808\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Jana KOLKATTA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1982\",\"rs_id\":4097},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918971963473\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"JanaMAM CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1983\",\"rs_id\":4098},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918897092859\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"JanardanBR CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1984\",\"rs_id\":4099},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919036026278\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"JanardanNew\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1985\",\"rs_id\":4100},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741095950\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Janardhan CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1986\",\"rs_id\":4101},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845169203\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Jaya ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1987\",\"rs_id\":4102},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986134118\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kataria\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1988\",\"rs_id\":4103},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918042066935\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kiran HOME\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1989\",\"rs_id\":4104},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918800446299\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kiran3 SR. Delhi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1990\",\"rs_id\":4105},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918095881122\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Konda BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1991\",\"rs_id\":4106},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980065577\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Konda2 Bang\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1992\",\"rs_id\":4107},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919343119494\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kondaddy Bang New\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1993\",\"rs_id\":4108},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918095119494\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kondaddy CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1994\",\"rs_id\":4109},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"07849019494\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kondaddy2 CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1995\",\"rs_id\":4110},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919611613301\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Koti ANNA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1996\",\"rs_id\":4111},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916580879\",\"from_user_id\":\"163\",\"dec_email\":\"hikoti143@gmail.com\",\"direction\":\"forward\",\"dec_name\":\"Koti. SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4112.jpg\",\"contact_user_id\":\"1997\",\"rs_id\":4112},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09845625199\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"KotiRdy JP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1998\",\"rs_id\":4113},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919010702143\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"KotiReddy Jail\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1999\",\"rs_id\":4114},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919949259709\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kullayappa SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2000\",\"rs_id\":4115},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886332006\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Kumar LEE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2001\",\"rs_id\":4116},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919494079522\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"LXMI Babai\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2002\",\"rs_id\":4117},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919885387794\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"LXMI Pavani (Subbareddy)\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2003\",\"rs_id\":4118},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919632921538\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"LXMI Sireesha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2004\",\"rs_id\":4119},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919666573700\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lakshmi BAVA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2006\",\"rs_id\":4120},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919177573746\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lakshmi Sis\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2368\",\"rs_id\":4121},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917411099811\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Laptop Anand\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2007\",\"rs_id\":4122},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919632360625\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lavan LARA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2008\",\"rs_id\":4123},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901580170\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"LaxmiRDY MRO\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2009\",\"rs_id\":4124},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09686488877\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"LeenaRent1\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2010\",\"rs_id\":4125},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919885426000\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Loknath SRIDAR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2011\",\"rs_id\":4126},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918374638467\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi AP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2012\",\"rs_id\":4127},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918904283450\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4128.jpg\",\"contact_user_id\":\"2013\",\"rs_id\":4128},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919963393862\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Home\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4129.jpg\",\"contact_user_id\":\"2014\",\"rs_id\":4129},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919989309155\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Mama\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4130.jpg\",\"contact_user_id\":\"2015\",\"rs_id\":4130},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918008349338\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Parvathi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4131.jpg\",\"contact_user_id\":\"2016\",\"rs_id\":4131},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918951471201\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Parvathi Bang\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2017\",\"rs_id\":4132},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849369340\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Pedananna\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2018\",\"rs_id\":4133},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919566108811\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi Tammudu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4134.jpg\",\"contact_user_id\":\"2452\",\"rs_id\":4134},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09866056463\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi(atha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2020\",\"rs_id\":4135},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08056078343\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Lxmi(prasanna)\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2021\",\"rs_id\":4136},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919962011194\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"M Sudhaa\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2022\",\"rs_id\":4137},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918951418918\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"MKrishna SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2023\",\"rs_id\":4138},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919492517480\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Maadha1\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2024\",\"rs_id\":4139},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918977239824\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Maadha2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2025\",\"rs_id\":4140},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919652368430\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Maadha3\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2026\",\"rs_id\":4141},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917382311742\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Maadha4\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2027\",\"rs_id\":4142},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919035840490\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Macharla ACTIVE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2028\",\"rs_id\":4143},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919008488656\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Madhavi PANDU\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2029\",\"rs_id\":4144},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919590159078\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Madhu GOUTHAM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2030\",\"rs_id\":4145},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919343175800\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Madhu GOUTHAM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2031\",\"rs_id\":4146},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986738178\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Madhu SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2032\",\"rs_id\":4147},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919985267024\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Mahesh ATP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2033\",\"rs_id\":4148},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845692420\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Mahesh SR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2034\",\"rs_id\":4149},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986373747\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"MalliJ SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2035\",\"rs_id\":4150},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986286040\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Manyam BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2036\",\"rs_id\":4151},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917829162990\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Meerakka GOUTHAM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2037\",\"rs_id\":4152},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919440650155\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Mohan Raaman\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2038\",\"rs_id\":4153},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919533211242\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Mouni MBBS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2039\",\"rs_id\":4154},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+911234567890\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"NR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1715\",\"rs_id\":4155},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+11234567890\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"NR2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2358\",\"rs_id\":4156},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919391477733\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"NagaBagvan SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2040\",\"rs_id\":4157},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919449687957\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Nagarjuna SR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2041\",\"rs_id\":4158},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845069944\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Narayana Swamy\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2042\",\"rs_id\":4159},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918686047373\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Naresh PV\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2043\",\"rs_id\":4160},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900701585\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Narsihma ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2044\",\"rs_id\":4161},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916943006\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Narsimha GRP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2045\",\"rs_id\":4162},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"9449234810\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Neighbour\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2046\",\"rs_id\":4163},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09493034764\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Niranjan CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2047\",\"rs_id\":4164},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918019838917\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Nirmalakka\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2048\",\"rs_id\":4165},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918025720242\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Office HSR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2049\",\"rs_id\":4166},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919538582570\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Padma RAAMAN\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2050\",\"rs_id\":4167},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919701923597\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"PalaMabu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2051\",\"rs_id\":4168},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919000013977\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Palle Govindham\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2052\",\"rs_id\":4169},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917893005536\",\"from_user_id\":\"163\",\"dec_email\":\"reddyranjit1@gmail.com\",\"direction\":\"forward\",\"dec_name\":\"Pandu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4170.jpg\",\"contact_user_id\":\"2053\",\"rs_id\":4170},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919010522280\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pandu Radhika\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2054\",\"rs_id\":4171},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919959518007\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pandu Swetha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2055\",\"rs_id\":4172},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919885037373\",\"from_user_id\":\"163\",\"dec_email\":\"nareshreddyvenkat@gmail.com\",\"direction\":\"forward\",\"dec_name\":\"Panga\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4173.jpg\",\"contact_user_id\":\"2056\",\"rs_id\":4173},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919652054834\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pawan ANNA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2057\",\"rs_id\":4174},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919880175383\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pawan BLR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2058\",\"rs_id\":4175},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919704816100\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pawan CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2059\",\"rs_id\":4176},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901077344\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pawan2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2060\",\"rs_id\":4177},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886561119\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pawana RANGA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2061\",\"rs_id\":4178},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919603739351\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peddamma\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2062\",\"rs_id\":4179},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919010402557\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peddhamma BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2063\",\"rs_id\":4180},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919603850401\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peddhamma2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2064\",\"rs_id\":4181},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918341321468\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pedha Vinay\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2359\",\"rs_id\":4182},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900479790\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pedhama BELARY\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2066\",\"rs_id\":4183},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986246972\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peera Anjum\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2067\",\"rs_id\":4184},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742331119\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peera BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2068\",\"rs_id\":4185},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919972931615\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peera2 Bang\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2069\",\"rs_id\":4186},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919985645430\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Peesu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2070\",\"rs_id\":4187},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986254052\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Phani ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2071\",\"rs_id\":4188},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916199926\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Phani SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2072\",\"rs_id\":4189},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919962551480\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Polris Shobana\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2073\",\"rs_id\":4190},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919676898025\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Potta\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2074\",\"rs_id\":4191},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919032860850\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"PrabakrMAM HYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2075\",\"rs_id\":4192},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919866807311\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pradeep BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2076\",\"rs_id\":4193},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919700840041\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Praneel SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2077\",\"rs_id\":4194},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09505001588\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Praneel SKD NEW\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2078\",\"rs_id\":4195},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918904542663\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Prathima\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2079\",\"rs_id\":4196},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919848966261\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pratima SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2080\",\"rs_id\":4197},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919945000221\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pratima Sriram\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2081\",\"rs_id\":4198},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919160226622\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Praveen GATES\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2082\",\"rs_id\":4199},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918884002999\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Praveen RAJ\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2083\",\"rs_id\":4200},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900138007\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pulki2 ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2084\",\"rs_id\":4201},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919966618568\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Purshotam RAVI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2085\",\"rs_id\":4202},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845050138\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Pursu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2086\",\"rs_id\":4203},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"9739282625\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raaman\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2087\",\"rs_id\":4204},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742617645\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raaman Ashok\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2088\",\"rs_id\":4205},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918861166377\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raaman New\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4206.jpg\",\"contact_user_id\":\"2089\",\"rs_id\":4206},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916710514\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raaman Raji\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2090\",\"rs_id\":4207},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919573049964\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raghu CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2091\",\"rs_id\":4208},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919948966325\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raghu SKDECE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2092\",\"rs_id\":4209},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740089012\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Raj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2093\",\"rs_id\":4210},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919902563262\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Rajanna RAMANA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2094\",\"rs_id\":4211},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919491428482\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"RajeshHYD ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2095\",\"rs_id\":4212},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849531193\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"RajeshIT SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2096\",\"rs_id\":4213},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919492843926\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"RakeshBABU SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2097\",\"rs_id\":4214},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918008508673\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"RamaKrishna CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2098\",\"rs_id\":4215},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918790733432\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ramakka\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2099\",\"rs_id\":4216},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917893712585\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ramana ANNA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2100\",\"rs_id\":4217},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919703440893\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ramana CHINNAN\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2101\",\"rs_id\":4218},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900888110\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ranga ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2102\",\"rs_id\":4219},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"03340071717\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Rangoli Sarees\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2103\",\"rs_id\":4220},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886454267\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Rasekar SEIMEN\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2104\",\"rs_id\":4221},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09945937937\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Rasmi School\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2105\",\"rs_id\":4222},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919642208631\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravanamma Atha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2106\",\"rs_id\":4223},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740555331\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4224.jpg\",\"contact_user_id\":\"2107\",\"rs_id\":4224},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919902670279\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi GAS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2108\",\"rs_id\":4225},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919620289679\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi Jyothi\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2109\",\"rs_id\":4226},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09440216998\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi MAMA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2110\",\"rs_id\":4227},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886782764\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi RAJASEMEN\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2111\",\"rs_id\":4228},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918801205448\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravi RAMU\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2112\",\"rs_id\":4229},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845417914\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"RaviANNA GOUTM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2113\",\"rs_id\":4230},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919704017471\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Ravindra SCHOOL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2114\",\"rs_id\":4231},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09939174605\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Resume Aakash\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"251\",\"rs_id\":4232},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741008845\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Riyaz SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2115\",\"rs_id\":4233},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09030937471\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Rukesh BELLARY\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2116\",\"rs_id\":4234},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980932513\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"SKD Raghu. ECE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2117\",\"rs_id\":4235},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919008746072\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sagar CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2118\",\"rs_id\":4236},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901424531\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Satyam\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4237.jpg\",\"contact_user_id\":\"163\",\"rs_id\":4237},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919949563168\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Satyam CDP\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2119\",\"rs_id\":4238},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09980206161\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"School\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2120\",\"rs_id\":4239},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919966964402\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Seena SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2121\",\"rs_id\":4240},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739216086\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Seenu KOTI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2122\",\"rs_id\":4241},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849265782\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Seenu MAMA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2123\",\"rs_id\":4242},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"191\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Self Service\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2336\",\"rs_id\":4243},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08522232022\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sesh KUGRAM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2125\",\"rs_id\":4244},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919008100334\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Seshu The Boss\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4245.jpg\",\"contact_user_id\":\"2126\",\"rs_id\":4245},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919880515171\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Setty SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2127\",\"rs_id\":4246},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918754595914\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Shaiksha SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2128\",\"rs_id\":4247},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919902959493\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sharana ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2129\",\"rs_id\":4248},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916122122\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sharath1\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2130\",\"rs_id\":4249},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919515728517\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sharif Mabu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2131\",\"rs_id\":4250},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986550650\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Shivan HOME\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2132\",\"rs_id\":4251},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986521721\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Shivan ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2133\",\"rs_id\":4252},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918880408392\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Shivan2 ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2134\",\"rs_id\":4253},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886778758\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Shoban LARA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2135\",\"rs_id\":4254},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919612163695\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siri SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2136\",\"rs_id\":4255},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918884029949\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siva BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2137\",\"rs_id\":4256},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917411604590\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siva BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2369\",\"rs_id\":4257},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919700639363\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siva BROTHER\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2138\",\"rs_id\":4258},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919700654778\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siva HYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2139\",\"rs_id\":4259},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919959999608\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Siva Kerala\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2140\",\"rs_id\":4260},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917847077939\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"SivaV ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2141\",\"rs_id\":4261},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09212692126\",\"from_user_id\":\"163\",\"dec_email\":\"help@snapdeal.com\",\"direction\":\"forward\",\"dec_name\":\"Snapdeal Support\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2142\",\"rs_id\":4262},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919701476769\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Somu CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2143\",\"rs_id\":4263},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886668681\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sreenivas KOTI\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2144\",\"rs_id\":4264},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919703226692\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sreenu ARAVINDA\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2145\",\"rs_id\":4265},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919985985685\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sreenu BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2146\",\"rs_id\":4266},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740677577\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sreenu BDVLVR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2147\",\"rs_id\":4267},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919686936941\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sreenu Degree\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2148\",\"rs_id\":4268},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919940690020\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Srikanth GRV\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2149\",\"rs_id\":4269},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"08022065000\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"St. Johns\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2150\",\"rs_id\":4270},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09491944180\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Subba Reddy\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2151\",\"rs_id\":4271},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917893632494\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"SubbaRao SCHOOL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2152\",\"rs_id\":4272},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919848342455\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"SubbaReddy SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2153\",\"rs_id\":4273},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919652233352\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sunil SR\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2154\",\"rs_id\":4274},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919966859599\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Sunku\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2155\",\"rs_id\":4275},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919008485851\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Suresh SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2156\",\"rs_id\":4276},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"9100406169\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Suvarnamuki(bus\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2157\",\"rs_id\":4277},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919916738122\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Suvrnamuk BANG\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2158\",\"rs_id\":4278},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919611391391\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Swathi Seshu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2159\",\"rs_id\":4279},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986282188\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"TRS SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2160\",\"rs_id\":4280},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918951205953\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Tatha(docomo\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2161\",\"rs_id\":4281},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917799830083\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Tirupathi BLOOD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2162\",\"rs_id\":4282},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919010203626\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Traffic Police\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2163\",\"rs_id\":4283},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919980163945\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Uday\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2164\",\"rs_id\":4284},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09449112860\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"VA Mallasandra\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2165\",\"rs_id\":4285},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919872455047\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"VAMS\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2166\",\"rs_id\":4286},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09908684831\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"VV Narayana Reddy Mama\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2167\",\"rs_id\":4287},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919490229468\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Varakka\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2168\",\"rs_id\":4288},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919666503269\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Varakka2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2169\",\"rs_id\":4289},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919008457723\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"VeeraPrasad CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2170\",\"rs_id\":4290},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739831826\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Veeraddy3 RM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2171\",\"rs_id\":4291},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919494222923\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Veeru SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2172\",\"rs_id\":4292},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919066898730\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Venkat reddy\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2173\",\"rs_id\":4293},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917676713827\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Venkateswara Reddy. Duthaluru\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2174\",\"rs_id\":4294},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919159623343\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Venky SKD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2175\",\"rs_id\":4295},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"8762132666\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Venu House\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2176\",\"rs_id\":4296},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900449905\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Venu LEE\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2177\",\"rs_id\":4297},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919000838384\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vidya ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2178\",\"rs_id\":4298},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919848111157\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vijay HYD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2179\",\"rs_id\":4299},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919739447142\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vikram2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2180\",\"rs_id\":4300},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917416410880\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vinay Bang\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/163/rs_4301.jpg\",\"contact_user_id\":\"2181\",\"rs_id\":4301},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919686601987\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vinay Bhargav\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2402\",\"rs_id\":4302},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919481380938\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vinay Harish\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2403\",\"rs_id\":4303},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919740838877\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vinod CPD\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2182\",\"rs_id\":4304},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741422882\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Visnu ROOM\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2183\",\"rs_id\":4305},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919985355884\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Viswanath BDVL\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2370\",\"rs_id\":4306},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886317184\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Vivek IIITB\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2186\",\"rs_id\":4307},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09986688033\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Avinash\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2187\",\"rs_id\":4308},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900115164\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Manoj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2188\",\"rs_id\":4309},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919742287974\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W NarayanRao\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2189\",\"rs_id\":4310},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901935900\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Naveen\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1194\",\"rs_id\":4311},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919975864028\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Ninad\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2190\",\"rs_id\":4312},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900108181\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Pranam\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2191\",\"rs_id\":4313},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919901455871\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Rajesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1317\",\"rs_id\":4314},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845648222\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Ranganath\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"1335\",\"rs_id\":4315},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919986033125\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Shafreen\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2192\",\"rs_id\":4316},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845966793\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Srini\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2193\",\"rs_id\":4317},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917411042227\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Tanuj\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2194\",\"rs_id\":4318},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919880825828\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Usha\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2195\",\"rs_id\":4319},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919886355226\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Velu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2196\",\"rs_id\":4320},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900849742\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W Venkatesh\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2197\",\"rs_id\":4321},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+917259810728\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"W manpreet\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2198\",\"rs_id\":4322},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919900932224\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Water\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2199\",\"rs_id\":4323},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919844943404\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Wirlpool Service. S\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2200\",\"rs_id\":4324},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+18001036286\",\"from_user_id\":\"163\",\"dec_email\":\"service.in@xiaomi.com\",\"direction\":\"forward\",\"dec_name\":\"Xiomi Service Center\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2201\",\"rs_id\":4325},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919844535772\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Y Anand\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2202\",\"rs_id\":4326},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+918884703458\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Y B. Mahendran\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2203\",\"rs_id\":4327},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919741054044\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Y Babanna\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2204\",\"rs_id\":4328},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919845168430\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Y Muthu\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2205\",\"rs_id\":4329},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919959254789\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"YellaRdy\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2206\",\"rs_id\":4330},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"+919849778088\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"Yelladdy2\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2207\",\"rs_id\":4331},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"8527355100\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"emergency alert\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2208\",\"rs_id\":4332},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"101\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"fire\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2209\",\"rs_id\":4333},{\"advanced_relation_type\":\"0\",\"dec_mobile\":\"09989467716\",\"from_user_id\":\"163\",\"dec_email\":\"\",\"direction\":\"forward\",\"dec_name\":\"v Siddaiah\",\"approval_status\":1,\"img_name_withpath\":\"user_contact_images/profile.jpg\",\"contact_user_id\":\"2210\",\"rs_id\":4334}]";

                    console.log(new Date()+"\t getMobileContacts_Remaining2 size: "+contacts_remaining_json.length);

                    contacts_arr_remaining = JSON.parse(contacts_remaining_json);

                    console.log(new Date()+"\t getMobileContacts_Remaining after JSON parsing");

                    if(contacts_arr_remaining == null || contacts_arr_remaining.length <= 0) {
                        $("#contacts_table_loading").hide();
                        $("#contacts_table_ref dl#no_contacts_id").remove(); //remove the No contacts message from UI
                        $("#contacts_table_ref dl#loading_row_id").remove(); //remove the Loading symbol from UI

                        //No contact list found, do nothing
                        return;
                    }

                    console.log(new Date()+"\t contacts_arr_remaining before sort");

                    contacts_arr_remaining.sort(function(a, b) {
                        var nameA = a.dec_name.toLowerCase(), nameB = b.dec_name.toLowerCase();
                        if (nameA < nameB) //sort string ascending
                            return -1;
                        if (nameA > nameB)
                            return 1;
                        return 0; //default return value (no sorting)
                    });

                    console.log(new Date()+"\t contacts_arr_remaining after sort");

                    contacts_arr_all = contacts_arr_intial.concat(contacts_arr_remaining);

                    console.log(new Date()+"\t contacts_arr_remaining after concat");

                    /*
                     contacts_arr_all.sort(function(a, b){
                     var nameA = a.dec_name.toLowerCase(), nameB = b.dec_name.toLowerCase();
                     if (nameA < nameB) //sort string ascending
                     return -1;
                     if (nameA > nameB)
                     return 1;
                     return 0; //default return value (no sorting)
                     });
                     */

                    var table_html = "";
                    var contacts_found = false;

                    console.log(new Date()+"\t Number of contacts loading remaining...: "+contacts_arr_remaining.length);

                    $("#contacts_table_loading").hide();
                    $("#contacts_table_ref dl#no_contacts_id").remove(); //remove the No contacts message from UI
                    $("#contacts_table_ref dl#loading_row_id").remove(); //remove the Loading symbol from UI

                    console.log(new Date()+"\t contacts_arr_remaining before table_html");

                    for(var cnt = 0; cnt < contacts_arr_remaining.length; cnt++, cnt_initial++) {
                        try {
                            var from_user_id = contacts_arr_remaining[cnt].from_user_id;
                            var contact_user_id = contacts_arr_remaining[cnt].contact_user_id;
                            var name = contacts_arr_remaining[cnt].dec_name;
                            var advanced_relation_type = contacts_arr_remaining[cnt].advanced_relation_type;
                            var approval_status = contacts_arr_remaining[cnt].approval_status;
                            var rs_id = contacts_arr_remaining[cnt].rs_id;
                            var direction = contacts_arr_remaining[cnt].direction;      //It's always in forward direction for now
                            var mobile = contacts_arr_remaining[cnt].dec_mobile;
                            var email = contacts_arr_remaining[cnt].dec_email;
                            var img_name_withpath = contacts_arr_remaining[cnt].img_name_withpath;

                            var row_html = getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, cnt_initial, img_name_withpath);
                            $("#contacts_table_ref").last().append(row_html);

//                            table_html += row_html;

                            contacts_found = true;
                        } catch (error) {
                            console.log(error);
                            continue;
                        }
                    }

                    console.log(new Date()+"\t contacts_arr_remaining after table_html");

                    contacts_arr_all_length = cnt_initial;
                    getinviteStaus();
                }
            });
        }, 100);
    };

    function getLoadingRowHTML() {
        var loading_row_html = "" +
            "<dl id='loading_row_id' style='padding:0px'>" +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top:2%; background-color: #e1e2cf;'>" +
            "           <div class='events-body'>" +
            "               <br><i class='fa fa-circle-o-notch fa-2x fa-pulse' style='color: white'></i>" +
            "           </div><br>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";

        return loading_row_html;
    }

    function getNoContactsHTML() {
        var no_contacts_html = "<dl id='no_contacts_id' style='padding:2px'>  " +
            "   <dd class='pos-left clearfix'>" +
            "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
            "           <div class='events-body'>" +
            "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
            "                   <center>No contacts found." +
//            "                       <br>Start adding contacts." +
            "                   </center>" +
            "               </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";

        return no_contacts_html;
    }

    var dl_id;
    function getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, contact_index, img_name_withpath) {
//        console.log(name+" : "+advanced_relation_type+" : "+direction);

        if(direction == "forward") {
            class_option_1 = (advanced_relation_type == "1" ? " active" : " ");
            class_option_2 = (advanced_relation_type == "2" ? (approval_status == 1 ? " active" : " pending") : " ");
            class_option_3 = (advanced_relation_type == "3" ? (approval_status == 1 ? " active" : " pending") : " ");

            onclick_1 = "updateContactRelationship('"+rs_id+"','1','"+(advanced_relation_type == "1" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')";
            onclick_2 = "updateContactRelationship('"+rs_id+"','2','"+(advanced_relation_type == "2" ? (approval_status == 1 ? "active" : "pending") : "not_active")+"', '"+direction+"', '"+contact_index+"')";
            onclick_3 = "updateContactRelationship('"+rs_id+"','3','"+(advanced_relation_type == "3" ? (approval_status == 1 ? "active" : "pending") : "not_active")+"', '"+direction+"', '"+contact_index+"')";
        } else {
/*
            class_option_1 = (advanced_relation_type == "1" ? " active" : " ");
            class_option_2 = (advanced_relation_type == "3" ? (approval_status == 1 ? " active" : " pending") : " ");
            class_option_3 = (advanced_relation_type == "2" ? (approval_status == 1 ? " active" : " pending") : " ");
*/
            class_option_1 = (advanced_relation_type == "1" ? " active" : " ");
            class_option_2 = (advanced_relation_type == "3" ? (approval_status == 1 ? " active" : " pending") : " ");
            class_option_3 = (advanced_relation_type == "2" ? (approval_status == 1 ? " active" : " pending") : " ");

            onclick_1 = "updateContactRelationship('"+rs_id+"','1','"+(advanced_relation_type == "1" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')";
            onclick_2 = "updateContactRelationship('"+rs_id+"','3','"+(advanced_relation_type == "3" ? (approval_status == 1 ? "active" : "pending") : "not_active")+"', '"+direction+"', '"+contact_index+"')";
            onclick_3 = "updateContactRelationship('"+rs_id+"','2','"+(advanced_relation_type == "2" ? (approval_status == 1 ? "active" : "pending") : "not_active")+"', '"+direction+"', '"+contact_index+"')";
        }

//        console.log("1: "+class_option_1+" : "+", 2: "+class_option_2+" : "+", 3: "+class_option_3);

        if(device_type == "android") {
            $("#invite_"+rs_id).attr("style","font-size: 20px;color: #34AF23;vertical-align: middle;margin-left: 5px; margin-right: 5px;");
        }

        var row_html = "";
        if(dl_id !== name.substring(0,1).toUpperCase()) {
            dl_id = name.substring(0,1).toUpperCase();
            $('#'+dl_id).remove();
            row_html += "<div style='display:hidden' id='"+dl_id+"'></div>"
        }

        row_html += "" +
            "<dl class = 'contact_list' name = '"+name+"' id='"+contact_user_id+"' style='padding:0px'>  " +
            "   <dd class='pos-left clearfix'>" +
            "        <div class='events' style='margin-top:1px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888;display:inline-block; width: 98%; padding: 5px 5px 5px 10px; margin-left: 3px;'>" +
            "           <p class='pull-left img-circle' style='margin-left:-3px;margin-bottom: 0px;margin-top: 10px'>" +
//            "               <img onclick='' class='img-circle' style='max-width:40px' src='user_contact_images/"+from_user_id+"/rs_"+rs_id+".jpg' onError='this.onerror=null;this.src=\"images/profile.jpg\";' class='events-object img-rounded'>" +
            "               <img onclick='' class='img-circle' style='max-width:40px' src="+img_name_withpath+" class='events-object img-rounded'>" +
            "           </p>" +
            "           <div class='events-body' style='margin-right:0px;margin-top:0px;padding:0px'>" +
            "               <div align='left' class='pull-left' style='width:75%; margin-top: 5px; margin-bottom:0px; margin-left: 8px;'>"+
            "                   <h2 id='"+contact_user_id+"_contactname' style='margin-top:5px;margin-bottom:3px;font-size:15px;display:inline'>"+name+"</h2>" +
            /*  Commented for now
             "                   <button  data-toggle='modal' type='button' class='btn btn-default btn-simple btn-xs text-center' style='padding: 1px 5px;background-color:#e1e2cf;' onclick=\"showContactDetails('"+name+"','"+mobile+"','"+email+"');\" >" +
             "                       <i class='fa fa-eye' style='color:#22A7F0'></i>" +
             "                   </button>" +
             */
            "               </div>" +
            "             <div class='pull-right'  style='width:20%;'>  " +

             "                   <button  id='invite_"+rs_id+"' onclick=\"sendAPPInvite('"+rs_id+"', '"+contact_user_id+"');\" type='button' class='btn btn-info btn-sm pull-right' style='display:inline;border-radius:5px; padding: .35rem .5rem'  >" +
             "                   Invite</button> " +

/*
            "                   <i id='invite_"+rs_id+"' class='fa fa-whatsapp' style='font-size: 20px;color: #34AF23;vertical-align: middle;margin-left: 5px; margin-right: 5px; display: none;' onclick='webapp.openWhatsAppIntentToSharebyContact(\""+mobile+"\");'></i></button> " +
*/
            "                  <button  id='invitesuccess_"+rs_id+"' onclick=\"sendAPPInvite('"+rs_id+"', '"+contact_user_id+"');\" type='button' class='btn btn-success btn-sm pull-right' style='display:inline;border-radius:5px; padding: .35rem .5rem;display:none'  >" +
            "                   Invite</button> </div>" +
            "               </div>" +

            "               <div class='btn-group pull-left' data-toggle='buttons' style='margin-left: 8px; margin-top: 3px;'>" +
            "                   <label id = 'connection_"+rs_id+"_1' class='btn btn-custom "+class_option_1+"' style='padding: .2rem 0.4rem; margin-bottom: 0rem;' onclick=\""+onclick_1+"\" >" +
            "                       <input type='radio' autocomplete='off'>Friend" +
            "                   </label>" +
            "                   <label id = 'connection_"+rs_id+"_2' class='btn btn-custom "+class_option_2+"' style='padding: .2rem 0.4rem; margin-bottom: 0rem;' onclick=\""+onclick_2+"\" >" +
            "                       <input type='radio' autocomplete='off'>Client" +
            "                   </label>" +
            "                   <label id = 'connection_"+rs_id+"_3' class='btn btn-custom "+class_option_3+"' style='padding: .2rem 0.4rem; margin-bottom: 0rem;' onclick=\""+onclick_3+"\" >" +
            "                       <input type='radio' autocomplete='off'>Professional" +
            "                   </label>" +
            "               </div>" +

/*
            "               <div class='events-body text-center pull-left' style='margin-top: 0px; margin-left: 6px;'>" +
            "                   <div class='ui-segment1'>" +
            "                       <span a id = 'connection_"+rs_id+"_1' class='option"+class_option_1+"' onclick=\""+onclick_1+"\" style='padding-top: 0.5rem;'>Friend</span>" +
            "                       <span a id = 'connection_"+rs_id+"_2' class='option"+class_option_2+"' onclick=\""+onclick_2+"\" style='padding-top: 0.5rem;'>Client</span>" +
            "                       <span a id = 'connection_"+rs_id+"_3' class='option"+class_option_3+"' onclick=\""+onclick_3+"\" style='padding-top: 0.5rem;'>Professional</span>" +
            "                   </div>" +
            "               </div>" +
*/

            "               <div class='events-body text-center pull-left' style='margin-top: 0px; margin-left: 35px;padding:0px; clear:both;'>" +
            "               <div class='pull-left' style='padding-left: 6px'>" +
            "                   <button  data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"shareContactForm('"+contact_user_id+"');\" >" +
            "                       <i class='fa fa-share' style='color:#22A7F0'></i>" +
            "                   </button>" +
            "                   <button data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"editContactForm('"+rs_id+"', '"+contact_user_id+"','"+contact_index+"');\" >" +
            "                       <i class='fa fa-edit' style='color:#F6BB42'></i>" +
            "                   </button>" +
            "                   <button  data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"getContactDetailsToDelete('"+rs_id+"','"+contact_user_id+"','"+contact_index+"');\" >" +
            "                       <i class='fa fa-times' style='color: #ff6666'></i>" +
            "                   </button>" +
            "               </div>" +
            "           </div>" +
            "           </div>" +
            "       </div>" +
            "   </dd>" +
            "</dl>";
        return row_html;
    }

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

    //Delay function to call up on every keyup. jQuery 1.7.1 or up required
    //REF: http://jsfiddle.net/Us9bu/2/
    $('#contact_search').delayKeyup(function(el) {
        window.stop();                                              //stop loading the remaining page before starting the new search. Is this correct way???
        $("#alphabet_status_id").css("display", "none"); // if you type any char in search text box alphabet scroll will be hide
        contact_search_fn();
    }, 500);                                                        //delay in milli seconds

    window.contact_search_fn = function() {
        var typed_string = $("#contact_search").val();
        if(typed_string == "") {
            $("#alphabet_status_id").css("display", ""); // if in search no char is there display the alphabet scroll
        }

        var table_html = "";
        var contacts_found = false;

        if(contacts_arr_all === undefined) {
            //No contacts found, do nothing...
            console.log("No contacts found for: "+typed_string);
        } else {
            for(var cnt_all = 0; cnt_all < contacts_arr_all.length; cnt_all++) {
                try {
                    var from_user_id = contacts_arr_all[cnt_all].from_user_id;
                    var contact_user_id = contacts_arr_all[cnt_all].contact_user_id;
                    var name = contacts_arr_all[cnt_all].dec_name;
                    var advanced_relation_type = contacts_arr_all[cnt_all].advanced_relation_type;
                    var approval_status = contacts_arr_all[cnt_all].approval_status;
                    var rs_id = contacts_arr_all[cnt_all].rs_id;
                    var direction = contacts_arr_all[cnt_all].direction;
                    var mobile = contacts_arr_all[cnt_all].dec_mobile;
                    var email = contacts_arr_all[cnt_all].dec_email;
                    var img_name_withpath = contacts_arr_all[cnt_all].img_name_withpath;

                    if(name.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0) {
//                    console.log("name: "+name+", typed_string: "+typed_string);

                        var row_html = getRowHTML(from_user_id, contact_user_id, name, mobile, email, advanced_relation_type, approval_status, rs_id, direction, cnt_all, img_name_withpath);

                        table_html += row_html+"";
                        contacts_found = true;
                    }
                } catch (error) {
                    console.log(error);
                    continue;
                }
            }
        }

        if(contacts_found == true) {
            $("#contacts_table_loading").hide();
            $("#contacts_table_ref dl").remove();
            $("#contacts_table_ref").last().append(table_html);
        } else {
            var status = getNoContactsHTML();
            $("#contacts_table_loading").hide();
            $("#contacts_table_ref dl").remove();
            $("#contacts_table_ref").last().append(status);
        }
        getinviteStaus(); // method calling for show invite button is selected or not
    }

    window.updateContactRelationship = function(rs_id, connection, status, direction, contact_index) {
//            alert("rs_id: "+rs_id+", connection: "+connection+", status: "+status);

        if(status == "active") {                    //Connection was already selected, no need to update it again
            //DO Nothing, return
        } else if(status == "pending") {
            //DO Nothing, return
        }  else if(status == "waiting") {
//                alert("Approval pending...");
        } else {
            if(direction == "forward") {
                $("#connection_"+rs_id+"_1").attr('class','btn btn-custom'+(connection == ("1") ? " active" : " "));
                $("#connection_"+rs_id+"_2").attr('class','btn btn-custom'+(connection == ("2") ? " pending" : " "));
                $("#connection_"+rs_id+"_3").attr('class','btn btn-custom'+(connection == ("3") ? " active" : " "));

                $("#connection_"+rs_id+"_1").attr("onclick","updateContactRelationship('"+rs_id+"','1','"+(connection == "1" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
                $("#connection_"+rs_id+"_2").attr("onclick","updateContactRelationship('"+rs_id+"','2','"+(connection == "2" ? "pending" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
                $("#connection_"+rs_id+"_3").attr("onclick","updateContactRelationship('"+rs_id+"','3','"+(connection == "3" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
            } else {
                $("#connection_"+rs_id+"_1").attr('class','btn btn-custom'+(connection == ("1") ? " active" : " "));
                $("#connection_"+rs_id+"_2").attr('class','btn btn-custom'+(connection == ("3") ? " pending" : " "));
                $("#connection_"+rs_id+"_3").attr('class','btn btn-custom'+(connection == ("2") ? " active" : " "));

                $("#connection_"+rs_id+"_1").attr("onclick","updateContactRelationship('"+rs_id+"','1','"+(connection == "1" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
                $("#connection_"+rs_id+"_2").attr("onclick","updateContactRelationship('"+rs_id+"','3','"+(connection == "3" ? "pending" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
                $("#connection_"+rs_id+"_3").attr("onclick","updateContactRelationship('"+rs_id+"','2','"+(connection == "2" ? "active" : "not_active")+"', '"+direction+"', '"+contact_index+"')");
            }

            $.ajax({
                type:         "post",
                url:         "action/update_mobile_contact_connection.jsp",
                data:        "rs_id="+rs_id+
                    "&connection="+connection+
                    "&direction="+direction,

                success:    function(msg) {
                    msg = escape(msg).replace(/%0A/g, "");
                    msg = msg.replace(/%0D/g, "");
                    msg = unescape(msg);

                    if(msg != null && msg.indexOf("session_expired") >= 0) {
                        window.location = "mobileregister_nc.html";
                    } else if(msg != null && msg.indexOf("success") >= 0) {
                        //update relationship in contact_all array
                        console.log("updating contacts_arr_all["+contact_index+"].advanced_relation_type = "+connection);
                        contacts_arr_all[contact_index].advanced_relation_type = connection;
                    } else {
                        alert("Could not save. Please try again or contact support.");
                    }
                }
            });
        }
    };

    window.sendAPPInvite = function(rs_id, contact_user_id) {
        $.ajax({
            type:         "post",
            url:         "action/send_appinvite.jsp",
            data:        "rs_id="+rs_id+"&contact_user_id="+contact_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                    $("#contact_page_status_info").html("<div class='alert alert-danger'>Please set your profile name to invite<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $('#invite_'+rs_id+'').hide();
                    $('#invitesuccess_'+rs_id+'').show();
                }
            }
        });
    };

    window.remindAPPInvite = function(invite_id, source_user_id, dest_user_id) {
        $.ajax({
            type:         "post",
            url:         "action/remind_appinvite.jsp",
            data:        "source_user_id="+source_user_id+"&dest_user_id="+dest_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                    $("#reminder_page_status_info").html("<div class='alert alert-danger'>Please set your profile name to invite<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#reminder_page_status_info").show();
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $('#remind_btn_'+invite_id+'').hide();
                    $('#remindsuccess_btn_'+invite_id+'').show();
                }
            }
        });
    };

    window.editContactForm_OLD = function(rs_id, contact_user_id, contact_index) {
        var contact_name = $("#"+contact_user_id+"_contactname").html().trim();

        var msg =  "<div class='modal-dialog'>" +
            "   <div class='modal-content' style='max-width: 550px'>" +
            "       <div class='modal-header' style='background-color:#2C93FF;border-radius: 5px 5px 0px 0px; padding: 10px;'>" +
            "           <button type='button' class='close' data-dismiss='modal' style='opacity: 0.8; color: white;' aria-hidden='true'>&times;</button>" +
            "           <h5 class='modal-title text-center' style='margin-bottom: 0px;height:5px;color: white;text-align: center' >Edit Contact</h5></br>" +
            "       </div>" +
            "       <div class='modal-body'> " +
            "           <div class='row'>" +
            "               <div class='col-xs-4' style='margin-top:2%;align:right;'>" +
            "                   <p class='pull-right' style='margin-top:2%;font-size:18px'>Name:</p>" +
            "               </div>" +
            "           <div class='col-xs-8'>" +
            "               <input type='text' name='contact_name' class='form-control' id='contact_name' style='margin-left:-4%;max-width:200px' value='"+contact_name+"' >" +
            "           </div>" +
            "       </div>" +
            "       <div id='add_contactedit_status' align='center'></div>" +
            "       <div class='modal-footer' style='display:inline; border-top: 0px;'>" +
            "           <center>" +
            "               <button id='fcm_id' class='btn btn-info' style='background-color:#2C93FF' data-toggle='button' type='submit' onclick=\"updateContactDetails("+rs_id+", "+contact_user_id+", "+contact_index+");\">Update Contact</button>&nbsp;&nbsp;" +
            "               <button class='btn btn-secondary active' data-toggle='button' data-dismiss='modal'>Cancel</button>" +
            "           </center>" +
            "       </div>" +
            "   </div>" +
            "</div>";
        $("#edit_contact_form").html(msg);
        $("#click_to_display_contact_form").click();
    };

    window.editContactForm = function(rs_id, contact_user_id, contact_index) {
        var contact_name = $("#"+contact_user_id+"_contactname").html().trim();

        var msg = "<div class='modal-dialog'>" +
            "            <div class='modal-content' style='max-width: 550px'>" +
            "               <div align='center' class='modal-header' style='background-color:#2C93FF;border-radius: 5px 5px 0px 0px; padding: 10px;'>" +
            "                   <div style='opacity: 0.8; color: white; display: inline; padding: 0px 10px 0px 10px; font-size: 20px;' class='pull-right' onclick=\"$('#edit_contact_form').hide();\">&times;</div>" +
            "                   <h5 class='modal-title pull-center' style='margin-bottom: 0px;height:5px;color: white;display: inline;'>Update Contact</h5>" +
            "               </div>" +
            "               <div class='modal-body'> " +
            "                   <div class='row'>" +
            "                       <div class='col-xs-4' style='margin-top:2%;align:right;'>" +
            "                           <p class='pull-right' style='margin-top:2%;font-size:16px'>Name:</p>" +
            "                       </div>" +
            "                   <div class='col-xs-8'>" +
            "                       <input type='text' name='contact_name' class='form-control' id='contact_name' style='margin-left:-4%;max-width:200px' value='"+contact_name+"' >" +
            "                   </div>" +
            "               </div>" +
            "               <div class='modal-footer' style='margin-top:-2%;display:inline; border-top: 0px;'>" +
            "                  <center>" +
            "                       <button id='fcm_id' class='btn btn-info' style='background-color:#2C93FF'  data-toggle='button' type='submit' onclick=\"updateContactDetails("+rs_id+", "+contact_user_id+", "+contact_index+");\">Update contact</button>&nbsp;&nbsp;" +
            "                       <button class='btn btn-secondary active' onclick=\"$('#edit_contact_form').hide();\">Cancel</button>" +
            "                   </center>" +
            "               </div>" +
            "               <div id='add_contactedit_status' align='center' style='display:none'></div>" +
            "            </div>" +
            "       </div>";
        $("#edit_contact_form").html(msg);
        $('#edit_contact_form').show();
    };

    window.shareContactForm_OLD = function(contact_user_id) {
        var contact_name = $("#"+contact_user_id+"_contactname").html().trim();
        var msg =  "<div class='modal-dialog'>" +
            "   <div class='modal-content' style='max-width: 550px'>" +
            "       <div class='modal-body'> " +
            "           <button type='button' class='close' data-dismiss='modal' style='opacity: 0.4; color: black; font-size: 25px;' aria-hidden='true'>&times;</button>" +
            "           <br><center>Share - To be implemented</center><br>" +
            "       </div>" +
            "   </div>" +
            "</div>";
        $("#share_contact_form").html(msg);
        $("#click_to_display_share_form").click();
    };

    window.shareContactForm = function(contact_user_id) {
        var contact_name = $("#"+contact_user_id+"_contactname").html().trim();

        $("#contact_page_status_info").html("<div class='alert alert-danger'>Share - To be implemented<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
        $("#contact_page_status_info").show();
    };

    window.showContactDetails = function(contact_name, mobile, email) {
        var msg =  "<div class='modal-dialog'>" +
            "   <div class='modal-content' style='max-width: 550px'>" +
            "       <div class='modal-body'> " +
            "           <button type='button' class='close' data-dismiss='modal' style='opacity: 0.4; color: black' aria-hidden='true' style='padding-top: 5px;'>&times;</button><br>" +
            "           &nbsp;&nbsp;Name: "+contact_name+"<br>" +
            "           &nbsp;&nbsp;Mobile: "+mobile+"<br>" +
            "           &nbsp;&nbsp;Email: "+email+"<br>" +
            "       </div>" +
            "   </div>" +
            "</div>";
        $("#show_contact_details").html(msg);
        $("#click_to_display_contact_details").click();
    };

    window.updateContactDetails = function(rs_id, contact_user_id, contact_index) {
        $('#add_contactedit_status').hide();

        var contact_name = $('#contact_name').val();

        if(contact_name == null || contact_name == "") {
            $("#add_contactedit_status").html("<p style='background-color:#ff6666; color:white; margin-top:10px; margin-bottom: 10px; font-size: 14px'>Please enter contact name</p>");
            $("#add_contactedit_status").show();
            $("#contact_name").focus();
            return false;
        }

        $.ajax({
            type:         "post",
            url:         "action/update_contact_details.jsp",
            data:         "rs_id="+rs_id+"&contact_user_id="+contact_user_id+"&contact_name="+encodeURIComponent(contact_name),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg > 0) {
                    //update contact name in UI
                    console.log("updating contactname["+contact_index+"] = "+contact_name);
                    $("#"+contact_user_id+"_contactname").html(contact_name);

                    //update contact name in contact_all array
                    console.log("updating contacts_arr_all["+contact_index+"].dec_name = "+contact_name);
                    contacts_arr_all[contact_index].dec_name = contact_name;

                    $('#edit_contact_form').hide();
                } else {
                    $("#add_contactedit_status").html("<p style='background-color:#ff6666; color:white; margin-top:10px; margin-bottom: 10px; font-size: 14px'>Could not save contact details.</p>");
                    $("#add_contactedit_status").show();
                }
            }
        });
    };

    window.getContactDetailsToDelete = function(rs_id, contact_user_id, contact_index) {
        var msg = "<div class='modal-dialog'>" +
            "            <div class='modal-content' style='max-width: 550px'>" +
            "               <div align='center' class='modal-header' style='background-color:#2C93FF;border-radius: 5px 5px 0px 0px; padding: 10px;'>" +
            "                   <div style='opacity: 0.8; color: white; display: inline; padding: 0px 10px 0px 10px; font-size: 20px;' class='pull-right' onclick=\"$('#delete_contact_form').hide();\">&times;</div>" +
            "                   <h5 class='modal-title pull-center' style='margin-bottom: 0px;height:5px;color: white;display: inline;'>Delete Contact</h5>" +
            "               </div>" +
            "                <div class='modal-body'> " +
            "                   <p align='center' style='margin-bottom: 0px'>Are you sure you wish to delete this contact?</p>" +
            "                   <div id='add_cledit_status' align='center' style='display:none'></div>" +
            "                   <div class='modal-footer' style='margin-top:-2%;display:inline; border-top: 0px;'>" +
            "                       <center>" +
            "                           <button id='fcm_id' class='btn btn-info' style='background-color:#2C93FF'  data-toggle='button' type='submit' onclick='deleteContact("+rs_id+","+contact_user_id+","+contact_index+");'>Delete contact</button>&nbsp;&nbsp;" +
            "                           <button class='btn btn-secondary active' onclick=\"$('#delete_contact_form').hide();\">Cancel</button>" +
            "                       </center>" +
            "                   </div>" +
            "               </div>" +
            "            </div>" +
            "       </div>";
        $("#delete_contact_form").html(msg);
        $('#delete_contact_form').show();
    };

    window.deleteContact = function(rs_id, contact_user_id, contact_index) {
        $.ajax({
            type:         "post",
            url:         "action/delete_contact_details.jsp",
            data:         "rs_id="+encodeURIComponent(rs_id),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg > 0) {
                    $("#"+contact_user_id).remove();
                    contacts_arr_all.splice(contact_index, 1);
                    $('#delete_contact_form').hide();
                } else {
                    //DO NOTHING
                }
            }
        });
    };
});

//script for the Networkfeed page

$(document).ready(function() {
    window.showposts = function()  {
        $("#ask_in_network").val("");
        $("#ask_in_network").attr("style","max-width: 500px;height:80px;");
        $('#post').show();
        $('#hidepost').show();
        $('#showpost').hide();
        $("#ask_in_network").focus();
    };

    window.hidepost = function()  {
        $('#post').hide();
        $('#hidepost').hide();
        $('#showpost').show();
    }

    window.loadActivities = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_activities.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#display_activity_results").html(msg);
                }
            }
        });
    };

    window.loadAskList = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_ask_list.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#ask_in_network_records").html(msg);
                }
            }
        });
    };

    window.loadUserNotifications = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_user_notifications.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("events-body") >= 0) {
                    $("#useralerts_ref").html(msg);
                } else {
                    $("#footer_icon_alert").hide();
                    $("#useralerts_page").hide();
                    loadProfessionals();
                }
            }
        });
    };

    window.loadReminders = function() {
        $.ajax({
            type:         "post",
            url:         "action/load_reminders.jsp",

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("events-body") >= 0) {
                    $("#reminders_ref").html(msg);
                }
            }
        });
    };

    window.broadcastAskInNetwork = function (broadcast_ask_path, activity_id, owner_id) {
        $.ajax({
            type:         "post",
            url:          "action/broadcast_ask_in_network.jsp",
            data:         "activity_id="+activity_id+
                "&owner_id=" + owner_id,

            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id).removeAttr('onclick');
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id).attr('style','padding: 0px; cursor: auto;background-color:#ffffff;');
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id).attr('class','btn btn-default btn-simple btn-sm pull-center');
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id).attr('data-original-title','Success');
//                    $("#"+broadcast_ask_path+"_"+activity_id+" i").removeClass("fa fa-wifi fa-lg").addClass("fa fa-check-circle fa-lg");
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id+" img").removeAttr("src").attr("src","images/broadcast_success.png");
                } else {
                    //DO NOTHING
                }

            }
        });
    };

    window.askInYourNetwork = function() {

        var comments = $("#ask_in_network").val();

        if(comments == null || comments.trim().length <= 0) {
            $("#ask_in_network").focus();
        } else {
            $.ajax({
                type:         "post",
                url:          "action/ask_in_network.jsp",
                data:         "comments="+comments,

                success:    function(msg) {
                    msg = escape(msg).replace(/%0A/g, "");
                    msg = msg.replace(/%0D/g, "");
                    msg = unescape(msg);

                    if(msg != null && msg.indexOf("session_expired") >= 0) {
                        window.location = "mobileregister_nc.html";
                    } else if(msg != null && msg.indexOf("success") >= 0) {
                        $('#ask_in_network').val('');
                        loadAskList();
                    } else {
                        $("#ask_in_network_status").html("<font color=red>Failed to post</font>");
                    }
                }
            });
        }
    };

    window.postResponseToAsk = function(activity_id, owner_id) {

        var optionVal = document.getElementById("ask_response_"+activity_id+"_"+owner_id);
        var optionText = optionVal.options[optionVal.selectedIndex].text;

        $.ajax({
            type:         "post",
            url:          "action/post_response_to_ask.jsp",
            data:         "pros_userid="+optionVal.value+
                "&comments="+optionText+
                "&activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
//                    $("#ask_response_"+activity_id+"_"+owner_id).val('');
                    $('#ask_response_btn_'+activity_id+'_'+owner_id+'').hide();
                    $('#hide_response_btn_'+activity_id+'_'+owner_id+'').show();
                } else {
                    $("#post_response_to_ask_status").html("<font color=red>Failed to post</font>");
                }
            }
        });
    };

    window.recommendFL = function(activity_id, fl_userid, recommend) {

        $.ajax({
            type:         "post",
            url:          "action/recommend_fl.jsp",
            data:         "activity_id="+activity_id +
                "&fl_userid=" + fl_userid+
                "&recommend=" + recommend,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
//                    alert("Success");
                } else {
                    //DO NOTHING
                }
            }
        });
    };

    window.getpostdetailstodelete = function(activity_id) {
        var post_url = "action/get_postdetail_form.jsp";

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("Delete post") >= 0) {
                    $("#delete_post_form").html(msg);
                } else {
                    alert(msg);
                }
            }
        });
        $("#click_to_display_deletepost_form").click();
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
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
//                    $("#ask_in_network_records").html;
                    $("#deletepost").modal('hide');
                    loadAskList();
                } else {
                    //DO NOTHING
                }
            }
        });
    };

    window.showAskResponses = function (activity_id) {
        $.ajax({
            type:         "post",
            url:         "action/show_ask_responses.jsp",
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#show_ask_responses").html(msg);
                } else {
                    //DO NOTHING
                }
            }
        });

        $('#network').hide();
        $('#postresponse').show();
        $('#show_ask_responses').show();
    };

    window.hideAskResponses = function(activity_id)  {
        $('#network').show();
        $('#postresponse').hide();
        $('#show_ask_responses').hide();
    };

    /*for serching contact list according to alphabet*/
    var start_point = 1;
    var end_point = 18;

    window.getContactAccorToAlphabetupdown = function(searchContactForChar) {
        if(searchContactForChar == 'up') {
            if(start_point <= 1) {
                return;
            }
            $('#'+end_point).attr('style','display: none');
            start_point = start_point - 1;
            end_point = end_point-1;
            for (i = end_point; i >= start_point; i--) {
                $('#'+i).attr('style','display: block; cursor: pointer;');
            }
        } else if(searchContactForChar == 'down') {
            //if(start_point > 8) { //after Iphone 5 we are using/showing 18 alphabet
            if(start_point > 15) { //Iphone 4 we are using/showing 14 alphabet
                return;
            }
            $('#'+start_point).attr('style','display: none');
            start_point = start_point+1;
            end_point = end_point+1;

            for (i = start_point; i <= end_point; i++) {
                $('#'+i).attr('style','display: block; cursor: pointer;');
            }
        }
    };

    var divID;
    var prevclicked;
    var call_time = "";
    var array;

    var availableTags;
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

    window.getinviteStaus = function() {
        $.ajax({

            type: "post",
            url: "action/get_app_invite_status.jsp",

            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);
                //alert(msg);

                if (msg == null || msg.length <= 0) {
                    // DO NOTHING
                } else {
                    var invite_status = JSON.parse(msg);

                    for(var cnt = 0; cnt < invite_status.length; cnt++) {
                        try {
                            var from_user_id = invite_status[cnt].from_user_id;
                            var invite_to_userId = invite_status[cnt].to_userId;
                            var invitation_status = invite_status[cnt].invitation_status;
                            var rs_id = invite_status[cnt].rs_id;

                            if (invitation_status == 1){
                                $("#invite_"+rs_id).css("display", "none");
                                $("#invitesuccess_"+rs_id).css("display", "");
                            }

                        } catch (error) {
                            console.log(error);
                            continue;
                        }
                    }
                }
            }
        });
    }

    /*------------------Get & Show professional detail---------------------*/
    window.getandShowProfessionalDetail = function(fl_userid)  {
        $.ajax({
            type:         "post",
            url:         "action/get_professional_detail.jsp",
            data:         "fl_userid="+fl_userid,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#professional_detail").html(msg);
                }
            }
        });
    }
});
