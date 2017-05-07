/**
 * JS bridge for BunchBall
 */

var apiKeyNitro = 'e5b43815f061450eaac4fb0eb4ec25d0';

var connectionParamsUser = {
	apiKey: apiKeyNitro,
	timeStamp: nitroTimestamp,
	signature: nitroSignature,
	userId: escape(nitroUID),
    server: nitroConnection,
	debug: false
};

var connectionParams = {
	apiKey: apiKeyNitro,
	debug: false
}

var sessionKey = '';
var pointsTotal = 0;

var nitro = new Nitro(connectionParamsUser);
nitro.refreshNML();
nitro.showPendingNotifications();

function errorHandlerNitro(errorMsg){
	alert(errorMsg.Nitro.Error.Message);
}

function loginNitro(userId, nickname){
	$.ajax({
		type: 'POST',
		url: site_url + 'ajax',
		data: 'mode=login&u=' + userId + '&n=' + nickname,
		success: function(msg){
		}
	});
}

function logNitroAction(tags){
	
	$.ajax({
		type: 'POST',
		url: site_url + 'ajax',
		data: 'mode=action&action='+tags,
		success: function(msg){
			//alert(msg);
			nitro.showPendingNotifications();
		}
	});
}