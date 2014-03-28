/**
 * Login
 */

var global_userid = ''; // not really used
var user_res;

var login_params=
{
	showTermsLink: 'false'
	,height: 29
	,width: 200
	,containerID: 'login-widget'
	,UIConfig: '<config><body><controls><snbuttons buttonsize="20" /></controls></body></config>'
	,autoDetectUserProviders: ''
	,facepilePosition: 'none'
	,showWhatsThis: 'false'
	,hideGigyaLink: 'true'
}

// event handlers

function register_gigya_events(){
	gigya.accounts.addEventHandlers({
		onLogin: onLoginHandler // A reference to a function that is called when the user is successfully logs in through Gigya
		,

		onLogout: onLogoutHandler // A reference to a function that is called when the user has logged out.
	});

}

/* PREVIOUS
function register_gigya_events(){
	gigya.services.socialize.addEventHandlers({
		onLogin: onLoginHandler // A reference to a function that is called when the user is successfully logs in through Gigya
		,
		onLogout: onLogoutHandler // A reference to a function that is called when the user has logged out.
	});
}

*/

function onLogoutHandler(eventObj) {
	// Site Logout
	try {
		$.post(site_url+"site-login", { "action" : "logoff" },
				function(data){ 
					location.reload();
				}
	 		, "json");
	}catch(e){}
}

function onLoginHandler(eventObj) {	
	try{    
	    $.post(site_url+"site-login", { "userObject": JSON.stringify(eventObj), "action" : "socialLogin" },
			function(data){ 	
				pUserObject = eventObj;
				switch(data.success)
				{
					case "ERROR":  // social login failure
						alert("Gigya Login error : " +  data.error);
					  	break;
					case "SUCCESS": //successfull social login
						location.reload(); // lets make sure we just reload the page, we need to reload because of BunchBall
					  	break;		  	
					case "NO ACCESS":
						location.href=site_url+'no-access';
					break;
					default:
						location.reload();
				}
			}
 		, "json");
	}catch(e){}			
}

function logoutUser() {
    gigya.services.socialize.logout();
}

/**
 * Social Follow
 */
var showFollowBarUI_params=
{ 
	containerID: 'social_links_container',
	iconSize: 32,
	buttons: [
	{ 
		provider: 'facebook',
		actionURL: 'http://www.facebook.com/IONTelevision',
		action: 'dialog'
	},
	{ 
		provider: 'twitter',
		action: 'dialog',
		followUsers: 'https://twitter.com/iontv'
	},
	{
		provider: 'custom',
		actionURL: 'http://getglue.com/tv_shows/ion_television',
		action: 'window',
		iconURL: site_url+'images/getglue-icon.png'
	}
	]
}

/** debug */

function __addDebug(debug){
	document.getElementById('debug').innerHTML += debug+'<br />';
}