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
        console.log("Coref: user is now successfully logged out from facebook");
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

function getNoEMPsHTML() {
    var no_emps_html = "<dl id='no_pros_id' style='padding:2px'>  " +
        "   <dd class='pos-left clearfix'>" +
        "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
        "           <div class='events-body'>" +
        "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
        "                   <center>No employees found</center>" +
        "               </div>" +
        "           </div>" +
        "       </div>" +
        "   </dd>" +
        "</dl>";

    return no_emps_html;
}

function getNoEMPReferralsHTML() {
    var no_emps_html = "<dl id='no_pros_id' style='padding:2px'>  " +
        "   <dd class='pos-left clearfix'>" +
        "       <div class='events' style='margin-top: 2%; box-shadow: 0.09em 0.09em 0.09em 0.05em  #888888; background-color: #f2dede; color: #a94442;'>" +
        "           <div class='events-body'>" +
        "               <div style='margin-top: 10px; margin-bottom: 10px;'>"+
        "                   <center>No referrals found</center>" +
        "               </div>" +
        "           </div>" +
        "       </div>" +
        "   </dd>" +
        "</dl>";

    return no_emps_html;
}

var contacts_arr_intial = [];
var contacts_arr_remaining = [];
var contacts_arr_all = [];
var contacts_arr_all_length;

//Script common for all pages
$(document).ready(function() {
    $("#footer_icon_comp_referrals").longclick(500, function() {
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
        $("#employees_page").hide();                                 //hiding company referrals tab by default on page load
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#contacts_page").hide();                                 //hiding contacts tab by default on page load, that is on body load
        $("#networkfeed_page").hide();                              //hiding networkfeed tab by default on page load, that is on body load
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab
        $("#professionals_page").show();                            //showing professionals tab by default on page load, that is on body load
    };

    window.networkEmployees = function () {
        if(device_type == "ios") {
            postContactsTODB_iOS();
        } else if(device_type == "android") {
            $("#footer_icon_android_whatsapp").show();
        }

        getUserDetails();   // to display the user details in the header

        var redirected_from = $.QueryString['redirected_from'];

        if (redirected_from != null && redirected_from == "lin") {
            setTimeout(function() {
                $("#my_profile_url").click();       //If the page is loaded from the linkedin login redirect url, simulate My Profile click
            }, 1000);
        } else {
            loadEMPView();
            $("#professionals_page").hide();                               //hiding referrals tab
            $("#contacts_page").hide();                                 //hiding contacts tab by default on page load, that is on body load
            $("#networkfeed_page").hide();                              //hiding networkfeed tab by default on page load, that is on body load
            $("#myprofile_page").hide();                                //hiding my profile tab
            $("#contactprofile_page").hide();                           //hiding contacts profile tab
            $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
            $("#employees_page").show();                                //showing employees tab by default on page load, that is on body load
        }
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
                    document.cookie = "coref_cookie_login=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                    document.cookie = "coref_cookie_mobile=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                    document.cookie = "coref_cookie_deviceid=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";

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
                        document.cookie = "coref_cookie_login=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                        document.cookie = "coref_cookie_mobile=;expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/";
                        window.location = "mobileregister_nc.html";
                    }, 200);
                }
            }
        });
    });

    window.loadProfessionals = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???
        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_active.png");

        $("#employees_page").hide();                                //hiding employees tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#networkfeed_page").hide();                              //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        showFLView();

        $("#showFLView_btn").attr("class","option active");             //showing professionals tab
        $("#professionals_page").show();                                //showing professionals tab

        $("#contact_search_div").hide();                                //hiding search by contacts input
        $("#networkfeed_post_div").hide();                              //hiding network feed post input
//        $("#search_by_val_div").show();                                 //showing search by pros input
    };

    window.loadCompanyReferrals = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???
        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_active.png");
        $("#professionals_page").hide();                               //hiding referrals tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#networkfeed_page").hide();                              //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        showEMPView();

        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#contact_search_div").hide();                            //hiding search by contacts input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
//        $("#search_by_val_div").show();                             //showing search by pros input

        $("#employees_page").show();                                //showing employees tab
    };

    function showEMPView () {
        $('#search_by_val').val('');
        $('#showfriendfreelancers').hide();
        $('#friendsview_table').hide();
        $('#prosclients').hide();
        $('#searchresult').hide();
        $('#showFriendsView_btn').attr("class","option");
        $('#showFLView_btn').attr("class","option active");
        loadEMPView();
        $('#empview_table').show();
        $('#emp_list').show();
    }

    window.loadRererralsHR = function () {
        // window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???

        $("#employees_page").hide();                                //hiding employees tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#networkfeed_page").hide();                              //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab
        $("#notifications_page").hide();

        showRererralsViewHR();

        $("#professionals_page").show();                            //showing professionals tab

        $("#contact_search_div").hide();                            //hiding search by contacts input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
//        $("#search_by_val_div").show();                            //showing search by pros input

        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional.png");
    };

    window.showRererralsViewHR = function() {
        $('#search_by_val').val('');
        $('#showfriendfreelancers').hide();
        $('#friendsview_table').hide();
        $('#prosclients').hide();
        $('#searchresult').hide();
        $('#showFriendsView_btn').attr("class","option");
        $('#showFLView_btn').attr("class","option active");

        loadReferralsViewHR();

        $('#flview_table').show();
        $('#professional_list').show();
    };

    var referral_arr = [];

    window.loadReferralsViewHR = function() {
        $("#search_results").val('');
        $("#load_referrals_loading").show();
        $.ajax({
            type:         "post",
            url:         "action/load_referrals.jsp",

            success:    function(referral_list_json) {
                referral_list_json = escape(referral_list_json).replace(/%0A/g, "");
                referral_list_json = referral_list_json.replace(/%0D/g, "");
                referral_list_json = unescape(referral_list_json);

                if(referral_list_json != null && referral_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

//                console.log(new Date()+"\t Got the response: "+referral_list_json.length+", profession_list_json: "+referral_list_json);

                referral_arr = JSON.parse(referral_list_json);

                if(referral_arr == null || referral_arr.length <= 0) {
                    $("#load_referrals dl").remove();
                    $("#load_referrals_loading").hide();

                    var no_pros_html = getNoReferralsHTML();
                    $("#load_referrals").append(no_pros_html);

                    //No referral list found, do nothing
                    return;
                }

                referral_arr.sort(function(a, b) {
                    var nameA = a.referral_name.toLowerCase(), nameB = b.referral_name.toLowerCase();
                    if (nameA < nameB) //sort string ascending
                        return -1;
                    if (nameA > nameB)
                        return 1;
                    return 0; //default return value (no sorting)
                });

                var referral_table_html = "";
                var referral_found = false;

                $("#load_referrals dl").remove();
                $("#load_referrals_loading").hide();

                for(var cnt = 0; cnt < referral_arr.length; cnt++) {
                    try {
                        var referral_userid = referral_arr[cnt].referral_userid;
                        var referral_name = referral_arr[cnt].referral_name;
                        var expertise = referral_arr[cnt].expertise;
                        var linkedin = referral_arr[cnt].linkedin;
                        var facebook = referral_arr[cnt].facebook;

                        var row_html = getReferralRowHTML(referral_userid, referral_name, expertise, linkedin, facebook);

                        $("#load_referrals").append(row_html);

                        referral_found = true;
                    } catch (error) {
                        continue;
                        console.log(error);
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                /*
                 if (jqXHR.status === 0) {
                 $("#load_referrals_loading").hide();
                 $("#load_referrals").html("Not connected.<br>Please verify your network connection.");
                 }
                 */

                $("#load_referrals_loading").hide();
                var err = getNoConnectionHTML();
                $("#load_referrals").html(err);
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

    function getReferralRowHTML(referral_userid, referral_name, expertise, linkedin, facebook) {

        var photo_path = "images/profile.jpg";

        var linkedin_str1 = "<button class='btn btn-info btn-simple btn-fill btn-sm' style='cursor: pointer;padding: 0px 5px' data-original-title='Linkedin profile' type='button' title='' rel='tooltip'  onclick=\"window.open('"+linkedin+"', '_blank')\"><i class='fa fa-linkedin'></i> </button>";
        var linkedin_str = (linkedin != null && linkedin.trim().length > 0 ? linkedin_str1 : "");

        var row_html = "<dl style='word-wrap: break-word;padding:0px; width: 99%'>" +
            "           <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
            "              <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block;'>" +
            "                   <p class='pull-left' style='margin-left:-3px;margin-bottom: 0px'> <img class='img-circle' style='main-width:35px;max-width:45px;margin-bottom:10px' src="+photo_path+"></p>"+
            "                      <div class='events-body ' style='margiun-right:0px;'>" +
            "                           <div align='left' class='pull-left' style='width:90%;margin-bottom:2px'>   " +
            "                               <h2 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(referral_name != null && referral_name.trim().length > 0 ? referral_name  : "N/A")+" &nbsp;"+(linkedin_str)+"</h2>"+
            "                                    <h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px' >" +
            "                                    Skills: "+(expertise != null && expertise.trim().length > 0 ? expertise : "N/A")+"<br>" +
            (facebook != null && facebook.trim().length > 0 ? "Facebook: "+facebook+"<br>" : "" )+"" +
            "                             </div>" +
            "                        </div>" +
            "                 </div>" +
            "               </dd>" +
            "           </dl>";

        return row_html;
    }

    window.loadContactsHR = function () {
//        window.stop();                                                //stop loading the remaining page before calling new function. Is this correct way???
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts.png");
        $("#professionals_page").hide();                               //hiding referrals tab
        $("#employees_page").hide();                                    //hiding employees tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#networkfeed_page").hide();                                  //hiding networkfeed tab
        $("#useralerts_page").hide();                                   //hiding user alerts tab
        $("#reminders_page").hide();                                    //hiding reminders tab
        $("#myprofile_page").hide();                                    //hiding my profile tab
        $("#contactprofile_page").hide();                               //hiding contacts profile tab

        $("#profile_notification").hide();
        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        $("#contacts_table_ref dl").remove();

        $("#contact_page_status_info").hide();

        $("#contacts_page").show();                                  //showing contacts tab

        if(contacts_arr_all != null && contacts_arr_all.length > 0) {
            console.log(new Date()+"\t Start calling contact_search_fn() on loadContacts() ...");

            setTimeout(function() {
                contact_search_fn();                //If array > 0, simulating the contacts loading from the js array instead of getting it from server
            }, 200);

            console.log(new Date()+"\t End calling  contact_search_fn() on loadContacts() ...");
        } else {
            console.log(new Date()+"\t contacts_arr_all is null or empty. calling getMobileContacts_FromServer()...");

            setTimeout(function() {
                getMobileContactsHR_FromServer();
            }, 200);
        }

        $("#search_by_val_div").hide();                            //hiding search by pros input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#contact_search_div").show();                            //showing search by contacts input
    };

    window.showContactsView = function () {
        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                             //hiding professionals tab
        $("#networkfeed_page").hide();                               //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#contact_page_status_info").hide();

        setTimeout(function() {
            $("#contacts_page").show();                                  //showing contacts tab
        }, 200);

        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts.png");

        $("#profile_notification").hide();
        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");

        $("#search_by_val_div").hide();                             //hiding search by pros input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#contact_search_div").show();                            //showing search by contacts input
    };

    window.loadNetworkFeed = function () {
        window.stop();                                              //stop loading the remaining page before calling new function. Is this correct way???

        $("#search_by_val_div").hide();                            //hiding search by pros input
        $("#contact_search_div").hide();                            //hiding search by contacts input

        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network.png");
        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                            //hiding professionals tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#contacts_table_loading").hide();
        $("#postresponse").hide();
        $("#screen_feed").show();

        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");
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
        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                            //hiding professionals tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#postresponse").hide();                                  //hiding post response area
        $("#networkfeed_page").hide();                              //hiding network feed area
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");
        $("#footer_icon_myaccount").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
//        $("#footer_icon_alert").attr("class","fa fa-exclamation fa-2x");

        loadUserNotifications();

        $("#useralerts_loading").hide();                         //hiding contacts loading symbol
        $("#useralerts_page").show();                               //showing networkfeed tab
    };

    window.showReminders = function () {
        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                            //hiding professionals tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#postresponse").hide();                                  //hiding post response area
        $("#networkfeed_page").hide();                              //hiding network feed area
        $("#useralerts_page").hide();                               //hiding networkfeed tab
        $("#myprofile_page").hide();                                //hiding my profile tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

        $("#footer_icon_comp_referrals").attr("style","color: #BF9069;margin-top: 10px;margin-left: 20px;margin-right: 20px;margin-bottom: 5px");
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
        var cookie_name = "coref_profile_check";
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
        var cookie_name = "coref_profile_check";
        var cookie_value = "coref_profile_val";
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
        var cookie_name = "coref_tooltips_check";
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
        var cookie_name = "coref_tooltips_check";
        var cookie_value = "coref_tooltips_val";
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

        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");

        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                             //hiding referrals tab
        $("#contacts_page").hide();                                 //hiding contacts tab
        $("#networkfeed_page").hide();                              //hiding networkfeed tab
        $("#useralerts_page").hide();                               //hiding user alerts tab
        $("#reminders_page").hide();                                //hiding reminders tab
        $("#contactprofile_page").hide();                           //hiding contacts profile tab

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
                        var profile_expertise = profile_details_arr[cnt].profile_expertise;
                        var profile_linkedin = profile_details_arr[cnt].profile_linkedin;
                        var profile_facebook = profile_details_arr[cnt].profile_facebook;
                        var lin_publicProfileUrl = profile_details_arr[cnt].lin_publicProfileUrl;

                        if(profile_image_file_name == null || profile_image_file_name == "" || profile_image_file_name == "Not Avilable") {
                            $("#profile_image_display").attr("src","profile_images/profile.jpg");
                            $("#profile_image").attr("src","profile_images/profile.jpg");
                        } else {
                            $("#profile_image_display").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
                            $("#profile_image").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
                        }

                        $("#profile_name").val(profile_name);
                        $("#profile_expertise").val(profile_expertise);

                        if(profile_linkedin == null || profile_linkedin.trim() == "") {
                            $("#profile_linkedin").val(lin_publicProfileUrl);
                        } else {
                            $("#profile_linkedin").val(profile_linkedin);
                        }
                        $("#profile_facebook").val(profile_facebook);
                    } catch (error) {
                        continue;
                    }
                }
            }
        });
    };

    window.openContactProfilePage = function(contact_name, contact_user_id) {
        $("#contact_search_div").hide();                            //hiding search by contacts input
        $("#networkfeed_post_div").hide();                          //hiding network feed post input
        $("#search_by_val_div").hide();                            //hiding search by pros input

        $("#profile_details_status_failed").hide();
        $("#profile_details_status_success").hide();

        $("#footer_icon_comp_referrals").removeAttr("src").attr("src","images/group_default.png");
        $("#footer_icon_networkfeed").removeAttr("src").attr("src","images/network_default.png");
        $("#footer_icon_contacts").removeAttr("src").attr("src","images/contacts_default.png");
        $("#footer_icon_referrals").removeAttr("src").attr("src","images/professional_default.png");

        $("#employees_page").hide();                             //hiding company referrals tab
        $("#employees_ref_page").hide();                                 //hiding company referrals inner tab
        $("#professionals_page").hide();                             //hiding referrals tab
        $("#contacts_page").hide();                                //hiding contacts tab
        $("#networkfeed_page").hide();                             //hiding networkfeed tab
        $("#useralerts_page").hide();                              //hiding user alerts tab
        $("#reminders_page").hide();                               //hiding reminders tab
        $("#professionals_page").hide();                               //hiding reminders tab

        getContactProfileDetails(contact_name, contact_user_id);

        $("#contactprofile_page").show();
    };

    window.addAsEmployee = function(rs_id, contact_name, contact_user_id) {
        $("#contact_page_status_info").hide();

        $.ajax({
            type:         "post",
            url:         "action/add_employee_for_user.jsp",
            data:         "contact_user_id="+contact_user_id +"&contact_name="+encodeURIComponent(contact_name)+"&rs_id="+rs_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg != null && msg.indexOf("profile_name_not_set") >= 0) {
                    $("#contact_page_status_info").html("<div class='alert alert-danger'>Please set your profile name to invite<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                } else if(msg != null && msg == "1") {
                    $("#addemployee_"+rs_id).hide();
                    $("#addemployeesuccess_"+rs_id).show();

                    $("#contact_page_status_info").html("<div class='alert alert-success' style='padding: 20px 0px 10px 10px;'>Successfully added "+contact_name+" as Employee <a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                } else {
                    $("#contact_page_status_info").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Could not add employee<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                }
            }
        });
    };

    window.removeAsEmployee = function(rs_id, contact_name, contact_user_id) {
        $("#contact_page_status_info").hide();

        $.ajax({
            type:         "post",
            url:         "action/remove_employee_for_user.jsp",
            data:         "contact_user_id="+contact_user_id +"&contact_name="+encodeURIComponent(contact_name),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "1") {
                    $("#addemployeesuccess_"+rs_id).hide();
                    $("#addemployee_"+rs_id).show();

                    $("#contact_page_status_info").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Successfully removed "+contact_name+" from Employee <a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                } else {
                    $("#contact_page_status_info").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Could not remove employee<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
                }
            }
        });
    };

    window.getContactProfileDetails = function(contact_name, contact_user_id) {
        var post_url = "action/get_contactprofile_details.jsp";

        $("#contactprofile_details_status_success").hide();
        $("#contactprofile_details_status_failed").hide();

        $.ajax({
            type:         "post",
            url:          post_url,
            data:         "contact_user_id="+encodeURIComponent(contact_user_id),

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
                        var contactprofile_image_file_name = profile_details_arr[cnt].profile_image_file_name;
                        var contactprofile_name = profile_details_arr[cnt].profile_name;
                        var contactprofile_profession = profile_details_arr[cnt].profile_profession;
                        var contactprofile_skills = profile_details_arr[cnt].profile_expertise;
                        var contactprofile_experience = profile_details_arr[cnt].profile_experience;
                        var contactprofile_linkedin = profile_details_arr[cnt].profile_linkedin;
                        var contactprofile_location = profile_details_arr[cnt].profile_location;
                        var contactprofile_about = profile_details_arr[cnt].profile_about;
                        var contactprofile_fb = profile_details_arr[cnt].profile_facebook;

                        if(contactprofile_image_file_name == null || contactprofile_image_file_name == "" || contactprofile_image_file_name == "Not Avilable") {
                            $("#contactprofile_image_display").attr("src","profile_images/profile.jpg");
                        } else {
                            $("#contactprofile_image_display").attr("src","profile_images/"+from_user_id+"/"+contactprofile_image_file_name);
                        }

                        if(contactprofile_name == null || contactprofile_name.length <= 0) {
                            contactprofile_name = contact_name;
                        }

                        $("#contactprofile_name").val(contactprofile_name);
                        $("#contactprofile_profession").val(contactprofile_profession);
                        $("#contactprofile_skills").val(contactprofile_skills);
                        $("#contactprofile_experience").val(contactprofile_experience);
                        $("#contactprofile_linkedin").val(contactprofile_linkedin);
                        $("#contactprofile_location").val(contactprofile_location);
                        $("#contactprofile_about").val(contactprofile_about);
                        $("#contactprofile_fb").val(contactprofile_fb);
                        $("#contactprofile_save").attr("onclick","saveContactProfileDetailsAndRefer('"+contact_user_id+"')");

                        if(contactprofile_profession == null || contactprofile_profession.trim().length <= 0) {
                            $("#contactprofile_profession").removeAttr("readonly");
                            $("#contactprofile_save").show();
                        } else {
                            $("#contactprofile_profession").attr("readonly","readonly");
                            $("#contactprofile_save").hide();
                        }
                    } catch (error) {
                        continue;
                    }
                }
            }
        });
    };

    window.saveContactProfileDetailsAndRefer = function(contact_user_id) {
        var contactprofile_linkedin = $('#contactprofile_linkedin').val().trim();
        //var contactprofile_fb = $('#contactprofile_fb').val().trim();
        var contactprofile_skills = $('#contactprofile_skills').val().trim();
        var contactprofile_name = $('#contactprofile_name').val().trim();

        if(contactprofile_linkedin == null || contactprofile_linkedin == "") {
            if (contactprofile_skills == null || contactprofile_skills == ""){
                $("#contactprofile_details_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Either linkedin or skills cannot be empty<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
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

        $.ajax({
            type:         "post",
            url:         "action/save_contactprofile_details_and_refer.jsp",
            data:         "contactprofile_linkedin="+encodeURIComponent(contactprofile_linkedin)+"&contactprofile_skills="+encodeURIComponent(contactprofile_skills)+"&contact_user_id="+contact_user_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
                    getsuggestion(contact_user_id,contactprofile_linkedin,contactprofile_name);
                    $("#contactprofile_details_status_failed").html("");
                    $("#contactprofile_details_status_failed").hide();

                    $("#contactprofile_details_status_success").html("<div class='alert alert-success' style='padding: 20px 0px 10px 10px;'>Successfully saved and referred<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contactprofile_details_status_success").show();

                    //reset the border color to none
                    $('#contactprofile_linkedin').attr("style","border-color: none;");
                    $('#contactprofile_fb').attr("style","border-color: none;");
                    $('#contactprofile_skills').attr("style","border-color: none;");
                } else {
                    $("#contactprofile_details_status_failed").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Could not save the details<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contactprofile_details_status_failed").show();
                }
            }
        });
    };

    window.post_like = function(activity_id,post_likes) {

        $.ajax({
            type:         "post",
            url:          "action/post_likes.jsp",
            data:         "&activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();
                if(msg == "success") {
                    loadActivities();
                    loadAskList();
                } else {

                }
            }
        });
    };

    window.post_dislike = function(activity_id,post_dislikes) {

        $.ajax({
            type:         "post",
            url:          "action/post_dislikes.jsp",
            data:         "&activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();
                if(msg == "success") {
                    loadActivities();
                    loadAskList();
                } else {

                }
            }
        });
    };

    function getsuggestion(contact_user_id,contactprofile_linkedin,contactprofile_name) {

        $.ajax({
            type:         "post",
            url:         "action/getsuggestions.jsp",
            data:         "contactprofile_linkedin="+encodeURIComponent(contactprofile_linkedin)+"&contactprofile_name="+encodeURIComponent(contactprofile_name)+"&contact_user_id="+contact_user_id,

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


    window.refreshProfileImage_Android = function(from_user_id, profile_image_file_name) {
        if(profile_image_file_name == null) {
            //Do nothing
        } else {
            $("#profile_image").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
            $("#profile_image_display").attr("src","profile_images/"+from_user_id+"/"+profile_image_file_name);
        }
        getUserDetails();
    };

    window.refreshBusinessDetailsImage_Android = function(from_user_id, profile_business_details_file_name) {
        if(profile_business_details_file_name == null) {
            //Do nothing
        } else {
            $("#business_details_image").attr("src","profile_images/"+from_user_id+"/"+profile_business_details_file_name);
        }
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
        var profile_expertise = $('#profile_expertise').val().trim();
        var profile_linkedin = $('#profile_linkedin').val().trim();
//        var profile_facebook = $('#profile_facebook').val().trim();

        if(profile_name == null || profile_name == "") {
            $("#profile_details_status_failed").html("<font color='red''>Please enter profile name</font>");
            $("#profile_details_status_failed").show();
            $('#profile_name').css({
                "border-color": "red"
            });
            $("#profile_name").focus();

            return false;
        }

        $("#profile_details_status_success").hide();
        $("#profile_details_status_failed").hide();

        $.ajax({
            type:         "post",
            url:         "action/save_profile_details.jsp",
            data:         "profile_name="+encodeURIComponent(profile_name)+
                "&profile_expertise="+encodeURIComponent(profile_expertise)+
                "&profile_linkedin="+encodeURIComponent(profile_linkedin),

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                msg = msg.trim();

                if(msg == "success") {
                    $("#profile_details_status_success").html("<div class='alert alert-success'>Successfully saved<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#profile_details_status_success").show();
                    $('#profile_name').css({
                        "border-color": ""
                    });
                    getUserDetails();
                } else {
                    $("#profile_details_status_failed").html("<font color='red'>Could not save the data</font>");
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
        $("#load_referrals_loading").show();
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
                    $("#load_referrals_loading").hide();
                    $("#display_sk_results").html(msg);
                    $("#display_friend_results").show();
                }
            },
            error: function(jqXHR, textStatus, error) {
                $("#load_referrals_loading").hide();
                $("#display_friend_results").hide();
                var err = getNoConnectionHTML();
                $("#display_sk_results").html(err);
            }
        });
    };

    var professional_arr = [];

    window.loadFLView = function() {
        $("#search_results").val('');
        $("#load_referrals_loading").show();
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
                    $("#load_referrals dl").remove();
                    $("#load_referrals_loading").hide();

                    var no_pros_html = getNoProfessionalsHTML();
                    $("#load_referrals").append(no_pros_html);

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

                $("#load_referrals dl").remove();
                $("#load_referrals_loading").hide();

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

                        $("#load_referrals").append(row_html);

                        professional_found = true;
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                /*
                 if (jqXHR.status === 0) {
                 $("#load_referrals_loading").hide();
                 $("#load_referrals").html("Not connected.<br>Please verify your network connection.");
                 }
                 */

                $("#load_referrals_loading").hide();
                var err = getNoConnectionHTML();
                $("#load_referrals").html(err);
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

    var emp_arr = [];

    window.loadEMPView = function() {
        $("#search_results_emp").val('');
        $("#load_emp_loading").show();
        $.ajax({
            type:         "post",
            url:         "action/load_employees.jsp",

            success:    function(emp_list_json) {
                emp_list_json = escape(emp_list_json).replace(/%0A/g, "");
                emp_list_json = emp_list_json.replace(/%0D/g, "");
                emp_list_json = unescape(emp_list_json);

                console.log("emp_list_json: "+emp_list_json);

                if(emp_list_json != null && emp_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

//                console.log(new Date()+"\t Got the response: "+emp_list_json.length+", emp_list_json: "+emp_list_json);

                emp_arr = JSON.parse(emp_list_json);

                if(emp_arr == null || emp_arr.length <= 0) {
                    $("#load_emps dl").remove();
                    $("#load_emp_loading").hide();

                    var no_emps_html = getNoEMPsHTML();
                    $("#load_emps").append(no_emps_html);

                    //No employee list found, do nothing
                    return;
                }

                emp_arr.sort(function(a, b) {
                    var nameA = a.emp_name.toLowerCase(), nameB = b.emp_name.toLowerCase();
                    if (nameA < nameB) //sort string ascending
                        return -1;
                    if (nameA > nameB)
                        return 1;
                    return 0; //default return value (no sorting)
                });

                var emp_table_html = "";
                var emp_found = false;

                console.log(new Date()+"\t Number of employees loading...: "+emp_arr.length);

                $("#load_emps dl").remove();
                $("#load_emp_loading").hide();

                for(var cnt = 0; cnt < emp_arr.length; cnt++) {
                    try {
                        var emp_userid = emp_arr[cnt].emp_userid;
                        var emp_name = emp_arr[cnt].emp_name;

                        var row_html = getEMPRowHTML(emp_userid, emp_name);

                        $("#load_emps").append(row_html);

                        emp_found = true;
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                $("#load_emp_loading").hide();
                var err = getNoConnectionHTML();
                $("#load_emps").html(err);
            }
        });

        $('#employee_ref_details_page').hide();
        $('#employees_ref_page').hide();
        $('#employees_page').show();
    };

    window.showEMPView = function() {
        $('#employee_ref_details_page').hide();
        $('#employees_ref_page').hide();
        $('#employees_page').show();
    };

    window.showEMPReferralView = function() {
        $('#employees_page').hide();
        $('#employee_ref_details_page').hide();
        $('#employees_ref_page').show();
    };

    function getEMPRowHTML(emp_userid, emp_name) {
        var row_html = "<dl style='word-wrap: break-word;padding:0px; width: 99%'>" +
            "           <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
            "              <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block;'>" +
            "                      <p class='pull-left' style='margin-left:-3px;margin-bottom: 0px'> <img class='img-circle' style='main-width:35px;max-width:45px;margin-bottom:10px' src='images/profile.jpg'></p>" +
            "                      <div class='events-body ' style='margiun-right:0px;'>" +
            "                           <div align='left' class='pull-left' style='width:90%;margin-bottom:2px; margin-top: 10px;'>   " +
            "                               <h2 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(emp_name != null && emp_name.trim().length > 0 ? emp_name  : "N/A")+"</h2>"+
            "                             </div>" +
            "                            <div class='pull-right' style='width:10%;background-color:#ffffff;'>  " +
            "                               <button  data-toggle='modal' type='button' id='showworkedwith_"+emp_userid+"' class='btn btn-default btn-simple btn-lg pull-right' style='background-color:#ffffff;' onclick='showEMPReferrals("+emp_userid+", \""+emp_name+"\");'><i class='fa fa-angle-right' style='color:#808080;font-size:25px'></i></button>" +
            "                           </div>" +
            "                        </div>" +
            "                 </div>" +
            "               </dd>" +
            "           <div  id='showflcl_"+emp_userid+"' class='text-left' style='max-width: 100%;margin-top: %;display_none;background-color:#f5f5f5'></div>"+
            "           </dl>";
        return row_html;
    };

    function getEMPReferralRowHTML(emp_userid, emp_name , expertise, linkedin, facebook) {
        var linkedin_str1 = "<button class='btn btn-info btn-simple btn-fill btn-sm' style='cursor: pointer;padding: 0px 5px' data-original-title='Linkedin profile' type='button' title='' rel='tooltip'  onclick=\"window.open('"+linkedin+"', '_blank')\"><i class='fa fa-linkedin'></i> </button>";
        var linkedin_str = (linkedin != null && linkedin.trim().length > 0 ? linkedin_str1 : "");


        var row_html = "<dl style='word-wrap: break-word;padding:0px; width: 99%'>" +
            "           <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
            "              <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block;'>" +
            "                      <p class='pull-left' style='margin-left:-3px;margin-bottom: 0px'> <img class='img-circle' style='main-width:35px;max-width:45px;margin-bottom:10px' src='images/profile.jpg'></p>" +
            "                      <div class='events-body ' style='margiun-right:0px;'>" +
            "                           <div align='left' class='pull-left' style='width:90%;margin-bottom:2px; margin-top: 10px;'>   " +
            "                               <h2 style='margin-top:0px;margin-bottom:3px;font-size:15px;margin-left:8px'>"+(emp_name != null && emp_name.trim().length > 0 ? emp_name  : "N/A")+" &nbsp;"+(linkedin_str)+"</h2>"+
            "                                    <h4 class='text-muted' style='margin-bottom:2px;font-family:monospace;overflow:auto; font-size-adjust: 0.58;line-height:1.1;font-size:12px;margin-left:8px' >" +
            "                                    Skills: "+(expertise != null && expertise.trim().length > 0 ? expertise : "N/A")+"<br>" +
            (facebook != null && facebook.trim().length > 0 ? "Facebook: "+facebook+"<br>" : "" )+"" +
            "                             </div>" +
            "                        </div>" +
            "                 </div>" +
            "               </dd>" +
            "           </dl>";

        return row_html;
    };

    var emp_ref_arr = [];

    window.showEMPReferrals = function(emp_userid, emp_name)  {
        $("#load_emp_ref_loading").show();
        $.ajax({
            type:         "post",
            url:         "action/show_emp_referrals.jsp",
            data:         "emp_userid="+emp_userid+"&emp_name="+encodeURIComponent(emp_name),

            success:    function(emp_ref_list_json) {
                emp_ref_list_json = escape(emp_ref_list_json).replace(/%0A/g, "");
                emp_ref_list_json = emp_ref_list_json.replace(/%0D/g, "");
                emp_ref_list_json = unescape(emp_ref_list_json);

                if(emp_ref_list_json != null && emp_ref_list_json.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                }

                emp_ref_arr = JSON.parse(emp_ref_list_json);

                if(emp_ref_arr == null || emp_ref_arr.length <= 0) {
                    $("#load_emp_refferals dl").remove();
                    $("#load_emp_ref_loading").hide();

                    var no_emp_ref_html = getNoEMPReferralsHTML();
                    $("#load_emp_refferals").append(no_emp_ref_html);

                    //No employee referral list found, do nothing
                    return;
                }

                emp_ref_arr.sort(function(a, b) {
                    var nameA = a.referral_name.toLowerCase(), nameB = b.referral_name.toLowerCase();

                    if (nameA < nameB) //sort string ascending
                        return -1;
                    if (nameA > nameB)
                        return 1;
                    return 0; //default return value (no sorting)
                });

                var emp_ref_table_html = "";
                var emp_ref_found = false;

                console.log(new Date()+"\t Number of employee referrals loading...: "+emp_ref_arr.length);

                $("#load_emp_refferals dl").remove();
                $("#load_emp_ref_loading").hide();

                for(var cnt = 0; cnt < emp_ref_arr.length; cnt++) {
                    try {
                        var referral_userid = emp_ref_arr[cnt].referral_userid;
                        var referral_name = emp_ref_arr[cnt].referral_name;
                        var expertise = emp_ref_arr[cnt].expertise;
                        var linkedin = emp_ref_arr[cnt].linkedin;
                        var facebook = emp_ref_arr[cnt].facebook;

                        var row_html = getEMPReferralRowHTML(referral_userid, referral_name, expertise, linkedin, facebook);

                        $("#load_emp_refferals").append(row_html);

                        emp_ref_found = true;
                    } catch (error) {
                        continue;
                    }
                }
            },
            error: function(jqXHR, textStatus, error) {
                $("#load_emp_ref_loading").hide();
                var err = getNoConnectionHTML();
                $("#load_emp_refferals").html(err);
            }
        });

        $('#employee_name').html(emp_name);

        $('#employee_ref_details_page').hide();
        $('#employees_page').hide();
        $('#employees_ref_page').show();
    };

    window.showEMPReferralDetails = function(emp_userid, emp_name)  {
        $.ajax({
            type:         "post",
            url:         "action/get_emp_referral_details.jsp",
            data:         "emp_userid="+emp_userid+"&emp_name="+emp_name,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#load_emp_refferal_details").html(msg);
                }
            }
        });
        $('#employees_page').hide();
        $('#employees_ref_page').hide();
        $('#employee_ref_details_page').show();
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

    //Delay function to call up on every keyup. jQuery 1.7.1 or up required
    //REF: http://jsfiddle.net/Us9bu/2/
    $('#search_by_val').delayKeyup(function(el) {
        get_search_results_fn();
    }, 500);                //delay in milli seconds

    window.get_search_results_fn = function() {
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
            $("#load_referrals dl").remove();
            $("#load_referrals_loading").hide();
            var no_pros_html = getNoProfessionalsHTML();
            $("#load_referrals").append(no_pros_html);
        } else {
            $("#load_referrals dl").remove();
            $("#load_referrals_loading").hide();
            $("#load_referrals").append(professional_table_html);
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

    window.getMobileContactsHR_FromServer = function() {
        $("#contact_search").val('');
        getMobileContactsHR();
    };

    window.getMobileContactsHR = function() {
        console.log(new Date()+"\t getMobileContactsHR called");

        setTimeout(function() {
            $.ajax({
                type:         "post",
                url:          "action/get_all_contacts_hr_from_db_session.jsp",

                success:    function(contacts_all_json) {
                    console.log(new Date()+"\t getMobileContacts got the contacts_all_json");

                    contacts_all_json = escape(contacts_all_json).replace(/%0A/g, "");
                    contacts_all_json = contacts_all_json.replace(/%0D/g, "");
                    contacts_all_json = unescape(contacts_all_json);

                    console.log(new Date()+"\t getMobileContacts got the contacts_all_json after removing special chars");
                    console.log(new Date()+"\t getMobileContacts size: "+contacts_all_json.length);

                    if(contacts_all_json != null && contacts_all_json.indexOf("session_expired") >= 0) {
                        window.location = "mobileregister_nc.html";
                    }

                    contacts_arr_all = JSON.parse(contacts_all_json);

                    console.log(new Date()+"\t getMobileContacts after JSON parsing");

                    if(contacts_arr_all == null || contacts_arr_all.length <= 0) {
                        $("#contacts_table_loading").hide();
                        $("#contacts_table_ref dl#loading_row_id").remove(); //remove the Loading symbol from UI

                        var no_contacts_html_1 = getNoContactsHTML();
                        $("#contacts_table_ref").last().append(no_contacts_html_1);

                        //No contact list found, do nothing
                        return;
                    }

                    var table_html = "";
                    var contacts_found = false;

                    $("#contacts_table_loading").hide();

                    console.log(new Date()+"\t Number of contacts loading...: "+contacts_arr_all.length);

                    for(var cnt = 0; cnt < contacts_arr_all.length; cnt++) {
                        try {
                            var from_user_id = contacts_arr_all[cnt].from_user_id;
                            var contact_user_id = contacts_arr_all[cnt].contact_user_id;
                            var name = contacts_arr_all[cnt].dec_name;
                            var rs_id = contacts_arr_all[cnt].rs_id;
                            var mobile = contacts_arr_all[cnt].dec_mobile;
                            var img_name_withpath = contacts_arr_all[cnt].img_name_withpath;

                            var row_html = getRowHTMLHR(from_user_id, contact_user_id, name, mobile, rs_id, cnt, img_name_withpath);

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

                        console.log(new Date()+"\t contacts_arr_all before table_html");

                        $("#contacts_table_ref").last().append(table_html);

                        console.log(new Date()+"\t contacts_arr_all after table_html");
                        getinviteStaus();                                               // method calling for showing invite status
                        getAddEmployeeStaus();                                               // method calling for showing invite status
                    }
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
    function getRowHTMLHR(from_user_id, contact_user_id, name, mobile, rs_id, contact_index, img_name_withpath) {
        var dl_id_first_char = name.substring(0,1).toUpperCase();

        var row_html = "";
        if(dl_id !== dl_id_first_char) {
            dl_id = dl_id_first_char;
            $('#'+dl_id).remove();
            row_html += "<div style='display:hidden' id='"+dl_id+"'></div>"
        }

        row_html += "<dl class = 'contact_list' name = '"+name+"' id='"+contact_user_id+"' style='padding:0px; width: 98%'>" +
            "           <dd class='pos-left clearfix' style='margin-bottom:0px'>" +
            "              <div class='events' style='margin-top:3px;line-height:1.0;background-color:#ffffff; box-shadow: 0.09em 0.09em 0.09em 0.05em #888888; display:inline-block; padding: 10px 0px 0px 10px;'>" +
            "                   <p class='pull-left' style='margin-left:-3px;margin-bottom: 0px'> " +
            "                       <img class='img-circle' style='max-width:40px' src='user_contact_images/"+img_name_withpath+"' onError='this.onerror=null;this.src=\"user_contact_images/profile.jpg\"' class='events-object img-rounded'>" +
            "                   </p>"+
            "                      <div class='events-body ' style='margiun-right:0px;'>" +
            "                           <div align='left' class='pull-left' style='width:80%;margin-bottom:2px; margin-left: 6px; margin-top: 2px;'>   " +
            "                               <h2 id='"+contact_user_id+"_contactname' style='margin-top:5px;margin-bottom:3px;font-size:15px;display:inline'>"+name+"</h2>"+
            "                               <h2 style='margin-left: -6px;'>" +
            "                                   <button data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"editContactForm('"+rs_id+"', '"+contact_user_id+"','"+contact_index+"');\" >" +
            "                                       <i class='fa fa-edit' style='color:#F6BB42'></i>" +
            "                                   </button>" +
            "                                   <button data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"getContactDetailsToDelete('"+rs_id+"','"+contact_user_id+"','"+contact_index+"');\" >" +
            "                                       <i class='fa fa-times' style='color: #ff6666'></i>" +
            "                                   </button>" +
            "                                   <button id='addemployee_"+rs_id+"' data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"addAsEmployee('"+rs_id+"', '"+name+"',"+contact_user_id+");\">" +
            "                                       <i class='fa fa-user-plus' style='color: #22A7F0'></i>" +
            "                                   </button>" +
            "                                   <button id='addemployeesuccess_"+rs_id+"' data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%; display:none' onclick=\"removeAsEmployee('"+rs_id+"', '"+name+"',"+contact_user_id+");\">" +
            "                                       <i class='fa fa-user-plus' style='color: #12B812'></i>" +
            "                                   </button>" +
            "                                   <button id='invite_"+rs_id+"' data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"sendAPPInvite('"+rs_id+"', '"+contact_user_id+"', '"+name+"');\">" +
            "                                       <i class='fa fa-envelope-o' style='color: #22A7F0'></i>" +
            "                                   </button>" +
            "                                   <button id='invitesuccess_"+rs_id+"' data-toggle='modal' type='button' class='btn btn-primary btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%; display:none' onclick=\"sendAPPInvite('"+rs_id+"', '"+contact_user_id+"', '"+name+"');\">" +
            "                                       <i class='fa fa-envelope-o' style='color: #12B812'></i>" +
            "                                   </button>" +
            "                                   <button  data-toggle='modal' type='button' class='btn btn-default btn-simple btn-lg  text-center' style='padding: 8px 10px 0px 10px; background-color:#ffffff;margin-top: 1%' onclick=\"openContactProfilePage('"+name+"',"+contact_user_id+")\" >" +
            "                                       <i class='fa fa-share' style='color:#22A7F0'></i>" +
            "                                   </button>" +
            "                               </h2>" +
            "                            </div>" +
            "                        </div>" +
            "                 </div>" +
            "               </dd>" +
            "           </dl>";
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
                    var rs_id = contacts_arr_all[cnt_all].rs_id;
                    var mobile = contacts_arr_all[cnt_all].dec_mobile;
                    var img_name_withpath = contacts_arr_all[cnt_all].img_name_withpath;

                    if(name.toLowerCase().indexOf(typed_string.toLowerCase()) >= 0) {
//                    console.log("name: "+name+", typed_string: "+typed_string);

                        var row_html = getRowHTMLHR(from_user_id, contact_user_id, name, mobile, rs_id, cnt_all, img_name_withpath);

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
        getinviteStaus();                                               // method calling for showing invite status
        getAddEmployeeStaus();                                          // method calling for showing add employee status
    };

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

    window.sendAPPInvite = function(rs_id, contact_user_id, contact_name) {
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

                    $("#contact_page_status_info").html("<div class='alert alert-success' style='padding: 20px 0px 10px 10px;'>Successfully invited "+contact_name+" <a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
                    $("#contact_page_status_info").show();
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
            "           <br><center>Refer - To be implemented</center><br>" +
            "       </div>" +
            "   </div>" +
            "</div>";
        $("#share_contact_form").html(msg);
        $("#click_to_display_share_form").click();
    };

    window.shareContactForm = function(contact_user_id) {
        var contact_name = $("#"+contact_user_id+"_contactname").html().trim();

        $("#contact_page_status_info").html("<div class='alert alert-danger' style='padding: 20px 0px 10px 10px;'>Refer - To be implemented<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
        $("#contact_page_status_info").show();
    };

    window.contactProfessional = function(event) {
        console.log(event.clientY);
        $("#contact_professional_info").html("<div class='alert alert-danger'>To be implemented<a href='#' class='custom_close' data-dismiss='alert' aria-label='close'>&times;</a>");
        $("#contact_professional_info").show();
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
        $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id+" img").removeAttr("src").attr("src","images/broadcast_success.png");

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
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id+" img").removeAttr("src").attr("src","images/broadcast_success.png");
                } else {
                    //DO NOTHING
                    $("#"+broadcast_ask_path+"_"+activity_id+"_"+owner_id+" img").removeAttr("src").attr("src","images/broadcast.png");
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

    window.postResponseToAsk = function(activity_id) {
        var optionVal = $('#post_comment_in_network').val().trim();
      
        $.ajax({
            type:         "post",
            url:          "action/post_response_to_ask.jsp",
            data:          "&comments="+optionVal+
                "&activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null && msg.indexOf("success") >= 0) {
                    $(post_comment_in_network).val('');
                    showAskResponses(activity_id);
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
                    $("#show_ask_responses_"+activity_id+"").html(msg);
                } else {
                    //DO NOTHING
                }
            }
        });

        $('#network').hide();
        $('#postresponse').show();
        $('#show_ask_responses').show();
    };
    window.showmypost = function (activity_id) {
        $.ajax({
            type:         "post",
            url:         "action/load_mypost.jsp",
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#display_post").html(msg);
                    showAskResponses(activity_id);
                } else {
                    //DO NOTHING
                }
            }
        });

        $('#network').hide();
        $('#display_post').show();
    };

    window.showpost = function (activity_id) {
        $.ajax({
            type:         "post",
            url:         "action/load_post.jsp",
            data:         "activity_id="+activity_id,

            success:    function(msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if(msg != null && msg.indexOf("session_expired") >= 0) {
                    window.location = "mobileregister_nc.html";
                } else if(msg != null) {
                    $("#display_post").html(msg);
                    showAskResponses(activity_id);

                } else {
                    //DO NOTHING
                }
            }
        });

        $('#network').hide();
        $('#display_post').show();
    };

    window.hideAskResponses = function(activity_id)  {
        $('#postresponse').hide();
        $('#show_ask_responses').hide();
        $('#display_post').hide();
        $('#network').show();
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

                            if (invitation_status == 1) {
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
    };

    window.getAddEmployeeStaus = function() {
        $.ajax({
            type: "post",
            url: "action/get_add_employee_status.jsp",

            success: function (msg) {
                msg = escape(msg).replace(/%0A/g, "");
                msg = msg.replace(/%0D/g, "");
                msg = unescape(msg);

                if (msg == null || msg.length <= 0) {
                    // DO NOTHING
                } else {
                    var invite_status = JSON.parse(msg);

                    for(var cnt = 0; cnt < invite_status.length; cnt++) {
                        try {
                            var from_user_id = invite_status[cnt].from_user_id;
                            var employee_userId = invite_status[cnt].employee_id;
                            var active_status = invite_status[cnt].active_status;
                            var rs_id = invite_status[cnt].rs_id;

                            if (active_status == 1) {
                                $("#addemployee_"+rs_id).css("display", "none");
                                $("#addemployeesuccess_"+rs_id).css("display", "");
                            }
                        } catch (error) {
                            console.log(error);
                            continue;
                        }
                    }
                }
            }
        });
    };

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

function showcommentbox(){
    $("#commentbox").show();
    $("#show_comment").hide();
}