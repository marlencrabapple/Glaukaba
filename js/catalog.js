var catItemTemplate=$("#catItem0").clone();
var ext=".html";
init(0,0);

function init(orderBy, searchTerms){
	$("#catItem0").remove();
	$(".catItem").remove();
	
	if(sitevars.noext==1){
		ext="";
	}
	
	// load json and build catalog items
	$(catalog.threads).each(function(index){
		var catItem=$(catItemTemplate).clone();
		var url=sitevars.boardpath+"res/"+this.no+ext;
		var sub="";
		
		if(!this.image){
			if(localStorage.getItem("thumbSize")=="small" || localStorage.getItem("thumbSize")==null){
				width=150;
				height=150;
			}
			else{
				width=250;
				height=250;
			}
			
			noFileImage=sitevars.domain+"img/nofile.png";
		}
		else{
			if(localStorage.getItem("thumbSize")=="small" || localStorage.getItem("thumbSize")==null){
				var width=this.tn_w*.6;
				var height=this.tn_h*.6;
			}
			else{
				var width=this.tn_w;
				var height=this.tn_h;
			}
			
			thumbUrl=sitevars.boardpath+this.image;
		}
		
		$(catItem).attr("id","catItem"+this.no);
		
		$(catItem).children("#catItemHoverLink0").attr("id","catItemHoverLink"+this.no);
		$(catItem).children("#catItemHoverLink"+this.no).attr("href",url);
		//$(catItem).children("#catItemLink"+this.no).attr("href",sitevars.boardpath+"res/"+this.no);
		
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover0").attr("id","catItemHover"+this.no);
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).width(width);
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).height(height);
		
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).children(".catItemHoverText").css("line-height",height+"px");
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).children(".catItemHoverText").width(width);
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).children(".catItemHoverText").height(height);
		$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).children(".catItemHoverText").html("&gt;&gt;"+this.no);
		
		$(catItem).children("#catItemImageLink0").attr("id","catItemImageLink"+this.no);
		$(catItem).children("#catItemImageLink"+this.no).attr("href",url);
		
		if(this.image){
			$(catItem).children("#catItemImageLink"+this.no).children('img').width(width);
			$(catItem).children("#catItemImageLink"+this.no).children('img').height(height);
			$(catItem).children("#catItemImageLink"+this.no).children('img').attr("src",thumbUrl);
		}
		else{
			//$(catItem).children("#catItemImageLink"+this.no).children('img').width("");
			//$(catItem).children("#catItemImageLink"+this.no).children('img').height("");
			//$(catItem).children("#catItemImageLink"+this.no).children('img').attr("src",thumbUrl);
			$(catItem).children("#catItemImageLink"+this.no).children('img').remove();
			$(catItem).children("#catItemImageLink"+this.no).append('<div class="catImageNoThumb"><img src="' +noFileImage+'" alt="No File" /></div>');
			$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).children(".catItemHoverText").attr("class","catItemHoverTextNoThumb");
			$(catItem).children("#catItemHoverLink"+this.no).children("#catItemHover"+this.no).attr("class","catItemHoverNoThumb");
		}
		
		$(catItem).children("#catItemComment0").attr("id","catItemComment"+this.no);
		
		$(catItem).children("#catItemComment"+this.no).children(".catCounts").html("R: "+this.postcount+"/ I:"+this.imagecount);
		
		if(this.sub){
			if(this.com){
				sub="<strong>"+this.sub+": </strong>";
			}
			else{
				sub="<strong>"+this.sub+"</strong>";
			}
		}
		
		$(catItem).children("#catItemComment"+this.no).children("span").last().html(sub + this.com);
		
		// hover stuff
		var postnum=this.no;
		
		$(catItem).children("#catItemImageLink"+this.no).children('img').mouseenter(function(){
			$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).fadeTo(100, 0.6, function () {
				$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).css("visibility", "visible");
			});
		});
		
		$(catItem).children("#catItemImageLink"+this.no).children('div').mouseenter(function(){
			$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).fadeTo(100, 0.6, function () {
				$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).css("visibility", "visible");
			});
		});
		
		$(catItem).mouseleave(function(){
			$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).fadeTo(100, 0, function () {
				$(catItem).children("#catItemHoverLink"+postnum).children("#catItemHover"+postnum).css("visibility", "hidden");
			});
		});
		
		$("#catalog").append(catItem);
	});
}

function savePrefs(){
}

function loadPrefs(){
}

function searchThreads(searchString){
	init(0,string);
}

function sortThreads(sortBy){
	init(sortBy,string);
}

function toggleImageSize(){
	if(localStorage.getItem("thumbSize")=="large"){
		localStorage.setItem("thumbSize", "small");
		init(0,0);
	}
	else{
		localStorage.setItem("thumbSize", "large");
		init(0,0);
	}
}