$.fn.exists = function(){return this.length>0;}
var programid="";

function init_calendar_btns(){
	//calendar day is clicked
	$(".oneweek .day").click(function(){
		if(!$(this).hasClass("disabled")){
			$(".oneweek .day").removeClass("selected");
			$(this).addClass("selected");
			//update the week nav
			$("#programs").html("<div class='loader'></div>");
			
			var to_update = "current_day,week_nav,programs";
				  to_update += ($(".featured_block").length>=1)? ",featured_block":"";
			
			$.post(site_url+"assets/ajax/update_schedule.php", {selected_date:$(this).attr("day"),update:to_update} ,function(response){
				
				$("#current_day").html(response.current_day);
				$("#week_nav").replaceWith(response.week_nav);
				$("#programs").replaceWith(response.programs);
				if($(".featured_block").length>=1){
					$(".featured_block").replaceWith(response.featured_block);
				}
				 init_week_nav();
				 init_programs();
				
			});
		}
	});
	
	$(".oneweek .day").hover(function(){
		var navid = $(this).attr("id");
			  navid = navid.replace("cal_","nav_");
			  $("#"+navid).addClass("on");
	},function(){
			var navid = $(this).attr("id");
			  navid = navid.replace("cal_","nav_");
			  $("#"+navid).removeClass("on");
	});
}

function init_calendar(){
		
		//programid is only used if the programid of an episode is passed thru the URL
		
		$("#programs").html("<div class='loader'></div>");
		var to_update = "navcal,current_day,week_nav,programs";
		$.post(site_url+"assets/ajax/update_schedule.php",{programid:programid,update:to_update},function(response){
			$("#navcal").replaceWith(response.navcal);
			$("#current_day").html(response.current_day);
			$("#week_nav").replaceWith(response.week_nav);
			$("#programs").replaceWith(response.programs);
		
			init_calendar_btns();
			init_week_nav();
			init_programs();
			
			//if a program is highlighted onload. open popup  automatically [misc feature]
			if( typeof(onload_popup) != "undefined" && onload_popup.length>1 && onload_popup=="true") $(".highlight").trigger("click");
			
			$(".featured_popup").click(function(){
				var pgid = $(this).attr("programid");
				$("#"+pgid).find(".img-holder").addClass($(this).attr("show"));
				open_program_popup(pgid);
			});
			
			$(".video_link").click(function(){
				showVideoSpot($(this).attr("video_name"),$(this).attr("video_type"));
			});
			
			
		});
}

function init_week_nav(){

	//week nav day is clicked
	$(".sched-day-box").click(function(){
		if(!$(this).hasClass("disabled")){
			$(".sched-day-box").removeClass("selected");
				$(this).addClass("selected");
				var calid = $(this).attr("id");
					  calid = calid.replace("nav_","cal_");
					 // console.log(calid);
					 $(".oneweek .day").removeClass("selected");
					 $("#"+calid).addClass("selected");
					 $("#programs").html("<div class='loader'></div>");
					var to_update = "current_day,programs";
						  to_update += ($(".featured_block").length>=1)? ",featured_block":"";
		
					$.post(site_url+"assets/ajax/update_schedule.php", {selected_date:$(this).attr("day"),update:to_update} ,function(response){
				
						$("#current_day").html(response.current_day);
						$("#programs").replaceWith(response.programs);
						if($(".featured_block").length>=1){
							$(".featured_block").replaceWith(response.featured_block);
						}
						 init_programs();
				});			
			
		}
	});
	
	
	$(".sched-day-box").hover(function(){
		var calid = $(this).attr("id");
			  calid = calid.replace("nav_","cal_");
			  $("#"+calid).addClass("on");
	},function(){
			var calid = $(this).attr("id");
			  calid = calid.replace("nav_","cal_");
			  $("#"+calid).removeClass("on");
	});
	
}

function init_programs(){

	$(".sched_cols").click(function(){
			$(this).addClass("highlight");
			
			//get the show attribute of the div of class.sched_cols and add it 
			//to the div of class .programid content img-holder before
			// its entire html content is transfered over to the popup
			$(this).find(".img-holder").addClass($(this).attr("show"));
			
			var pgid = $(this).attr("programid");				
			open_program_popup(pgid);
	});
	
}


function open_program_popup(pgid){
	if($("#"+pgid).exists()){
		$("#program_popup").html( $("#"+pgid).html() );
		$.fancybox({
			'href'			: '#program_popup',
			'scrolling'     :  'no',
			'overlayOpacity':  0.2,
			'overlayShow'   :  true,
			'onStart'			  :function(){
				//check if the video is available on limelight before displaying the play button
				if(popupHasVideo()){
					showPopupVideoButton();
				}
				
			},		
			'onClosed'		: function() {		
				$('.sched_cols').removeClass("highlight");
			}
		});		
	}else{
		//load program popup
		//************************************
		$("#program_popup").html("");
		$.post(site_url+"assets/ajax/update_schedule.php", {update:"program_popup",programid:pgid} ,function(response){
			$("#program_popup").html(response.program_popup);
		});
		//************************************
		$.fancybox({
			'href'			: '#program_popup',
			'scrolling'     :  'no',
			'overlayOpacity':  0.2,
			'overlayShow'   :  true,
			'onStart'			  :function(){
				//check if the video is available on limelight before displaying the play button
				if(popupHasVideo()){
					showPopupVideoButton();
				}
				
			},		
			'onClosed'		: function() {		
				$('.sched_cols').removeClass("highlight");
			}
		});		
		
	}
	

	$(document).ready(function(){
	   // add drag and drop functionality to #box1
	   $("#fancybox-wrap").easydrag();
    });
}

function showPopupVideoButton(){
	//console.log($("#program_popup").find(".video_link").attr("filename"));
	$.post(site_url+"assets/ajax/video_exists.php", {type:"episodes",filename:$("#program_popup").find(".video_link").attr("filename")} ,function(response){
		if(response.status==1){
			$("#program_popup").find(".video_link").fadeIn();
		}
	});
}

function init_popup_showlink(){
	/* $(".popup_showlink").live("click",function(){
		parent.window.location = $(this).attr("url");	
	});*/	
}

function popupHasVideo(){
 return ($("#program_popup").find(".video_link").length>0) ? 1:0;
}

function showVideoSpot(video_name,video_type){
	
	   	$(document).ready(function(){
	
			 $.fancybox({
				'href'			:site_url+'assets/handler/flowplayer.php?type='+video_type+'&video_src='+video_name+'&width=687&height=374&autoplay=true&hidecontrols=false&autoclose=true&hideplaybutton=true',
				'type'			:'iframe',
				'transitionIn'	:'elastic',
				'transitionOut' :'elastic',
				'titlePosition' :'outside',
				'speedIn'		:600, 
				'speedOut'	    :200, 
				'width'	        :705,
				'height'        :390,
				'scrolling'     :'no',
				'showCloseButton':true,
				'overlayShow'	:true
			});
		});
}

//INIT CALENDAR
$(document).ready(function(){
	init_calendar();
	init_popup_showlink();
});


