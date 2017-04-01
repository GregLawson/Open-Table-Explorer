$(document).ready(function(){
	
	$(".cfinder").click(function(){
		loadChannelFinder();
	});	
	
	if(channelfinder==1){
	   loadChannelFinder();
	}
	
	loadSourceInfo();
	
});


function loadChannelFinder(){
	$.fancybox.open({ href:site_url+'callbacks/channelfinder.php',
				  type:'iframe',
				  width:240,
				  height:450});	
}

function loadSourceInfo(){
	var hash_source_path = window.location.hash;
		hash_source_path = hash_source_path.replace("#","");
	if(hash_source_path.length>1 || source_path.length>1){
		var keyword = (source_path.length > 1) ? source_path : hash_source_path ;
	
		$.post(site_url+'assets/ajax/load_source_info.php',{ keyword: keyword },function(response) {
					if(response.status==1){
						$('#source_banner_content').html(response.text); //add content to div
						$.fancybox.open({'href':'#source_banner'});		
		
				}
		});	
		
	}
}

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function getCookie(name) {
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    }
    else
    {
        begin += 2;
        var end = document.cookie.indexOf(";", begin);
        if (end == -1) {
        end = dc.length;
        }
    }
    return unescape(dc.substring(begin + prefix.length, end));
} 
