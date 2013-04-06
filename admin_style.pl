use strict;
use POSIX qw/strftime/;
BEGIN { require "wakautils.pl" }

use constant MANAGER_HEAD_INCLUDE => MINIMAL_HEAD_INCLUDE.q{
<if $admin>
	<div class="topNavContainer" id="adminNav">

		<div class="topNavLeft">
			<span style="vertical-align: middle">
			<strong>Navigation:&nbsp;&nbsp;</strong>
			<select id="managerBoardList" onchange="window.location = 'http://<var DOMAIN>/'+value+'/wakaba.pl?task=mpanel&amp;admin=<var $admin>'">
				<if $session-\>[1] eq 'janitor'><loop $session-\>[6]><option value="<var $board>">/<var $board>/</option></loop></if>
				<if $session-\>[1] ne 'janitor'><loop BOARDS><option value="<var $dir>">/<var $dir>/</option></loop></if>
				<option value="#">Boards</option>
			</select>
			</span>
		</div>

		<div class="topNavRight">
			<span style="vertical-align: middle">
			<if $session-\>[2]>[<a href="<var $self>?task=inbox&amp;admin=<var $admin>">New Messages</a>]</if>
			<if $session-\>[3]>[<a href="<var $self>?task=viewreports&amp;admin=<var $admin>">New Reports</a>]</if>
			<if $session-\>[4]>[<a href="<var $self>?task=listrequests&amp;admin=<var $admin>">New Ban Requests</a>]</if>
			<strong>Logged in as:</strong> <var $session-\>[0]>
			</span>
		</div>
	</div>
	<div class="logo adminLogo">
		<span class="title"><const TITLE></span>
	</div>
	<hr style="margin-top: 10px; margin-bottom: 20px;" />
</if>
[<a href="<var expand_filename(HTML_SELF)>"><const S_MANARET></a>]
<if $admin>
	[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>"><const S_MANAPANEL></a>]
	<if $session-\>[1] eq 'mod'>
		[<a href="<var $self>?task=bans&amp;admin=<var $admin>"><const S_MANABANS></a>]
		[<a href="<var $self>?task=passlist&amp;admin=<var $admin>">Pass List</a>]
		[<a href="<var $self>?task=rebuild&amp;admin=<var $admin>"><const S_MANAREBUILD></a>]
		[<a href="<var $self>?task=listrequests&amp;admin=<var $admin>">Ban Requests</a>]
		[<a href="<var $self>?task=viewlog&amp;admin=<var $admin>">View Log</a>]
	</if>
	<if $session-\>[1] eq 'admin'>
		[<a href="<var $self>?task=bans&amp;admin=<var $admin>"><const S_MANABANS></a>]
		[<a href="<var $self>?task=passlist&amp;admin=<var $admin>">Pass List</a>]
		[<a href="<var $self>?task=proxy&amp;admin=<var $admin>"><const S_MANAPROXY></a>]
		[<a href="<var $self>?task=spam&amp;admin=<var $admin>"><const S_MANASPAM></a>]
		[<a href="<var $self>?task=sqldump&amp;admin=<var $admin>"><const S_MANASQLDUMP></a>]
		[<a href="<var $self>?task=sql&amp;admin=<var $admin>"><const S_MANASQLINT></a>]
		[<a href="<var $self>?task=rebuild&amp;admin=<var $admin>"><const S_MANAREBUILD></a>]
		[<a href="<var $self>?task=listrequests&amp;admin=<var $admin>">Ban Requests</a>]
		[<a href="<var $self>?task=viewlog&amp;admin=<var $admin>">View Log</a>]
	</if>
	[<a href="<var $self>?task=manageusers&amp;admin=<var $admin>"><if $session-\>[1] eq 'admin'>Manage Users</if><if $session-\>[1] ne 'admin'>User List</if></a>]
	[<a href="<var $self>?task=edituser&amp;admin=<var $admin>&amp;user=<var $session-\>[0]>">Edit Profile</a>]
	[<a href="<var $self>?task=inbox&amp;admin=<var $admin>">Inbox</a>]
	[<a id="reportQueueButton" href="<var $self>?task=viewreports&amp;admin=<var $admin>"><const S_REPORTS></a>]
	[<a href="<var $self>?task=logout&amp;type=admin"><const S_MANALOGOUT></a>]
</if>
<div class="passvalid"><const S_MANAMODE></div><br />
};

use constant ADMIN_POST_BUTTONS_TEMPLATE => q{
<if $session-\>[1] ne 'janitor'>[<a href="<var $self>?task=ippage&amp;ip=<var $ip>&amp;admin=<var $admin>" title="IP Page"><var dec_to_dot $ip></a>]
[<a href="<var $self>?task=bantemplate&amp;ip=<var $ip>&amp;num=<var $num>&amp;admin=<var $admin>" title="Ban User">B</a>]</if>
[<a href="<var $self>?task=delete&amp;delete=<var $num>&amp;admin=<var $admin>" title="Delete Post">D</a>]
[<a href="<var $self>?task=delete&amp;delete=<var $num>&amp;fileonly=1&amp;admin=<var $admin>" title="Delete File">F</a>]
<if $session-\>[1] eq 'admin'>[<a href="<var $self>?task=editpost&amp;num=<var $num>&amp;admin=<var $admin>" title="Edit Post">E</a>]</if>
<if !$parent><if $session-\>[1] ne 'janitor'>
	<if $sticky>[<a href="<var $self>?admin=<var $admin>&amp;task=stickdatshit&amp;num=<var $num>&amp;jimmies=rustled" title="Toggle Sticky">-S</a>]</if>
	<if !$sticky>[<a href="<var $self>?admin=<var $admin>&amp;task=stickdatshit&amp;num=<var $num>&amp;jimmies=unrustled" title="Toggle Sticky">S</a>]</if>
	<if $locked>[<a href="<var $self>?admin=<var $admin>&amp;task=lockthread&amp;num=<var $num>&amp;jimmies=rustled" title="Toggle Lock">-L</a>]</if>
	<if !$locked>[<a href="<var $self>?admin=<var $admin>&amp;task=lockthread&amp;num=<var $num>&amp;jimmies=unrustled" title="Toggle Lock">L</a>]</if></if>
	<if $permasage>[<a href="<var $self>?admin=<var $admin>&amp;task=permasage&amp;num=<var $num>&amp;jimmies=rustled" title="Toggle Permasage">-PS</a>]</if>
	<if !$permasage>[<a href="<var $self>?admin=<var $admin>&amp;task=permasage&amp;num=<var $num>&amp;jimmies=unrustled" title="Toggle Permasage">PS</a>]</if>
</if>
<if $reported>[<a href="<var $self>?admin=<var $admin>&amp;task=viewreport&amp;num=<var $num>" title="View detailed report information for this post">View Report</a>]</if>
};

use constant ADMIN_LOGIN_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div align="center"><form id="login" action="<var $self>" method="post">
<input type="hidden" name="task" value="admin" />
<input type="hidden" name="nexttask" value="mpanel" />
<table style="border-spacing: 2px"><tbody>
<tr><td><strong>Username </strong></td><td style="text-align: right"><input type="text" name="user" size="9" value="" /></td></tr>
<tr><td><strong>Password </strong></td><td style="text-align: right"><input type="password" name="berra" size="9" value="" /></td></tr>
<tr><td colspan=2><label><input type="checkbox" name="savelogin" /> Remember me</label></td></tr>
<tr><td colspan=2><input type="submit" value="Login" /></td></tr>
</tbody></table>
</form><br /></div>
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
		<td><a href="<var $self>?task=ippage&amp;ip=<var $ival1>&amp;admin=<var $admin>"><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></a></td>
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
		<td><a href="<var $self>?task=ippage&amp;ip=<var $ival1>&amp;admin=<var $admin>"><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></a></td>
	</if>

	<td><var $comment></td>
	<td>
	<if $active><a href="<var $self>?task=updateban&amp;num=<var $num>&amp;active=0&amp;ip=<var $ival1>&amp;admin=<var $admin>">Deactivate</a></if>
	<if !$active><a href="<var $self>?task=updateban&amp;num=<var $num>&amp;active=1&amp;ip=<var $ival1>&amp;admin=<var $admin>">Activate</a></if>
	<a href="<var $self>?admin=<var $admin>&amp;task=removeban&amp;num=<var $num>"><const S_BANREMOVE></a>
	</td>
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
			<input type="hidden" name="admin" value="<var $admin>" />
			<div class="delbuttons"><const S_SQLNUKE>
				<input type="password" name="nukepass" value="<var $nuke>" />
				<input type="submit" value="Nuke Board" />
			</div>
		</form>
	</div>
</div>

<pre><code><var $results></code></pre>

}.NORMAL_FOOT_INCLUDE);

use constant REPORTS_PAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div class="dellist">Report Queue</div>
<if !$posts>
There are zero reported posts!
</if>
<loop $posts>
<div class="reportContainer" id="reportContainer<var $num>">
	<div class="reportHeader"><strong>Board: </strong><a href="http://<var DOMAIN>/<var BOARD_DIR>/" target="_blank">/<var BOARD_DIR>/</a> No. <var $num> <a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<if $parent><var $parent></if><if !$parent><var $num></if>#<var $num>" target="_blank">[View Full]</a> <strong>Total: </strong><var $totalreports> <strong>Illegal: </strong><var $illegal> <strong>Spam: </strong><var $spam> <strong>Rule: </strong><var $vio></div>
	<div class="reportPostHeader">
		<div style="float:left">
		<span class="postername"><var $name></span> <span class="postertrip"><var $trip></span>
		</div>
		<div style="float:right">
			<var make_date $timestamp,tiny>
			<if !$parent><strong>[OP]</strong></if>
		</div>
		<div style="clear:both;"></div>
	</div>
	<div class="reportContent">
		<div>
			<if $image><a class="thumbLink" target="_blank" href="<var expand_filename($image)>">
				<img src="<var expand_filename($thumbnail)>" class="thumb replyThumb" alt="<var $size>" data-md5="<var $md5>" style="width:<var $tn_width*.504>px; height:<var $tn_height*.504>px; margin-left:5px;">
			</a></if>
			<div class="reportComment">
				<var $comment>
			</div>
		</div>
		<div class="reportOptions">
			[<a href="<var $self>?task=viewreport&amp;num=<var $num>&amp;admin=<var $admin>">More info</a>]
			[<a href="<var $self>?task=dismiss&amp;num=<var $num>&amp;admin=<var $admin>">Dismiss</a>]
			<if $session-\>[1] eq 'janitor'>[<a href="<var $self>?task=requestban&amp;num=<var $num>&amp;admin=<var $admin>">Request Ban</a>]</if>
			}.ADMIN_POST_BUTTONS_TEMPLATE.q{
		</div>
	</div>
</div>
</loop>
}.NORMAL_FOOT_INCLUDE);

use constant BAN_REQUEST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div align="center"><strong>Request a ban.</strong></div>
<div class="postarea"><form id="banRequest" action="<var $self>" method="post" enctype="multipart/form-data">
	<table><tbody><input type="hidden" name="task" value="submitrequest" />
	<input type="hidden" name="admin" value="<var $admin>" />
	<tr><td class="postBlock">No.</td><td><input type="text" value="<var $num>" name="num" size="28" /></td></tr>
	<tr><td class="postBlock">Reason</td><td><select name="reason">
		<option value="spam">Spammer</option>
		<option value="illegal">Illegal content posted</option>
		<option value="evasion">Ban evasion</option>
		<option value="vio">Rule breaking posts</option>
	</select></td></tr>
	<tr><td class="postBlock" style="width: 73px">Details</td><td><textarea name="reason2" class="postInput" id="field4"></textarea></td></tr>
	<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
</tbody></table></form></div>
<if $requested>
<hr />
<div align="center"><strong>Existing requests.</strong></div>
<loop $requested>
<div style="margin: 0 auto; width: 650px;">
User '<em><var $fromuser></em>' requested a ban for the following reason: <em>'<var $reason>'</em>. <if $reason2>Additional Details: '<em><var $reason2></em>'</if><br />
</div>
</loop>
</if>
<hr />
}.NORMAL_FOOT_INCLUDE);

use constant REPORT_PAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<strong>
	Displaying report details for <a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<if $parent><var $parent></if><if !$parent><var $num></if>#<var $num>" target="_blank">/<const BOARD_DIR>/<var $num></a>.<br />
	[<a href="<var $self>?admin=<var $admin>&amp;task=viewreports">Return</a>]<br/ >
	<br/ >
	Report Statistics:
</strong>
<table class="reportstats">
	<tbody>
		<tr>
			<td class="reportblock">Total Reports</td>
			<td class="reportright"><var $total></td>
		</tr>
		<tr>
			<td class="reportblock">Reported 'spam'</td>
			<td class="reportright"><var $$reports[0]{spam}></td>
		</tr>
		<tr>
			<td class="reportblock">Reported 'illegal'</td>
			<td class="reportright"><var $$reports[0]{illegal}></td>
		</tr>
		<tr>
			<td class="reportblock">Reported 'rule vio.'</td>
			<td class="reportright"><var $$reports[0]{vio}></td>
		</tr>
		<tr>
			<td class="reportblock">Last reported</td>
			<td class="reportright"><var make_date $last,DATE_STYLE></td>
		</tr>
		<tr>
			<td class="reportblock">First reported</td>
			<td class="reportright"><var make_date $first,DATE_STYLE></td>
		</tr>
		<if $session-\>[1] ne 'janitor'><tr>
			<td class="reportblock">Reported By</td>
			<td class="reportright">
				<loop $reports>
					[<a href="<var $self>?task=ippage&amp;ip=<var dot_to_dec $fromip>&amp;admin=<var $admin>"><var $fromip></a>] [<a href="<var $self>?task=bantemplate&amp;ip=<var $fromip>&amp;admin=<var $admin>">Ban</a>]<br />
				</loop>
			</td>
		</tr></if>
	</tbody>
</table>
<br/ >
<strong>Actions:</strong><br />
<if $session-\>[1] eq 'janitor'>[<a href="<var $self>?task=requestban&amp;num=<var $num>&amp;admin=<var $admin>">Request Ban</a>] </if>[<a href="<var $self>?task=dismiss&amp;num=<var $num>&amp;admin=<var $admin>">Dismiss Reports</a>]
<br /><br />
<strong>Post:</strong>
<loop $post>
<div class="replyContainer" id="replyContainer<var $num>">
	<div class="reply<if $reported> reportedReply</if>" id="reply<var $num>">
		<a id="<var $num>"></a>
		<div class="replyPostInfo"><input type="checkbox" name="delete" value="<var $num>" />
			<span class="replytitle"><var $subject></span>
			<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
			<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
			<var substr($date,0,index($date,"ID:"))><span class="id"><var substr($date, index($date,"ID:"))></span>
			<span class="reflink">
			<if !$thread><a class="refLinkInner" href="<var get_reply_link($parent,0)>#i<var $num>">No.<var $num></a></if>
			<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if></span>
			}.ADMIN_POST_BUTTONS_TEMPLATE.q{
		</div>
		<if $image><br />
			<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
			-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span><br />
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
		</blockquote>
	</div>
</div>
</loop>
<br /><br />
}.NORMAL_FOOT_INCLUDE);

use constant BAN_REQUEST_LIST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div align="center"><strong>Ban Requests</strong><br /></div>
<loop $requested>
<div>
User '<em><var $fromuser></em>' requested a ban for user [<a href="<var $self>?task=ippage&amp;ip=<var $ip>&amp;admin=<var $admin>"><var dec_to_dot $ip></a>] the following reason: <em>'<var $reason>'</em>. <if $reason2>Additional Details: '<em><var $reason2></em>'.</if> Post Number: <em>'<a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<if $postparent><var $postparent></if><if !$postparent><var $postnum></if>#<var $postnum>" target="_blank">/<const BOARD_DIR>/<var $postnum></a>'</em>.
 - [<a href="<var $self>?task=bantemplate&amp;ip=<var $ip>&amp;num=<if $postparent><var $postparent></if><if !$postparent><var $postnum></if>&amp;admin=<var $admin>">Ban</a>] [<a href="<var $self>?task=dismissrequests&amp;ip=<var $ip>&amp;admin=<var $admin>">Dismiss</a>]
<br />
</div>
</loop>
}.NORMAL_FOOT_INCLUDE);

use constant ADMIN_POST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div align="center"><em><const S_NOTAGS></em><br /></div>

<div class="postarea">
<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
<input type="hidden" name="task" value="post" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="no_captcha" value="1" />
<br />

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
<tr><td class="postBlock">Other</td><td><label>Self Format<input type="checkbox" name="no_format" value="1" /></label> <label> Use Capcode<input type="checkbox" name="capcode" value="1" /></label></td></tr>
</tbody></table></form></div><hr />
<script type="text/javascript">set_inputs("postform")</script>

}.NORMAL_FOOT_INCLUDE);

use constant REGISTER_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div align="center"><em>Add a new user.</em></div>
	<div class="postarea"><form id="registForm" action="<var $self>" method="post" enctype="multipart/form-data">
		<table><tbody><input type="hidden" name="task" value="adduser" />
		<input type="hidden" name="admin" value="<var $admin>" />
		<tr><td class="postBlock"><const S_NAME></td><td><input type="text" name="user" size="28" /></td></tr>
		<tr><td class="postBlock"><const S_DELPASS></td><td><input type="password" name="pass" size="28" /></td></tr>
		<tr><td class="postBlock">Email</td><td><input type="text" name="email" size="28" /></td></tr>
		<tr><td class="postBlock">Class</td><td><select name="class">
			<option value="janitor">Janitor</option>
			<option value="mod">Moderator</option>
			<option value="admin">Administrator</option>
		</select></td></tr>
		<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
	</tbody></table></form></div>
}.NORMAL_FOOT_INCLUDE);

use constant SELECT_BOARDS_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div align="center"><em>Manage <var $user>'s boards.</em></div>
	<div class="postarea" align="center"><form id="registForm" action="<var $self>" method="post" enctype="multipart/form-data">
		<table><tbody><input type="hidden" name="task" value="adduser" />
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="user" value="<var $user>" />
		<input type="hidden" name="pass" value="<var $pass>" />
		<input type="hidden" name="class" value="janitor" />
		<input type="hidden" name="email" value="<var $email>" />
		<loop BOARDS>
			<label><input type="checkbox" value="<var $dir>" name="boards" />/<var $dir>/ - <var $name></label><br />
		</loop>
		<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
	</tbody></table></form></div>
}.NORMAL_FOOT_INCLUDE);

use constant MANAGE_USERS_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<table align="center" id="threadList" style="white-space: nowrap; width: auto;">
	<thead>
	<tr><td class="listHead">Username</td><td class="listHead">Email</td><td class="listHead">Class</td><td class="listHead">Last Session</td><td class="listHead">Options</td></tr>
	</thead>
	<tbody>
	<loop $users>
		<tr class="listRow"><td class="listCol"><var $user></td><td class="listCol"><var $email></td><td><var $class></td><td class="listCol"><if $session-\>[1] eq 'admin'><var $lastip> on </if><var make_date($lastdate,tiny)></td><td class="listCol">
		<if $session-\>[1] eq 'admin'>[<a href="<var $self>?admin=<var $admin>&amp;task=edituser&amp;user=<var $user>">Edit</a>]
		[<a href="<var $self>?admin=<var $admin>&amp;task=removeuser&amp;user=<var $user>">Remove</a>]</if>
		[<a href="<var $self>?admin=<var $admin>&amp;task=composemsg&amp;to=<var $user>">Send Message</a>]
		</td></tr>
	</loop>
	<tr><td><br/></td></tr>
	<if $session-\>[1] eq 'admin'><tr><td colspan="5">[<a href="<var $self>?task=register&amp;admin=<var $admin>">Add User</a>]</td></tr></if>
	<tbody></table>
}.NORMAL_FOOT_INCLUDE);

use constant EDIT_USER_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div align="center"><em>Editing details for <if $session-\>[1] eq 'admin'><var $user></if><if $session-\>[1] ne 'admin'><var $session-\>[0]></if></em></div>
<div class="postarea"><form id="changePass" action="<var $self>" method="post" enctype="multipart/form-data">
	<table><tbody><input type="hidden" name="task" value="setnewpass" />
	<input type="hidden" name="admin" value="<var $admin>" />
	<input type="hidden" name="user" value="<if $session-\>[1] eq 'admin'><var $user></if><if $session-\>[1] ne 'admin'><var $session-\>[0]></if>" />
	<tr><td class="postBlock">Email</td><td><input name="email" value="<var $$userinfo{email}>" size="28" /></td></tr>
	<if (($session-\>[1] eq 'admin') and ($session-\>[0] ne $user))><tr><td class="postBlock">Class</td><td><select name="class">
		<option value="janitor">Janitor</option>
		<option value="mod">Moderator</option>
		<option value="admin">Administrator</option>
	</select></td></tr></if>
	<tr><td class="postBlock">Old Pass</td><td><input <if (($session-\>[1] eq 'admin') and ($session-\>[0] ne $user))>disabled="disabled"</if> type="password" name="oldpass" size="28" /></td></tr>
	<tr><td class="postBlock">New Pass</td><td><input type="password" name="newpass" size="28" /></td></tr>
	<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
</tbody></table></form></div>
}.NORMAL_FOOT_INCLUDE);

use constant COMPOSE_MESSAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div align="center">Compose Message<em></em>
		<div class="postarea"><form id="changePass" action="<var $self>" method="post" enctype="multipart/form-data">
		<table><tbody><input type="hidden" name="task" value="sendmsg" />
		<input type="hidden" name="admin" value="<var $admin>" />
		<if $parentmsg><input type="hidden" name="replyto" value="<var $parentmsg>" /><tr><td class="postBlock">Reply To</td><td><input type="text" name="replyto" disabled="true" value="<var $parentmsg>" /></td></tr></if>
		<if !$parentmsg><tr><td class="postBlock">To</td><td><input type="text" name="to" value="<var $to>" size="28" /></td></tr></if>
		<tr><td class="postBlock">Message</td><td><textarea name="message" cols="48" rows="4"></textarea></td></tr>
		<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
	</tbody></table></form></div>
}.NORMAL_FOOT_INCLUDE);

use constant INBOX_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<table align="center" id="threadList" style="white-space: nowrap; width: auto;">
<thead><tr>
<td class="listHead">No.</td><td class="listHead">Message</td><td class="listHead">From</td><td class="listHead">To</td><td class="listHead">Date</td><td class="listHead">Options</td>
</tr></thead>
<tbody>
<loop $messages>
<tr class="listRow"><td class="listCol"><var $num></td>
<if !$wasread><td class="listCol"><strong><a href="<var $self>?task=viewmsg&amp;num=<var $num>&amp;admin=<var $admin>"><var truncateComment $message></a></strong></td></if>
<if $wasread><td><a href="<var $self>?task=viewmsg&amp;num=<var $num>&amp;admin=<var $admin>"><var truncateComment $message></a></td></if>
<td class="listCol"><var $fromuser></td>
<td class="listCol"><var $touser></td>
<td class="listCol"><var make_date($timestamp,tiny)></td>
<td class="listCol">[<a href="<var $self>?task=composemsg&amp;replyto=<var $num>&amp;admin=<var $admin>">Reply</a>]</td></tr>
</loop>
<tr><td><br/></td></tr>
<tr><td colspan="5">[<a href="<var $self>?task=composemsg&amp;admin=<var $admin>">Compose Message</a>]</td></tr>
<tbody></table>
}.NORMAL_FOOT_INCLUDE);

use constant VIEW_MESSAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<loop $messages>
<table>
<tbody>
<tr><td class="postBlock">From</td><td><var $fromuser> on <var make_date($timestamp,"tiny")></td></tr>
<tr><td class="postBlock">Message</td><td><var $message></td></tr>
</tbody>
</table>
<hr/>
</loop>
[<a href="<var $self>?task=composemsg&amp;replyto=<var $num>&amp;admin=<var $admin>">Reply</a>]
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_LOG_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<if $session-\>[1] eq 'admin'>
	[<a href="<var $self>?task=clearlog&amp;admin=<var $admin>">Clear Log</a>]
	<hr />
</if>
<loop $log>
<var $num>: User [<var $user>@<var $ip>] <var $action> <var $object> from /<var $board>/ on <var make_date $time,DATE_STYLE><br />
</loop>
}.NORMAL_FOOT_INCLUDE);

use constant EDIT_POST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<loop $posts>
<div class="postarea">
	<div style="text-align:center; font-weight: bold;">Editing Post No. <var $num></div>
	<br />
	<form action="<var $self>" method="post" enctype="multipart/form-data">
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="no_captcha" value="1" />
		<input type="hidden" name="task" value="updatepost" />
		<input type="hidden" name="num" value="<var $num>" />
		<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
		<if !$image_inp and !$thread and ALLOW_TEXTONLY><input type="hidden" name="nofile" value="1" /></if>
		<div id="postForm">
			<if !FORCED_ANON><div class="postTableContainer">
				<div class="postBlock">Name</div>
				<div class="postField"><input type="text" class="postInput" name="field1" id="field1" value="<var decode_string($name,CHARSET,1)>" /></div>
			</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Trip</div>
				<div class="postField"><input type="text" class="postInput" name="field1andahalf" id="field1andahalf" value="<var decode_string($trip,CHARSET,1)>" /></div>
			</class>
			<div class="postTableContainer">
				<div class="postBlock">Link</div>
				<div class="postField"><input type="text" class="postInput" name="field2" id="field2" value="<var decode_string($email,CHARSET,1)>" /></div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Subject</div>
				<div class="postField">
					<input type="text" name="field3" class="postInput" value="<var decode_string($subject,CHARSET,1)>" id="field3" />
					<input type="submit" id="field3s" value="Submit" />
				</div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Comment</div>
				<div class="postField"><textarea name="field4" class="postInput" id="field4"><var decode_string($comment,CHARSET,1)></textarea></div>
			</div>
			<if !$thread>
			</div>
			</if>
		</div>
	</form>
</div>
</loop>
}.NORMAL_FOOT_INCLUDE);

use constant PASS_LIST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<fieldset>
<legend>Pending Action</legend>
<loop $unverified>
<p>
<strong>Token</strong>: '<var $token>'
<strong>Pin:</strong> '<var $pin>'
<strong>Email:</strong> '<var $email>'
<strong>Created:</strong> '<var make_date($timestamp,DATE_STYLE)>'
<strong>Last Use:</strong> '<var make_date($lasthit,DATE_STYLE)>'
<strong>Last IP Change:</strong> '<var make_date($lastswitch,DATE_STYLE)>'
<strong>Last IP:</strong> '<var $ip>'
[<a href="<var $self>?task=updatepass&amp;admin=<var $admin>&amp;num=<var $num>&amp;action=verify">Verify</a>]
[<a href="<var $self>?task=updatepass&amp;admin=<var $admin>&amp;num=<var $num>&amp;action=ban">Revoke</a>]
[<a href="<var $self>?task=viewposts&amp;admin=<var $admin>&amp;num=<var $num>&amp;selectby=passnum">View Posts</a>]
</p>
</loop>
</fieldset>
<fieldset>
<legend>Active</legend>
<loop $normal>
<p>
<var $num>.
<strong>Token</strong>: '<var $token>'
<strong>Pin:</strong> '<var $pin>'
<strong>Email:</strong> '<var $email>'
<strong>Last Use:</strong> '<var make_date($lasthit,DATE_STYLE)>'
<strong>Created:</strong> '<var make_date($timestamp,DATE_STYLE)>'
<strong>IP List:</strong> '<var $ip>'
[<a href="<var $self>?task=updatepass&amp;admin=<var $admin>&amp;num=<var $num>&amp;action=ban">Revoke</a>]
[<a href="<var $self>?task=viewposts&amp;admin=<var $admin>&amp;num=<var $num>&amp;selectby=passnum">View Posts</a>]
</p>
</loop>
</fieldset>
<fieldset>
<legend>Banned</legend>
<loop $banned>
<p>
<var $num>.
<strong>Token</strong>: '<var $token>'
<strong>Pin:</strong> '<var $pin>'
<strong>Email:</strong> '<var $email>'
<strong>Last Use:</strong> '<var make_date($lasthit,DATE_STYLE)>'
<strong>Created:</strong> '<var make_date($timestamp,DATE_STYLE)>'
<strong>IP List:</strong> '<var $ip>'
[<a href="<var $self>?task=viewposts&amp;admin=<var $admin>&amp;num=<var $num>&amp;selectby=passnum">View Posts</a>]
</p>
</loop>
</fieldset>
}.NORMAL_FOOT_INCLUDE);

use constant BAN_TEMPLATE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<form action="<var $self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="admin" value="<var $admin>" />
	<input type="hidden" name="task" value="addip" />
	<input type="hidden" name="type" value="ipban" />
	<table class="reportstats bantemplate">
		<tr>
			<td class="reportblock">Template:</td>
			<td class="reportright">
				<select name="template" disabled>
					<option value="clear">None</option>
					<option value="illegal">Illegal</option>
					<option value="spam">Spam</option>
					<option value="minor">Minor Violation</option>
					<option value="major">Major Violation</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="reportblock">Citations:</td>
			<td class="reportright">
				<em>No. </em><input type="text" class="postInput" name="num" value="<var $num>" /><br />
			</td>
		</tr>
		<tr>
			<td class="reportblock">IP:</td>
			<td class="reportright">
				<em>IP: </em><input type="text" class="postInput" name="ip" value="<var dec_to_dot $ip>" /><br />
				<em>Mask: </em><input type="text" class="postInput" name="mask" value="255.255.255.255" /><br />
				<label>[<input type="checkbox" name="threadban" value="1" />Ban entire thread]</label>
				[<a href="<var $self>?task=ippage&amp;ip=<var $ip>&amp;admin=<var $admin>" target="_blank">Ban history</a>]
			</td>
		</tr>
		<tr>
			<td class="reportblock">Public reason:</td>
			<td class="reportright">
				<textarea name="public" class="postInput"></textarea><br />
				<span class="passDesc">(This must be filled out)</span>
			</td>
		</tr>
		<tr>
			<td class="reportblock">Private info:</td>
			<td class="reportright">
				<textarea name="private" class="postInput"></textarea><br />
				<span class="passDesc">(This will only be seen by other moderation staff)</span>
			</td>
		</tr>
		<tr>
			<td class="reportblock">Banned by:</td>
			<td class="reportright">
				<input type="text" class="postInput" name="fromuser" value="<var $session-\>[0]>" /><br />
				<label>[<input type="checkbox" name="displayfrom" value="1" />Display]</label>
			</td>
		</tr>
		<tr>
			<td class="reportblock">Ban options:</td>
			<td class="reportright">
				<em>Scope: </em>
				<select name="scope">
					<option value="global">Global</option>
					<option value="<const BOARD_DIR>">/<const BOARD_DIR>/</option>
					<option value="hell">Hell ban</option>
				</select>
				<br />
				<em>Duration: </em>
				<input type="text" class="postInput" name="duration" style="width: 30px"/> <em>days</em><br />
				<label>[<input type="checkbox" name="warn" value="1" />Warning]</label>
				<label>[<input type="checkbox" name="perm" value="1" />Permanent]</label>
			</td>
		</tr>
		<tr>
			<td class="reportblock">Post-ban action:</td>
			<td class="reportright">
				<select name="postban">
					<option value="">None</option>
					<option value="deletebynum">Delete post</option>
					<option value="deletebynumfo">Delete file only</option>
					<option value="deletebyip">Delete all posts by IP</option>
				</select>
			</td>
		</tr>
	</table>
	<input type="submit" style="margin-top: 5px;" value="Submit">
</form>
}.NORMAL_FOOT_INCLUDE);

use constant IP_PAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div class="logo">
<span class="title" style="font-size: 14pt;"><var dec_to_dot $ip></span>
<p class="logoSubtitle"><var $host></p>
</div>
<fieldset><legend>Ban History</legend>
	<table id="threadList" align="center" style="white-space: nowrap; width: auto;">
		<tbody>
			<thead>
				<tr>
					<td class="listHead">Active</td>
					<td class="listHead">Public Reason</td>
					<td class="listHead">Details</td>
					<td class="listHead">By</td>
					<td class="listHead">Date</td>
					<td class="listHead">Expiration</td>
					<td class="listHead">Options</td>
				</tr>
			</thead>
			<loop $bans>
			<tr class="listRow">
				<td class="listCol"><var $active></td>
				<td class="listCol"><var $comment></td>
				<td class="listCol"><var $private></td>
				<td class="listCol"><var $fromuser></td>
				<td class="listCol"><var make_date($timestamp,tiny)></td>
				<td class="listCol">
					<if $perm>Permanent</if>
					<if !$perm>
						<if !$warning><var make_date($duration,tiny)></if>
						<if $warning>Warning</if>
					</if>
				</td>
				<td class="listCol">
					<if !$active>[<a href="<var $self>?task=updateban&amp;num=<var $num>&amp;active=1&amp;ip=<var $ip>&amp;admin=<var $admin>">Activate</a>]</if>
					<if $active>[<a href="<var $self>?task=updateban&amp;num=<var $num>&amp;&amp;active=0&amp;ip=<var $ip>&amp;admin=<var $admin>">Deactivate</a>]</if>
					<a href="<var $self>?task=removeban&amp;num=<var $num>&amp;admin=<var $admin>">[Delete]</a>
					<if $postnum>[<a href="<var $self>?task=viewdeletedpost&amp;num=<var $postnum>&amp;admin=<var $admin>">View Post</a>]</if>
				</td>
			</tr>
			</loop>
			<tr><td><br/></td></tr>
			<tr><td>[<a href="<var $self>?task=bantemplate&amp;ip=<var $ip>&amp;admin=<var $admin>">Add Ban</a>]</td></tr>
		</tbody>
	</table>
</fieldset>
<fieldset><legend>Ban Requests</legend>
	<table id="threadList" align="center" style="white-space: nowrap; width: auto;">
	<thead>
	<tr><td class="listHead">Reason</td><td class="listHead">By</td><td class="listHead">Date</td><td class="listHead">Options</td></tr>
	</thead>
	<tbody>
	<loop $requested>
	<tr class="listRow">
	<td class="listCol">Code: <em>'<var $reason>'</em>. <if $reason2>Additional Details: '<em><var $reason2></em>'.</if> Post: <em>'<a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<if $postparent><var $postparent></if><if !$postparent><var $postnum></if>#<var $postnum>" target="_blank">/<const BOARD_DIR>/<var $postnum></a>'</em>.</td>
	<td class="listCol"><var $fromuser></td>
	<td class="listCol"><var make_date($timestamp,tiny)></td>
	<td class="listCol">[<a href="<var $self>?task=bantemplate&amp;ip=<var $ip>&amp;admin=<var $admin>">Ban</a>]</td></tr>
	</loop>
	<tr><td><br/></td></tr>
	<tbody>
	</table>
	<div align="center">[<a href="<var $self>?task=dismissrequests&amp;ip=<var $ip>&amp;admin=<var $admin>">Dismiss All</a>]</div>
</fieldset>
<fieldset><legend>Notes</legend>
	<loop $notes>
		<table>
		<tbody>
		<tr><td class="postBlock">From</td><td><var $fromuser> on <var make_date($timestamp,"tiny")></td></tr>
		<tr><td class="postBlock">Message</td><td><var $message></td></tr>
		</table>
		</tbody>
		<hr/>
	</loop>
	<div align="center"><strong>Add Note</strong>
		<div class="postarea"><form id="addNote" action="<var $self>" method="post" enctype="multipart/form-data">
		<table><tbody><input type="hidden" name="task" value="sendmsg" />
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="isnote" value="1" />
		<input type="hidden" name="to" value="<var $ip>" />
		<tr><td class="postBlock">Message</td><td><textarea name="message" cols="48" rows="4"></textarea></td></tr>
		<tr><td><input type="submit" value="<const S_SUBMIT>" /></td></tr>
		</tbody></table></form></div>
</fieldset>
<fieldset><legend>Posts [<a href="<var $self>?admin=<var $admin>&amp;task=deleteall&amp;ip=<var $ip>">Delete All</a>]</legend>
<div class="thread"><loop $posts>
		<if !$parent>
			<div class="parentPost" id="parent<var $num>">
				<div class="hat"></div>
				<if $image><span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
					-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
					<br />
					<if $thumbnail><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>">
						<if !$tnmask><img src="<var expand_filename($thumbnail)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if><if $tnmask><img src="http://<var DOMAIN>/img/spoiler.png" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if></a></if>
					<if !$thumbnail>
						<if DELETED_THUMBNAIL><a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>"><img src="<var expand_filename(DELETED_THUMBNAIL)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" alt="" class="thumb opThumb" /></a></if>
					<if !DELETED_THUMBNAIL><div class="thumb nothumb"><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div></if></if></if>
				<a id="<var $num>"></a>
				<span class="parentPostInfo">
					<label><input type="checkbox" name="delete" value="<var $num>" />
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
					<var $date></label>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var get_reply_link($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					<if $sticky><img src="http://<var DOMAIN>/img/sticky.gif" alt="Stickied"/></if>
					<if $locked><img src="http://<var DOMAIN>/img/closed.gif " alt="Locked"/></if>
					</span>&nbsp;
					<if !$thread>[<a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<var $num>"><const S_REPLY></a>]</if>				
					}.ADMIN_POST_BUTTONS_TEMPLATE.q{
				</span>
				<blockquote<if $email=~/aa$/i> class="aa"</if>>
				<var $comment>
				<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
				</blockquote>
			</div>
			<if $omit><span class="omittedposts">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
			</span></if></if>
			<if $parent><div class="replyContainer" id="replyContainer<var $num>">
					<div class="doubledash"></div>
					<div class="reply" id="reply<var $num>">
						<a id="<var $num>"></a>
						<label><input type="checkbox" name="delete" value="<var $num>" />
						<span class="replytitle"><var $subject></span>
						<if $email><span class="commentpostername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
						<if !$email><span class="commentpostername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
						<var $date></label>
						<span class="reflink">
							<if !$thread><a class="refLinkInner" href="<var get_reply_link($parent,0)>#i<var $num>">No.<var $num></a></if>
							<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
						</span>
						}.ADMIN_POST_BUTTONS_TEMPLATE.q{
						<if $image>
							<br />
							<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
							-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
							<br />
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
							<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
						</blockquote>
					</div>
				</div>
			</if>
			<hr />
		</loop>
	</div>
</fieldset>
}.NORMAL_FOOT_INCLUDE);

use constant DELETED_POST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<loop $post>
<strong>Deleted by <var $deletedby>.</strong>
<div class="replyContainer" id="replyContainer<var $num>">
	<div class="doubledash">&gt;&gt;</div>
	<div class="reply" id="reply<var $num>">
		<a id="<var $num>"></a>
		<span class="replytitle"><var $subject></span>
		<if $email><span class="commentpostername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
		<if !$email><span class="commentpostername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
		<var $date>
		<span class="reflink">
			<a class="refLinkInner" href="#">No.<var $num></a>
		</span>
		<if $image>
			<br />
			<span class="filesize"><const S_PICNAME><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if>
			-(<em><var int($size/1024)> KB, <var $width>x<var $height>, MD5: <var $md5></em>)</span><br />
			<div class="thumb replyThumb nothumb">
				Image<br />
				Deleted
			</div>
		</if>
		<blockquote<if $email=~/aa$/i> class="aa"</if>>
			<var $comment>
		</blockquote>
	</div>
</div>
</loop>
}.NORMAL_FOOT_INCLUDE);

use constant ADMIN_PAGE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
<div id="content">
<if $thread>
	[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>"><const S_RETURN></a>]
	[<a href="#bottom">Bottom</a>]
	<div class="theader"><const S_POSTING></div>
</if>
<if $postform><div class="postarea">
	<form action="<var $self>" method="post" enctype="multipart/form-data">
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="no_captcha" value="1" />
		<input type="hidden" name="task" value="post" />
		<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
		<if !$image_inp and !$thread and ALLOW_TEXTONLY><input type="hidden" name="nofile" value="1" /></if>
		<if FORCED_ANON><input type="hidden" name="name" /></if>
		<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name"  autocomplete="off" /><input type="text" name="link" autocomplete="off" /></div></if>
		<div id="postForm">
			<if !FORCED_ANON><div class="postTableContainer">
					<div class="postBlock">Name</div>
					<div class="postField"><input type="text" class="postInput" name="field1" id="field1" /></div>
				</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Link</div>
				<div class="postField"><input type="text" class="postInput" name="field2" id="field2" /></div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Subject</div>
				<div class="postField">
					<input type="text" name="field3" class="postInput" id="field3" />
					<input type="submit" id="field3s" value="Submit" />
				</div>
			</div>
			<div class="postTableContainer">
				<div class="postBlock">Comment</div>
				<div class="postField"><textarea name="field4" class="postInput" id="field4"></textarea></div>
			</div>
			<if $image_inp><div class="postTableContainer" id="uploadField">
					<div class="postBlock">File</div>
					<div class="postField">
						<input type="file" name="file" id="file" /><br />
						<if $textonly_inp><label>[<input type="checkbox" name="nofile" value="on" />No File]</label></if>
						<if SPOILERIMAGE_ENABLED><label>[<input type="checkbox" name="spoiler" value="1" />Spoiler]</label></if>
						<if NSFWIMAGE_ENABLED><label>[<input type="checkbox" name="nsfw" value="1" />NSFW]</label></if>
					</div>
			</div></if>
			<div class="postTableContainer">
				<div class="postBlock">Password</div>
				<div class="postField">
					<input type="password" class="postInput" id="password" name="password"/>
					<span class="passDesc">(for post and file deletion)</span>
				</div>
			</div>
			<if $session-\>[1] ne 'janitor'>
				<div class="postTableContainer">
					<div class="postBlock">Options</div>
					<div class="postField">
						<if $session-\>[1] eq 'admin'><label>[<input type="checkbox" name="no_format" value="1" />HTML]</label></if>
						<label>[<input type="checkbox" name="capcode" value="1" />Capcode]</label>
					</div>
				</div>
				
				<if !$thread>
					<div class="postTableContainer">
					<div class="postBlock">Flags</div>
					<div class="postField">
					<label>[<input type="checkbox" name="sticky" value="1" />Sticky]</label>
					<label>[<input type="checkbox" name="locked" value="1" />Lock]</label>
					</div>
				</div>
				</if>
			</if>
		</div>
	</form>
</div>
<script type="text/javascript">setPostInputs()</script></if>
<hr class="postinghr" />
<form id="delform" action="<var $self>" method="post">
<input type="hidden" name="admin" value="<var $admin>" />
<loop $threads>
<if $thread><label>[<input type="checkbox" onchange="expandAllImages();" /> Expand Images ]</label></if>
	<div class="thread"><loop $posts>
		<if !$parent>
			<div class="parentPost<if $reported> reportedParent</if>" id="parent<var $num>">
				<div class="hat"></div>
				<if $image><span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
					-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span>
					<br />
					<if $thumbnail><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>">
						<if !$tnmask><img src="<var expand_filename($thumbnail)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if><if $tnmask><img src="http://<var DOMAIN>/img/spoiler.png" data-md5="<var $md5>" alt="<var $size>" class="thumb opThumb" /></if></a></if>
					<if !$thumbnail>
						<if DELETED_THUMBNAIL><a target="_blank" class="thumbLink" href="<var expand_image_filename(DELETED_IMAGE)>"><img src="<var expand_filename(DELETED_THUMBNAIL)>" style="width:<var $tn_width>px; height:<var $tn_height>px;" alt="" class="thumb opThumb" /></a></if>
					<if !DELETED_THUMBNAIL><div class="thumb nothumb"><a target="_blank" class="thumbLink" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div></if></if></if>
				<a id="<var $num>"></a>
				<span class="parentPostInfo">
					<input type="checkbox" name="delete" value="<var $num>" />
					<span class="filetitle"><var $subject></span>
					<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip> <span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
					<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
					<var substr($date,0,index($date,"ID:"))><span class="id"><var substr($date, index($date,"ID:"))></span>
					<span class="reflink">
					<if !$thread><a class="refLinkInner" href="<var get_reply_link($num,0)>#i<var $num>">No.<var $num></a></if>
					<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
					<if $sticky><img src="http://<var DOMAIN>/img/sticky.gif" alt="Stickied"/></if>
					<if $locked><img src="http://<var DOMAIN>/img/closed.gif " alt="Locked"/></if>
					</span>&nbsp;
					}.ADMIN_POST_BUTTONS_TEMPLATE.q{
					<if !$thread>[<a href="<var $self>?admin=<var $admin>&amp;task=viewthread&amp;num=<var $num>"><const S_REPLY></a>]</if>
					<a href="javascript:void(0)" onclick="togglePostMenu(this);"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
				</span>
				<div class="postMenu" id="postMenu<var $num>">
					<a href="http://<var DOMAIN>/<var BOARD_DIR>/res/<var $parent>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
				</div>
				<blockquote<if $email=~/aa$/i> class="aa"</if>>
				<var $comment>
				<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
				</blockquote>
			</div>
			<if $omit><span class="omittedposts">
				<if $omitimages><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if !$omitimages><var sprintf S_ABBR,$omit></if>
			</span></if></if>
		<if $parent><div class="replyContainer" id="replyContainer<var $num>">
				<div class="doubledash">&gt;&gt;</div>
				<div class="reply<if $reported> reportedReply</if>" id="reply<var $num>">
					<a id="<var $num>"></a>
					<div class="replyPostInfo"><input type="checkbox" name="delete" value="<var $num>" />
						<span class="replytitle"><var $subject></span>
						<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
						<if !$email><span class="postername"><var $name></span><if $trip> <span class="postertrip"><var $trip></span></if></if>
						<var substr($date,0,index($date,"ID:"))><span class="id"><var substr($date, index($date,"ID:"))></span>
						<span class="reflink">
						<if !$thread><a class="refLinkInner" href="<var get_reply_link($parent,0)>#i<var $num>">No.<var $num></a></if>
						<if $thread><a class="refLinkInner" href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if></span>
						}.ADMIN_POST_BUTTONS_TEMPLATE.q{
						<a href="javascript:void(0)" onclick="togglePostMenu(this);"  class="postMenuButton" id="postMenuButton<var $num>">[<span></span>]</a>
					</div>
					
					<div class="postMenu" id="postMenu<var $num>">
						<a href="http://<var DOMAIN>/<var BOARD_DIR>/res/<var $parent>#<var $num>" class="postMenuItem" target="_blank">Permalink</a>
					</div>
					
					<if $image><br />
						<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><if !$filename><var get_filename($image)></if><if $filename><var truncateLine($filename)></if></a>
						-(<em><var int($size/1024)> KB, <var $width>x<var $height></em>)</span><br />
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
						<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
					</blockquote>
				</div>
			</div></if>
		</loop>
	</div>
	<hr />
</loop>

<if $thread>
	[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>"><const S_RETURN></a>]
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
<if !$thread>
	<div id="pageNumber">
	<loop $pages>
		<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
		<if $current>[<var $page>]</if>
	</loop>
	</div><br />
</if>
<div id="bottomNavStatic" class="staticNav">
	<div style="float:right">
		[<a href="javascript:void(0)" onclick="toggleNavMenu(this,0);">Board Options</a>]
		[<a href="<var $self>?task=mpanel&amp;admin=<var $admin>">Home</a>]
	</div>
</div>
</div>
}.NORMAL_FOOT_INCLUDE);

1;