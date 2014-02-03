// AC's general js store
// shop around!

// used to show and hide the seasons on episodes
function showSeason(season){
	$( '#season-episode-'+season).toggle('slow');
	$( '#season-'+season).toggleClass('selected');
}

function testFunc(metaValue){
	logNitroAction('SHOW_FAVORITE', metaValue);
}

// These are our favorites
function episodeFavorite(eventObj){
	logNitroAction('EPISODE_FAVORITE');
}

function gameFavorite(eventObj){
	logNitroAction('GAME_FAVORITE');
}

function showFavorite(eventObj){
	logNitroAction('SHOW_FAVORITE');
	if (eventObj['context'] != '') {
		 try {
		 	_gaq.push(['_trackEvent', 'Favorite Shows', 'favorite', eventObj['context'], 1, true]);
		} catch(e) {}
	}
}

function movieFavorite(eventObj){
	logNitroAction('MOVIE_FAVORITE');
}

function holidayFavorite(eventObj){
	logNitroAction('HOLIDAY_FAVORITE');
}

// I'm watching you!
function imWatchingEpisode(eventObj){
		logNitroAction('EPISODE_CHECKIN');
}

function imWatchingMovie(eventObj){
		logNitroAction('MOVIE_CHECKIN');
}

function imWatchingHoliday(eventObj){
		logNitroAction('HOLIDAY_CHECKIN');
}

// TODOL: ADD MOVIE CHECKIN

// Share with the world my child!
function shareEpisode(eventObj){
		logNitroAction('EPISODE_SHARE');
}

function shareGame(eventObj){
		logNitroAction('GAME_SHARE');
}

function shareMovie(eventObj){
		logNitroAction('MOVIE_SHARE');
}

function shareHoliday(eventObj){
		logNitroAction('SHARE_HOLIDAY');
}

function shareHolidayContest(eventObj){
		logNitroAction('SHARE_HOLIDAY_CONTEST');
}

function shareAvatar(eventObj){
		logNitroAction('USR_SHARE_AVATAR');
}

// Comments
function episodeComment(eventObj){
		logNitroAction('EPISODE_COMMENT_WRITE');
}

function holidayComment(eventObj){
		logNitroAction('EPISODE_COMMENT');
}

function photoComment(eventObj){
		logNitroAction('EPISODE_PHOTO_COMMENT');
}

function gameComment(eventObj){
		logNitroAction('GAME_COMMENT');
}

// Holiday contest specific
function refreshHolidayContestPage(eventObj){
	location.reload();
}

// Lounge room
function loungeRoomFavorite(eventObj){
	logNitroAction('FAVORITE_LOUNGE_ROOM');	
}

function loungeRoomShare(eventObj){
	logNitroAction('SHARE_LOUNGE_ROOM');	
}

// Sponsor Vignette Specific 

function watchedSponsorVideo(eventObj){
		logNitroAction('WATCH_SPONSOR_VIDEO_TYSONS');
}
function shareSponsorVideo(eventObj){
		logNitroAction('SHARE_SPONSOR_VIDEO_TYSONS');
}