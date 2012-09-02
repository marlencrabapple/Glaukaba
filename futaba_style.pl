use strict;
use POSIX qw/strftime/;
BEGIN { require "wakautils.pl" }
use constant NORMAL_HEAD_INCLUDE => q{
	<!DOCTYPE html>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
	<meta name="viewport" content="width=device-width,initial-scale=1" />
	<title><if $title><var $title> - </if><const TITLE></title>
	<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />
	<style type="text/css">
	body { margin: 0; margin-bottom: auto; }
	blockquote blockquote { margin-left: 0em;}
	form { margin-bottom: 0px }
	form .trap { display:none }
	.postarea table { margin: 0px auto; text-align: left }
	.reflink a { color: inherit; text-decoration: none }
	.reply .filesize { margin-left: 20px }
	.userdelete { float: right; text-align: center; white-space: nowrap }
	.replypage .replylink { display: none }
	.aa { font-family: Mona,'MS PGothic' !important; font-size: 12pt; }
	</style>

	<loop $stylesheets>
	<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="http://<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" title="<var $title>" />
	</loop>
	<link href="http://<var DOMAIN>/css/prettify.css" type="text/css" rel="stylesheet" />
	<link href="http://<var DOMAIN>/css/mobile.css" type="text/css" rel="stylesheet" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.21/jquery-ui.min.js"></script>
	<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
	<script type="text/javascript" src="http://<var DOMAIN>/js/<var JS_FILE>?<var int(rand(10000))>"></script>
	<script type="text/javascript" src="http://<var DOMAIN>/js/<var EXTRA_JS_FILE>?<var int(rand(10000))>"></script>
	<script src="http://<var DOMAIN>/js/jquery.form.js"></script>
	<script type="text/javascript" src="http://<var DOMAIN>/js/prettify/prettify.js"></script>
	<script type="text/javascript">
	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', 'UA-26348635-1']);
	  _gaq.push(['_trackPageview']);

	  (function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();
	</script>
	<script>
		$(document).ready(function() {
			$(".catItem").mouseenter(function () {
				var catItem = $(this).attr("id");
				$("#"+catItem+"Hover").fadeTo(250, 0.5, function () {
					console.log(catItem);
					$("#"+catItem+"Hover").css("visibility", "visible");
				});
			});
			
			$(".catItem").mouseleave(function () {
				var catItem = $(this).attr("id");
				$("#"+catItem+"Hover").fadeTo(250, 0, function () {
					console.log(catItem);
					$("#"+catItem+"Hover").css("visibility", "hidden");
				});
			});
		});
	</script>
	</head>
	<if $thread><body class="replypage"></if>
	<if !$thread><body></if>
	<a name="top"></a>
		<div id="overlay">
		<div id="navOptionsMenu">
			<div id="navOptionsTopBar">
				Board Options
			</div>
			<hr>
			<div id="navOptionsContent">
				<strong>These features may have bugs and are constantly changing. Make sure to clear your cache often.</strong>
				<p>
					<strong>Style Options</strong><br />
					<loop $stylesheets>[<a href="javascript:set_stylesheet('<var $title>')" ><var $title></a>] </loop>
				</p>
				<p>
					<strong>General Enhancements</strong><br />
					<label class="navOptionsListItem"><input id="expandPosts" type=checkbox onchange="toggleFeature('expandPosts',this.checked);" />Comment Expansion</label>: Expands truncated comments<br />
					<label class="navOptionsListItem"><input id="expandThreads" type=checkbox onchange="toggleFeature('expandThreads',this.checked);" />Thread Expansion</label>: View all replies without changing pages<br />
				</p>
				<p>
					<strong>Filtering</strong><br />
					<label class="navOptionsListItem"><input id="replyHiding" type=checkbox onchange="toggleFeature('replyHiding',this.checked);" />Reply Hiding</label>: Hide replies<br />
					<label class="navOptionsListItem"><input id="threadHiding" type=checkbox onchange="toggleFeature('threadHiding',this.checked);" />Thread Hiding</label>: Hide threads<br />
					<label class="navOptionsListItem"><input id="anonymize" type=checkbox onchange="toggleFeature('anonymize',this.checked);" />Anonymize</label>: Makes everybody anonymous<br />
				</p>
				<p>
					<strong>Image Options</strong><br />
					<label class="navOptionsListItem"><input id="inlineExpansion" type=checkbox onchange="toggleFeature('inlineExpansion',this.checked);" />Inline Expansion</label>: View fullsize images without opening a new window or tab<br />
				</p>
				<p>
					<strong>Monitoring</strong><br />
					<label class="navOptionsListItem"><input id="threadUpdater" type=checkbox onchange="toggleFeature('threadUpdater',this.checked);" />Thread Updater</label>: Get new posts automatically without refreshing the page<br />
				</p>
				<p>
					<strong>Posting</strong><br />
					<label class="navOptionsListItem"><input id="qRep" type=checkbox onchange="toggleFeature('qRep',this.checked);" />Quick Reply</label>: Reply without reloading the page<br />
				</p>
				<p>
					<strong>Quoting</strong><br />
					<label class="navOptionsListItem"><input id="quotePreview" type=checkbox onchange="toggleFeature('quotePreview',this.checked);" />Quote Previews</label>: Show quoted post on hover<br />
					<label class="navOptionsListItem"><input id="inlineQuote" type=checkbox onchange="toggleFeature('inlineQuote',this.checked);" />Inline Quotes</label>: Show quoted post inline when clicked on<br />
				</p>
			</div>
		</div>
	</div>
	<div id="topNavContainer">
		}.include("include/header.html").q{
		<div id="topNavRight">
			<a href="javascript:void(0)" onclick="toggleNavMenu(this,0);">[Board Options]</a>
		</div>
	</div>
	<div class="logo">
	<div id="image" style="padding: 0; margin: 0;"></div>
	<const TITLE>
	<p style="margin:0; padding:1px; font-size: x-small; font-weight: normal; font-family: arial,helvetica,sans-serif;"><const SUBTITLE></p>
	</div>
	
	<hr class="postinghr" />
		<if !$admin><div class="denguses">}.include("include/topad.html").q{</div></if>
	<hr class="postinghr" />
};

use constant MINIMAL_HEAD_INCLUDE => q{
	<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
			<meta name="viewport" content="width=device-width,initial-scale=1" />
			<title><if $title><var $title> - </if><const TITLE></title>
			<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />
			<style type="text/css">
				body { margin: 0; padding: 8px; margin-bottom: auto;}
				blockquote blockquote { margin-left: 0em;}
				form { margin-bottom: 0px }
				form .trap { display:none }
				.postarea table { margin: 0px auto; text-align: left }
				.reflink a { color: inherit; text-decoration: none }
				.reply .filesize { margin-left: 20px }
				.userdelete { float: right; text-align: center; white-space: nowrap }
				.replypage .replylink { display: none }
				.aa { font-family: Mona,'MS PGothic' !important; font-size: 12pt; }
				.admNum{ font-size: 13pt; }
			</style>
			<loop $stylesheets>
			<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="http://<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" />
			</loop>
			<link href="http://<var DOMAIN>/css/prettify.css" type="text/css" rel="stylesheet" />
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.21/jquery-ui.min.js"></script>
			<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
			<script type="text/javascript" src="http://<var DOMAIN>/js/<var JS_FILE>?<var int(rand(10000))>"></script>
			<script type="text/javascript" src="http://<var DOMAIN>/js/<var EXTRA_JS_FILE>?<var int(rand(10000))>"></script>
			<script src="http://malsup.github.com/jquery.form.js"></script>
			<script type="text/javascript" src="http://<var DOMAIN>/js/prettify/prettify.js"></script>			
			<script>
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
			</script>
			<script type="text/javascript">
			  var _gaq = _gaq || [];
			  _gaq.push(['_setAccount', 'UA-26348635-1']);
			  _gaq.push(['_trackPageview']);

			  (function() {
				var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
				ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
				var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
			  })();
			</script>
		</head>
	<body>
};

use constant NORMAL_FOOT_INCLUDE => include("include/footer.html").q{
</body></html>
};

use constant PAGE_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
<div id="content">
<if $thread>
	[<a href="http://<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
	[<a href="#bottom">Bottom</a>]
	<div class="theader"><const S_POSTING></div> 
</if>
<if $postform><div class="postarea">
	<style type="text/css" scoped="scoped">.recaptchatable{background-color:transparent!important;border:none!important;}.recaptcha_image_cell{background-color:transparent!important;}#recaptcha_response_field{border:1px solid #AAA!important;}#recaptcha_div{height:107px;width:440px;}#recaptcha_challenge_field{width:400px}</style>
	<script type="text/javascript">
		var RecaptchaOptions = {
			theme : 'clean'
		};
	</script>
	<form action="<var $self>" method="post" enctype="multipart/form-data">
		<input type="hidden" name="task" value="post" />
		<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
		<if !$image_inp and !$thread and ALLOW_TEXTONLY><input type="hidden" name="nofile" value="1" /></if>
		<if FORCED_ANON><input type="hidden" name="name" /></if>
		<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name"  autocomplete="off" /><input type="text" name="link" autocomplete="off" /></div></if>
		<div id="postForm">
			<if !FORCED_ANON><div class="postTableContainer">
					<div class="postBlock">Name</div>
					<div class="postSpacer"></div>
					<div class="postField"><input type="text" class="postInput" name="field1" id="field1" /></div>
				</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Link</div>
				<div class="postSpacer"></div>
				<div class="postField"><input type="text" class="postInput" name="field2" id="field2" /></div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Subject</div>
				<div class="postSpacer"></div>
				<div class="postField">
					<input type="text" name="field3" class="postInput" id="field3" />
					<input type="submit" id="field3s" value="Submit" />
					<if SPOILERIMAGE_ENABLED><label>[<input type="checkbox" name="spoiler" value="1" /> Spoiler ]</label></if><if NSFWIMAGE_ENABLED><label>[<input type="checkbox" name="nsfw" value="1" /> NSFW ]</label></if>
				</div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Comment</div>
				<div class="postSpacer"></div>
				<div class="postField"><textarea name="field4" class="postInput" id="field4"></textarea></div>
			</div>
			<if ENABLE_CAPTCHA && ENABLE_CAPTCHA ne 'recaptcha'><div class="postBlock"><const S_CAPTCHA></div>
				<div class="postSpacer"></div>
				<div class="postField">
					<input type="text" name="captcha" class="field6" size="10" />
					<img alt="" src="<var expand_filename(CAPTCHA_SCRIPT)>?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>" />
				</div></if>
			<if ENABLE_CAPTCHA eq 'recaptcha'><div class="postTableContainer" id="recaptchaContainer">
					<div class="postBlock" id="captchaPostBlock"><const S_CAPTCHA></div>
					<div class="postSpacer"></div>
					<div class="postField">
						<script type="text/javascript" src="http://www.google.com/recaptcha/api/challenge?k=<const RECAPTCHA_PUBLIC_KEY>"></script>
						<noscript>
							<iframe src="http://www.google.com/recaptcha/api/noscript?k=<const RECAPTCHA_PUBLIC_KEY>" height="300" width="500"></iframe><br />
							<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
							<input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
						</noscript>
					</div>
				</div></if>
			<if $image_inp><div class="postTableContainer">
					<div class="postBlock">File</div>
					<div class="postSpacer"></div>
					<div class="postField">
						<input type="file" name="file" id="file" />
						<if $textonly_inp>
							<label><input type="checkbox" name="nofile" value="on" />No File</label>
						</if>
					</div>
				</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Password</div>
				<div class="postSpacer"></div>
				<div class="postField"><input type="password" class="postInput" id="password" name="password"/> (for post and file deletion)</div>
			</div>
			<div class="postTableContainer">
				<div class="rules">
					}.include("include/rules.html").q{
				</div>
			</div>
		</div>
	</form>
</div>
<script type="text/javascript">setPostInputs()</script></if>

<hr class="postinghr" />

<div class="denguses">}.include("include/middlead.html").q{</div>

<div class="announcement">
}.include("../announcement.html").q{
</div>

<form id="delform" action="<var $self>" method="post">
<loop $threads>
	<div class="thread"><loop $posts>
		<if !$parent>
			<div class="parentPost" id="parent<var $num>">
				<div class="mobileParentPostInfo">
					<label ><input type="checkbox" name="delete" value="<var $num>" />
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
					<var $date></label>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var getPrintedReplyLink($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					</span>&nbsp;
					<if !$thread>[<a href="<var getPrintedReplyLink($num,0)>"><const S_REPLY></a>]</if>
					<a href="javascript:void(0)" onclick="reportPostPopup(<var $num>, '<var BOARD_DIR>')" class="reportButton" id="rep<var $num>">[ ! ]</a>
				</div>
				<div class="hat"></div>
				<if $image><span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
					-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
					<div style="display:none" class="forJsImgSize">
						<span><var $width></span>
						<span><var $height></span>
					</div>
					<br />
					<if $thumbnail><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>">
						<if !$tnmask><img src="<var expand_filename($thumbnail)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if><if $tnmask><img src="http://<var DOMAIN>/img/spoiler.png" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if></a></if>
					<if !$thumbnail>
						<if DELETED_THUMBNAIL><a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>"><img src="<var expand_filename(DELETED_THUMBNAIL)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" alt="" class="thumb opThumb" /></a></if>
					<if !DELETED_THUMBNAIL><div class="thumb nothumb"><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div></if></if></if>
				<a id="<var $num>"></a>
				<div class="parentPostInfo">
					<label><input type="checkbox" name="delete" value="<var $num>" />
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
					<var $date></label>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var getPrintedReplyLink($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					<if $sticky><img src="http://<var DOMAIN>/img/sticky.gif" alt="Stickied"/></if>
					<if $locked><img src="http://<var DOMAIN>/img/closed.gif " alt="Locked"/></if>
					</span>&nbsp;
					<if !$thread>[<a href="<var getPrintedReplyLink($num,0)>"><const S_REPLY></a>]</if>
					<a href="javascript:void(0)" onclick="togglePostMenu('postMenu<var $num>','postMenuButton<var $num>');"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
					<div class="postMenu" id="postMenu<var $num>">
						<a onmouseover="closeSub(this);" href="javascript:void(0)" onclick="reportPostPopup(<var $num>, '<var BOARD_DIR>')" class="postMenuItem">Report this post</a>
						<div class="hasSubMenu" onmouseover="showSub(this);">
							<span class="postMenuItem">Delete</span>
							<div onmouseover="$(this).addClass('focused')" class="postMenu subMenu">
								<a class="postMenuItem" href="javascript:void(0);" onclick="deletePost(<var $num>);">Post</a>
								<a class="postMenuItem" href="javascript:void(0);" onclick="deleteImage(<var $num>);">Image</a>
							</div>
						</div>
						<div class="hasSubMenu" onmouseover="showSub(this);">
							<span class="postMenuItem">Filter</span>
							<div class="postMenu subMenu">
								<a class="postMenuItem" href="javascript:void(0);">Not yet implemented</a>
							</div>
						</div>
						<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="facebookPost(window.location.hostname,<var $num>,<var $parent>)" class="postMenuItem">Post to Facebook</a>
						<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="twitterPost(window.location.hostname,<var $num>,<var $parent>)" class="postMenuItem">Post to Twitter</a>
						<a onmouseover="closeSub(this);" href="http://<var DOMAIN>/<var BOARD_DIR>/res/<var $num>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
					</div>
				</div>
				
				<blockquote<if $email=~/aa$/i> class="aa"</if>>
				<var $comment>
				<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,getPrintedReplyLink($num,$parent))></div></if>
				</blockquote>
			</div>
			<if $omit><span class="omittedposts">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
			</span></if></if>
		<if $parent><div class="replyContainer" id="replyContainer<var $num>">
				<div class="doubledash">&gt;&gt;</div>
				<div class="reply" id="reply<var $num>">
					<a id="<var $num>"></a>
					<label><input type="checkbox" name="delete" value="<var $num>" />
					<span class="replytitle"><var $subject></span>
					<if $email><span class="commentpostername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="commentpostername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
					<var $date></label>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var getPrintedReplyLink($parent,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if></span>
					<a href="javascript:void(0)" onclick="togglePostMenu('postMenu<var $num>','postMenuButton<var $num>');"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
					<div class="postMenu" id="postMenu<var $num>">
						<a onmouseover="closeSub(this);" href="javascript:void(0)" onclick="reportPostPopup(<var $num>, '<var BOARD_DIR>')" class="postMenuItem">Report this post</a>
						<div class="hasSubMenu" onmouseover="showSub(this);">
							<span class="postMenuItem">Delete</span>
							<div onmouseover="$(this).addClass('focused')" class="postMenu subMenu">
								<a class="postMenuItem" href="javascript:void(0);" onclick="deletePost(<var $num>);">Post</a>
								<a class="postMenuItem" href="javascript:void(0);" onclick="deleteImage(<var $num>);">Image</a>
							</div>
						</div>
						<div class="hasSubMenu" onmouseover="showSub(this);">
							<span class="postMenuItem">Filter</span>
							<div class="postMenu subMenu">
								<a class="postMenuItem" href="javascript:void(0);">Not yet implemented</a>
							</div>
						</div>
						<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="facebookPost(window.location.hostname,<var $num>,<var $parent>)" class="postMenuItem">Post to Facebook</a>
						<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="twitterPost(window.location.hostname,<var $num>,<var $parent>)" class="postMenuItem">Post to Twitter</a>
						<a href="http://<var DOMAIN>/<var BOARD_DIR>/res/<var $parent>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
					</div>
					<if $image>
						<br />
						<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
						-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
						<div style="display:none" class="forJsImgSize"><span><var $width></span><span><var $height></span>
						</div><br />
						<if $thumbnail>
							<a class="thumbLink" target="_blank" href="<var expand_image_filename($image)>">
								<if !$tnmask><img src="<var expand_filename($thumbnail)>" alt="<var $size>" class="thumb replyThumb" data-md5="<var $md5>" style="width: <var $tn_width*.504>px; height: <var $tn_height*.504>px;" /></if><if $tnmask><img src="http://<var DOMAIN>/img/spoiler.png" alt="<var $size>" class="thumb replyThumb" data-md5="<var $md5>" /></if></a>
						</if>
						<if !$thumbnail>
							<if DELETED_THUMBNAIL>
								<a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>">
								<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" class="thumb replyThumb" /></a>
							</if>
							<if !DELETED_THUMBNAIL>
								<div class="thumb replyThumb nothumb"><a class="thumbLink" target="_blank" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div>
							</if></if></if>
					<blockquote<if $email=~/aa$/i> class="aa"</if>>
						<var $comment>
						<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,getPrintedReplyLink($num,$parent))></div></if>
					</blockquote>
				</div>
			</div></if>
		</loop>
	</div>
	<hr />
</loop>

<div class="denguses">}.include("include/bottomad.html").q{</div>

<hr />

<if $thread>
	[<a href="http://<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
	[<a href="#">Top</a>]
	<a name="bottom"></a>
</if>

<div id="deleteForm">
	<input type="hidden" name="task" value="delete" />
	Delete Post
	<label>[<input type="checkbox" name="fileonly" value="on" /> <const S_DELPICONLY>]</label>
	<const S_DELKEY><input type="password" name="password" id="delPass" class="postInput"/>
	<input value="<const S_DELETE>" type="submit" class="formButtom" />
	<script type="text/javascript">setDelPass();</script>
</div>
</form>

<div id="forJs" style="display:none"><var BOARD_DIR></div>

<if !$thread>
	<div id="pageNumber">

	<if $prevpage><form class="pageForm" method="get" action="<var $prevpage>"><input value="<const S_PREV>" type="submit" /></form></if>
	<if !$prevpage><const S_FIRSTPG></if>
	<loop $pages>
		<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
		<if $current>[<var $page>]</if>
	</loop>

	<if $nextpage><form class="pageForm" method="get" action="<var $nextpage>"><input value="<const S_NEXT>" type="submit" /></form></if>
	<if !$nextpage><const S_LASTPG></if>

	</div><br />
</if>

</div>
}.NORMAL_FOOT_INCLUDE);

use constant ERROR_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

	<h1 style="text-align: center"><var $error><br /><br />
	<a href="<var escamp($ENV{HTTP_REFERER})>"><const S_RETURN></a><br /><br />
	</h1>
	</div>
	
}.NORMAL_FOOT_INCLUDE);

use constant CATALOG_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
	[<a href="http://<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
	<div class="theader">Catalog Mode</div>
	<div id="catalog">
		<loop $threads>
			<div class="catItem" id="catItem<var $num>" style="display: inline-block;">
				<a href="/<var BOARD_DIR>/res/<var $num>"><if $thumbnail><div class="catItemHover" id="catItem<var $num>Hover" style="width: <var $tn_width*.504>px; height: <var $tn_height*.504>px;"><div class="catItemHoverText" style="width: <var $tn_width*.504>px; height: <var $tn_height*.504>px; line-height:<var ($tn_height*.504)>px;">&gt;&gt;<var $num></div></div></if>
				<if !$thumbnail><div id="catItem<var $num>Hover" class="catItemHoverNoThumb"><div class="catItemHoverTextNoThumb">&gt;&gt;<var $num></div></div></if></a>
				<a href="/<var BOARD_DIR>/res/<var $num>"><if $thumbnail><img src="/<var BOARD_DIR>/<var $thumbnail>" class="catImage" style="width: <var $tn_width*.504>px; height: <var $tn_height*.504>px;" /></if><if !$thumbnail><div class="catImageNoThumb"></div></if></a>
			</div>
		</loop>
	</div>
	<hr />
	<div class="denguses">}.include("include/bottomad.html").q{</div>
}.NORMAL_FOOT_INCLUDE);

use constant REPORT_TEMPLATE => compile_template(q{
	<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
			<title>Reporting Post No.<var $num> on /<var $board>/</title>
			<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />
			<style type="text/css">
				body { margin: 0; padding: 8px; margin-bottom: auto;}
				h3 {margin: 0; margin-bottom: 5px;}
			</style>
			<loop $stylesheets><link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="http://<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" /></loop>
			<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
			<script type="text/javascript" src="http://<var DOMAIN>/js/<var JS_FILE>?<var int(rand(10000))>"></script>
			<script type="text/javascript" src="http://<var DOMAIN>/js/<var EXTRA_JS_FILE>?<var int(rand(10000))>"></script>
		</head>
		<body>
			<h3>Reporting Post No.<var $num> on /<var $board>/</h3>
			<form action="<var $self>" method="post" enctype="multipart/form-data">
				<input type="hidden" name="task" value="report" />
				<input type="hidden" name="num" value="<var $num>" />
				<input type="hidden" name="board" value="<var $board>" />
				<fieldset style="margin-bottom: 5px;"><legend>Report type</legend>
					<input type="radio" name="reason" id="cat1" value="vio"> <label for="cat1">Rule violation</label><br/>
					<input type="radio" name="reason" id="cat2" value="illegal"> <label for="cat2">Illegal content</label><br/>
					<input type="radio" name="reason" id="cat3" value="spam"> <label for="cat3">Spam/advertising/flooding</label>
				</fieldset>
				<input type="submit" value="<const S_SUBMIT>" />
			</form>
			<p style="font-size: 10px">Note: Submitting frivolous reports will result in a ban. When reporting, make sure that the post in question violates the global/board rules, or contains content illegal in the United States.</p>
		</body>
	</html>
});

use constant LIST_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
	[<a href="http://<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
	<div class="theader">Thread Index</div>
	<table id="threadList" style="white-space: nowrap;">
		<thead><tr class="head">
			<td class="postBlock">Subject</td>
			<td class="postBlock">Created by</td>
			<td class="postBlock">Time</td>
			<td class="postBlock">Post No.</td>
		</tr></thead>
		<tbody><loop $threads><tr>
			<td><a href="/<var BOARD_DIR>/res/<var $num>"><if $subject><var $subject></a></if><if !$subject><var truncateComment($comment)></a></if>&nbsp;&nbsp;[<var $postcount-1> <if $postcount\>1>replies</if><if $postcount==1>reply</if>]</td>
			<td><span class="postername"><var $name></span><span class="postertrip"><var $trip></span></td>
			<td><var make_date($timestamp,"tiny")></td>
			<td>No.<var $num></td>
		</tr></loop></tbody>
	</table>
	<hr />
	<div class="denguses">}.include("include/bottomad.html").q{</div>
	<hr />
}.NORMAL_FOOT_INCLUDE);

use constant SEARCH_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

}.NORMAL_FOOT_INCLUDE);

use constant BAN_PAGE_TEMPLATE => compile_template(MINIMAL_HEAD_INCLUDE.q{
<div class="logo" style="text-align: center; width:800px;margin-left:auto; margin-right:auto;">
	<span>You (<var dec_to_dot $ip>) have been banned!</span>
	<br /><br />
	<div style="float:left; width: 49.1%">
	<img src="http://<var DOMAIN>/img/banned.png"/>
	</div>
	<div style="float:right; width: 49.1%">
	<loop $bans>
	<p style="font-size:10pt; font-weight: normal;">You were banned on <var make_date($timestamp,DATE_STYLE)> for the following reason: "<em><var $comment></em>"</p>
	</loop>
	</div>
</div>
<div style="clear:both"></div>
<br /><br />
}.NORMAL_FOOT_INCLUDE);

#
# Stylesheet stuff
#

no strict;
$stylesheets=get_stylesheets(); # make stylesheets visible to the templates
use strict;

sub get_filename($) { my $path=shift; $path=~m!([^/]+)$!; clean_string($1) }

sub get_stylesheets()
{
	my $found=0;
	my @stylesheets=map
	{
		my %sheet;

		$sheet{filename}=$_;
		$sheet{filename}=~s/ /%20/g;

		($sheet{title})=m!([^/]+)\.css$!i;
		$sheet{title}=ucfirst $sheet{title};
		$sheet{title}=~s/_/ /g;
		$sheet{title}=~s/ ([a-z])/ \u$1/g;
		$sheet{title}=~s/([a-z])([A-Z])/$1 $2/g;
		#$sheet{title}=~s/ /'%20'/g;

		if($sheet{title} eq DEFAULT_STYLE) { $sheet{default}=1; $found=1; }
		else { $sheet{default}=0; }

		\%sheet;
	} glob("..".CSS_DIR."*.css");

	$stylesheets[0]{default}=1 if(@stylesheets and !$found);

	return \@stylesheets;
}

1;

