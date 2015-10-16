function setCurrentPageLinksActive() {
	var curPage = document.URL;
	
	var lastSeparator = curPage.lastIndexOf("/");
	if (lastSeparator != -1) {
		curPage = curPage.substring(lastSeparator + 1);
	}

	if (curPage != '' && curPage != 'index.html') {
		$('#main').toc();
	}
}

$(document).ready(function() {
	setCurrentPageLinksActive();
});