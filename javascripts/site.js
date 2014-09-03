function setCurrentPageLinksActive() {
	var curPage = document.URL;
	
	var lastSeparator = curPage.lastIndexOf("/");
	if (lastSeparator != -1) {
		curPage = curPage.substring(lastSeparator + 1);
	}
	
	var hashTag = curPage.indexOf("#");
	if (hashTag != -1) {
		curPage = curPage.substring(0, hashTag - 1);
	}
	
	if (curPage == '') {
		$(".nav > li > a[href='index.html']").parent().addClass('active');
	}
	else {
		$(".nav > li > a[href='" + curPage + "']").each(function() {
			$(this).parent().addClass('active');
		});
	}
}

$(document).ready(function() {
	setCurrentPageLinksActive();
});