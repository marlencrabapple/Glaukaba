var isOn = 0;
var updaterTimer;
var updaterTimeLeft;
var timeLeft = 30;
var req = new XMLHttpRequest();
var modified;
var newPosts;
var currentPosts;
var postsAdded = 0;
var logoRandomized = 0;
var numberOfPosts = 0;

function get_cookie(name)
{
	with(document.cookie)
	{
		var regexp=new RegExp("(^|;\\s+)"+name+"=(.*?)(;|$)");
		var hit=regexp.exec(document.cookie);
		if(hit&&hit.length>2) return unescape(hit[2]);
		else return '';
	}
};

function set_cookie(name,value,days)
{
	if(days)
	{
		var date=new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires="; expires="+date.toGMTString();
	}
	else expires="";
	document.cookie=name+"="+value+expires+"; path=/";
}

function get_password(name)
{
	var pass=get_cookie(name);
	if(pass) return pass;

	var chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	var pass='';

	for(var i=0;i<8;i++)
	{
		var rnd=Math.floor(Math.random()*chars.length);
		pass+=chars.substring(rnd,rnd+1);
	}

	return(pass);
}

function insert(text)
{
	var textarea=document.getElementById("field4");
	if(textarea)
	{
		if(textarea.createTextRange && textarea.caretPos) // IE
		{
			var caretPos=textarea.caretPos;
			caretPos.text=caretPos.text.charAt(caretPos.text.length-1)==" "?text+" ":text;
		}
		else if(textarea.setSelectionRange) // Firefox
		{
			var start=textarea.selectionStart;
			var end=textarea.selectionEnd;
			textarea.value=textarea.value.substr(0,start)+text+textarea.value.substr(end);
			textarea.setSelectionRange(start+text.length,start+text.length);
		}
		else
		{
			textarea.value+=text+" ";
		}
		textarea.focus();
	}
}

function highlight(post)
{
	// needs logic for detecting OP
	var cells=document.getElementsByTagName("div");
	for(var i=0;i<cells.length;i++) if(cells[i].className=="reply highlight") cells[i].className="reply";

	var reply = document.getElementById("reply"+post);
	if(reply)
	{
		reply.className="reply highlight";
		var match=/^([^#]*)/.exec(document.location.toString());
		document.location=match[1]+"#"+post;
		return false;
	}

	return true;
}

function set_stylesheet(styletitle,norefresh)
{
	set_cookie("wakabastyle",styletitle,365);

	var links=document.getElementsByTagName("link");
	var found=false;
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title)
		{
			links[i].disabled=true; // IE needs this to work. IE needs to die.
			if(styletitle==title) { links[i].disabled=false; found=true; }
		}
	}
	if(!found) set_preferred_stylesheet();
}

function set_preferred_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title) links[i].disabled=(rel.indexOf("alt")!=-1);
	}
}

function get_active_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title&&!links[i].disabled) return title;
	}
	return null;
}

function get_preferred_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&rel.indexOf("alt")==-1&&title) return title;
	}
	return null;
}

function set_inputs(id) { with(document.getElementById(id)) {if(!field1.value) field1.value=get_cookie("name"); if(!field2.value) field2.value=get_cookie("email"); if(!password.value) password.value=get_password("password"); } }
function set_delpass(id) { with(document.getElementById(id)) password.value=get_cookie("password"); }

function setQrInputs(){
	document.getElementById("qrField1").value=get_cookie("name");
	document.getElementById("qrField2").value=get_cookie("email");
	document.getElementById("qrPassword").value=get_password("password");
}

function setPostInputs(){
	document.getElementById("field1").value=get_cookie("name");
	document.getElementById("field2").value=get_cookie("email");
	document.getElementById("password").value=get_password("password");
}

function setDelPass(){
	document.getElementById("delPass").value=get_password("password");
}

function do_ban(el)
{
	var reason=prompt("Give a reason for this ban:");
	if(reason) document.location=el.href+"&comment="+encodeURIComponent(reason);
	return false;
}

window.onunload=function(e)
{
	if(style_cookie)
	{
		var title=get_active_stylesheet();
		set_cookie(style_cookie,title,365);
	}
}

window.onload=function(e)
{
	var match;

	if(match=/#i([0-9]+)/.exec(document.location.toString()))
	if(!document.getElementById("field4").value)
	insert(">>"+match[1]);

	if(match=/#([0-9]+)/.exec(document.location.toString()))
	highlight(match[1]);
	
	doIt();
	prettyPrint();
	
	// style for mobile browsers
	//for (var i = 0; i < document.getElementsByClassName('opThumb').length; i++ ){
		//document.getElementsByClassName('opThumb')[i].width = document.getElementsByClassName('opThumb')[i].width*.504 + "px";
		//document.getElementsByClassName('opThumb')[i].height = document.getElementsByClassName('opThumb')[i].height*.504 + "px";
	//}
}

if(style_cookie)
{
	var cookie=get_cookie(style_cookie);
	var title=cookie?cookie:get_preferred_stylesheet();
	set_stylesheet(title);
}

function preventDef(event) {
	event.preventDefault();
}

function doIt(){
	if (logoRandomized == 0){
		logoSwitch();
		logoRandomized = 1;
	}
	
	document.getElementById("boardList").selectedIndex = 4;
	
	// inline image expansion prep
	thumbnails = document.getElementsByClassName('thumb');
	thumbLinks = document.getElementsByClassName('thumbLink');
	fullSize = document.getElementsByClassName('forJsImgSize');
	var imgSrc = new Array();
	
	for (var i = 0; i < thumbnails.length; i++ ){
		(function(e) {
			if (thumbLinks[e].className.indexOf("processed") == -1){
				imgSrc[e] = thumbLinks[e].href;
				thumbLinks[e].setAttribute("class", "thumbLink processed");
				//thumbLinks[e].href = "javascript:void(0)";
				//thumbLinks[e].removeAttribute("target");
				// named the inner anonymous function (i think)
				thumbLinks[e].addEventListener("click", function(a){
					expandThumb(thumbLinks[e],thumbnails[e],imgSrc[e],fullSize[e], e); a.preventDefault();}, true);
				//alert(imgSrc[i] +"\n\n"+ thumbLinks[i] +"\n\n"+ thumbnails[i] +"\n\n"+ i);
			}
		})(i);
	}

	// quick reply prep
	var refLinks = document.getElementsByClassName('refLinkInner');
	var board = document.getElementById('forJs').innerHTML;
	console.log(board);
	
	for (var i = 0; i < refLinks.length; i++ ){
		if (i == 0){
			i = numberOfPosts;
			console.log("Number of posts = " + numberOfPosts);
		}
		(function(e) {
			refLinks[e].href = "javascript:void(0)";
			refLinks[e].addEventListener("click",function(){
				quickReply(refLinks[e],board)});
		})(i);
	}
	
	// mouse over quote preview and inline quote prep
	var varReferences = document.getElementsByClassName("postlink");
	for (var i = 0; i < varReferences.length; i++ ){
		(function(e) {
			if (varReferences[e].className.indexOf("processed") == -1){
			varReferences[e].setAttribute("class", "postlink processed");
				varReferences[e].addEventListener("mouseover",function(){
					quotePreview(varReferences[e],0)});
				varReferences[e].addEventListener("mouseout",function(){
					quotePreview(varReferences[e],1)});
				//varReferences[e].addEventListener("click",function(){
					//inlineQuote(varReferences[e],varReferences[e].href,0)});
				//varReferences[e].href = "javascript:void(0)";
				
				// For auto-updater (may be obsolete now)
				varReferences[e].innerHTML = varReferences[e].innerHTML.replace(" (OP)","");
				varReferences[e].innerHTML = varReferences[e].innerHTML.replace(" (Cross-thread)","");
						
				if (document.getElementById("parent" + varReferences[e].innerHTML.substring(8)) != null){
					varReferences[e].innerHTML += " (OP)";
				}
				else{
					if (document.getElementById("reply" + varReferences[e].innerHTML.substring(8)) == null){
						if (document.body.className == "replypage"){
							varReferences[e].innerHTML += " (Cross-thread)"
						}
					}
				}
			}
		})(i);
		//varReferences[i].href = "javascript:void(0)";
	}
	
	// thread updater prep
	if (postsAdded < 1){
		if(document.body.className=="replypage"){
			req = new XMLHttpRequest();
			req.open('HEAD', document.location, false);
			req.send(null);
			modified = req.getResponseHeader("Last-Modified");
			
			currentPosts = document.getElementsByClassName("replyContainer");
			
			var updateLink = document.createElement('a');
			updateLink.innerHTML = "<a style='position: fixed; padding: 5px; right: 0; bottom:0;' id='threadUpdaterButton' href='javascript:void(0)' onclick='updateThread()'>Auto update</a>";
			
			var modifiedDiv = document.createElement('div');
			modifiedDiv.setAttribute("id","lastModified");
			modifiedDiv.style.display = "none";
			modifiedDiv.innerHTML = modified;
			
			document.body.appendChild(modifiedDiv);
			document.body.appendChild(updateLink);
		}
	}
	
	// hide thread prep
	if (postsAdded < 1){
		if (document.body.className!="replypage"){
			// something goes here
		}
	}
}

function masturbate(){
	
}

function logoSwitch(){
	var imageArray = new Array();

	imageArray[0] = "http://i.imgur.com/t1dxL.jpg"; 
	imageArray[1] = "http://i.imgur.com/ItcAw.gif";
	imageArray[2] = "http://i.imgur.com/ixLBA.gif";
	imageArray[3] = "http://i.imgur.com/B8qd2.jpg";
	imageArray[4] = "http://i.imgur.com/7BKwF.jpg";
	imageArray[5] = "http://i.imgur.com/1XsxE.jpg";
	imageArray[6] = "http://i.imgur.com/99eYy.jpg";
	imageArray[7] = "http://i.imgur.com/DCPTv.jpg";
	imageArray[8] = "http://i.imgur.com/jXxHC.jpg";
	imageArray[9] = "http://i.imgur.com/pDCSm.jpg";
	imageArray[10] = "http://i.imgur.com/5PIbe.png";
	
	
	var rand = Math.floor(Math.random()*11);
	var imgPath = "<img src='"+imageArray[rand]+"' alt='logo' class='banner' />";

	if (Date.getMonth == 11){
		document.getElementById("image").innerHTML = "<img src='"+"http://www.glauchan.org/img/christmas.jpg"+"' alt='logo' class='banner' />";
	}
	else{
		document.getElementById("image").innerHTML = imgPath;
	}
}

function recaptchaRefresh(){
	Recaptcha.reload("t");
	document.getElementById("qrCaptcha").innerHTML = document.getElementById("recaptchaContainer").innerHTML;
}

function quickReply(refLink, board){
	var ref = refLink.text.replace("No.",">>");
	var _div = document.createElement('div');
	_div.id = "quickReply";
	var parent;
	
	//document.getElementById("recaptcha_reload_btn").href = "javascript:recaptchaRefresh();";
	var recaptchaInsert = document.createElement('div');
	recaptchaInsert.id = "recaptchaInsert";
	recaptchaInsert.innerHTML = document.getElementById("recaptchaContainer").innerHTML;
	
	if(refLink.parentNode.parentNode.parentNode.parentNode.childNodes[1].id==""){
		parent = refLink.parentNode.parentNode.parentNode.childNodes[1].id;
		console.log(parent);
	}
	else
	{
		parent = refLink.parentNode.parentNode.parentNode.parentNode.childNodes[1].id;
		console.log(parent);
	}
	
	parent = parent.replace("parent","");

	if(document.getElementById("quickReply") == null){
		document.body.appendChild(_div);
		_div.innerHTML += '<span>Quick Reply</span><a href="javascript:void(0)" style="float: right" onclick="closeQuickReply();">[ x ]</a><form id="qrActualForm" action="/' + board + '/wakaba.pl" method="post" enctype="multipart/form-data"> <input type="hidden" name="task" value="post"> <input type="hidden" name="parent" value=' + parent + '> <div class="trap">Leave these fields empty (spam trap): <input type="text" name="name" autocomplete="off"><input type="text" name="link" autocomplete="off"></div> <div id="qrPostForm"> <div class="postTableContainer"> <div class="postBlock">Name</div> <div class="postSpacer"></div> <div class="postField"><input type="text" class="postInput" name="field1" id="qrField1"></div> </div> <div class="postTableContainer"> <div class="postBlock">Link</div> <div class="postSpacer"></div> <div class="postField"><input type="text" class="postInput" name="field2" id="qrField2"></div> </div> <div class="postTableContainer"> <div class="postBlock">Subject</div> <div class="postSpacer"></div> <div class="postField"> <input type="text" name="field3" class="postInput" id="qrField3"> <input type="submit" id="qrField3s" value="Submit" onclick="setSubmitText();"> </div> </div> <div class="postTableContainer"> <div class="postBlock">Comment</div> <div class="postSpacer"></div> <div class="postField"><textarea name="field4" class="postInput" id="qrField4"></textarea></div> </div> <div class="postTableContainer" id="qrCaptcha">' + recaptchaInsert.innerHTML + '</div> <div class="postTableContainer"> <div class="postBlock">File</div> <div class="postSpacer"></div> <div class="postField"> <input type="file" name="file" id="file"> <label><input type="checkbox" name="nofile" value="on">No File</label> </div> </div> <div class="postTableContainer"> <div class="postBlock">Password</div> <div class="postSpacer"></div> <div class="postField"><input type="password" class="postInput" id="qrPassword" name="password"> (for post and file deletion)</div> </div> <div class="postTableContainer"> </div> </div> </form>';
		
		document.getElementById("quickReply").childNodes[2].childNodes[7].childNodes[7].childNodes[5].childNodes[0].value += ref+"\n";
		setQrInputs("qrPostForm");
		ajaxSubmit();
	}
	else{
		document.getElementById("quickReply").childNodes[2].childNodes[7].childNodes[7].childNodes[5].childNodes[0].value += ref+"\n";
	}
}

function setSubmitText(){
	document.getElementById("qrField3s").value = "Submitting...";
}

function ajaxSubmit(){
	$(document).ready(function() {
		// bind 'qrActualForm' and provide a simple callback function
		$('#qrActualForm').ajaxForm(function() {
			closeQuickReply();
			Recaptcha.reload("t");
		});
	});
}

function closeQuickReply(){
	document.getElementById("quickReply").innerHTML = "";
	document.body.removeChild(document.getElementById("quickReply"));
}

function expandThumb(tl, tn, src, fs, index){
	if (tn.className.indexOf("expandedThumb") == -1){
		tn.src = src;
		tn.removeAttribute("style");
		tn.className = tn.className + " expandedThumb";
		
		var imgWidth = fs.childNodes[1].innerHTML;
		var imgHeight = fs.childNodes[3].innerHTML;
		
		console.log(imgWidth+" x "+imgHeight);
		
		var pageWidth = window.innerWidth;
		var pageHeight = window.innerHeight;
		
		// Half of this might be useless, but it works.
		if(imgWidth > pageWidth){
			// The next line makes no sense and I don't remember why I wrote it that way
			//if ((" " + tn.className + " ").replace(/[\n\t]/g, " ").indexOf(" opThumb ") > -1 ){
			if (tn.className.indexOf("opThumb") > -1){
				if (tn.offsetLeft > 30){
					//console.log("Offset left: " + tn.offsetLeft);
					tn.style.width = pageWidth - 150 - tn.offsetLeft + "px";
				}
				else{
					//console.log("Offset left: " + tn.offsetLeft);
					tn.style.width = pageWidth - 150 + "px";
				}
			}
			else{
				if (tn.parentNode.parentNode.offsetLeft > 30){
					//console.log("Offset left: " + tn.offsetLeft);
					tn.style.width = pageWidth - 150 - tn.parentNode.parentNode.offsetLeft + "px";
				}
				else{
					//console.log("Offset left: " + tn.offsetLeft);
					tn.style.width = pageWidth - 150 + "px";
				}
				tn.style.height = "auto";
			}
		}
	}
	else{
		// Need to implement scroll up
		//tn.src = tn.src.replace(".","s.");
		//tn.src = tn.src.replace("src","thumb");
		tn.className = tn.className.replace(" expandedThumb","");
		var width = tn.clientWidth;
		var height = tn.clientHeight;
		
		var selector;
		var className = " " + selector + " ";
		
		if ((" " + tn.className + " ").replace(/[\n\t]/g, " ").indexOf(" opThumb ") > -1 ){
			if ((width >= 250)&&(height >= 250)){
				if (width > height){
					tn.style.width = "250px";
					tn.style.height = "auto";
				}
				else{
					tn.style.height = "250px";
					tn.style.width = "auto";
				}
			}
			else{
				tn.style.width = fs.childNodes[1].innerHTML + "px";
				tn.style.height = fs.childNodes[3].innerHTML + "px";
				console.log("Image smaller than 250px.");
			}
		}
		else{
			if ((width >= 126)&&(height >= 126)){
				if (width > height){
					tn.style.width = "126px";
					tn.style.height = "auto";
				}
				else{
					tn.style.height = "126px";
					tn.style.width = "auto";
				}
			}
			else{
				tn.style.width = fs.childNodes[1].innerHTML + "px";
				tn.style.height = fs.childNodes[3].innerHTML + "px";
				console.log("Image smaller than 126px.");
			}
		}
	}
	return false;
}

function quotePreview(reference, mode){
	var referenceWork = reference.innerHTML.replace(" (OP)", "");
	
	if (document.getElementById("parent" + referenceWork.substring(8)) == null){
		var referencedPostNumber = "reply" + referenceWork.substring(8);
	}
	else{
		var referencedPostNumber = "parent" + referenceWork.substring(8);
	}

	//console.log(referencedPostNumber+ " = " +document.getElementById(referencedPostNumber));
	
	if (document.getElementById(referencedPostNumber) != null){
		if (mode == 0){
			console.log(referencedPostNumber);
			var referencedPost = document.getElementById(referencedPostNumber).innerHTML;
			var div = document.createElement('div');
			div.id = "quotePreview";
			div.className = "reply";
			div.style.position = "absolute";
			div.style.border = "1px solid grey";
			div.innerHTML = referencedPost;
			var previewOffsetY = document.getElementById(referencedPostNumber).offsetHeight;
			var previewOffsetX = document.getElementById(referencedPostNumber).offsetWidth;

			$(document).mousemove(function(e){
				div.style.top = (e.pageY-(previewOffsetY+10))+"px";
				div.style.left = (e.pageX+50)+"px";
			});
			
			document.body.appendChild(div);
		}
		
		if (mode == 1){
			document.getElementById("quotePreview").innerHTML = "";
			document.body.removeChild(document.getElementById("quotePreview"));
		}
	}
	else{
		// load thread page in background and grab post
	}
}

function inlineQuote(reference, url, mode){
	var referencedPostNumber = "reply" + reference.innerHTML.substring(8);
	
	if (document.getElementById(referencedPostNumber) != null){
		//console.log(reference.parentElement.parentElement);
		var referencedPost = document.getElementById(referencedPostNumber).childNodes[9].innerHTML;
		var inline = document.createElement('div');
		inline.id = "inlineQuote";
		inline.className = "reply";
		inline.style.border = "1px solid grey";
		inline.innerHTML = referencedPost;
		reference.parentElement.parentElement.appendChild(inline);
	}
	else{
		var board = document.getElementById('forJs').innerHTML;
	}
}

function threadUpdater(){
	req = new XMLHttpRequest();
	req.open('HEAD', document.location, false);
	req.send(null);
	modified = req.getResponseHeader("Last-Modified");
	
	if (document.getElementById("lastModified").innerHTML == modified){
		console.log("No new posts");
	}
	else{
		document.getElementById("lastModified").innerHTML = modified;
		console.log("New post!");
		postsAdded++;
		
		req = new XMLHttpRequest();
		req.open('GET', document.location, false);
		//req.requestType = "document";
		req.send();
		newPostsText = req.responseText;
		
		var newPostsFrame = document.createElement('div');
		newPostsFrame.setAttribute("id","newPostsFrame");
		newPostsFrame.style.display = "none";
		newPostsFrame.innerHTML = newPostsText;
		var newPosts = newPostsFrame.getElementsByClassName("replyContainer");
		//document.body.appendChild(newPostsFrame);
		
		
		//var newPosts = req.response.getElementsByClassName("replyContainer");
		//console.log(newPostsFrame.innerHTML);
		
		
		var newPostsAmount = newPosts.length;
		var currentPostsAmount = currentPosts.length;
		numberOfPosts = currentPosts.length + 1;
		var difference = newPostsAmount - currentPostsAmount;
		
		//console.log("Got to before for loop "+difference);
		
		for (var i = 0; i < difference; i++){
			//document.getElementsByClassName("thread")[0].innerHTML += newPosts[currentPostsAmount].innerHTML;
			var denguson = document.createElement('div');
			denguson.setAttribute("class","replyContainer");
			denguson.innerHTML = newPosts[currentPostsAmount + i].innerHTML;
			document.getElementsByClassName("thread")[0].appendChild(denguson);
			//console.log("Made it into for loop"+i);
		}
		
		doIt();
		
		//console.log("Made it out of for loop");
		currentPosts = newPosts;
	}
	
	updaterTimer = setTimeout("threadUpdater()",30000);
}

function updateThread(){
	if(isOn == 0){
		console.log("Thread updater started.");
		threadUpdater();
		updaterCounter();
		isOn = 1;
	}
	else{
		console.log("Thread updater stopped");
		clearTimeout(updaterTimer);
		clearTimeout(updaterTimeLeft);
		isOn = 0;
		document.getElementById("threadUpdaterButton").innerHTML = "Auto update";
	}
}

function updaterCounter(){
	if (timeLeft == 0){
		timeLeft = 30;
	}
	
	document.getElementById("threadUpdaterButton").innerHTML = "-"+timeLeft;
	timeLeft--;
	updaterTimeLeft = setTimeout("updaterCounter()",1000);
}

// TBD: Save hidden posts in a cookie or something
function hidePost(replyDivId){
	var dengus = document.createElement("div");
	dengus.innerHTML = "Post Hidden";
	dengus.setAttribute("id","postStub"+replyDivId.substring(5));
	
	if((document.getElementById(replyDivId).style.display=="table")||(document.getElementById(replyDivId).style.display=="")){
		document.getElementById(replyDivId).style.display="none";
		//document.getElementById("replyContainer"+replyDivId.substring(5)).innerHTML+="Post Hidden";
		document.getElementById("replyContainer"+replyDivId.substring(5)).appendChild(dengus);
		document.getElementById("hidePostButton"+replyDivId.substring(5)).innerHTML="[ + ]";
	}
	else{
		document.getElementById(replyDivId).style.display="table";
		document.getElementById("hidePostButton"+replyDivId.substring(5)).innerHTML="[ - ]";
		document.getElementById("replyContainer"+replyDivId.substring(5)).removeChild(document.getElementById("postStub"+replyDivId.substring(5)));
	}
}

function hideThread(){
}

// no longer in use
function thumbSize(){
	var widthgreater = 0;
	for (var i = 0; i < document.getElementsByClassName('replythumb').length; i++ ){
		if (document.getElementsByClassName('replythumb')[i].width > document.getElementsByClassName('replythumb')[i].height){
			//document.getElementsByClassName('replythumb')[i].style.width = "126px";
			//document.getElementsByClassName('replythumb')[i].style.height = "auto";
			widthgreater = 1;
		}
		else if (widthgreater == 0){
			//document.getElementsByClassName('replythumb')[i].style.height = "126px";
			//document.getElementsByClassName('replythumb')[i].style.width = "auto";
		}
		widthgreater = 0;
	}
}

function birthday(birthday, play){
	for (var i = 0; i < document.getElementsByClassName('hat').length; i++ ){
		document.getElementsByClassName('hat')[i].innerHTML = "<img src='http://www.glauchan.org/img/partyhat.gif' style='position:absolute; margin-top:-100px;'/>"
	}
	
	if (birthday == 1){
		if (play == 1){
			play = 0;
			
			document.body.innerHTML+="<audio controls='controls' autoplay='autoplay' loop='loop'><source src='http://onlinebargainshrimptoyourdoor.com/asdf.ogg' type='audio/ogg'></audio>";
		}

		window.setTimeout("birthday(1,0)", 30); // 5000 milliseconds delay
		var index = Math.round(Math.random() * 5);
		var ColorValue = "FFFFFF"; // default color - white (index = 0)
		var ColorValue2 = "000000";
		if (index == 1) {
			ColorValue = "RED"; //peach
			ColorValue2 = "BLUE";
		}
		if (index == 2) {
			ColorValue = "PURPLE"; //violet
			ColorValue2 = "GREEN";
		}
		if (index == 3) {
			ColorValue = "BLUE"; //lt blue
			ColorValue2 = "RED";
		}
		if (index == 4) {
			ColorValue = "GREEN"; //cyan
			ColorValue2 = "PURPLE";
		}
		if (index == 5) {
			ColorValue = "BLACK"; //tan
			ColorValue2 = "WHITE";
		}
		//document.getElementByClassName('reply').style.background = ColorValue;
		//document.getElementById('container').style.background = ColorValue;
		//document.getElementById('main').style.background = ColorValue;
		//document.getElementById('content').style.background = ColorValue;
		//document.getElementById('container').style.color = ColorValue2;
		document.body.style.background=ColorValue2;
		
		for (var i=0; i < document.getElementsByClassName('reply').length; i++ ){
			document.getElementsByClassName('reply')[i].style.background=ColorValue;
		}
	}
}

function partyHard(){
	birthday = 1;
}

function reportPostPopup(post, board){
	reportWindow = window.open('', post, 'width=190,height=170,scrollbars=no');
	
	//oh god why
	reportWindow.document.write("<!DOCTYPE html><head><title>Report Post</title><link rel='stylesheet' href='http://www.glauchan.org/css/boards/Yotsuba B.css' type='text/css' media='screen' /><script src='//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js' type='text/javascript'></script><script src='http://malsup.github.com/jquery.form.js'></script></head><body style='margin:0'><h3 style='color: #AF0A0F'>Report Post</h3><form method='get' action='http://www.glauchan.org/"+board+"/report.pl' enctype='multipart/form-data'><div id='reportFormDiv'><div id='reportPostDiv' class='reportFieldDiv'><div class='reportFieldDivText'>Post Number</div><div class='reportFieldDivInput' id='postNumberField'><INPUT NAME='Post' TYPE='text' id='postNumberInput' value='"+post+"' SIZE=7></div></div><div id='reportReasonDiv' class='reportFieldDiv'><div class='reportFieldDivText'>Reason</div><div class='reportFieldDivInput'><INPUT NAME='Reason' TYPE='text' SIZE=7>&nbsp;<input value='Report' type='submit' class='field3s' /></div></div></div></form><script>$(document).ready(function(){$('#reportPopupForm').ajaxForm(function(){try{}catch(e){}});});</script></body>");
}

function toggleNavMenu(){
	var menuState = document.getElementById("overlay").style.display;
	
	if((menuState=="none")||(menuState=="")){
		document.getElementById("overlay").style.display="block";
	}
	else{
		document.getElementById("overlay").style.display="none";
	}
}

function togglePostMenu(postMenuId,postMenuButtonId){
	console.log(document.getElementById(postMenuButtonId).offsetLeft);
	
	var menuState = document.getElementById(postMenuId).style.display;

	if((menuState=="none")||(menuState=="")){
		document.getElementById(postMenuId).style.left = document.getElementById(postMenuButtonId).offsetLeft-2 + "px";
		document.getElementById(postMenuId).style.display="block";
	}
	else{
		document.getElementById(postMenuId).style.display="none";
	}
}

function deletePost(){
	
}