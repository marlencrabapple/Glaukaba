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
	body { margin: 0; margin-bottom: auto; padding-top: 50px; }
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
	<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="<var $path><var $filename>" title="<var $title>" />
	</loop>
	<link href="http://glauchan.org/css/prettify.css" type="text/css" rel="stylesheet" />
	<link href="http://glauchan.org/css/mobile.css" type="text/css" rel="stylesheet" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.21/jquery-ui.min.js"></script>
	<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
	<script type="text/javascript" src="<var expand_filename(JS_FILE)>?<var int(rand(10000))>"></script>
	<script type="text/javascript" src="<var expand_filename(EXTRA_JS_FILE)>?<var int(rand(10000))>"></script>
	<script src="http://malsup.github.com/jquery.form.js"></script>
	<script type="text/javascript" src="http://glauchan.org/js/prettify/prettify.js"></script>
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
				<a class="navOptionsListItem">Main</a> | 
				<a class="navOptionsListItem">Filter</a> | 
				<a class="navOptionsListItem">Sauce</a> | 
				<a class="navOptionsListItem">Rice</a> | 
				<a class="navOptionsListItem">Keybinds</a>
			</div>
			<hr>
			<div id="navOptionsContent">
				<p>
					<strong>Style Options</strong><br />
					<loop $stylesheets>
						<a href="javascript:set_stylesheet('<var $title>')" ><var $title></a><br />
					</loop>
				</p>
				<p>
					<strong>General Enhancements</strong><br />
					Nothing here yet...
				</p>
				<p>
					<strong>Filtering</strong><br />
					<label class="navOptionsListItem"><input id="replyHiding" type=checkbox onchange="toggleFeature('replyHiding',this.checked);" />Reply Hiding</label>: Hide replies<br />
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
					<strong>Posting</strong><br />
					<label class="navOptionsListItem"><input id="quotePreview" type=checkbox onchange="toggleFeature('quotePreview',this.checked);" />Quote Previews</label>: Show quoted post on hover<br />
				</p>
			</div>
		</div>
	</div>
	<div id="topNavContainer">
		}.include("include/header.html").q{
		<div id="topNavRight">
			<a href="javascript:void(0)" onclick="toggleNavMenu();">[Board Options]</a>
		</div>
	</div>
	<div class="logo">
	<div id="image" style="padding: 0; margin: 0;"></div>
	<const TITLE>
	<p style="margin:0; padding:1px; font-size: x-small; font-weight: normal; font-family: arial,helvetica,sans-serif;"><const SUBTITLE></p>
	</div>
	<hr class="postinghr" />
		<div class="denguses">}.include("include/topad.html").q{</div>
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
			<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="<var $path><var $filename>" title="<var $title>" />
			</loop>
			<link href="http://glauchan.org/css/prettify.css" type="text/css" rel="stylesheet" />
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.21/jquery-ui.min.js"></script>
			<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
			<script type="text/javascript" src="<var expand_filename(JS_FILE)>?<var int(rand(10000))>"></script>
			<script src="http://malsup.github.com/jquery.form.js"></script>
			<script type="text/javascript" src="http://glauchan.org/js/prettify/prettify.js"></script>			
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
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
	[<a href="#bottom">Bottom</a>]
	<div class="theader"><const S_POSTING></div> 
</if>
<if $postform>
	<div class="postarea">
	
	<style type="text/css" scoped="scoped">.recaptchatable{background-color:transparent!important;border:none!important;}.recaptcha_image_cell{background-color:transparent!important;}#recaptcha_response_field{border:1px solid #AAA!important;}#recaptcha_div{height:107px;width:440px;}#recaptcha_challenge_field{width:400px}</style>
	
	<script type="text/javascript">
		var RecaptchaOptions = {
			theme : 'clean'
		};
	</script>
	 
	<form action="<var $self>" method="post" enctype="multipart/form-data">

	<input type="hidden" name="task" value="post" />
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<if !$image_inp and !$thread and ALLOW_TEXTONLY>
		<input type="hidden" name="nofile" value="1" />
	</if>
	<if FORCED_ANON><input type="hidden" name="name" /></if>
	<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name"  autocomplete="off" /><input type="text" name="link" autocomplete="off" /></div></if>
	
		<div id="postForm">
			<if !FORCED_ANON>
				<div class="postTableContainer">
					<div class="postBlock">Name</div>
					<div class="postSpacer"></div>
					<div class="postField"><input type="text" class="postInput" name="field1" id="field1" /></div>
				</div>
			</if>
			
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
			
			<if ENABLE_CAPTCHA && ENABLE_CAPTCHA ne 'recaptcha'>
				<div class="postBlock"><const S_CAPTCHA></div>
				<div class="postSpacer"></div>
				<div class="postField">
					<input type="text" name="captcha" class="field6" size="10" />
					<img alt="" src="<var expand_filename(CAPTCHA_SCRIPT)>?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>" />
				</div>
			</if>
			
			<if ENABLE_CAPTCHA eq 'recaptcha'>
				<div class="postTableContainer" id="recaptchaContainer">
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
				</div>
			</if>
			
			<if $image_inp>
				<div class="postTableContainer">
					<div class="postBlock">File</div>
					<div class="postSpacer"></div>
					<div class="postField">
						<input type="file" name="file" id="file" />
						<if $textonly_inp>
							<label><input type="checkbox" name="nofile" value="on" />No File</label>
						</if>
					</div>
				</div>
			</if>
			
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
	</form></div>
	<script type="text/javascript">setPostInputs()</script>
</if>

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
				<if $image>
					<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
					-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
					<div style="display:none" class="forJsImgSize">
						<span><var $width></span>
						<span><var $height></span>
					</div>
					<br />
					<if $thumbnail>
						<a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>">
							<if !$tnmask><img src="<var expand_filename($thumbnail)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if><if $tnmask><img src="http://<var DOMAIN>/img/spoiler.png" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if></a>
					</if>
					<if !$thumbnail>
						<if DELETED_THUMBNAIL>
							<a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>">
							<img src="<var expand_filename(DELETED_THUMBNAIL)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" alt="" class="thumb opThumb" /></a>
						</if>
						<if !DELETED_THUMBNAIL>
							<div class="thumb nothumb"><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div>
						</if>
					</if>
				</if>
				<a id="<var $num>"></a>
				<div class="parentPostInfo">
					<label ><input type="checkbox" name="delete" value="<var $num>" />
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
					<var $date></label>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var getPrintedReplyLink($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					<if $sticky><img src="http://<var DOMAIN>/img/sticky.gif"/></if>
					<if $locked><img src="http://<var DOMAIN>/img/closed.gif"/></if>
					</span>&nbsp;
					<if !$thread>[<a href="<var getPrintedReplyLink($num,0)>"><const S_REPLY></a>]</if>
					<a href="javascript:void(0)" onclick="togglePostMenu('postMenu<var $num>','postMenuButton<var $num>');"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
					<div class="postMenu" id="postMenu<var $num>">
						<a href="javascript:void(0)" onclick="reportPostPopup(<var $num>, '<var BOARD_DIR>')" class="postMenuItem">Report this post</a>
						<a href="javascript:void(0)" onclick="deletePost(<var $num>)" class="postMenuItem">Delete this post</a>
						<span href="javascript:void(0)" class="postMenuItem">Filter</span>
						<a href="http://www.facebook.com/sharer.php?u=http://www.glauchan.org&t=Glauchan" onclick="sharePost(<var $num>, '<var BOARD_DIR>')" class="postMenuItem" target="_blank">Post to Facebook</a>
						<a href="https://twitter.com/share?url=http://www.glauchan.org" onclick="sharePost(<var $num>, '<var BOARD_DIR>')" class="postMenuItem" target="_blank">Post to Twitter</a>
					</div>
				</div>
				<blockquote<if $email=~/aa$/i> class="aa"</if>>
				<var $comment>
				<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,getPrintedReplyLink($num,$parent))></div></if>
				</blockquote>
			</div>
			<if $omit>
				<span class="omittedposts">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
				</span>
			</if>
		</if>
		<if $parent>
			<div class="replyContainer" id="replyContainer<var $num>">
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
						<a href="javascript:void(0)" onclick="reportPostPopup(<var $num>, '<var BOARD_DIR>')" class="postMenuItem">Report this post</a>
						<a href="javascript:void(0)" onclick="deletePost(<var $num>)" class="postMenuItem">Delete this post</a>
						<span href="javascript:void(0)" class="postMenuItem">Filter</span>
						<a href="javascript:void(0)" onclick="sharePost(<var $num>, '<var BOARD_DIR>')" class="postMenuItem">Share</a>
					</div>
					&nbsp;
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
							</if>
						</if>
					</if>
					<blockquote<if $email=~/aa$/i> class="aa"</if>>
						<var $comment>
						<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,getPrintedReplyLink($num,$parent))></div></if>
					</blockquote>
				</div>
			</div>
		</if>
	</loop>
	</div>
	<hr />
</loop>

<div class="denguses">}.include("include/bottomad.html").q{</div>

<hr />

<if $thread>
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
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
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
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

use constant LIST_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
	<div class="theader">Thread Index</div>
	<table id="threadList" style="white-space: nowrap;">
		<thead><tr class="head">
			<td class="postBlock">Subject</td>
			<td class="postBlock">Last post by</td>
			<td class="postBlock">Time</td>
			<td class="postBlock">Post ID</td>
		</tr></thead>
		<tbody><loop $threads><tr>
			<td><a href="/<var BOARD_DIR>/res/<var $num>"><if $subject><var $subject></if><if !$subject><var truncateComment($comment)></if></a></td>
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


#
# Admin pages
#

use constant MANAGER_HEAD_INCLUDE => MINIMAL_HEAD_INCLUDE.q{

<if $admin>
	<div id="reportQueue" style="display: none; height: 100%; position: fixed; right: 0; float: right; padding-top: 30px; width: 360px; background-color:#f1f1f1; border-left: 1px solid grey;">
		<div style="padding: 10px; clear: both;">
			<div style="float:right;"><a id="closeReportQueue" href="javascript:void(0)">[ x ]</a></div>
			<h3 style="margin: 0">Report Queue</h3>
			[<a id="refreshReportsButton" href="javascript:void(0)">Refresh Reports</a>]
		</div>
		<div style="clear:both;"></div>
		<div id="reportsContainer" style="clear:both; overflow-y:auto; overflow-x: hidden; height: 100%">
		</div>
	</div>
	
	<if ($session-\>[1] eq 'mod')||($session-\>[1] eq 'admin')>
		<div id="topNavContainer">
			<div id="topNavLeft">
				<strong>Navigation:&nbsp;&nbsp;</strong>
				<select id="managerBoardList" onchange="window.location = 'http://<var DOMAIN>/'+value+'/wakaba.pl?task=mpanel&admin=<var $admin>'">
					<option value="glau">/glau/</option>
					<option value="meta">/meta/</option>
					<option value="test">/test/</option>
					<option value="#">Boards</option>
				</select>
			</div>
		</div>
		<script>
			document.getElementById("managerBoardList").selectedIndex = 3;
		</script>
	</if>
	
	<div class="logo" style="margin-top: 30px;">
		<const TITLE>
	</div>
	
	<div style="width: 100%; text-align: center; margin-bottom: 30px; margin-top: 10px;">
		<hr / >
		<h2 style="color: red; margin: 0;">Announcements</h3>
		}.include("../managementannouncement.html").q{
		<hr / >
	</div>
</if>

[<a href="<var expand_filename(HTML_SELF)>"><const S_MANARET></a>]

<if $admin>
	[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>"><const S_MANAPANEL></a>]
	<if $session-\>[1] eq 'mod'>
		[<a href="<var $self>?task=bans&amp;admin=<var $admin>"><const S_MANABANS></a>]
		[<a href="<var $self>?task=mpost&amp;admin=<var $admin>"><const S_MANAPOST></a>]
		[<a href="<var $self>?task=rebuild&amp;admin=<var $admin>"><const S_MANAREBUILD></a>]
	</if>
	<if $session-\>[1] eq 'admin'>
		[<a href="<var $self>?task=bans&amp;admin=<var $admin>"><const S_MANABANS></a>]
		[<a href="<var $self>?task=proxy&amp;admin=<var $admin>"><const S_MANAPROXY></a>]
		[<a href="<var $self>?task=spam&amp;admin=<var $admin>"><const S_MANASPAM></a>]
		[<a href="<var $self>?task=sqldump&amp;admin=<var $admin>"><const S_MANASQLDUMP></a>]
		[<a href="<var $self>?task=sql&amp;admin=<var $admin>"><const S_MANASQLINT></a>]
		[<a href="<var $self>?task=mpost&amp;admin=<var $admin>"><const S_MANAPOST></a>]
		[<a href="<var $self>?task=rebuild&amp;admin=<var $admin>"><const S_MANAREBUILD></a>]
	</if>
	[<a id="reportQueueButton" href="javascript:void(0)"><const S_REPORTS></a>]
	[<a href="<var $self>?task=logout"><const S_MANALOGOUT></a>]
	<div style="float: right"> <strong>User:</strong> <var $session-\>[0]> <strong>Class:</strong> <var $session-\>[1]> </div>
</if>
<div class="passvalid" style="margin-top: 5px; padding: 3px;"><const S_MANAMODE></div><br />

};

use constant ADMIN_LOGIN_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div align="center"><form action="<var $self>" method="post">
<input type="hidden" name="task" value="admin" />
<input type="hidden" name="nexttask" value="mpanel" />
<const S_ADMINPASS>
<input type="password" name="berra" size="8" value="" />
<br />
<label><input type="checkbox" name="savelogin" /> <const S_MANASAVE></label>
<br />
<input type="submit" value="<const S_MANASUB>" />
</form></div>

}.NORMAL_FOOT_INCLUDE);


use constant POST_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="delete" />
<input type="hidden" name="admin" value="<var $admin>" />

<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

<table align="center" style="white-space: nowrap"><tbody>
<tr class="managehead"><const S_MPTABLE></tr>

<loop $posts>
	<if !$parent><tr class="managehead"><th colspan="6"></th></tr></if>
	<tr class="row<var $rowtype>">
		<if !$image><td></if>
		<if $image><td rowspan="2"></if>
		<label><input type="checkbox" name="delete" value="<var $num>" /><strong class="admNum"><var $num></strong>&nbsp;&nbsp;</label><if !$parent><a onclick="togglePostMenu('postMenu<var $num>','postMenuButton<var $num>');" href="javascript:void(0)" class="postMenuButton" id="postMenuButton<var $num>">[ <span></span> ]</a><div class="postMenu" id="postMenu<var $num>">
			<a class="postMenuItem" href="javascript:void(0)">Move</a>
			<a class="postMenuItem" href="http://<var DOMAIN>/<var BOARD_DIR>/wakaba.pl?admin=<var $admin>&task=stickdatshit&num=<var $num>&jimmies=<if $sticky==1>rustled</if><if !$sticky>unrustled</if>">Toggle Sticky</a>
			<a class="postMenuItem" href="http://<var DOMAIN>/<var BOARD_DIR>/wakaba.pl?admin=<var $admin>&task=permasage&num=<var $num>&jimmies=<if $permasage==1>rustled</if><if !$permasage>unrustled</if>">Toggle Permasage</a>
			<a class="postMenuItem" href="http://<var DOMAIN>/<var BOARD_DIR>/wakaba.pl?admin=<var $admin>&task=lockthread&num=<var $num>&jimmies=<if $locked==1>rustled</if><if !$locked>unrustled</if>">Toggle Lock</a>
		</div></if></td>
		<td><var make_date($timestamp,"tiny")></td>
		<td><var clean_string(substr $subject,0,20)></td>
		<td><strong><var $name></strong><var $trip></td>
		<td><var clean_string(substr $comment,0,30)></td>
		<td><if $session-\>[1] ne 'janitor'><var dec_to_dot($ip)></if><if $session-\>[1] eq 'janitor'>ID: <var make_id_code($ip,$time,$email)></if>[<a href="<var $self>?admin=<var $admin>&amp;task=deleteall&amp;ip=<var $ip>"><const S_MPDELETEALL></a>]<if $session-\>[1] ne 'janitor'>[<a href="<var $self>?admin=<var $admin>&amp;task=addip&amp;type=ipban&amp;ip=<var $ip>" onclick="return do_ban(this)"><const S_MPBAN></a>]</if></td>
	</tr>
	<if $image>
		<tr class="row<var $rowtype>">
		<td colspan="6"><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image))>"><var clean_string($image)></a>
		(<var $size> B, <var $width>x<var $height>)&nbsp; MD5: <var $md5>
		</small></td></tr>
	</if>
</loop>

</tbody></table>

<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

</form>

<br /><div class="postarea">

<if $session-\>[1] ne 'janitor'>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>
</if>

</div><br />

<var sprintf S_IMGSPACEUSAGE,int($size/1024)>

}.NORMAL_FOOT_INCLUDE);




use constant BAN_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MANABANS></div>

<div class="postarea">
<table><tbody><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANIP>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWHITELIST>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="wordban" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_BANWORDLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWORD>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_BANTRUSTTRIP></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postBlock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANTRUST>" /></td></tr>
</tbody></table></form>

</td></tr></tbody></table>
</div><br />

<table align="center"><tbody>
<tr class="managehead"><const S_BANTABLE></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="6"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq 'ipban'>
		<td>IP</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
	</if>
	<if $type eq 'wordban'>
		<td>Word</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'trust'>
		<td>NoCap</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'whitelist'>
		<td>Whitelist</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
	</if>

	<td><var $comment></td>
	<td><a href="<var $self>?admin=<var $admin>&amp;task=removeban&amp;num=<var $num>"><const S_BANREMOVE></a></td>
	</tr>
</loop>

</tbody></table><br />

}.NORMAL_FOOT_INCLUDE);

use constant PROXY_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MANAPROXY></div>
        
<div class="postarea">
<table><tbody><tr><td valign="bottom">

<if !ENABLE_PROXY_CHECK>
	<div class="dellist"><const S_PROXYDISABLED></div>
	<br />
</if>        
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addproxy" />
<input type="hidden" name="type" value="white" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postBlock"><const S_PROXYIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postBlock"><const S_PROXYTIMELABEL></td><td><input type="text" name="timestamp" size="24" />
<input type="submit" value="<const S_PROXYWHITELIST>" /></td></tr>
</tbody></table></form>

</td></tr></tbody></table>
</div><br />

<table align="center"><tbody>
<tr class="managehead"><const S_PROXYTABLE></tr>

<loop $scanned>
        <if $divider><tr class="managehead"><th colspan="6"></th></tr></if>

        <tr class="row<var $rowtype>">

        <if $type eq 'white'>
                <td>White</td>
	        <td><var $ip></td>
        	<td><var $timestamp+PROXY_WHITE_AGE-time()></td>
        </if>
        <if $type eq 'black'>
                <td>Black</td>
	        <td><var $ip></td>
        	<td><var $timestamp+PROXY_BLACK_AGE-time()></td>
        </if>

        <td><var $date></td>
        <td><a href="<var $self>?admin=<var $admin>&amp;task=removeproxy&amp;num=<var $num>"><const S_PROXYREMOVEBLACK></a></td>
        </tr>
</loop>

</tbody></table><br />

}.NORMAL_FOOT_INCLUDE);


use constant SPAM_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div align="center">
<div class="dellist"><const S_MANASPAM></div>
<p><const S_SPAMEXPL></p>

<form action="<var $self>" method="post">

<input type="hidden" name="task" value="updatespam" />
<input type="hidden" name="admin" value="<var $admin>" />

<div class="buttons">
<input type="submit" value="<const S_SPAMSUBMIT>" />
<input type="button" value="<const S_SPAMCLEAR>" onclick="document.forms[0].spam.value=''" />
<input type="reset" value="<const S_SPAMRESET>" />
</div>

<textarea name="spam" rows="<var $spamlines>" cols="60"><var $spam></textarea>

<div class="buttons">
<input type="submit" value="<const S_SPAMSUBMIT>" />
<input type="button" value="<const S_SPAMCLEAR>" onclick="document.forms[0].spam.value=''" />
<input type="reset" value="<const S_SPAMRESET>" />
</div>

</form>

</div>

}.NORMAL_FOOT_INCLUDE);



use constant SQL_DUMP_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MANASQLDUMP></div>

<pre class="sqldump"><code><var $database></code></pre>

}.NORMAL_FOOT_INCLUDE);



use constant SQL_INTERFACE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MANASQLINT></div>

<div align="center">
	<form action="<var $self>" method="post">
		<input type="hidden" name="task" value="sql" />
		<input type="hidden" name="admin" value="<var $admin>" />

		<textarea name="sql" rows="10" cols="60"></textarea>

		<div class="delbuttons"><const S_SQLNUKE>
			<input type="password" name="nuke" value="<var $nuke>" />
			<input type="submit" value="<const S_SQLEXECUTE>" />
		</div>
	</form>
	
	<hr />
	<br /><br /><br />
	
	<strong><a href="javascript:void(0)" onclick="if(document.getElementById('nukeBoard').style.display=='none'){document.getElementById('nukeBoard').style.display='block';}else{document.getElementById('nukeBoard').style.display='none';}">Nuke Board</a></strong>
	<div id="nukeBoard" style="display:none">
		<form action="<var $self>" method="post">
			<input type="hidden" name="task" value="nuke" />
			<div class="delbuttons"><const S_SQLNUKE>
				<input type="password" name="admin" value="<var $nuke>" />
				<input type="submit" value="Nuke Board" />
			</div>
		</form>
	</div>
</div>



<pre><code><var $results></code></pre>

}.NORMAL_FOOT_INCLUDE);




use constant ADMIN_POST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div align="center"><em><const S_NOTAGS></em></div>

<div class="postarea">
<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
<input type="hidden" name="task" value="post" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="no_captcha" value="1" />
<br />
<label>Self Format<input type="checkbox" name="no_format" value="1" /></label><br />
<label>Sticky Thread<input type="checkbox" name="sticky" value="1" /></label>

<table><tbody>
<tr><td class="postBlock"><const S_NAME></td><td><input type="text" name="field1" size="28" /></td></tr>
<tr><td class="postBlock"><const S_EMAIL></td><td><input type="text" name="field2" size="28" /></td></tr>
<tr><td class="postBlock"><const S_SUBJECT></td><td><input type="text" name="field3" size="35" />
<input type="submit" value="<const S_SUBMIT>" /></td></tr>
<tr><td class="postBlock"><const S_COMMENT></td><td><textarea name="field4" cols="48" rows="4"></textarea></td></tr>
<tr><td class="postBlock"><const S_UPLOADFILE></td><td><input type="file" name="file" size="35" />
<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE> </label>
</td></tr>
<tr><td class="postBlock"><const S_PARENT></td><td><input type="text" name="parent" size="8" /></td></tr>
<tr><td class="postBlock"><const S_DELPASS></td><td><input type="password" name="password" size="8" /><const S_DELEXPL></td></tr>
</tbody></table></form></div><hr />
<script type="text/javascript">set_inputs("postform")</script>

}.NORMAL_FOOT_INCLUDE);



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

		($sheet{title})=m!([^/]+)\.css$!i;
		$sheet{title}=ucfirst $sheet{title};
		$sheet{title}=~s/_/ /g;
		$sheet{title}=~s/ ([a-z])/ \u$1/g;
		$sheet{title}=~s/([a-z])([A-Z])/$1 $2/g;

		if($sheet{title} eq DEFAULT_STYLE) { $sheet{default}=1; $found=1; }
		else { $sheet{default}=0; }

		\%sheet;
	} glob(CSS_DIR."*.css");

	$stylesheets[0]{default}=1 if(@stylesheets and !$found);

	return \@stylesheets;
}

1;

