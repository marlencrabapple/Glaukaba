use strict;
use POSIX qw/strftime/;
BEGIN { require "wakautils.pl" }

use constant BOARD_OPTIONS => q{
<if !$noextra>
<div id="overlay">
	<div id="navOptionsMenu">
		<div id="navOptionsTopBar">
			Board Options
		</div>
		<hr>
		<div id="navOptionsContent">
			<p>
				<strong>Style Options</strong><br>
				<loop $stylesheets>[<a href="javascript:set_stylesheet('<var $title>')" ><var $title></a>] </loop>
			</p>
			<p>
				<strong>General Enhancements</strong><br>
				<label class="navOptionsListItem"><input id="expandPosts" type=checkbox onchange="toggleFeature('expandPosts',this.checked);">Comment Expansion</label>: Expands truncated comments<br>
				<label class="navOptionsListItem"><input id="expandThreads" type=checkbox onchange="toggleFeature('expandThreads',this.checked);">Thread Expansion</label>: View all replies without changing pages<br>
				<label class="navOptionsListItem"><input id="fixedNav" type=checkbox onchange="toggleFeature('fixedNav',this.checked);">Fixed Navigation</label>: Pins navigation to the top of the page even when scrolling<br>
			</p>
			<p>
				<strong>Filtering</strong><br>
				<label class="navOptionsListItem"><input id="replyHiding" type=checkbox onchange="toggleFeature('replyHiding',this.checked);">Reply Hiding</label>: Hide replies<br>
				<label class="navOptionsListItem"><input id="threadHiding" type=checkbox onchange="toggleFeature('threadHiding',this.checked);">Thread Hiding</label>: Hide threads<br>
				<label class="navOptionsListItem"><input id="anonymize" type=checkbox onchange="toggleFeature('anonymize',this.checked);">Anonymize</label>: Makes everybody anonymous<br>
			</p>
			<p>
				<strong>Image Options</strong><br>
				<label class="navOptionsListItem"><input id="inlineExpansion" type=checkbox onchange="toggleFeature('inlineExpansion',this.checked);">Inline Expansion</label>: View fullsize images without opening a new window or tab<br>
				<label class="navOptionsListItem"><input id="reverseImgSearch" type=checkbox onchange="toggleFeature('reverseImgSearch',this.checked);">Reverse Image Search</label>: Insert links to reverse image search engines<br>
				<textarea id="reverseImgSearchLinks" onchange="toggleFeature('reverseImgSearchLinks',this.value)"></textarea>
			</p>
			<p>
				<strong>Monitoring</strong><br>
				<label class="navOptionsListItem"><input id="threadUpdater" type=checkbox onchange="toggleFeature('threadUpdater',this.checked);">Thread Updater</label>: Get new posts automatically without refreshing the page<br>
				<label class="navOptionsListItem"><input id="expandFilename" type=checkbox onchange="toggleFeature('expandFilename',this.checked);">Expand Filenames</label>: Expands an image's filename on mouseover<br>
			</p>
			<p>
				<strong>Posting</strong><br>
				<label class="navOptionsListItem"><input id="qRep" type=checkbox onchange="toggleFeature('qRep',this.checked);">Quick Reply</label>: Reply without reloading the page<br>
			</p>
			<p>
				<strong>Quoting</strong><br>
				<label class="navOptionsListItem"><input id="quotePreview" type=checkbox onchange="toggleFeature('quotePreview',this.checked);">Quote Previews</label>: Show quoted post on hover<br>
				<label class="navOptionsListItem"><input id="inlineQuote" type=checkbox onchange="toggleFeature('inlineQuote',this.checked);">Inline Quotes</label>: Show quoted post inline when clicked on<br>
				<label class="navOptionsListItem"><input id="replyBacklinking" type=checkbox onchange="toggleFeature('replyBacklinking',this.checked);">Post Backlinks</label>: Shows a post's replies in its header<br>
				<label class="navOptionsListItem"><input id="markPosts" type=checkbox onchange="toggleFeature('markPosts',this.checked);">Mark Replies</label>: Appends "(You)" to all posts linking to yours<br>
			</p>
		</div>
	</div>
</div>
</if>
};

use constant SITE_VARS_INCLUDE => q{
<script>
var sitevars = {
	"sitename": "<const SITE_NAME>",
	"domain": "//<const DOMAIN>/",
	"boarddir": "<const BOARD_DIR>",
	"boardpath": "//<const DOMAIN>/<const BOARD_DIR>/",
	"social": <if SOCIAL>1</if><if !SOCIAL>0</if>,
	"noext": <if REWRITTEN_URLS>1</if><if !REWRITTEN_URLS>0</if>
};
</script>
};

use constant NORMAL_HEAD_INCLUDE => q{
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="description" content="<const SUBTITLE>">
<title><if $title><var $title> - </if><const TITLE></title>
<link rel="shortcut icon" href="<var expand_filename(FAVICON)>">
<style type="text/css">
	form { margin-bottom: 0px }
	form .trap { display:none }
	.reflink a { color: inherit; text-decoration: none }
	.reply .filesize { margin-left: 20px }
	.userdelete { float: right; text-align: center; white-space: nowrap }
	.replypage .replylink { display: none }
	.sjis { font-family: Mona,'MS PGothic' !important; font-size: 12pt; }
	.recaptchatable { border: none; }
</style>
<link rel="stylesheet" href="//<var DOMAIN>/css/Boards.css">
<loop $stylesheets>
<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="//<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" title="<var $title>">
</loop>
<link rel="stylesheet" href="//<var DOMAIN>/css/mobile.css">
<link href="//<var DOMAIN>/css/prettify.css" type="text/css" rel="stylesheet">
}.SITE_VARS_INCLUDE.q{
<if !$noextra>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
</if>
<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
<script type="text/javascript" src="//<var DOMAIN>/js/<var JS_FILE>"></script>
<if !$noextra><script type="text/javascript" src="//<var DOMAIN>/js/<var EXTRA_JS_FILE>"></script>
<script type="text/javascript" src="//<var DOMAIN>/js/logo.js"></script></if>
<if !$noextra>
<script type="text/javascript" src="//<var DOMAIN>/js/prettify/prettify.js"></script>
<script type="text/javascript" src="//<var DOMAIN>/js/jquery.jqote2.min.js"></script>
</if>
</head>
<if $thread><body class="replypage"></if>
<if $indexpage><body class="indexpage"></if>
<if !$indexpage><if !$thread><body></if></if>
<a id="top"></a>
<div id="topNavStatic" class="staticNav">
	[<loop BOARDS><a href="//<const DOMAIN>/<var $dir>/" title="/<var $dir>/ - <var $name>"><var $dir></a><if !$lastBoard> / </if></loop>]
	<if LINKS>[<loop LINKS><a href="<var $url>" <if $rel>rel="<var $rel>"</if>><var $name></a><if !$lastlink> / </if></loop>]</if>
	<div style="float:right">
		[<a href="javascript:void(0)" onclick="toggleNavMenu(this,0);">Settings</a>]
		[<a href="//<const DOMAIN>">Home</a>]
	</div>
</div>
<div class="topNavContainer">
	}.include("include/header.html").q{
	<div class="topNavRight">
		<span>[<a href="javascript:void(0)" onclick="toggleNavMenu(this,0);">Settings</a>]</span>
	</div>
</div>
<div class="logo">
	<if SHOWTITLEIMG><div id="image"><img src="<const TITLEIMG>" class='banner' alt="<const TITLE>"></div></if>
	<h1 class="title"><const TITLE></h1>
	<h2 class="logoSubtitle"><const SUBTITLE></h2>
	<if TITLEIMGSCRIPT><script>logoSwitch();</script></if>
</div>
<if !$thread><if $indexpage>
	<div id="topPageNumber" class="pageNumber">
		<if $prevpage><button onclick="location.href='<var $prevpage>'"><const S_PREV></button></if>
		<if !$prevpage><const S_FIRSTPG></if>
		<loop $pages>
			<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
			<if $current>[<var $page>]</if>
		</loop>
		<if $nextpage><button onclick="location.href='<var $nextpage>'"><const S_NEXT></button></if>
		<if !$nextpage><const S_LASTPG></if>
		<if ENABLE_CATALOG>
			<div class="catalogLink">
				<a href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a>
			</div>
		</if>
		<if ENABLE_LIST>
			<div class="catalogLink">
				<a href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a>
			</div>
		</if>
	</div>
</if></if>
<hr class="postinghr">
<if !$admin><div class="denguses"><var include("include/topad.html",1)></div></if>
}.BOARD_OPTIONS;

use constant MINIMAL_HEAD_INCLUDE => q{
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>">
		<meta name="viewport" content="width=device-width,initial-scale=1">
		<title><if $title><var $title> - </if><if $noboard><const TITLE></if><if !$noboard><const SITE_NAME></if></title>
		<link rel="shortcut icon" href="<var expand_filename(FAVICON)>">
		<style type="text/css">
			form { margin-bottom: 0px }
			form .trap { display:none }
			.reflink a { color: inherit; text-decoration: none }
			.reply .filesize { margin-left: 20px }
			.userdelete { float: right; text-align: center; white-space: nowrap }
			.replypage .replylink { display: none }
			.sjis { font-family: Mona,'MS PGothic' !important; font-size: 12pt; }
			.recaptchatable { border: none; }
		</style>
		<link rel="stylesheet" href="//<var DOMAIN>/css/Boards.css">
		<loop $stylesheets>
		<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="//<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" title="<var $title>">
		</loop>
		<link rel="stylesheet" href="//<var DOMAIN>/css/mobile.css">
		<link href="//<var DOMAIN>/css/prettify.css" type="text/css" rel="stylesheet">
		<link rel="stylesheet" href="//<var DOMAIN>/css/manage.css">
		<if !$noextra>
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		</if>
		<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
		<script type="text/javascript" src="//<var DOMAIN>/js/<var JS_FILE>"></script>
		<if !$noextra><script type="text/javascript" src="//<var DOMAIN>/js/<var EXTRA_JS_FILE>"></script></if>
		<if $admin><script type="text/javascript" src="//<var DOMAIN>/js/glaukaba-admin.js"></script></if>
		<if !$noextra>
		<script type="text/javascript" src="//<var DOMAIN>/js/prettify/prettify.js"></script>
		<script type="text/javascript" src="//<var DOMAIN>/js/jquery.jqote2.min.js"></script>
		</if>
		}.SITE_VARS_INCLUDE.q{
	</head>
	<if $thread><body class="replypage"></if>
	<if $indexpage><body class="indexpage"></if>
	<if !$indexpage><if !$thread><body></if></if>
	<a id="top"></a>
}.BOARD_OPTIONS;

use constant CONTENT_HEAD_INCLUDE => q{
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>">
		<meta name="viewport" content="width=device-width,initial-scale=1">
		<title><if $title><var $title> - </if><const SITE_NAME></title>
		<link rel="shortcut icon" href="<var expand_filename(FAVICON)>">
		<style type="text/css">
			body { margin: 0; margin-bottom: auto; }
			form { margin-bottom: 0px }
			form .trap { display:none }
			.postarea table { margin: 0px auto; text-align: left }
			.reflink a { color: inherit; text-decoration: none }
			.reply .filesize { margin-left: 20px }
			.userdelete { float: right; text-align: center; white-space: nowrap }
			.replypage .replylink { display: none }
			.sjis { font-family: Mona,'MS PGothic' !important; font-size: 12pt; }
		</style>
		<link href="//<var DOMAIN>/css/Boards.css" type="text/css" rel="stylesheet">
		<loop $stylesheets>
		<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="//<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>">
		</loop>
		<link href="//<var DOMAIN>/css/othercontent.css" type="text/css" rel="stylesheet">
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
		<script type="text/javascript" src="//<var DOMAIN>/js/logo.js"></script>
		}.SITE_VARS_INCLUDE.q{
	</head>
	<body class="contentPage">
	<a id="top"></a>
};

use constant CONTENT_FOOT_INCLUDE => include("include/footer.html").q{
</body>
</html>
};

use constant NORMAL_FOOT_INCLUDE => include("include/footer.html").q{
</body>
</html>
};

use constant PAGE_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
<div id="content">
<if $thread>
<div class="desktop threadlinks">
	[<a href="//<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
	<if ENABLE_CATALOG>[<a href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a>]</if>
	<if ENABLE_LIST>[<a href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a>]</if>
	[<a href="#bottom">Bottom</a>]
	<div class="theader"><const S_POSTING></div>
</div>
<div class="mobile threadlinks">
	<a href="//<var DOMAIN>/<var BOARD_DIR>" class="button"><const S_RETURN></a>
	<if ENABLE_CATALOG><a class="button" href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a></if>
	<if ENABLE_LIST><a class="button" href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a></if>
	<a class="button" href="#bottom">Bottom</a>
</div>
</if>
<if $postform>
	<script type="text/javascript">
		var RecaptchaOptions = {
			theme : 'clean'
		};
	</script>
	
	<div style="text-align:center">
	<a id="postFormToggle" class="button" onclick="togglePostForm()" href="javascript:void(0)">
		<if !$thread>New Thread</if>
		<if $thread>Reply</if>
	</a>
	</div>
	
	<form action="<var $self>" method="post" id="post_form" enctype="multipart/form-data">
		<input type="hidden" name="task" value="post">
		<if $thread><input type="hidden" name="parent" value="<var $thread>"></if>
		<if !$image_inp and !$thread and ALLOW_TEXTONLY><input type="hidden" name="nofile" value="1"></if>
		<if FORCED_ANON><input type="hidden" name="name"></if>
		<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name"  autocomplete="off"><input type="text" name="link" autocomplete="off"></div></if>
		<div id="postForm">
			<if !FORCED_ANON><div class="postTableContainer">
					<div class="postBlock">Name</div>
					<div class="postField"><input type="text" class="postInput" name="field1" id="field1"></div>
				</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Link</div>
				<div class="postField"><input type="text" class="postInput" name="field2" id="field2"></div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Subject</div>
				<div class="postField">
					<input type="text" name="field3" class="postInput" id="field3">
					<input type="submit" id="field3s" value="Submit">
				</div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Comment</div>
				<div class="postField"><textarea name="field4" class="postInput" id="field4"></textarea></div>
			</div>
			<if ENABLE_CAPTCHA && ENABLE_CAPTCHA ne 'recaptcha'><div class="postBlock"><const S_CAPTCHA></div>
				<div class="postField">
					<input type="text" name="captcha" class="field6" size="10">
					<img alt="" src="<var expand_filename(CAPTCHA_SCRIPT)>?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>">
				</div></if>
			<if ENABLE_CAPTCHA eq 'recaptcha'><div class="postTableContainer" id="recaptchaContainer">
					<div class="postBlock" id="captchaPostBlock"><const S_CAPTCHA></div>
					<div class="postField">
						<style type="text/css" scoped="scoped">
							.recaptchatable{background-color:transparent!important;border:none!important;}.recaptcha_image_cell{background-color:transparent!important;padding:0px!important;padding-bottom:3px!important;}#recaptcha_div{height:107px;width:442px;}#recaptcha_challenge_field{width:400px}@media only screen and (min-width: 481px) {.recaptcha_input_area{padding:0!important;}#recaptcha_table tr:first-child{height:auto!important;}#recaptcha_table tr:first-child>td:not(:first-child){padding:0 7px 0 7px!important;}#recaptcha_table tr:last-child td:last-child{padding-bottom:0!important;}#recaptcha_table tr:last-child td:first-child{padding-left:0!important;}#recaptcha_response_field{width:292px;margin-right:0px!important;font-size:10pt!important;}input:-moz-placeholder{color:gray!important;}#recaptcha_image{border:1px solid #aaa!important;}#recaptcha_table tr>td:last-child{display:none!important;}}
						</style>
						<script type="text/javascript" src="//www.google.com/recaptcha/api/challenge?k=<const RECAPTCHA_PUBLIC_KEY>"></script>
						<noscript>
							<iframe src="//www.google.com/recaptcha/api/noscript?k=<const RECAPTCHA_PUBLIC_KEY>" height="300" width="500"></iframe><br>
							<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
							<input type="hidden" name="recaptcha_response_field" value="manual_challenge">
						</noscript>
						<if PASS_ENABLED>
							<div class="passNotice">
								Bypass this CAPTCHA.
								[<a href="<if REWRITTEN_URLS>//<var DOMAIN>/pass/</if><if !REWRITTEN_URLS>//<var DOMAIN>/<const BOARD_DIR>/wakaba.pl?task=getpass</if>">Learn More</a>]
							</div>
						</if>
					</div>
					<script type="text/javascript">
						document.getElementById("recaptcha_response_field").setAttribute("placeholder", "reCAPTCHA Challenge (Required)");
						document.getElementById("recaptcha_response_field").removeAttribute("style");
						document.getElementById("recaptcha_image").setAttribute("style", "border: 1px solid #aaa!important;");
						document.getElementById("recaptcha_image").parentNode.parentNode.setAttribute("style", "padding: 0px!important; padding-bottom: 3px!important; height: 57px!important;");
						document.getElementById("recaptcha_table").setAttribute("style", "border: none!important");
					</script>
			</div></if>
			<if $image_inp><div class="postTableContainer" id="uploadField">
					<div class="postBlock">File</div>
					<div class="postField">
						<input type="file" name="file" id="file"><br>
						<if $textonly_inp><label>[<input type="checkbox" name="nofile" value="on">No File]</label></if>
						<if SPOILERIMAGE_ENABLED><label>[<input type="checkbox" name="spoiler" value="1">Spoiler]</label></if>
						<if NSFWIMAGE_ENABLED><label>[<input type="checkbox" name="nsfw" value="1">NSFW]</label></if>
					</div>
			</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Password</div>
				<div class="postField">
					<input type="password" class="postInput" id="password" name="password"/>
					<span class="passDesc">(for post and file deletion)</span>
				</div>
			</div>
			<div class="postTableContainer">
				<div class="rules">
					}.include("include/rules.html").q{
				</div>
			</div>
		</div>
	</form>
<script type="text/javascript">setPostInputs()</script></if>
<div class="denguses"><var include("include/middlead.html",1)></div>
<div id="announcement">
}.include("../announcement.html").q{
</div>
<form id="delform" action="<var $self>" method="post">
<loop $threads>
<if $thread><label class="desktop">[<input type="checkbox" onchange="expandAllImages();"> Expand Images ]</label></if>
	<div class="thread"><loop $posts>
		<if !$parent>
			<div class="parentContainer">
			<div class="parentPost" id="parent<var $num>">
				<div class="mobile mobileParentPostInfo">
					<input type="checkbox" name="delete" value="<var $num>">
					<div class="leftblock">
						<if $subject><span class="filetitle"><var $subject></span></if>
						<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip> <span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
						<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
						<if $id><span class="posterid">(ID: <span class="posteridnum"><var $id></span>)</span></if>
					</div>
					<div class="rightblock">
						<span class="date"><var $date></span>
						<span class="reflink">
							<if !$thread><a class="refLinkInner" href="<var get_reply_link($num,0)>#i<var $num>">No.<var $num></a></if>
							<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
							<if $sticky><img src="//<var DOMAIN>/img/sticky.gif" alt="Stickied"/></if>
							<if $locked><img src="//<var DOMAIN>/img/closed.gif " alt="Locked"/></if>
						</span>
						<a href="javascript:void(0)" onclick="togglePostMenu(this);"  class="postMenuButton" id="postMenuButton<var $num>Mobile">[<span></span>]</a>
						<div class="postMenu" id="postMenu<var $num>Mobile">
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
							<if SOCIAL><a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="facebookPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Facebook</a>
							<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="twitterPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Twitter</a></if>
							<a onmouseover="closeSub(this);" href="//<var DOMAIN>/<var BOARD_DIR>/res/<var $num>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
						</div>
					</div>
					<div style="clear:both"></div>
				</div>
				<if $image>
					<div class="fileinfo"><span class="filesize"><const S_PICNAME>
					<a target="_blank" href="<var expand_image_filename($image)>" title="<var $filename>">
						<if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
					- (<var int($size/1024)> KB, <var $width>x<var $height>)</span></div>
					<if $thumbnail><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>">
						<if !$tnmask><img src="<var expand_filename($thumbnail)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb"></if><if $tnmask><img src="//<var DOMAIN>/img/spoiler.png" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb"></if></a></if>
					<if !$thumbnail>
						<if DELETED_THUMBNAIL><a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>"><img src="<var expand_filename(DELETED_THUMBNAIL)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" alt="" class="thumb opThumb"></a></if>
					<if !DELETED_THUMBNAIL><div class="thumb nothumb"><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div></if></if></if>
				<a id="<var $num>"></a>
				<div class="parentPostInfo">
					<input type="checkbox" name="delete" value="<var $num>">
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip> <span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
					<if $id><span class="posterid">(ID: <span class="posteridnum"><var $id></span>)</span></if>
					<span class="date"><var $date></span>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var get_reply_link($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					<if $sticky><img src="//<var DOMAIN>/img/sticky.gif" alt="Stickied"/></if>
					<if $locked><img src="//<var DOMAIN>/img/closed.gif " alt="Locked"/></if>
					</span>&nbsp;
					<if !$thread>[<a href="<var get_reply_link($num,0)>"><const S_REPLY></a>]</if>
					<a href="javascript:void(0)" onclick="togglePostMenu(this);"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
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
						<if SOCIAL><a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="facebookPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Facebook</a>
						<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="twitterPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Twitter</a></if>
						<a onmouseover="closeSub(this);" href="//<var DOMAIN>/<var BOARD_DIR>/res/<var $num>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
					</div>
				</div>
				<blockquote<if $email=~/aa$/i> class="aa"</if>>
					<var $comment>
					<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
					<if SHOW_STAFF_POSTS>
						<if $capcodereplies\>0>
							<br><br>
							<span class="capcodeReplies">
								<if $adminreplies><strong>Administrator Replies: </strong><var $adminreplies><br></if>
								<if $modreplies><strong>Moderator Replies: </strong><var $modreplies><br></if>
								<if $devreplies><strong>Developer Replies: </strong><var $devreplies><br></if>
								<if $vipreplies><strong>VIPPER Replies: </strong><var $vipreplies></if>
							</span>
						</if>
					</if>
				</blockquote>
			</div>
			<if !$thread>
			<div class="mobilePostReplyLink mobile">
			<if $omit><span class="omittedposts mobile">
				<if $omitimages><var sprintf S_ABBRIMG_M,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR_M,$omit></if>
			</span></if>
				<a class="button" href="<var get_reply_link($num,0)>"><const S_REPLY></a>
			</div>
			</if>
			</div>
			
			<if $omit><span class="omittedposts desktop">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
			</span></if>
		</if>
		<if $parent><div class="replyContainer" id="replyContainer<var $num>">
				<div class="doubledash">&gt;&gt;</div>
				<div class="reply" id="reply<var $num>">
					<a id="<var $num>"></a>
					<div class="replyPostInfo"><input type="checkbox" name="delete" value="<var $num>">
						<div class="leftblock">
							<if $subject><span class="replytitle"><var $subject></span></if>
							<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
							<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
							<if $id><span class="posterid">(ID: <span class="posteridnum"><var $id></span>)</span></if>
						</div>
						<div class="rightblock">
							<span class="date"><var $date></span>
							<span class="reflink">
							<if !$thread><a class="refLinkInner" href="<var get_reply_link($parent,0)>#i<var $num>">No.<var $num></a></if>
							<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if></span>
							<a href="javascript:void(0)" onclick="togglePostMenu(this);"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
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
								<if SOCIAL><a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="facebookPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Facebook</a>
								<a onmouseover="closeSub(this);" href="javascript:void(0);" onclick="twitterPost(<var $num>,<var $parent>)" class="postMenuItem">Post to Twitter</a></if>
								<a href="//<var DOMAIN>/<var BOARD_DIR>/res/<var $parent>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
							</div>
						</div>
						<div style="clear:both"></div>
					</div>
					<if $image>
						<div class="fileinfo">
							<span class="filesize">
								<const S_PICNAME>
								<a target="_blank" href="<var expand_image_filename($image)>" title="<var $filename>">
									<if !$filename><var get_filename($image)></a></if>
									<if $filename><var truncateLine($filename)></a></if>
								- (<var int($size/1024)> KB, <var $width>x<var $height>)
							</span>
						</div>
						<if $thumbnail>
							<a class="thumbLink" target="_blank" href="<var expand_image_filename($image)>">
								<if !$tnmask><img src="<var expand_filename($thumbnail)>" alt="<var $size>" class="thumb replyThumb" data-md5="<var $md5>" style="width: <var $tn_width*.504>px; height: <var $tn_height*.504>px;"></if><if $tnmask><img src="//<var DOMAIN>/img/spoiler.png" alt="<var $size>" class="thumb replyThumb" data-md5="<var $md5>"></if></a>
						</if>
						<if !$thumbnail>
							<if DELETED_THUMBNAIL>
								<a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>">
								<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" class="thumb replyThumb"></a>
							</if>
							<if !DELETED_THUMBNAIL>
								<div class="thumb replyThumb nothumb"><a class="thumbLink" target="_blank" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div>
							</if></if></if>
					<blockquote<if $email=~/aa$/i> class="aa"</if>>
						<var $comment>
						<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
					</blockquote>
				</div>
			</div></if>
		</loop>
	</div>
	<hr>
</loop>
<div class="denguses"><var include("include/bottomad.html",1)></div>
<if $thread>
<div class="desktop threadlinks">
[<a href="//<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
<if ENABLE_CATALOG>[<a href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a>]</if>
<if ENABLE_LIST>[<a href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a>]</if>
[<a href="#">Top</a>]
</div>
<div class="mobile threadlinks">
<a href="//<var DOMAIN>/<var BOARD_DIR>" class="button"><const S_RETURN></a>
<if ENABLE_CATALOG><a class="button" href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a></if>
<if ENABLE_LIST><a class="button" href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a></if>
<a class="button" href="#">Top</a>
<hr>
</div>
<a id="bottom"></a>
</if>
<div id="deleteForm">
	<input type="hidden" name="task" value="delete">
	Delete Post
	<label>[<input type="checkbox" name="fileonly" value="on"> <const S_DELPICONLY>]</label>
	<const S_DELKEY><input type="password" name="password" id="delPass" class="postInput"/>
	<input value="<const S_DELETE>" type="submit" class="formButtom">
	<script type="text/javascript">setDelPass();</script>
	<div class="styleChanger">
		Style
		<select id="styleSelector" onchange="set_stylesheet(value)">
			<loop $stylesheets><option value="<var $title>"><var $title></option></loop>
		</select>
	</div>
</div>
</form>
<if !$thread>
	<div class="pageNumber">
		<if $prevpage><button onclick="location.href='<var $prevpage>'"><const S_PREV></button></if>
		<if !$prevpage><const S_FIRSTPG></if>
		<loop $pages>
			<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
			<if $current>[<var $page>]</if>
		</loop>
		<if $nextpage><button onclick="location.href='<var $nextpage>'"><const S_NEXT></button></if>
		<if !$nextpage><const S_LASTPG></if>
		<if ENABLE_CATALOG>
			<div class="catalogLink">
				<a href="//<const DOMAIN>/<const BOARD_DIR>/catalog<if !REWRITTEN_URLS>.html</if>">Catalog</a>
			</div>
		</if>
		<if ENABLE_LIST>
			<div class="catalogLink">
				<a href="//<const DOMAIN>/<const BOARD_DIR>/subback<if !REWRITTEN_URLS>.html</if>">Thread List</a>
			</div>
		</if>
	</div>
</if>
<div id="bottomNavStatic" class="staticNav">
	[<loop BOARDS><a href="//<const DOMAIN>/<var $dir>/"><var $dir></a><if !$lastBoard> / </if></loop>]
	<div style="float:right">
		[<a href="javascript:void(0)" onclick="toggleNavMenu(this,0);">Settings</a>]
		[<a href="//<const DOMAIN>" title="">Home</a>]
	</div>
</div>
</div>
}.NORMAL_FOOT_INCLUDE);

use constant ERROR_TEMPLATE => compile_template(MINIMAL_HEAD_INCLUDE.q{
	<h1 id="errorMessage" style="text-align: center"><var $error></h1>
	<h3 style="text-align: center">[<a href="<var escamp($ENV{HTTP_REFERER})>"><const S_RETURN></a>]</h3>
	<hr>
}.NORMAL_FOOT_INCLUDE);

use constant REPORT_TEMPLATE => compile_template(q{
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>">
		<title>Reporting Post No.<var $num> on /<var BOARD_DIR>/</title>
		<link rel="shortcut icon" href="<var expand_filename(FAVICON)>">
		<style type="text/css">
			body { margin: 0; padding: 8px; margin-bottom: auto;}
			h3 {margin: 0; margin-bottom: 5px;}
		</style>
		<link rel="stylesheet" href="//<var DOMAIN>/css/Boards.css">
		<loop $stylesheets>
			<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="//<var DOMAIN><var CSS_DIR><var substr($filename,rindex($filename,'/')+1)>" title="<var $title>">
		</loop>
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
		<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
		<script type="text/javascript" src="//<var DOMAIN>/js/<var JS_FILE>"></script>
	</head>
	<body>
		<h3>Reporting Post No.<var $num> on /<var BOARD_DIR>/</h3>
		<form action="<var $self>" method="post" enctype="multipart/form-data">
			<input type="hidden" name="task" value="report">
			<input type="hidden" name="num" value="<var $num>">
			<input type="hidden" name="board" value="<var BOARD_DIR>">
			<fieldset style="margin-bottom: 5px;"><legend>Report type</legend>
				<input type="radio" name="reason" id="cat1" value="vio"> <label for="cat1">Rule violation</label><br/>
				<input type="radio" name="reason" id="cat2" value="illegal"> <label for="cat2">Illegal content</label><br/>
				<input type="radio" name="reason" id="cat3" value="spam"> <label for="cat3">Spam/advertising/flooding</label>
			</fieldset>
			<input type="submit" value="<const S_SUBMIT>">
		</form>
		<p style="font-size: 10px">Note: Submitting frivolous reports will result in a ban. When reporting, make sure that the post in question violates the global/board rules, or contains content illegal in the United States.</p>
	</body>
</html>
});

use constant LIST_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
[<a href="//<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
<div class="listPageHeader">Thread Index</div>
<table id="threadList" style="white-space: nowrap;">
	<thead><tr class="head">
		<td class="listHead">Subject</td>
		<td class="listHead" style="width:1%">Created by</td>
		<td class="listHead" style="width:1%">Time</td>
		<td class="listHead" style="width:1%">Post No.</td>
	</tr></thead>
	<tbody><loop $threads><tr class="listRow">
		<td class="listCol"><a href="/<var BOARD_DIR>/res/<var $num>"><if $subject><var $subject></a></if><if !$subject><var truncateComment($comment)></a></if>&nbsp;&nbsp;[<var $postcount> <if $postcount\>1 or $postcount==0>replies</if><if $postcount==1>reply</if>]</td>
		<td class="listCol"><span class="postername"><var $name></span> <span class="postertrip"><var $trip></span></td>
		<td class="listCol"><var make_date($timestamp,"tiny")></td>
		<td class="listCol">No.<var $num></td>
	</tr></loop></tbody>
</table>
<hr>
<div class="denguses"><var include("include/bottomad.html",1)></div>
<hr>
}.NORMAL_FOOT_INCLUDE);

use constant CATALOG_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
[<a href="//<var DOMAIN>/<var BOARD_DIR>"><const S_RETURN></a>]
<div class="listHead" style="margin-top: 5px;">Catalog Mode</div>
<div id="catalog">
	<loop $threads>
		<div class="catItem" id="catItem<var $num>">
			<a href="/<var BOARD_DIR>/res/<var $num>"><if $thumbnail><div class="catItemHover" id="catItem<var $num>Hover" style="width: <var $tn_width*.6>px; height: <var $tn_height*.6>px;"><div class="catItemHoverText" style="width: <var $tn_width*.6>px; height: <var $tn_height*.6>px; line-height:<var ($tn_height*.6)>px;">&gt;&gt;<var $num></div></div></if>
			<if !$thumbnail><div id="catItem<var $num>Hover" class="catItemHoverNoThumb"><div class="catItemHoverTextNoThumb">&gt;&gt;<var $num></div></div></if></a>
			<a href="/<var BOARD_DIR>/res/<var $num>"><if $thumbnail><img src="<var expand_filename($thumbnail)>" class="catImage" style="width: <var $tn_width*.6>px; height: <var $tn_height*.6>px;"></if><if !$thumbnail><div class="catImageNoThumb"></div></if></a>
			<div class="catComment" id="catItem<var $num>Comment">
				<span class="catCounts">R:<var $postcount><if $imagecount> / I:<var $imagecount></if></span><br>
				<span><if $subject><var $subject></if><if !$subject><var truncateComment($comment,200)></if></span>
			</div>
		</div>
	</loop>
</div>
<hr>
<div class="denguses"><var include("include/bottomad.html",1)></div>
<script>
	$(document).ready(function() {
		$(".catItem").mouseenter(function () {
			var catItem = $(this).attr("id");
			$("#"+catItem+"Hover").fadeTo(200, 0.6, function () {
				$("#"+catItem+"Hover").css("visibility", "visible");
			});
		});
		
		$(".catItem").mouseleave(function () {
			var catItem = $(this).attr("id");
			$("#"+catItem+"Hover").fadeTo(200, 0, function () {
				$("#"+catItem+"Hover").css("visibility", "hidden");
			});
		});
	});
</script>
}.NORMAL_FOOT_INCLUDE);

use constant SEARCHABLE_CATALOG_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{
[<a href="//<const DOMAIN>/<const BOARD_DIR>"><const S_RETURN></a>]
<div id="catalog">
	<div class="catItem" id="catItem0">
		<a id="catItemHoverLink0" href="/<const BOARD_DIR>/res/0">
			<div class="catItemHover" id="catItemHover0" style="width: 150px; height:150px;">
				<div class="catItemHoverText" style="width: 150px; height: 150px; line-height: 150px;">&gt;&gt;0</div>
			</div>
		</a>
		<a id="catItemImageLink0" href="/<const BOARD_DIR>/res/0">
			<img src="//<const DOMAIN>/img/mod.png" class="catImage" style="width: 150px; height: 150px;">
		</a>
		<div class="catComment" id="catItemComment0">
			<span class="catCounts">R: 0/ I: 0</span><br>
			<span>Taargus Taargus</span>
		</div>
	</div>
</div>
<div class="denguses"><var include("include/bottomad.html",1)></div>
<script>
	var catalog=
		{
			"threads": [
			<loop $threads>
				{
					"no":<var $num>,
					<if $sticky>"sticky":<var $sticky>,</if>
					<if $permasage>"psage":<var $permasage>,</if>
					<if $locked>"closed":<var $locked>,</if>
					"time":<var $timestamp>,
					"now":"<var $date>",
					<if $id>"id":"<var $id>",</if>
					"name":"<var mahou_inyoufu $name>",
					"trip":"<var $trip>",
					<if $email>"email":"<var mahou_inyoufu $email>",</if>
					"sub":"<var mahou_inyoufu $subject>",
					"com":"<var mahou_inyoufu $comment>",
					<if $image>
						"image":"<var $thumbnail>",
						"fsize":<var $size>,
						"md5":"<var $md5>",
						"w":<var $width>,
						"h":<var $height>,
						"tn_w":<var $tn_width>,
						"tn_h":<var $tn_height>,
						"filename":"<var $filename>",
						<if $tn_mask>"spoiler":<var $tnmask>,</if>
					</if>
					"postcount":<var $postcount>,
					"imagecount":<var $imagecount>
				}<if !$lastthread>,</if>
			</loop>
			]
		};
</script>
<script src="//<var DOMAIN>/js/catalog.js"></script>
}.NORMAL_FOOT_INCLUDE);

use constant SEARCH_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

}.NORMAL_FOOT_INCLUDE);

use constant BAN_PAGE_TEMPLATE => compile_template(MINIMAL_HEAD_INCLUDE.q{
<div class="logo" style="text-align: center; width:800px;margin-left:auto; margin-right:auto;">
	<h2 class="title">You (<var dec_to_dot $ip>) have been banned!</h2>
	<hr>
	<div style="float:left; width: 49.1%">
	<img src="//<var DOMAIN>/img/banned.png"/>
	</div>
	<div style="float:right; width: 49.1%">
	<loop $bans>
	<p style="font-size:10pt; font-weight: normal;">You were <if $warning!=1>banned</if><if $warning==1>warned</if> on <var make_date($timestamp,DATE_STYLE)> for the following reason: "<em><var $comment></em>".<if ((!$perm) and (!$warning))> Your ban will expire on <var make_date($duration,DATE_STYLE)>.</if></p>
	</loop>
	</div>
	<hr>
</div>
<div style="clear:both"></div>
<br><br>
}.NORMAL_FOOT_INCLUDE);

use constant REGISTER_PASS_TEMPLATE => compile_template(CONTENT_HEAD_INCLUDE.q{
<div id="doc">
	<div class="logo">
		<if SHOWTITLEIMG><div id="image"><img src="<const TITLEIMG>" class='banner' alt="<const SITE_NAME> Pass" title="<const SITE_NAME> Pass"></div></if>
		<if TITLEIMGSCRIPT><script>logoSwitch();</script></if>
	</div>
	<div id="topBox" class="box full red">
		<div class="boxHeader red">
			<h2>Get a <const SITE_NAME> Pass</h2>
		</div>
		<div class="boxContent">
			<h3 style="font-size: large; color: red; text-align: center; margin-top: 9px; margin-bottom: 12px; font-weight:normal"><strong>&rarr; Already have a <const SITE_NAME> pass? <a href="<if !REWRITTEN_LINKS><var $self>?task=passauth</if><if REWRITTEN_LINKS>//<const DOMAIN>/pass/auth</if>">Click here</a> to login. &larr;</strong></h3>
			<hr>
			<p>A <const SITE_NAME> pass is a feature intended to simplify the posting experience for loyal and quality posters. The <const SITE_NAME> Pass's main and only feature is the ability to bypass reCAPTCHA, a necessary evil to avoid spam and floods from other imageboard communities. Although inspired by 4chan's pass system, <const SITE_NAME> Pass is similar only in function. Unlike 4chan Pass, <const SITE_NAME> Pass costs nothing, and will be compatible across multiple sites running <const SITE_NAME> in the future.</p>
			<p>You will not be able to bypass reCAPTCHA immediately after registering for a <const SITE_NAME> Pass. After signing up, you will be automatically logged into the pass system, and your posts will be identifiable by your pass, regardless of your IP address. After you've made a minimum of 5 posts while logged in with your pass, a <const SITE_NAME> moderator or administrator will either approve or deny your pass application. As long as the posts don't break any rules, chances are you will be approved immediately after review.</p>
			<p>Because <const SITE_NAME> pass is free, the bases on which it can be revoked are slightly more liberal than those on 4chan. If you get banned or warned for a rule breaking post, chances are you will no longer have a pass once you've served your sentence. Luckily, bans are usually reserved for automated spam and illegal posts. If you bothered applying for a pass, you'll probably find its very hard to get it taken away.</p>
			<p><const SITE_NAME> Passes are valid for an infinite period of time, barring streaks of inactivity greater than 31 days. If you make at least one post on a participating imageboard (only <const SITE_NAME> for now) every 31 days, your pass will never expire.</p>
			<p><strong>If you have any issues or find any bugs in our pass system, please post in <a href="//<const DOMAIN>/meta/">/meta/</a> for support.</strong></p>
		</div>
	</div>
	<div class="half left">
		<div class="box green">
			<div class="boxHeader green">
			<h2>Apply</h2>
			</div>
			<div class="boxContent">
				<form action="<var $self>" method="post" id="post_form" enctype="multipart/form-data">
					<input type="hidden" name="task" value="addpass">
					<div class="email">
						<div class="left">
							<strong>Email</strong><br>
							<input type="text" name="email">
						</div>
						<div class="right">
							<strong>Verify Email</strong><br>
							<input type="text" name="mailver">
						</div>
						<br style="clear:both">
						<br>
						<div style="text-align:center">
						<input type="checkbox" id="acceptTerms" name="acceptTerms" value=1>
						<label for="acceptTerms">I have read and agree to the<br><a href="#terms1">Terms of Application</a> and <a href="#terms2">Terms of Use</a>.</label>
						<br><br><button type="submit">Apply Now!</button>
						<br>
						<br>
						<span class="passDesc">Javascript and cookies must be enabled for guaranteed success.</span>
						</div>
					</div>
				</form>
			</div>
		</div>
		<div class="box green" name="#terms1">
			<div class="boxHeader green">
			<h2><a id="terms1">Terms of Application</a></h2>
			</div>
			<div class="boxContent">
				<ol>
					<li>Your pass is only valid once approved by a moderator.</li>
					<li>Use of your pass is bound by the <a href="#terms2">Terms of Use</a> and site rules.</li>
					<li>You must make a minimum of one post every 31 days to keep your pass valid.</li>
					<li>You must make at least 5 posts with your Pass on before being approved. Alternatively, if you have a static IP, your posts pre-pass may count towards that minimum.</li>
				</ol>
			</div>
		</div>
		<div class="box green">
			<div class="boxHeader green">
			<h2><a id="terms2">Terms of Use</a></h2>
			</div>
			<div class="boxContent">
				<ol>
					<li>You understand that the service being offered only allows you to bypass entering a CAPTCHA verification on the <const SITE_NAME> imageboards while using an authorized device.</li>
					<li>A Pass may be used to authorize multiple devices, but can only be associated with one IP address at a time.</li>
					<li>Passes are for individual use by the purchaser only.</li>
					<li>Passes may not be shared, transferred, or sold. Passes that are found to violate this term will be revoked.</li>
					<li>Posting spam messages, advertising of any kind, or other content that violates United States law to <const SITE_NAME> will result in immediate revocation of the Pass.</li>
					<li>You must have browser cookies enabled to use your Pass. JavaScript is optional, but recommended.</li>
					<li>You must make a minimum of one post every 31 days to keep your pass valid.</li>
					<li>You agree to abide by the Rules of <const SITE_NAME>, and understand that failure to do so may result in temporary or permanent suspension of your posting priveleges. If your pass is revoked following a ban, you will not be eligible to apply for a new one.</li>
					<li>Passes and all related services offered by <const SITE_NAME> are provided "as is" and without any warranty of any kind. <const SITE_NAME> makes no guarantee that Passes or the use thereof will be available at any particular time or that the results of using the Pass will meet your requirements.</li>
					<li>These terms are subject to change without notice.</li>
				</ol>
			</div>
		</div>
	</div>
	<div class="half right">
		<div class="box blue">
			<div class="boxHeader blu">
			<h2>Frequently Asked Questions</h2>
			</div>
			<div class="boxContent">
			<div class="faq">
				<strong>What exactly does a Pass allow me to do?</strong>
				<p>
					A <const SITE_NAME> Pass allows you to bypass typing a CAPTCHA verification when posting on the <const SITE_NAME> imageboards.
				</p>
				<hr>
				<strong>What doesn't a Pass allow me to do?</strong>
				<p>
					A Pass does not confer any special privileges beyond bypassing the CAPTCHA verification. You will still be subject to various post timers and the Rules of <const SITE_NAME>.
				</p>
				<hr>
				<strong>Will other people know I'm using a pass?</strong>
				<p>
					No. We at <const SITE_NAME> believe anonymity is a very valuable thing, and have made sure that using a <const SITE_NAME> pass will not compromise your outward facing anonymity in any way.
				</p>
				<hr>
				<strong>How will I receive and use my Pass?</strong>
				<p>
					After applying, you will be emailed a copy of your 10-character Token and 6-digit PIN. You will be automatically logged in the browser used to apply, and no further action will be required on your part to start the verification process. If you plan on posting from another computer and want said posts to count towards your verification, just log in by clicking the link on the top of this page.
				</p>
				<hr>
				<strong>How do I know if I've been verified?</strong>
				<p>
					Upon verification, you will be sent an email congratulating you on your verified status. Just submit a post without typing in the CAPTCHA, and the next time you view a page, the post form will no longer have a CAPTCHA field.
				</p>
				<hr>
				<strong>How long is my pass valid?</strong>
				<p>
					As long as you post at least once every 31 days, your pass is valid until manually revoked for a severe rule violation.
				</p>
				<hr>
				<strong>What happens if I am banned?</strong>
				<p>
					Because there is no monetary value behind a <const SITE_NAME> Pass, we tend to be a little more liberal when it comes to revoking them. If you end up getting banned, chances are you're a computer, a spammer for hire, or a troll, so barring unique circumstances, a ban will be accompanied by a revokation of your pass.
				</p>
			</div>
			</div>
		</div>
	</div>
</div>
<br style="clear:both">
<br>
}.CONTENT_FOOT_INCLUDE);

use constant PASS_SUCCESS_TEMPLATE => compile_template(MINIMAL_HEAD_INCLUDE.q{
<div style="text-align:center">
<div class="logo">
<h2 class="title"><const SITE_NAME> Pass</h2>
<hr>
<br>
</div>
<strong>Congratulations! Your pass has been successfully created.</strong>
<br><br>
<span><strong>Token:</strong> <var $token></span><br>
<span><strong>Pin:</strong> <var $pin></span><br>
<br>
[<a href="//<const DOMAIN>">Home</a>]
</div>
<br>
<hr>
}.NORMAL_FOOT_INCLUDE);

use constant AUTHORIZE_PASS_TEMPLATE => compile_template(MINIMAL_HEAD_INCLUDE.q{
<div class="logo">
<h2 class="title"><const SITE_NAME> Pass</h2>
<hr>
<br>
</div>
<div style="text-align:center">
	<form action="<var $self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="task" value="authpass">
	<div id="postForm">
		<div class="postTableContainer">
			<div class="postBlock">Token</div>
			<div class="postField"><input type="text" class="postInput" style="text-align: center;" name="token" id="token"></div>
		</div>
		<div class="postTableContainer">
			<div class="postBlock">Pin</div>
			<div class="postField"><input type="text" style="text-align: center;" class="postInput" name="pin" id="pin"></div>
		</div>
		<div style="text-align:center">
			[<input type="checkbox" id="remember" name="remember" value=1>
			<label for="remember">Remember this device for 30 days</label>]
			<br><button type="submit">Submit</button>
		</div>
	</div>
	</form>
	<br>
	Don't have a <const SITE_NAME> Pass?<br>
	Click <if REWRITTEN_URLS==1><a href="//<const DOMAIN>/pass/">here</a></if><if REWRITTEN_URLS==0><a href="<var $self>?task=getpass">here</a></if> to learn more.
	<br><br>
</div>
<hr>
}.NORMAL_FOOT_INCLUDE);

use constant JSON_THREAD_TEMPLATE => compile_template(q{
{"posts":[
<loop $posts>
	{
		"no":<var $num>,
		<if !$parent>
			<if $sticky>"sticky":<var $sticky>,</if>
			<if $permasage>"psage":<var $permasage>,</if>
			<if $locked>"closed":<var $locked>,</if>
		</if>
		"time":<var $timestamp>,
		"now":"<var $date>",
		<if $id>"id":"<var $id>",</if>
		"name":"<var mahou_inyoufu $name>",
		<if $trip>"trip":"<var $trip>",</if>
		<if $email>"email":"<var mahou_inyoufu $email>",</if>
		<if $sub>"sub":"<var mahou_inyoufu $subject>",</if>
		<if $comment>"com":"<var mahou_inyoufu $comment>",</if>
		<if $image>
			"image":"<var $image>",
			"fsize":<var $size>,
			"md5":"<var $md5>",
			"w":<var $width>,
			"h":<var $height>,
			"tn_w":<var $tn_width>,
			"tn_h":<var $tn_height>,
			"filename":"<var $filename>",
			<if $tn_mask>"spoiler":<var $tnmask>,</if>
		</if>
		"parent":<var $parent>
	}<if $lastpost!=$num>,</if>
</loop>
]}
},2);

use constant JSON_INDEX_TEMPLATE => compile_template(q{
{
	"threads":[
	<loop $threads>
		{
		"posts":[
			<loop $posts>
				{
					"no":<var $num>,
					<if !$parent>
						<if $sticky>"sticky":<var $sticky>,</if>
						<if $permasage>"psage":<var $permasage>,</if>
						<if $locked>"closed":<var $locked>,</if>
					</if>
					"time":<var $timestamp>,
					"now":"<var $date>",
					<if $id>"id":"<var $id>",</if>
					"name":"<var mahou_inyoufu $name>",
					<if $trip>"trip":"<var $trip>",</if>
					<if $email>"email":"<var mahou_inyoufu $email>",</if>
					<if $sub>"sub":"<var mahou_inyoufu $subject>",</if>
					<if $comment>"com":"<var mahou_inyoufu $comment>",</if>
					<if $image>
						"image":"<var $image>",
						"fsize":<var $size>,
						"md5":"<var $md5>",
						"w":<var $width>,
						"h":<var $height>,
						"tn_w":<var $tn_width>,
						"tn_h":<var $tn_height>,
						"filename":"<var $filename>",
						<if $tn_mask>"spoiler":<var $tnmask>,</if>
					</if>
					"parent":<var $parent>
				}<if !$lastpost>,</if>
			</loop>
			]
		}<if !$lastthread>,</if>
	</loop>
	]
}
},2);

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

