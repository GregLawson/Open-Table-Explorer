var nitroProtocol="http";if(document.location.toString().indexOf("https://")!=-1){nitroProtocol="https"}if(typeof nitroLibsVersion=="undefined"){nitroLibsVersion="current"}Nitro_Widget=function(){this.embedNames=new Array();this.loadedLocales={}};Nitro_Widget.prototype.embed=function(c,b){if(b==null){}b.version=nitroLibsVersion;if(typeof b.wmode=="undefined"||b.wmode==null){if(b.transparent=="true"){b.wmode="transparent"}else{b.wmode="opaque"}}switch(c.toUpperCase()){case"AVATAR":this.embedAvatar(b);break;case"AVATAR_REDESIGN":this.embedAvatarRedesign(b);break;case"AVATAR_VIEWER":this.embedAvatarViewer(b);break;case"CANVAS":this.embedCanvas(b);break;case"COOKIES":this.embedCookies(b);break;case"TROPHIES":this.embedTrophies(b);break;case"POKER":this.embedPoker(b);break;case"SOCIALLINK_BROADCASTER":this.embedSocialLinkBroadcaster(b);break;case"SOCIALLINK_CONNECTOR":this.embedSocialLinkConnector(b);break;case"STAR_RATING":this.embedStarRating(b);break;case"TRIVIA":this.embedTrivia(b);break;case"TRIVIA_SUBMIT":this.embedTriviaSubmit(b);break;case"WELCOME_WAGON":this.loadHTML5Widget(this.embedWelcomeWagon,b);break;case"DOUBLE_OR_NOTHING":this.loadHTML5Widget(this.embedDoubleOrNothing,b);break;case"STORE":this.loadHTML5Widget(this.embedStore,b);break;case"MINI_PROFILE":this.loadHTML5Widget(this.embedMiniProfile,b);break;case"MISSIONS":this.loadHTML5Widget(this.embedMissions,b);break;case"LEADERBOARD":this.loadHTML5Widget(this.embedLeaderboard,b);break;case"MOBILE_MISSIONS":var a=document.getElementById(b.divId);a.innerHTML="";this.loadHTML5Widget(this.embedMobileMissions,b);this.loadHTML5Widget(this.embedMobileStatus,b);break;case"MOBILE_STORE":var a=document.getElementById(b.divId);a.innerHTML="";this.loadHTML5Widget(this.embedMobileStatus,b);this.loadHTML5Widget(this.embedMobileStore,b);break;case"MOBILE_STATUS":var a=document.getElementById(b.divId);a.innerHTML="";this.loadHTML5Widget(this.embedMobileStatus,b);break;case"TROPHY_CASE":this.loadHTML5Widget(this.embedTrophyCase,b);break;case"NEWS_FEED":this.loadHTML5Widget(this.embedNewsFeed,b);break}};Nitro_Widget.prototype.welcomeWagonCSS=false;Nitro_Widget.prototype.doubleOrNothingCSS=false;Nitro_Widget.prototype.storeCSS=false;Nitro_Widget.prototype.miniProfileCSS=false;Nitro_Widget.prototype.missionsCSS=false;Nitro_Widget.prototype.leaderboardCSS=false;Nitro_Widget.prototype.trophyCaseCSS=false;Nitro_Widget.prototype.newsFeedCSS=false;Nitro_Widget.prototype.coreCSS=false;Nitro_Widget.prototype.welcomeWagonJS=false;Nitro_Widget.prototype.doubleOrNothingJS=false;Nitro_Widget.prototype.storeJS=false;Nitro_Widget.prototype.miniProfileJS=false;Nitro_Widget.prototype.missionsJS=false;Nitro_Widget.prototype.leaderboardJS=false;Nitro_Widget.prototype.trophyCaseJS=false;Nitro_Widget.prototype.newsFeedJS=false;Nitro_Widget.prototype.coreJS=false;Nitro_Widget.prototype.embedAvatar=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/avatar/"+b.version+"/";var c=d+"AvatarCatalog.swf?version=2";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroAvatar",name:"nitroAvatar"};this.embedNames.push(a.id);b.servers=b.server;b.uploadURL=b.server.replace("api","avatar");this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedAvatarRedesign=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/avatarRedesign/"+b.version+"/";var c=d+"AvatarWidget.swf?version=2";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroAvatarRedesign",name:"nitroAvatarRedesign"};this.embedNames.push(a.id);b.servers=b.server;b.uploadURL=b.server.replace("api","avatar");this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedAvatarViewer=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/avatarviewer/"+b.version+"/";var c=d+"AvatarViewer.swf?version=1";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroAvatarViewer",name:"nitroAvatarViewer"};this.embedNames.push(a.id);b.servers=b.server;this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedCanvas=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/canvas/"+b.version+"/";var c=d+"CanvasWidget.swf?version=1";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroCanvas",name:"nitroCanvas"};this.embedNames.push(a.id);b.servers=b.server;b.uploadURL=b.server.replace("api","avatar");this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedCookies=function(b){var d=nitroProtocol+"://assets.bunchball.net/scripts/cookies/"+b.version+"/";var c=d+"NitroCookies.swf?force=1";var e={base:d,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroCookies",name:"nitroCookies"};this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedTrophies=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/trophies/"+b.version+"/";var c=d+"TrophyCaseApplication.swf?version=2";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroTrophies",name:"nitroTrophies"};this.embedNames.push(a.id);this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedPoker=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/poker/"+b.version+"/";var c=d+"PokerLobby.swf?version=2";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroPoker",name:"nitroPoker"};this.embedNames.push(a.id);this.embedSWF(c,b.divId,"600","500",b,e,a)};Nitro_Widget.prototype.embedTrivia=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/trivia/"+b.version+"/";var c=d+"trivia.swf";b.userId=b.viewerId;var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all"};var a={id:"nitroTrivia",name:"nitroTrivia"};this.embedNames.push(a.id);this.embedSWF(c,b.divId,b.width,b.height,b,e,a)};Nitro_Widget.prototype.embedTriviaSubmit=function(f){var a=f.triviaServer+f.siteId+"/html/index.php?";f.userId=f.viewerId;var h="";for(var d in f){h+="&"+d+"="+escape(f[d])}var c="600";if(f.width){c=f.width}var j="800";if(f.height){j=f.height}var e="<iframe src='"+a+h+"' width='"+c+"' height='"+j+"' marginwidth='0' marginheight='0' align='middle' border='0' frameborder='0'></iframe>";var b=document.getElementById(f.divId);var g=document.createElement("div");g.innerHTML=e;b.parentNode.replaceChild(g,b)};Nitro_Widget.prototype.embedSocialLinkBroadcaster=function(b){var f=document.getElementById(b.divId);var d=document.createElement("div");d.id="nitro_statusUpdater";d.style.background="url("+nitroProtocol+"://assets.bunchball.net/widgets/embed/"+b.version+"/SocialLinkBroadcaster/twitterFb_widget_bkgd_logos_text.png) no-repeat";d.style.width="300px";d.style.height="250px";d.style.position="relative";var e=document.createElement("div");e.id="nitro_statusUpdater_twitter";e.style.background="url("+nitroProtocol+"://assets.bunchball.net/widgets/embed/"+b.version+"/SocialLinkBroadcaster/twitter_on_off.png) no-repeat 40px 0px";e.style.width="80px";e.style.height="25px";e.style.position="absolute";e.style.top="195px";e.style.left="175px";e.style.cursor="pointer";var a=document.createElement("div");a.id="nitro_statusUpdater_facebook";a.style.background="url("+nitroProtocol+"://assets.bunchball.net/widgets/embed/"+b.version+"/SocialLinkBroadcaster/Fb_on_off.png) no-repeat 40px 0px";a.style.width="80px";a.style.height="25px";a.style.position="absolute";a.style.top="135px";a.style.left="175px";a.style.cursor="pointer";var c=document.createElement("div");c.style.position="absolute";c.style.bottom="5px";c.style.right="15px";c.style.width="120px";c.style.height="15px";c.style.cursor="pointer";c.style.backgroundColor="transparent";c.onclick=function(){window.open("http://apps.facebook.com/sociallink_broadcast/")};d.appendChild(e);d.appendChild(a);d.appendChild(c);f.parentNode.replaceChild(d,f);Nitro.callAPI("method=user.twitter.status","Nitro.updateTwitterSettings",b.nitroInstanceId);Nitro.callAPI("method=user.facebook.status","Nitro.updateFacebookSettings",b.nitroInstanceId)};Nitro_Widget.prototype.embedSocialLinkConnector=function(a){nitroWidgetSLCArgs=a;var b=document.getElementsByTagName("head").item(0);var c=document.createElement("script");c.setAttribute("language","javascript");c.setAttribute("type","text/javascript");c.setAttribute("src",nitroProtocol+"://assets.bunchball.net/scripts/connector/"+a.version+"/NitroSocialLinkConnector.js");b.appendChild(c)};Nitro_Widget.prototype.embedStarRating=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/StarRating/"+b.version+"/";var c=d+"StarRating.swf";var e={base:d,wmode:b.wmode,allowscriptaccess:"always",allownetworking:"all",bgcolor:b.backgroundColor.replace(/0x/,"#")};b.server=escape(b.server);var a={id:"nitroStarRating_"+b.divId,name:"nitroStarRating_"+b.divId};this.embedNames.push(a.id);this.embedSWF(c,b.divId,"175","60",b,e,a)};Nitro_Widget.prototype.embedWelcomeWagon=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("welcomeWagon/"+b.version+"/nitro.wdgt.welcomewagon.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.welcomeWagonCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.ie.css":""))}else{if(nitroWidget.welcomeWagonCSS===false){nitroWidget.welcomeWagonCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.welcomeWagonJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.welcomeWagon();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.js"}else{if(nitroWidget.welcomeWagonJS===false){a="widgets/HTML5Widgets/welcomeWagon/"+b.version+"/nitro.widget.welcomewagon.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedDoubleOrNothing=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("doubleOrNothing/"+b.version+"/nitro.wdgt.doubleornothing.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.doubleOrNothingCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.ie.css":""))}else{if(nitroWidget.doubleOrNothingCSS===false){nitroWidget.doubleOrNothingCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.doubleOrNothingJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.doubleOrNothing();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.js"}else{if(nitroWidget.doubleOrNothingJS===false){a="widgets/HTML5Widgets/doubleOrNothing/"+b.version+"/nitro.widget.doubleornothing.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedStore=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("store/"+b.version+"/nitro.wdgt.store.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.storeCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.ie.css":""))}else{if(nitroWidget.storeCSS===false){nitroWidget.storeCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.storeJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.store();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.js"}else{if(nitroWidget.storeJS===false){a="widgets/HTML5Widgets/store/"+b.version+"/nitro.widget.store.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedMobileStore=function(a){var b=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("mobile-store/"+a.version+"/nitro.wdgt.mobile.store.static.html");if(nitro$(".nitro-widget").length==0){nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,widgets/HTML5Widgets/common/css/nitro.widget.mobile.css,widgets/HTML5Widgets/mobile-store/"+a.version+"/nitro.widget.mobile.store.css")}else{nitroWidget.loadHTML5Style("widgets/HTML5Widgets/mobile-store/"+a.version+"/nitro.widget.mobile.store.css")}nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files=widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/mobile-store/"+a.version+"/nitro.widget.mobile.store.js",function(){nitro$.ajax({url:b,dataType:"jsonp",success:function(d){var c=document.getElementById(a.divId);nitro$(c).append(d.html);nitro$(function(){var e=new nitro_html_widget.mobileStore();e.init(Nitro.getInstanceForCounter(0),a)})}})})};Nitro_Widget.prototype.embedMiniProfile=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("miniProfile/"+b.version+"/nitro.wdgt.miniprofile.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.miniProfileCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/miniProfile/"+b.version+"/nitro.widget.miniprofile.css")}else{if(nitroWidget.miniProfileCSS===false){nitroWidget.miniProfileCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/miniProfile/"+b.version+"/nitro.widget.miniprofile.css")}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.miniProfileJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.miniProfile();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/miniProfile/"+b.version+"/nitro.widget.miniprofile.js"}else{if(nitroWidget.miniProfileJS===false){a="widgets/HTML5Widgets/miniProfile/"+b.version+"/nitro.widget.miniprofile.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedMobileStatus=function(a){var b=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("mobile-status/"+a.version+"/nitro.wdgt.mobile.status.static.html");if(nitro$(".nitro-widget").length==0){nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,widgets/HTML5Widgets/common/css/nitro.widget.mobile.css,widgets/HTML5Widgets/mobile-status/"+a.version+"/nitro.widget.mobile.status.css")}else{nitroWidget.loadHTML5Style("widgets/HTML5Widgets/mobile-status/"+a.version+"/nitro.widget.mobile.status.css")}nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files=widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/mobile-status/"+a.version+"/nitro.widget.mobile.status.js",function(){nitro$.ajax({url:b,dataType:"jsonp",success:function(d){var c=document.getElementById(a.divId);nitro$(c).prepend(d.html);nitro$(function(){var e=new nitro_html_widget.mobileStatus();e.init(Nitro.getInstanceForCounter(0),a)})}})})};Nitro_Widget.prototype.embedMissions=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("missions/"+b.version+"/nitro.wdgt.missions.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.missionsCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.ie.css":""))}else{if(nitroWidget.missionsCSS===false){nitroWidget.missionsCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.missionsJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.missions();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.js"}else{if(nitroWidget.missionsJS===false){a="widgets/HTML5Widgets/missions/"+b.version+"/nitro.widget.missions.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedMobileMissions=function(a){var b=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("mobile-missions/"+a.version+"/nitro.wdgt.mobile.missions.static.html");if(nitro$(".nitro-widget").length==0){nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,widgets/HTML5Widgets/common/css/nitro.widget.mobile.css,widgets/HTML5Widgets/mobile-missions/"+a.version+"/nitro.widget.mobile.missions.css")}else{nitroWidget.loadHTML5Style("widgets/HTML5Widgets/mobile-missions/"+a.version+"/nitro.widget.mobile.missions.css")}nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files=widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/mobile-missions/"+a.version+"/nitro.widget.mobile.missions.js",function(){nitro$.ajax({url:b,dataType:"jsonp",success:function(d){var c=document.getElementById(a.divId);nitro$(c).append(d.html);nitro$(function(){var e=new nitro_html_widget.mobileMissions();e.init(Nitro.getInstanceForCounter(0),a)})}})})};Nitro_Widget.prototype.embedLeaderboard=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("leaderboard/"+b.version+"/nitro.wdgt.leaderboard.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.leaderboardCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.ie.css":""))}else{if(nitroWidget.leaderboardCSS===false){nitroWidget.leaderboardCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.leaderboardJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.leaderboard();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.js"}else{if(nitroWidget.leaderboardJS===false){a="widgets/HTML5Widgets/leaderboard/"+b.version+"/nitro.widget.leaderboard.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedTrophyCase=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("trophyCase/"+b.version+"/nitro.wdgt.trophycase.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.trophyCaseCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.ie.css":""))}else{if(nitroWidget.trophyCaseCSS===false){nitroWidget.trophyCaseCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.trophyCaseJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.trophyCase();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.js"}else{if(nitroWidget.trophyCaseJS===false){a="widgets/HTML5Widgets/trophyCase/"+b.version+"/nitro.widget.trophycase.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.embedNewsFeed=function(b){var d=nitroProtocol+"://assets.bunchball.net/widgets/HTML5Widgets/common/serve/widget.php?page="+escape("newsFeed/"+b.version+"/nitro.wdgt.newsfeed.static.html");if(nitroWidget.coreCSS===false){nitroWidget.coreCSS=true;nitroWidget.newsFeedCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/common/css/nitro.widget.reset.css,widgets/HTML5Widgets/common/css/nitro.widget.core.css,"+((nitro$.browser.msie)?"widgets/HTML5Widgets/common/css/nitro.widget.core.ie.css,":"")+"widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.ie.css":""))}else{if(nitroWidget.newsFeedCSS===false){nitroWidget.newsFeedCSS=true;nitroWidget.loadHTML5Style("widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.css"+((nitro$.browser.msie)?",widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.ie.css":""))}}var c=function(){nitro$.ajax({url:d,dataType:"jsonp",success:function(f){nitroWidget.coreJS=true;nitroWidget.newsFeedJS=true;var e=document.getElementById(b.divId);e.innerHTML=f.html;nitro$(function(){var g=new nitro_html_widget.newsFeed();g.init(Nitro.getInstanceForCounter(0),b)})}})};var a="";if(nitroWidget.coreJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.core.js,widgets/HTML5Widgets/common/js/nitro.widget.date.js,widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.js"}else{if(nitroWidget.newsFeedJS===false){a="widgets/HTML5Widgets/common/js/nitro.widget.date.js,widgets/HTML5Widgets/newsFeed/"+b.version+"/nitro.widget.newsfeed.js"}}if(a.length==0){c()}else{nitroWidget.loadScript(nitroProtocol+"://assets.bunchball.net/combine.php?type=javascript&files="+a,c)}};Nitro_Widget.prototype.loadHTML5Widget=function(f,b){var a=this;var d=("abbr,article,aside,audio,canvas,datalist,details,figure,figcaption,footer,header,hgroup,mark,menu,meter,nav,output,progress,section,time,video").split(",");for(var c=0;c<d.length;c++){document.createElement(d[c])}if(typeof(window.html5)!="object"){}if(typeof bunchball_jQuery=="undefined"){this.loadScript(nitroProtocol+"://assets.bunchball.net/widgets/embed/"+nitroLibsVersion+"/lib/jquery.1.7.2.bunchball.js",function(){a.loadLocale(f,b)})}else{a.loadLocale(f,b)}};Nitro_Widget.prototype.loadLocale=function(c,b){var a=this;nitro$=bunchball_jQuery.noConflict();if(typeof b.locale!="undefined"&&b.locale!=""&&typeof a.loadedLocales[b.locale]=="undefined"){nitro$.ajax({url:nitroProtocol+"://assets.bunchball.net/scripts/locale/localeLoader.php?locale="+b.locale,dataType:"jsonp",success:function(d){a.loadedLocales[b.locale]=d;c(b)}})}else{c(b)}};Nitro_Widget.prototype.loadHTML5Style=function(b){var a=document.createElement("link");a.type="text/css";a.rel="stylesheet";a.href=nitroProtocol+"://assets.bunchball.net/combine.php?type=css&files="+b;document.getElementsByTagName("head")[0].appendChild(a)};Nitro_Widget.prototype.loadScript=function(b,c){var a=document.createElement("script");a.type="text/javascript";if(a.readyState){a.onreadystatechange=function(){if(a.readyState=="loaded"||a.readyState=="complete"){a.onreadystatechange=null;c()}}}else{a.onload=function(){c()}}a.src=b;document.getElementsByTagName("head")[0].appendChild(a)};Nitro_Widget.prototype.embedSWF=function(h,d,f,b,c,g,e){if(typeof swfobject=="undefined"){var a=this;setTimeout(function(){a.embedSWF(h,d,f,b,c,g,e)},10);return}c.ownerId=encodeURIComponent(c.ownerId);c.viewerId=encodeURIComponent(c.viewerId);swfobject.embedSWF(h,d,f,b,"9.0.0",null,c,g,e)};Nitro_Widget.prototype.merge=function(c,b){for(var a in b){c[a]=b[a]}return c};var nitroWidget=new Nitro_Widget();if(typeof swfobject=="undefined"){nitroWidget.loadScript(nitroProtocol+"://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js",function(){})}var nitroWidgetSLCArgs;var nitro$;