function loadPanel(board){
	document.getElementById("panel").src = "http://glauchan.org/" + board + "/wakaba.pl?task=admin";
	document.getElementById("site").src = "http://glauchan.org/" + board + "/";
	document.getElementById("reportsFrame").src = "http://glauchan.org/" + board + "/reports.html";
}

function refreshReports(){
	document.getElementById("reportsFrame").src = document.getElementById("reportsFrame").src;
}

function toggleReportsView(){
	if (document.getElementById("reportsFrame").style.height == "200px"){
		document.getElementById("reportsFrame").style.height = "10px";
	}
	else{
		document.getElementById("reportsFrame").style.height = "200px";
	}
}

function togglePanelView(){
	if (document.getElementById("panelDiv").style.width == "49%"){
		document.getElementById("panelDiv").style.width = "40px";
		document.getElementById("panel").style.width = "40px";
		document.getElementById("siteDiv").style.width = (document.documentElement.clientWidth - 90) + "px";
		document.getElementById("site").style.width = (document.documentElement.clientWidth - 90) + "px";
		document.getElementById("panelDiv").childNodes[1].innerHTML = "&gt;&gt;"
	}
	else{
		document.getElementById("panelDiv").style.width = "49%";
		document.getElementById("panel").style.width = "100%";
		document.getElementById("siteDiv").style.width = "49%";
		document.getElementById("site").style.width = "100%";
		document.getElementById("panelDiv").childNodes[1].innerHTML = "&lt;&lt;"
	}
}

function toggleSiteView(){
	if (document.getElementById("siteDiv").style.width == "49%"){
		document.getElementById("siteDiv").style.width = "40px";
		document.getElementById("site").style.width = "40px";
		document.getElementById("panelDiv").style.width = (document.documentElement.clientWidth - 90) + "px";
		document.getElementById("panel").style.width = (document.documentElement.clientWidth - 90) + "px";
		document.getElementById("siteDiv").childNodes[1].innerHTML = "&lt;&lt;"
	}
	else{
		document.getElementById("siteDiv").style.width = "49%";
		document.getElementById("site").style.width = "100%";
		document.getElementById("panelDiv").style.width = "49%";
		document.getElementById("panel").style.width = "100%";
		document.getElementById("siteDiv").childNodes[1].innerHTML = "&gt;&gt;"
	}
}

function resizeTeamPanels(){
	document.getElementById('panel').style.height = (document.documentElement.clientHeight - 120) + "px";
	document.getElementById('site').style.height = (document.documentElement.clientHeight - 120) + "px";
}