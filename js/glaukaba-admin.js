$(document).ready(function() {	
	$("#managerBoardList").children().each(function(option){
		if($(this).text()=="Boards"){
			$("#managerBoardList").prop("selectedIndex",$(this).prop("index"));
		}
	});
});