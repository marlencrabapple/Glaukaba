$(document).ready(function() {
	// I have no idea what this is.
	$(".moveButton").click(function () {
		var toBeOpened = $(this).attr("id");
		$("#"+toBeOpened+"Div").show("slide", { direction: "up" }, 500);
	});
	
	$("#managerBoardList").children().each(function(option){
		if($(this).text()=="Boards"){
			$("#managerBoardList").prop("selectedIndex",$(this).prop("index"));
		}
	});
});

function addBan(board,ip,admin){
	var reason=prompt("Give a reason for this ban:");
	if(reason) document.location="http://"+window.location.hostname+"/"+board+"/"+'wakaba.pl?task=addip&ip='+ip+'&type=ipban'+'&admin='+admin+"&comment="+encodeURIComponent(reason);
	return false;
}