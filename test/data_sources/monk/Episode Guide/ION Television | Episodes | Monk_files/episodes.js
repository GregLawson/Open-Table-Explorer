
function collapseMenu() {
    
	if ($(window).width() < 767){
		$("#vault-menu").removeClass('in');
	}
	if ($(window).width() >= 767){
	 	$("#vault-menu").removeAttr('style');
		$("#vault-menu").addClass('in');
	}
};

$(window).load(function() {
      collapseMenu()
});

var resizeTimer;
$(window).resize(function() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(collapseMenu, 100);
});