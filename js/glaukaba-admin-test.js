$(document).ready(function() {
	$("#reportQueueButton").click(function () {
		if(document.getElementById("reportQueue").style.display=="none"){
			$("#reportsContainer").load("reports.html");
			$("#reportQueue").show("slide", { direction: "right" }, 500);
			$("#reportsContainer").animate({ scrollTop: $("#reportsContainer").attr("scrollHeight") }, 500);
			document.getElementById("reportsContainer").style.height = ($(window).height()- 120) +"px";
		}
		else{
			$("#reportQueue").hide("slide", { direction: "right" }, 500);
		}
	});
	
	$("#closeReportQueue").click(function () {
		$("#reportQueue").hide("slide", { direction: "right" }, 500);
	});
	
	$("#refreshReportsButton").click(function () {
		$("#reportsContainer").load("reports.html");
	});
	
	$(".moveButton").click(function () {
		var toBeOpened = $(this).attr("id");
		$("#"+toBeOpened+"Div").show("slide", { direction: "up" }, 500);
	});
});

function addBan(board,ip,admin){
	//var banReasonWindow = window.open('http://'+window.location.hostname+"/"+board+"/"+'wakaba.pl?task=addip&ip='+ip+'&type=ipban'+'&admin='+admin,'', 'width=400px,height=210px,scrollbars=no');
	var reason=prompt("Give a reason for this ban:");
	if(reason) document.location="http://"+window.location.hostname+"/"+board+"/"+'wakaba.pl?task=addip&ip='+ip+'&type=ipban'+'&admin='+admin+"&comment="+encodeURIComponent(reason);
	return false;
}