#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use CGI;
use DBI;

#
# Import settings
#

use lib '.';
BEGIN { require "config.pl"; }
BEGIN { require "../globalconfig.pl"; } # path to your global config file
BEGIN { require "config_defaults.pl"; }
BEGIN { require "strings_en.pl"; }		# edit this line to change the language
BEGIN { require "futaba_style.pl"; }	# edit this line to change the board style
BEGIN { require "admin_style.pl"; } # awwwwwwwwwwww shit
BEGIN { require "captcha.pl"; }
BEGIN { require "wakautils.pl"; }

#
# Optional modules
#

my ($has_encode, $use_fastcgi);
my ($query,$dbh,$task);
my $protocol_re=qr/(?:http|https|ftp|mailto|nntp)/;

if(CONVERT_CHARSETS){
	eval 'use Encode qw(decode encode)';
	$has_encode=1 unless($@);
}

if(USE_FASTCGI){
	eval 'use CGI::Fast';
	unless($@){
		$use_fastcgi=1;

		# set up signal handlers
		# http://www.fastcgi.com/docs/faq.html#Signals
		$SIG{USR1}=\&sig_handler;
		$SIG{TERM}=\&sig_handler;
		$SIG{PIPE}='IGNORE';
	}
}

if($use_fastcgi){
	FASTCGI:
	while($query=new CGI::Fast){
		init();
		last if(!$use_fastcgi);
	}
}
else { $query=new CGI; init(); }

sub sig_handler
{
	$use_fastcgi=0;
}

#
# Global init
#

sub init(){
	# This must be placed in here so we can spawn a new DB connection if the old one dies.
	if($use_fastcgi) { $dbh=DBI->connect_cached(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or make_error(S_SQLCONF); }
	else { $dbh=DBI->connect(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or make_error(S_SQLCONF); }

	$task=($query->param("task") or $query->param("action"));

	# check for admin tables
	init_admin_database() if(!table_exists(SQL_ADMIN_TABLE));
	initMessageDatabase() if(!table_exists(SQL_MESSAGE_TABLE));
	initReportDatabase() if(!table_exists(SQL_REPORT_TABLE));
	initBanRequestDatabase()  if(!table_exists(SQL_BANREQUEST_TABLE));
	initDeletedDatabase()  if(!table_exists(SQL_DELETED_TABLE));
	initLogDatabase()  if(!table_exists(SQL_LOG_TABLE));
	initPassDatabase() if(!table_exists(SQL_PASS_TABLE));

	if(!table_exists(SQL_USER_TABLE)){
		initUserDatabase();
		my $sth=$dbh->prepare("INSERT INTO ".SQL_USER_TABLE." VALUES(?,?,?,?,NULL,NULL,NULL,NULL,NULL);") or make_error(S_SQLFAIL);
		$sth->execute('admin','admin','admin@admin.com','admin') or make_error(S_SQLFAIL);
	}

	# check for proxy table
	init_proxy_database() if(!table_exists(SQL_PROXY_TABLE));

	if(!table_exists(SQL_TABLE)) # check for comments table
	{
		init_database();
		build_cache();
		make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
	}
	elsif(!$task){
		build_cache() unless -e HTML_SELF;
		make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
	}
	elsif($task eq "post"){
		my $parent=$query->param("parent");
		my $name=$query->param("field1");
		my $email=$query->param("field2");
		my $subject=$query->param("field3");
		my $comment=$query->param("field4");
		my $file=$query->param("file");
		my $password=$query->param("password");
		my $nofile=$query->param("nofile");
		my $captcha=$query->param("captcha");
		my $admin=$query->param("admin");
		my $no_captcha=$query->param("no_captcha");
		my $no_format=$query->param("no_format");
		my $postfix=$query->param("postfix");
		my $challenge=$query->param("recaptcha_challenge_field");
		my $response=$query->param("recaptcha_response_field");
		my $sticky=$query->param("sticky");
		my $permasage=$query->param("permasage");
		my $locked=$query->param("locked");
		my $capcode=$query->param("capcode");
		my $spoiler=$query->param("spoiler");
		my $nsfw=$query->param("nsfw");
		my $passcookie=$query->cookie("wakapass");

		post_stuff($parent,$name,$email,$subject,$comment,$file,$file,$password,$nofile,$captcha,$admin,$no_captcha,$no_format,$postfix,$challenge,$response,$sticky,$permasage,$locked,$capcode,$spoiler,$nsfw,$passcookie);
	}
	elsif($task eq "delete"){
		my $password=$query->param("password");
		my $fileonly=$query->param("fileonly");
		my $archive=$query->param("archive");
		my $admin=$query->param("admin");
		my @posts=$query->param("delete");
		
		#make_error("ur a faggot1") unless(@posts=~m/[0-9]*/);
		make_error("ur a faggot2") unless($fileonly=~m/[0-9]*/);
		make_error("ur a faggot3") unless($archive=~m/[0-9]*/);
		
		delete_stuff($password,$fileonly,$archive,$admin,@posts);
	}
	elsif($task eq "admin"){
		my $user=$query->param("user");
		my $password=$query->param("berra"); # lol obfuscation
		my $nexttask=$query->param("nexttask"); # I should delete this
		my $savelogin=$query->param("savelogin");
		my $admincookie=$query->cookie("wakaadmin");

		do_login($user,$password,$nexttask,$savelogin,$admincookie);
	}
	elsif($task eq "logout"){
		my $type=$query->param("type");
		do_logout($type);
	}
	elsif($task eq "mpanel"){
		my $admin=$query->param("admin");
		#make_admin_post_panel($admin);
		make_page($admin,0);
	}
	elsif($task eq "deleteall"){
		my $admin=$query->param("admin");
		my $ip=$query->param("ip");
		my $mask=$query->param("mask");
		delete_all($admin,parse_range($ip,$mask));
	}
	elsif($task eq "bans"){
		my $admin=$query->param("admin");
		make_admin_ban_panel($admin);
	}
	elsif($task eq "addip"){
		my $admin=$query->param("admin");
		my $type=$query->param("type");
		my $comment=$query->param("comment");
		my $ip=$query->param("ip");
		my $mask=$query->param("mask");
		my $public=$query->param("public");
		my $private=$query->param("private");
		my $duration=$query->param("duration");
		my $pubbannedby=$query->param("fromuser");
		my $displayfrom=$query->param("displayfrom");
		my $scope=$query->param("scope");
		my $threadban=$query->param("threadban");
		my $num=$query->param("num");
		my $postban=$query->param("postban");
		my $warn=$query->param("warn");
		my $perm=$query->param("perm");
		
		advancedIPBan($admin,$type,$public,$private,parse_range($ip,$mask),$duration,$pubbannedby,$displayfrom,$scope,$threadban,$num,$postban,$warn,$perm);
	}
	elsif($task eq "addstring"){
		my $admin=$query->param("admin");
		my $type=$query->param("type");
		my $string=$query->param("string");
		my $comment=$query->param("comment");
		add_admin_entry($admin,$type,$comment,0,0,$string);
	}
	elsif($task eq "removeban"){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		remove_admin_entry($admin,$num);
	}
	elsif($task eq "proxy"){
		my $admin=$query->param("admin");
		make_admin_proxy_panel($admin);
	}
	elsif($task eq "addproxy"){
		my $admin=$query->param("admin");
		my $type=$query->param("type");
		my $ip=$query->param("ip");
		my $timestamp=$query->param("timestamp");
		my $date=make_date(time(),DATE_STYLE);
		add_proxy_entry($admin,$type,$ip,$timestamp,$date);
	}
	elsif($task eq "removeproxy"){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		remove_proxy_entry($admin,$num);
	}
	elsif($task eq "spam"){
		my ($admin);
		$admin=$query->param("admin");
		make_admin_spam_panel($admin);
	}
	elsif($task eq "updatespam"){
		my $admin=$query->param("admin");
		my $spam=$query->param("spam");
		update_spam_file($admin,$spam);
	}
	elsif($task eq "sqldump"){
		my $admin=$query->param("admin");
		make_sql_dump($admin);
	}
	elsif($task eq "sql"){
		my $admin=$query->param("admin");
		my $nuke=$query->param("nuke");
		my $sql=$query->param("sql");
		make_sql_interface($admin,$nuke,$sql);
	}
	elsif($task eq "mpost"){
		my $admin=$query->param("admin");
		make_admin_post($admin);
	}
	elsif($task eq "rebuild"){
		my $admin=$query->param("admin");
		do_rebuild_cache($admin);
	}
	elsif($task eq "nuke"){
		my $admin=$query->param("admin");
		my $nukepass=$query->param("nukepass");
		do_nuke_database($nukepass,$admin);
	}
	elsif($task eq "list"){
		make_error("Disabled");
	}
	elsif($task eq "cat"){
		make_error("Disabled");
	}
	elsif($task eq "stickdatshit"){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		
		# since everyone using wakaba already hates stickies, might as well continue with the trend of hated things
		my $jimmies=$query->param("jimmies");
		toggle_sticky($admin,$num,$jimmies);
	}
	elsif($task eq "permasage"){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		my $jimmies=$query->param("jimmies");
		toggle_permasage($admin,$num,$jimmies);
	}
	elsif($task eq "lockthread"){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		my $jimmies=$query->param("jimmies");
		toggle_lock($admin,$num,$jimmies);
	}
	elsif($task eq "report"){
		my $num=$query->param("num");
		my $board=$query->param("board");
		my $reason=$query->param("reason");
		report($num,$board,$reason) if(length $reason>1); # lol perl style
		makeReportForm($num, $board);
	}
	elsif($task eq "register"){
		my $admin=$query->param("admin");
		make_add_user($admin) unless length($admin)<1;
	}
	elsif($task eq "adduser"){
		my $user=$query->param("user");
		my $pass=$query->param("pass");
		my $class=$query->param("class");
		my $email=$query->param("email");
		my $admin=$query->param("admin");
		
		add_user($admin,$user,$pass,$email,$class);
	}
	elsif($task eq 'manageusers'){
		my $admin=$query->param("admin");
		make_manage_users($admin);
	}
	elsif($task eq 'removeuser'){
		my $admin=$query->param("admin");
		my $user=$query->param("user");
		remove_user($user,$admin);
	}
	elsif($task eq 'edituser'){
		my $admin=$query->param("admin");
		my $user=$query->param("user");
		make_edit_user($admin,$user);
	}
	elsif($task eq 'setnewpass'){
		my $admin=$query->param("admin");
		my $user=$query->param("user");
		my $oldpass=$query->param("oldpass");
		my $newpass=$query->param("newpass");
		my $email=$query->param("email");
		my $class=$query->param("class");
		update_user_details($user,$oldpass,$newpass,$email,$class,$admin);
	}
	elsif($task eq 'composemsg'){
		my $admin=$query->param("admin");
		my $parentmsg=$query->param("replyto");
		my $to=$query->param("to");
		make_compose_message($admin,$parentmsg,$to);
	}
	elsif($task eq 'sendmsg'){
		my $admin=$query->param("admin");
		my $msg=$query->param("message");
		my $to=$query->param("to");
		my $parentmsg=$query->param("replyto");
		my $isnote=$query->param("isnote");
		send_message($admin,$msg,$to,$parentmsg,$isnote);
	}
	elsif($task eq 'inbox'){
		my $admin=$query->param("admin");
		make_inbox($admin);
	}
	elsif($task eq 'viewmsg'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		make_view_message($admin,$num);
	}
	elsif($task eq 'viewthreads'){
		my $admin=$query->param("admin");
		my $page=$query->param("page");
		make_page($admin,$page);
	}
	elsif($task eq 'viewthread'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		make_thread($admin,$num);
	}
	elsif($task eq 'ippage'){
		my $admin=$query->param("admin");
		my $ip=$query->param("ip");
		make_ip_page($ip,$admin);
	}
	elsif($task eq 'updateban'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		my $ip=$query->param("ip");
		my $reason=$query->param("comment");
		my $active=$query->param("active");
		update_ban($admin,$num,$ip,$reason,$active);
	}
	elsif($task eq 'editpost'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		make_edit_post($admin,$num);
	}
	elsif($task eq 'updatepost'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		my $comment=$query->param("field4");
		my $subject=$query->param("field3");
		my $name=$query->param("field1");
		my $link=$query->param("field2");P
		my $trip=$query->param("field1andahalf");
		edit_post($admin,$num,$comment,$subject,$name,$link,$trip);
	}
	elsif($task eq 'viewreports'){
		my $admin=$query->param("admin");
		make_reports_list($admin);
	}
	elsif($task eq 'viewreport'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		make_view_report($num,$admin);
	}
	elsif($task eq 'requestban'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		make_ban_request($admin,$num);
	}
	elsif($task eq 'submitrequest'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		my $reason=$query->param("reason");
		my $reason2=$query->param("reason2");
		request_ban($admin,$num,$reason,$reason2)
	}
	elsif($task eq 'dismiss'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		dismiss_remort($admin,$num);
	}
	elsif($task eq 'listrequests'){
		my $admin=$query->param("admin");
		make_ban_requests($admin);
	}
	elsif($task eq 'dismissrequests'){
		my $admin=$query->param("admin");
		my $ip=$query->param("ip");
		my $num=$query->param("num");
		dismiss_requests($admin,$ip,$num);
	}
	elsif($task eq 'bantemplate'){
		my $admin=$query->param("admin");
		my $ip=$query->param("ip");
		my $num=$query->param("num");
		make_ban_page($ip,$num,$admin);
	}
	elsif($task eq 'viewdeletedpost'){
		my $admin=$query->param("admin");
		my $num=$query->param("num");
		view_deleted_post($admin,$num);
	}
	elsif($task eq 'viewlog'){
		my $admin=$query->param("admin");
		make_view_log($admin)
	}
	elsif($task eq 'clearlog'){
		my $admin=$query->param("admin");
		clear_log($admin);
	}
	elsif($task eq 'getpass'){
		make_pass_page();
	}
	elsif($task eq 'addpass'){
		my $email=$query->param("email");
		my $mailver=$query->param("mailver");
		my $accept=$query->param("acceptTerms");
		add_pass($email,$mailver,$accept);
	}
	elsif($task eq 'passauth'){
		my $passcookie=$query->cookie("wakapass");
		make_authorize_pass($passcookie);
	}
	elsif($task eq 'authpass'){
		my $token=$query->param("token");
		my $pin=$query->param("pin");
		my $remember=$query->param("remember");
		authorize_pass($token,$pin,$remember);
	}
	elsif($task eq 'passlist'){
		my $admin=$query->param("admin");
		make_pass_list($admin);
	}
	elsif($task eq 'updatepass'){
		my $admin=$query->param("admin");
		my $action=$query->param("action");
		my $num=$query->param("num");
		update_pass($admin,$num,$action);
	}
	elsif($task eq 'restart'){
		my $admin=$query->param("admin");
		restart_script($admin);
	}
	else{
		make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
	}

	unless($use_fastcgi){
		$dbh->disconnect();
	}
}

sub restart_script($){
	my ($admin)=@_;
	my @session = check_password($admin);
	
	logAction("restartscript","",@session);

	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
	last FASTCGI;
}

sub makeList(@){
	my (@rows)=@_; # less queries = less load
	my (@threads,$filename);
	
	foreach my $row (@rows){
		my ($posts,$size)=count_posts($$row{num});
		$$row{'postcount'}=$posts; # add post count to hash
		$$row{'threadsize'}=$size; # guess
		push @threads,$row;
	}
	
	$filename = "subback.html";
	print_page($filename,LIST_TEMPLATE->(threads=>\@threads));
}

sub makeCatalog(@){
	my (@rows)=@_;
	my ($filename,@threads);
	
	foreach my $row (@rows){
		my ($posts,$size,$images)=count_posts($$row{num},1);
		$$row{'postcount'}=$posts-1; # add post count to hash
		$$row{'imagecount'}=$images-1; # add image count to hash
		push @threads,$row;
	}
	
	$filename = "catalog.html";
	print_page($filename,CATALOG_TEMPLATE->(threads=>\@threads));
}

sub makeReportForm($$){
	my ($num,$board)=@_;
	
	make_http_header();
	print encode_string(REPORT_TEMPLATE->(num=>$num,board=>$board));
}

sub report($$$){
	my ($num,$board,$reason)=@_;
	my ($sth,$index,$row,$vio,$spam,$illegal,$parent,$post,$time);
	
	ban_check(dot_to_dec(get_ip(USE_CLOUDFLARE)),'','','');
	
	$time=time();

	make_error("Invalid Post No.") unless($num=~m/[0-9]*/);
	make_error("Invalid Board") unless($board eq BOARD_DIR); # will replace with global board list soon
	make_error("Invalid Reason") unless($reason=~m/(vio|illegal|spam)/);
	
	# check if post exists and if its reportable
	$post = get_post($num);
	make_error("Could not find post.") unless $post;
	make_error("You can't report a sticky.") if $$post{sticky} and !$$post{parent};
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_REPORT_TABLE." WHERE board=? AND postnum=? ORDER BY num ASC;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR,$num) or make_error(S_SQLFAIL);
	$index=0;
	
	while($row=get_decoded_hashref($sth)){
		if($index==0) { $parent=$$row{num} }
		$index++;
		unless($$row{parent}){
			$vio=$$row{vio};
			$spam=$$row{spam};
			$illegal=$$row{illegal};
		}
		if($$row{fromip} eq get_ip(USE_CLOUDFLARE)){
			make_error("You or someone with the same IP has already reported this post.")
		}
	}
	
	$vio++ if $reason eq 'vio';
	$spam++ if $reason eq 'spam';
	$illegal++ if $reason eq 'illegal';
	
	if($index==0){
		$sth=$dbh->prepare("INSERT INTO ".SQL_REPORT_TABLE." VALUES(null,?,null,?,?,?,?,?,?);") or make_error(S_SQLFAIL);
		$sth->execute($num,BOARD_DIR,get_ip(USE_CLOUDFLARE),$time,$vio,$spam,$illegal) or make_error(S_SQLFAIL);
		
		# notify moderation staff
		my $sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET newreports=1") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);
	}
	else{
		# update original/parent report
		$sth=$dbh->prepare("UPDATE ".SQL_REPORT_TABLE." SET vio=?,spam=?,illegal=? WHERE postnum=? AND num=?;") or make_error($dbh->errstr);
		$sth->execute($vio,$spam,$illegal,$num,$parent) or make_error(S_SQLFAIL);
		
		# add a child report with the "unique" data
		$sth=$dbh->prepare("INSERT INTO ".SQL_REPORT_TABLE." VALUES(null,?,?,?,?,?,null,null,null);") or make_error(S_SQLFAIL);
		$sth->execute($num,$parent,BOARD_DIR,get_ip(USE_CLOUDFLARE),$time) or make_error(S_SQLFAIL);
	}
	
	make_http_forward('javascript:window.close();',1);
}

sub dismiss_remort($$){
	my ($admin,$num)=@_;
	my $sth;
	my @session = check_password($admin);
	
	logAction("dismissreport",$num,@session);
	
	$sth=$dbh->prepare("DELETE FROM ".SQL_REPORT_TABLE." WHERE postnum=? AND board=?;") or make_error(S_SQLFAIL);
	$sth->execute($num,BOARD_DIR) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=viewreports",ALTERNATE_REDIRECT);
}

sub make_ban_request($$){
	my ($admin,$num)=@_;
	my ($sth,$row,@requested);
	my @session = check_password($admin);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_BANREQUEST_TABLE." WHERE postnum=? AND board=?;") or make_error(S_SQLFAIL);
	$sth->execute($num,BOARD_DIR) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @requested, $row;
	}
	
	make_http_header();
	print encode_string(BAN_REQUEST_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		requested=>\@requested,
		num=>$num
	));
}

sub request_ban($$){
	my ($admin,$num,$reason,$reason2)=@_;
	my ($sth,$row,$posturl);
	my @session = check_password($admin);
	my $time=time();
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	
	my $post=get_decoded_hashref($sth);
	logAction("banrequest",$$post{ip},@session);
	
	$sth=$dbh->prepare("INSERT INTO ".SQL_BANREQUEST_TABLE." VALUES(null,?,?,?,?,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($num,$$post{parent},BOARD_DIR,$$post{ip},$reason,$reason2,@session[0],$time) or make_error(S_SQLFAIL);
	
	# notify non-janitor moderation staff
	my $sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET newbanreqs=1 WHERE class<>?") or make_error(S_SQLFAIL);
	$sth->execute("janitor") or make_error(S_SQLFAIL);
		
	make_http_forward(get_script_name()."?admin=$admin&task=viewreports",ALTERNATE_REDIRECT);
}

sub make_ban_requests($){
	my ($admin)=@_;
	my @session = check_password($admin);
	my (@requested,@postnumbers,$sth,$row);
	
	if (@session[1] eq "janitor"){
		make_error(S_CLASS);
	}
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_BANREQUEST_TABLE." WHERE board=? ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @requested, $row;
	}
	
	clear_notifications(@session[0],"banrequests");
	
	make_http_header();
	print encode_string(BAN_REQUEST_LIST_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		requested=>\@requested
	));
}

sub dismiss_requests($$$){
	my ($admin,$ip,$num)=@_;
	my $sth;
	my @session = check_password($admin);
	
	if (@session[1] eq "janitor"){
		make_error(S_CLASS);
	}
	
	logAction("dismissrequests",$ip,@session);
	
	if($ip){
		$sth=$dbh->prepare("DELETE FROM ".SQL_BANREQUEST_TABLE." WHERE ip=? AND board=?;") or make_error(S_SQLFAIL);
		$sth->execute($ip,BOARD_DIR) or make_error(S_SQLFAIL);
	}
	elsif($num){
		$sth=$dbh->prepare("DELETE FROM ".SQL_BANREQUEST_TABLE." WHERE postnum=? AND board=?;") or make_error(S_SQLFAIL);
		$sth->execute($num,BOARD_DIR) or make_error(S_SQLFAIL);
	}
	
	make_http_forward(get_script_name()."?admin=$admin&task=listrequests",ALTERNATE_REDIRECT);
}

sub make_reports_list($){
	my ($admin)=@_;
	my @session = check_password($admin);
	my ($sth,$row,$lastnum,$lastrow,$index,$statement,@reportedposts,@reports,@posts);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_REPORT_TABLE." WHERE board=? AND (parent IS NULL) ORDER BY postnum DESC;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @reports,$row;
		push @reportedposts,$$row{postnum};
		$$row{vio}=0 unless $$row{vio};
		$$row{spam}=0 unless $$row{spam};
		$$row{illegal}=0 unless $$row{illegal};
		$$row{totalreports}=$$row{vio}+$$row{spam}+$$row{illegal};
	}
	
	if((scalar @reportedposts) == 0) { push @reportedposts,1 };
	
	# fucking magic
	$statement = "SELECT * FROM ".SQL_TABLE." WHERE num IN (" . join( ',', map { "?" } @reportedposts ) . ") ORDER BY num DESC;";
	$sth=$dbh->prepare($statement) or make_error($dbh->errstr);
	$sth->execute(@reportedposts) or make_error($dbh->errstr);
	
	$index = 0;
	
	while($row=get_decoded_hashref($sth)){
		# add report data to posts
		$$row{fromip}=$reports[$index]{fromip};
		$$row{totalreports}=$reports[$index]{totalreports};
		$$row{vio}=$reports[$index]{vio};
		$$row{illegal}=$reports[$index]{illegal};
		$$row{spam}=$reports[$index]{spam};
		
		push @posts,$row;
		$index++;
	}
	
	clear_notifications(@session[0],"reports");
	
	make_http_header();
	print encode_string(REPORTS_PAGE_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		posts=>\@posts
	));
}

sub make_view_report($$){
	my ($num,$admin)=@_;
	my @session = check_password($admin);
	my ($sth,$row,@post,@reports,$first,$last,@iplist,$total);
	
	# grab all reports for the post and prepare some data
	$sth=$dbh->prepare("SELECT * FROM ".SQL_REPORT_TABLE." WHERE board=? AND postnum=? ORDER BY postnum DESC;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR,$num) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @reports, $row;
		$$row{vio}=0 unless $$row{vio};
		$$row{spam}=0 unless $$row{spam};
		$$row{illegal}=0 unless $$row{illegal};
	}
	
	$first = $reports[0]{timestamp};
	if((scalar @reports)==1) { $last=$first } else { $last = $reports[((scalar @reports) - 1)]{timestamp} }
	$total = $reports[0]{vio} + $reports[0]{illegal} + $reports[0]{spam};
	
	# grab the post without get_post() to make modifying the template easier
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)) { push @post, $row }
	
	make_http_header();
	print encode_string(REPORT_PAGE_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		post=>\@post,
		first=>$first,
		last=>$last,
		total=>$total,
		reports=>\@reports,
		num=>$num,
		parent=>$post[0]{parent}
	));
}

sub make_ban_page($$$){
	my ($ip,$num,$admin)=@_;
	my ($sth,$row,@bans);
	my @session = check_password($admin);
	make_error(S_CLASS) if (@session[1] eq 'janitor');
	
	# get current bans
	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE ival1=? ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @bans, $row;
	}
	
	make_http_header();
	print encode_string(BAN_TEMPLATE_TEMPLATE->( # ha!
		admin=>$admin,
		ip=>$ip,
		num=>$num,
		session=>\@session,
		bans=>\@bans
	));
}

sub advancedIPBan($$$){
	my ($admin,$type,$public,$private,$ival1,$ival2,$duration,$pubbannedby,$displayfrom,$scope,$threadban,$num,$postban,$warn,$perm)=@_;
	my ($sth,$row,$post,@bans);
	my @session = check_password($admin);
	make_error(S_CLASS) if (@session[1] eq 'janitor');
	make_error("Thread banning not yet implemented") if ($threadban==1);
	make_error("You are required to give a public ban reason.") if (length $public < 1);
	
	if((!$duration)&&(!$perm)&&(!$warn)){
		make_error("Invalid ban duration. Select Permanent, Warning, or enter a valid number in the duration field before submitting a ban.");
	}
	
	logAction("ipban",dec_to_dot $ival1."<>".dec_to_dot $ival2,@session);
	
	# get the current time
	my $time = time();
	
	# clean up text
	$public=clean_string(decode_string($public,CHARSET));
	$private=clean_string(decode_string($private,CHARSET));
	if($displayfrom==1) { $pubbannedby=clean_string(decode_string($pubbannedby,CHARSET)) }
	else { $pubbannedby='' }
	
	# convert days into seconds and add that to the current time
	$duration=$time+(($duration*24)*3600);

	# add ban to database
	$sth=$dbh->prepare("INSERT INTO ".SQL_ADMIN_TABLE." VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($type,$public,$private,$ival1,$ival2,'',@session[0],$pubbannedby,$duration,$perm,$scope,$num,BOARD_DIR,$warn,$time,1) or make_error(S_SQLFAIL);
	
	# clear all ban requests for the banned ip
	$sth=$dbh->prepare("DELETE FROM ".SQL_BANREQUEST_TABLE." WHERE ip=? AND board=?;") or make_error(S_SQLFAIL);
	$sth->execute($ival1,BOARD_DIR) or make_error(S_SQLFAIL);
	
	# post ban action
	if($postban eq 'deletebynum'){
		delete_stuff('',0,0,$admin,$num);
	}
	elsif($postban eq 'deletebynumfo'){
		delete_stuff('',1,0,$admin,$num);
	}
	elsif($postban eq 'deletebyip'){
		delete_all($admin,$ival1,$ival2);
	}
	
	# redirect to the ip page
	make_http_forward(get_script_name()."?admin=$admin&task=ippage&ip=".$ival1,ALTERNATE_REDIRECT);
}

#
# Cache page creation
#

sub build_cache(){
	my ($sth,$row,@thread);
	my $page=0;

	# grab all posts, in thread order (ugh, ugly kludge)
	# lol stickies
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	$row=get_decoded_hashref($sth);

	if(!$row) # no posts on the board!
	{
		build_cache_page(0,1); # make an empty page 0
	}
	else
	{
		my (@threads);
		my @thread=($row);
		my @parentposts=($row);

		while($row=get_decoded_hashref($sth)){
			if(!$$row{parent}){
				push @threads,{posts=>[@thread]};
				push @parentposts,$row;
				@thread=($row); # start new thread
			}
			else
			{
				push @thread,$row;
			}
		}
		push @threads,{posts=>[@thread]};
		
		# hurray for optimization
		makeList(@parentposts);
		makeCatalog(@parentposts);

		my $total=get_page_count(scalar @threads);
		my @pagethreads;
		while(@pagethreads=splice @threads,0,IMAGES_PER_PAGE){
			build_cache_page($page,$total,@pagethreads);
			$page++;
		}
	}

	# check for and remove old pages
	while(-e $page.PAGE_EXT){
		unlink $page.PAGE_EXT;
		unlink $page.".json";
		$page++;
	}
}

sub build_cache_page($$@){
	my ($page,$total,@threads)=@_;
	my ($filename,$tmpname,$threadindex);

	if($page==0) { $filename=HTML_SELF; }
	else { $filename=$page.PAGE_EXT; }

	# do abbrevations and such
	foreach my $thread (@threads){
		# split off the parent post, and count the replies and images
		my ($parent,@replies)=@{$$thread{posts}};
		my $replies=@replies;
		my $images=grep { $$_{image} } @replies;
		my $curr_replies=$replies;
		my $curr_images=$images;
		my $max_replies=REPLIES_PER_THREAD;
		my @staffposts;
		my $capcodereplies;
		
		# count staff posts
		if(SHOW_STAFF_POSTS){
			foreach my $post (@replies){
				if($$post{staffpost}){
					# 1=admin, 2=mod, 3=dev, and 4=vip
					if($$post{staffpost}==1){
						@staffposts[0].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
					}
					elsif($$post{staffpost}==2){
						@staffposts[1].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
					}
					elsif($$post{staffpost}==3){
						@staffposts[2].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
					}
					elsif($$post{staffpost}==4){
						@staffposts[3].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
					}
					$capcodereplies+=1;
				}
			}
		}
		
		# only display one reply if the thread is stickied
		if($$parent{sticky}==1){
			$max_replies=1;
		}
		
		my $max_images=(IMAGE_REPLIES_PER_THREAD or $images);

		# drop replies until we have few enough replies and images
		while($curr_replies>$max_replies or $curr_images>$max_images){
			my $post=shift @replies;
			$curr_images-- if($$post{image});
			$curr_replies--;
		}

		# write the shortened list of replies back
		$$thread{posts}=[$parent,@replies];
		$$thread{adminreplies}=@staffposts[0];
		$$thread{modreplies}=@staffposts[1];
		$$thread{devreplies}=@staffposts[2];
		$$thread{vipreplies}=@staffposts[3];
		$$thread{capcodereplies}=$capcodereplies;
		$$thread{omit}=$replies-$curr_replies;
		$$thread{omitimages}=$images-$curr_images;
		
		# json stuff
		my $lastpost = $$thread{posts}[(scalar @replies)];
		$$lastpost{lastpost} = 1;

		# abbreviate the remaining posts
		foreach my $post (@{$$thread{posts}}){
			my $abbreviation=abbreviate_html($$post{comment},MAX_LINES_SHOWN,APPROX_LINE_LENGTH);
			if($abbreviation){
				$$post{comment}=$abbreviation;
				$$post{abbrev}=1;
			}
		}
	}
	
	# json stuff
	my $lastthread = @threads[(scalar @threads)-1];
	$$lastthread{lastthread} = 1;

	# make the list of pages
	my @pages=map +{ page=>$_ },(0..$total-1);
	foreach my $p (@pages){
		if($$p{page}==0) { $$p{filename}=expand_filename(HTML_SELF) } # first page
		else { $$p{filename}=expand_filename($$p{page}.PAGE_EXT) }
		if($$p{page}==$page) { $$p{current}=1 } # current page, no link
	}

	my ($prevpage,$nextpage);
	$prevpage=$pages[$page-1]{filename} if($page!=0);
	$nextpage=$pages[$page+1]{filename} if($page!=$total-1);

	print_page($filename,PAGE_TEMPLATE->(
		postform=>(ALLOW_TEXTONLY or ALLOW_IMAGES),
		image_inp=>ALLOW_IMAGES,
		textonly_inp=>(ALLOW_IMAGES and ALLOW_TEXTONLY),
		prevpage=>$prevpage,
		nextpage=>$nextpage,
		pages=>\@pages,
		threads=>\@threads
	));
	
	if($filename eq 'wakaba.html'){
		print_page("0.json",JSON_INDEX_TEMPLATE->(
			threads=>\@threads,
			isindex=>1
		));
	}
	else{
		print_page(substr($filename,0,-4)."json",JSON_INDEX_TEMPLATE->(
			threads=>\@threads,
			isindex=>1
		));
	}
}

sub build_thread_cache($){
	my ($thread)=@_;
	my ($sth,$row,$lastpost,$capcodereplies,@thread,@staffposts);
	my ($filename,$tmpname);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? OR parent=? ORDER BY num ASC;") or make_error(S_SQLFAIL);
	$sth->execute($thread,$thread) or make_error(S_SQLFAIL);

	while($row=get_decoded_hashref($sth)) { push(@thread,$row); }
	
	# count staff posts
	if(SHOW_STAFF_POSTS){
		foreach my $post (@thread){
			if(($$post{staffpost}) and ($$post{parent})){
				# 1=admin, 2=mod, 3=dev, and 4=vip
				if($$post{staffpost}==1){
					@staffposts[0].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
				}
				elsif($$post{staffpost}==2){
					@staffposts[1].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
				}
				elsif($$post{staffpost}==3){
					@staffposts[2].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
				}
				elsif($$post{staffpost}==4){
					@staffposts[3].= " <a class=\"postlink\" href=\"http://".DOMAIN."/".BOARD_DIR."/res/".$$post{parent}."#".$$post{num}."\">&gt;&gt;".$$post{num}."</a>";
				}
				$capcodereplies+=1;
			}
		}
	}

	make_error(S_NOTHREADERR) if($thread[0]{parent});

	$filename=RES_DIR.$thread.PAGE_EXT;

	print_page($filename,PAGE_TEMPLATE->(
		thread=>$thread,
		postform=>(ALLOW_TEXT_REPLIES or ALLOW_IMAGE_REPLIES),
		image_inp=>ALLOW_IMAGE_REPLIES,
		textonly_inp=>0,
		capcodereplies=>$capcodereplies,
		adminreplies=>@staffposts[0],
		modreplies=>@staffposts[1],
		devreplies=>@staffposts[2],
		vipreplies=>@staffposts[3],
		dummy=>$thread[$#thread]{num},
		threads=>[{posts=>\@thread}])
	);
	
	# now build the json file
	$lastpost = $thread[(scalar @thread) - 1]{num};
	#make_error(scalar @thread);
	$filename=RES_DIR.$thread.".json";
	
	print_page($filename,JSON_THREAD_TEMPLATE->(
		lastpost=>$lastpost,
		posts=>\@thread
	));
}

sub print_page($$){
	my ($filename,$contents)=@_;

	$contents=encode_string($contents);
#		$PerlIO::encoding::fallback=0x0200 if($has_encode);
#		binmode PAGE,':encoding('.CHARSET.')' if($has_encode);

	if(USE_TEMPFILES){
		my $tmpname=RES_DIR.'tmp'.int(rand(1000000000));

		open (PAGE,">$tmpname") or make_error(S_NOTWRITE);
		print PAGE $contents;
		close PAGE;

		rename $tmpname,$filename;
	}
	else
	{
		open (PAGE,">$filename") or make_error(S_NOTWRITE);
		print PAGE $contents;
		close PAGE;
	}
}

sub build_thread_cache_all(){
	my ($sth,$row,@thread);

	$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	while($row=$sth->fetchrow_arrayref()){
		build_thread_cache($$row[0]);
	}
}

#
# Posting
#

sub post_stuff($$$$$$$$$$$$$$$$$$$$$){
	my ($parent,$name,$email,$subject,$comment,$file,$uploadname,$password,$nofile,$captcha,$admin,$no_captcha,$no_format,$postfix,$challenge,$response,$sticky,$permasage,$locked,$capcode,$spoiler,$nsfw,$passcookie)=@_;
	my $parent_res; # defining this earlier for locked threads
	
	# get a timestamp for future use
	my $time=time();
	my ($class,@session,@taargus);

	# check that the request came in as a POST, or from the command line
	make_error(S_UNJUST) if($ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST");

	if($admin) # check admin password - allow both encrypted and non-encrypted
	{
		if ($parent){
			$parent_res=get_parent_post($parent) or make_error(S_NOTHREADERR);
		}
		
		@session = check_password($admin);
	}
	else
	{
		# forbid admin-only features
		make_error(S_WRONGPASS) if($no_captcha or $no_format or $postfix or $sticky or $permasage or $locked);

		# forbid posting if thread is locked
		if ($parent){
			$parent_res=get_parent_post($parent) or make_error(S_NOTHREADERR);
			
			if($$parent_res{locked}){
				$locked = 1;
			}
			
			make_error(S_LOCKED) if($locked==1);
		}
		
		# check what kind of posting is allowed
		if($parent){
			make_error(S_NOTALLOWED) if($file and !ALLOW_IMAGE_REPLIES);
			make_error(S_NOTALLOWED) if(!$file and !ALLOW_TEXT_REPLIES);
		}
		else
		{
			make_error(S_NOTALLOWED) if($file and !ALLOW_IMAGES);
			make_error(S_NOTALLOWED) if(!$file and !ALLOW_TEXTONLY);
		}
	}

	# check for weird characters
	make_error(S_UNUSUAL) if($parent=~/[^0-9]/);
	make_error(S_UNUSUAL) if(length($parent)>10);
	make_error(S_UNUSUAL) if($name=~/[\n\r]/);
	make_error(S_UNUSUAL) if($email=~/[\n\r]/);
	make_error(S_UNUSUAL) if($subject=~/[\n\r]/);

	# check for excessive amounts of text
	make_error(S_TOOLONG) if(length($name)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($email)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($subject)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($comment)>MAX_COMMENT_LENGTH);

	# check to make sure the user selected a file, or clicked the checkbox
	make_error(S_NOPIC) if(!$parent and !$file and !$nofile and !$admin);

	# check for empty reply or empty text-only post
	make_error(S_NOTEXT) if($comment=~/^\s*$/ and !$file);

	# get file size, and check for limitations.
	my $size=get_file_size($file) if($file);

	# find IP
	my $ip=get_ip(USE_CLOUDFLARE);

	#$host = gethostbyaddr($ip);
	my $numip=dot_to_dec($ip);

	# set up cookies
	my $c_name=$name;
	my $c_email=$email;
	my $c_password=$password;

	# check if IP is whitelisted
	my $whitelisted=is_whitelisted($numip);

	# process the tripcode - maybe the string should be decoded later
	my $trip;
	($name,$trip)=process_tripcode($name,TRIPKEY,SECRET,CHARSET);
	
	# manual i <3 summer glau override
	if($trip eq "&nbsp;&#39;:3&nbsp;99YfK2R6d2") { $trip = "&nbsp;&#39;:3&nbsp;glauJJoHPM" }

	# check for bans
	ban_check($numip,$c_name,$subject,$comment) unless $whitelisted;

	# spam check
	spam_engine(
		query=>$query,
		trap_fields=>SPAM_TRAP?["name","link"]:[],
		spam_files=>[SPAM_FILES],
		charset=>CHARSET,
		included_fields=>["field1","field2","field3","field4"],
	) unless $whitelisted;
	
	if(!$no_captcha){
		@taargus=has_pass($passcookie);
		make_error("You must enter a CAPTCHA until your pass is approved by a moderator.") if @taargus[0]==2;
	}

	# check captcha
	if(ENABLE_CAPTCHA and !$no_captcha and !is_trusted($trip) and @taargus[0]!=1){
		check_captcha($dbh,$captcha,$ip,$parent) if(ENABLE_CAPTCHA ne 'recaptcha');
		check_recaptcha($challenge,$response,$ip) if(ENABLE_CAPTCHA eq 'recaptcha');
	}

	# proxy check
	proxy_check($ip) if (!$whitelisted and ENABLE_PROXY_CHECK);

	# check if thread exists, and get lasthit value
	# checks for sticky as well
	# and permasage too now
	# and locked threads as well
	my ($lasthit);
	
	if($parent){
		$lasthit=$$parent_res{lasthit};
		
		# sets the child posts to sticky if the parent is one
		if($$parent_res{sticky}){
			$sticky = 1;
		}
		
		if($$parent_res{permasage}){
			$permasage = 1;
		}
		
		if($$parent_res{locked}){
			$locked = 1;
		}
	}
	else
	{
		$lasthit=$time;
	}


	# kill the name if anonymous posting is being enforced
	if(FORCED_ANON){
		$name='';
		$trip='';
		if($email=~/sage/i) { $email='sage'; }
		else { $email=''; }
	}

	# clean up the inputs
	$email=clean_string(decode_string($email,CHARSET));
	$subject=clean_string(decode_string($subject,CHARSET));
	$uploadname=clean_string(decode_string($uploadname,CHARSET));

	# noko and nokosage
	my $noko = 0;
	my $nokosage = 0;
	
	if($email=~/noko/i){
		if($email=~/nokosage/i){
			$nokosage=1;
		}
		$noko=1;
		$email='';
	}

	# fix up the email/link
	$email="mailto:$email" if $email and $email!~/^$protocol_re:/;

	# format comment
	$comment=format_comment(clean_string(decode_string($comment,CHARSET))) unless $no_format;
	$comment.=$postfix;
	
	# last second code tag fixes
	$comment=~s/\<\/pre\>\<br \/\>$/\<\/pre\>/g;

	# insert default values for empty fields
	$parent=0 unless $parent;
	$name=make_anonymous($ip,$time) unless $name or $trip;
	$subject=S_ANOTITLE unless $subject;
	$comment=S_ANOTEXT unless $comment;

	# flood protection - must happen after inputs have been cleaned up
	flood_check($numip,$time,$comment,$file);

	# Manager and deletion stuff - duuuuuh?

	# generate date
	my $date=make_date($time,DATE_STYLE);

	# generate ID code if enabled
	$date.=' ID:'.make_id_code($ip,$time,$email) if(DISPLAY_ID);

	# copy file, do checksums, make thumbnail, etc
	my ($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height)=process_file($file,$uploadname,$time,$nsfw) if($file);
	
	if (($admin)&&($capcode==1)){
		if (@session[1] eq "admin"){
			$name = "<span class='adminName'>".$name."</span>";
			$trip = "<span class='adminTrip'>".$trip."<span class='adminCap'> ## Admin</span></span><img class='capIcon' title='This user is a ".SITE_NAME." Administrator' alt='This user is a ".SITE_NAME." Administrator' src='http://".DOMAIN."/img/adm_opct2.png' />";
		}
		elsif (@session[1] eq "mod"){
			$name = "<span class='modName'>".$name."</span>";
			$trip = "<span class='modTrip'>".$trip."<span class='modCap'> ## Mod</span></span><img class='capIcon' title='This user is a ".SITE_NAME." Moderator' alt='This user is a ".SITE_NAME." Moderator' src='http://".DOMAIN."/img/mod_opct.png' />";
		}
		
		if(@session[1] eq "admin") { $class=1; }
		elsif(@session[1] eq "mod") { $class=2; }
		elsif(@session[1] eq "dev") { $class=3; }
		elsif(@session[1] eq "vip") { $class=4; }
	}
	
	# set spoilered image
	my $tnmask;
	
	if($spoiler==1){
		$tnmask = 1;
	}
	
	# finally, write to the database
	my $sth=$dbh->prepare("INSERT INTO ".SQL_TABLE." VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($parent,$time,$lasthit,$numip,
	$date,$name,$trip,$email,$subject,$password,$comment,
	$filename,$size,$md5,$width,$height,$thumbnail,$tn_width,$tn_height,$sticky,$permasage,$locked,$uploadname,$tnmask,$class,@taargus[1]) or make_error(S_SQLFAIL);

	if($parent) # bumping
	{
		# check for sage, or too many replies
		unless($email=~/sage/i or sage_count($parent_res)>MAX_RES or $nokosage==1 or $permasage==1){
			$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET lasthit=$time WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
			$sth->execute($parent,$parent) or make_error(S_SQLFAIL);
		}
	}

	# remove old threads from the database
	trim_database();

	# update the cached HTML pages
	build_cache();

	# update the individual thread cache
	my $num;
	if($parent && !$noko) { build_thread_cache($parent);}
	else # must find out what our new thread number is
	{
		if($filename){
			$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE image=?;") or make_error(S_SQLFAIL);
			$sth->execute($filename) or make_error(S_SQLFAIL);
		}
		else
		{
			$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE timestamp=? AND comment=?;") or make_error(S_SQLFAIL);
			$sth->execute($time,$comment) or make_error(S_SQLFAIL);
		}
		$num=($sth->fetchrow_array())[0];

		if($num){
			build_thread_cache($parent || $num);
		}
	}

	# set the name, email and password cookies
	make_cookies(name=>$c_name,email=>$c_email,password=>$c_password,
	-charset=>CHARSET,-autopath=>COOKIE_PATH); # yum!

	# forward back to the main page
	if ($admin) #unless you're an admin, it'll go back to the manager post page
	{
		$parent=$num unless $parent;
		make_http_forward($noko ? get_script_name()."?admin=$admin&task=viewthread&num=".$parent."#".$num : get_script_name()."?admin=$admin&task=viewthreads",ALTERNATE_REDIRECT);
	}
	else
	{
		make_http_forward($noko ? getPrintedReplyLink($num,$parent) : "http://".DOMAIN."/".BOARD_DIR."/",ALTERNATE_REDIRECT);
	}
}

sub is_whitelisted($){
	my ($numip)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='whitelist' AND ? & ival2 = ival1 & ival2;") or make_error(S_SQLFAIL);
	$sth->execute($numip) or make_error(S_SQLFAIL);

	return 1 if(($sth->fetchrow_array())[0]);

	return 0;
}

# deprecated
sub is_trusted($){
	my ($trip)=@_;
	my $key = TRIPKEY; # constants r stoopid
	
	$trip =~ s/$key+//g; # removes the key so shit doesn't break.
	#$trip =~ s/\'\:3/dicks/g;
	
	my ($sth);
        $sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='trust' AND sval1 = ?;") or make_error(S_SQLFAIL);
        $sth->execute($trip) or make_error(S_SQLFAIL);

        return 1 if(($sth->fetchrow_array())[0]);

	return 0;
}

sub has_pass($){
	my($passcookie)=@_;
	my($row,$sth,$time,$invalid,$num);
	my($pin,$token,$verified)=split("##",$passcookie);
	
	return 0 unless $passcookie;
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_PASS_TABLE." WHERE pin=?;") or make_error(S_SQLFAIL);
	$sth->execute($pin) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		$time=time();
		$invalid=1 unless $token eq $$row{token};
		$num = $$row{num};
		
		# gives an error code if the pass isn't approved yet
		return 2,$num unless $$row{approved}==1;
		
		if(($verified==0)and($$row{approved}==1)){
			make_cookies(wakapass=>$pin."##".$token."##"."1",
			-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>$time+(60*60*24*30));
		}
		
		# checks if pass has expired
		if(($$row{lasthit}+2678000) < $time){
			my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET approved=0 WHERE pin=?;") or make_error(S_SQLFAIL);
			$sth->execute($pin) or make_error(S_SQLFAIL);
			$invalid=2;
		}
		
		# checks if a different IP is currently authorized
		if($$row{ip} ne get_ip(USE_CLOUDFLARE)){
			authorize_pass($token,$pin,1);
		}
		else{
			# update lasthit
			my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET lasthit=? WHERE pin=?;") or make_error(S_SQLFAIL);
			$sth->execute($time,$pin) or make_error(S_SQLFAIL);
		}
	}
	
	$invalid=1 unless $time;
	
	# removes pass cookie if its invalid or expired
	if($invalid!=0){
		make_cookies(wakapass=>$pin."##".$token."##"."0",
		-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>"Thu, 01-Jan-1970 00:00:01 GMT");
		make_error("Your pass has expired due to inactivity.") if $invalid==2;
		make_error("Invalid Pass.") if $invalid==1;
	}

	return 1,$num;
}

sub ban_check($$$$){
	my ($numip,$name,$subject,$comment)=@_;
	my ($sth,$row,$banned,@bans);
	my $time = time();

	# updated to allow for ban history
	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' AND (? & ival2 = ival1 & ival2) AND (active='1') ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute($numip) or make_error(S_SQLFAIL);

	while($row=get_decoded_hashref($sth)){
		if ($$row{active}==1){
			# check if ban is expired
			if(($time>=$$row{duration}) and ($$row{perm}!=1) and ($$row{warning}!=1)){
				# deactivate ban
				$sth=$dbh->prepare("UPDATE ".SQL_ADMIN_TABLE." SET active=? WHERE num=?;") or make_error("here?");
				$sth->execute(0,$$row{num}) or make_error("or here");
			}
			elsif($$row{warning}){
				# deactivate warning
				push @bans,$row;
				$banned++;
				$sth=$dbh->prepare("UPDATE ".SQL_ADMIN_TABLE." SET active=? WHERE num=?;") or make_error("here?");
				$sth->execute(0,$$row{num}) or make_error("or here");
			}
			else{
				push @bans,$row;
				$banned++;
			}
		}
	}

	# new ban page
	if ($banned){
		make_http_header();
		print encode_string(BAN_PAGE_TEMPLATE->(
			ip=>$numip,
			bans=>\@bans
		));
		
		stop_script();
	}
	else{
		$sth=$dbh->prepare("SELECT sval1 FROM ".SQL_ADMIN_TABLE." WHERE type='wordban';") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		my $row;
		while($row=$sth->fetchrow_arrayref()){
			my $regexp=quotemeta $$row[0];
			make_error(S_STRREF) if($comment=~/$regexp/);
			make_error(S_STRREF) if($name=~/$regexp/);
			make_error(S_STRREF) if($subject=~/$regexp/);
		}
	}
	
	return(0);
}

sub flood_check($$$$){
	my ($ip,$time,$comment,$file)=@_;
	my ($sth,$maxtime);

	if($file){
		# check for to quick file posts
		$maxtime=$time-(RENZOKU2);
		$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
		$sth->execute($ip) or make_error(S_SQLFAIL);
		make_error(S_RENZOKU2) if(($sth->fetchrow_array())[0]);
	}
	else
	{
		# check for too quick replies or text-only posts
		$maxtime=$time-(RENZOKU);
		$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
		$sth->execute($ip) or make_error(S_SQLFAIL);
		make_error(S_RENZOKU) if(($sth->fetchrow_array())[0]);

		# check for repeated messages
		$maxtime=$time-(RENZOKU3);
		$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND comment=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
		$sth->execute($ip,$comment) or make_error(S_SQLFAIL);
		make_error(S_RENZOKU3) if(($sth->fetchrow_array())[0]);
	}
}

sub proxy_check($){
	my ($ip)=@_;
	my ($sth);

	proxy_clean();

	# check if IP is from a known banned proxy
	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_PROXY_TABLE." WHERE type='black' AND ip = ?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

	make_error(S_BADHOSTPROXY) if(($sth->fetchrow_array())[0]);

	# check if IP is from a known non-proxy
	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_PROXY_TABLE." WHERE type='white' AND ip = ?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

        my $timestamp=time();
        my $date=make_date($timestamp,DATE_STYLE);

	if(($sth->fetchrow_array())[0]){	# known good IP, refresh entry
		$sth=$dbh->prepare("UPDATE ".SQL_PROXY_TABLE." SET timestamp=?, date=? WHERE ip=?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp,$date,$ip) or make_error(S_SQLFAIL);
	}
	else
	{	# unknown IP, check for proxy
		my $command = PROXY_COMMAND . " " . $ip;
		$sth=$dbh->prepare("INSERT INTO ".SQL_PROXY_TABLE." VALUES(null,?,?,?,?);") or make_error(S_SQLFAIL);

		if(`$command`){
			$sth->execute('black',$ip,$timestamp,$date) or make_error(S_SQLFAIL);
			make_error(S_PROXY);
		} 
		else
		{
			$sth->execute('white',$ip,$timestamp,$date) or make_error(S_SQLFAIL);
		}
	}
}

sub add_proxy_entry($$$$$){
	my ($admin,$type,$ip,$timestamp,$date)=@_;
	my ($sth);

	check_password($admin);
	logAction("addproxyentry",$ip,$admin);

	# Verifies IP range is sane. The price for a human-readable db...
	unless ($ip =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ && $1 <= 255 && $2 <= 255 && $3 <= 255 && $4 <= 255) {
		make_error(S_BADIP);
	}
	if ($type = 'white') { 
		$timestamp = $timestamp - PROXY_WHITE_AGE + time(); 
	}
	else
	{
		$timestamp = $timestamp - PROXY_BLACK_AGE + time(); 
	}	

	# This is to ensure user doesn't put multiple entries for the same IP
	$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE ip=?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

	# Add requested entry
	$sth=$dbh->prepare("INSERT INTO ".SQL_PROXY_TABLE." VALUES(null,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($type,$ip,$timestamp,$date) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=proxy",ALTERNATE_REDIRECT);
}

sub proxy_clean(){
	my ($sth,$timestamp);

	if(PROXY_BLACK_AGE == PROXY_WHITE_AGE){
		$timestamp = time() - PROXY_BLACK_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);
	} 
	else
	{
		$timestamp = time() - PROXY_BLACK_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE type='black' AND timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);

		$timestamp = time() - PROXY_WHITE_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE type='white' AND timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);
	}
}

sub remove_proxy_entry($$){
	my ($admin,$num)=@_;
	my ($sth);

	check_password($admin);
	logAction("removeproxyentry",$num,$admin);

	$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);

	make_http_forward(get_script_name()."?admin=$admin&task=proxy",ALTERNATE_REDIRECT);
}

sub format_comment($){
	my ($comment)=@_;

	# hide >>1 references from the quoting code
	#$comment=~s/&gt;&gt;([0-9\-]+)/&gtgt;$1/g;
	$comment=~s/&gt;&gt;(?:&(gt);(\/[A-Za-z0-9-]+\/))?([0-9\-]+)?/&gtgt$1;$2$3/g; # fixed for cross-board linking

	my $handler=sub # fix up >>1 references
	{
		my $line=shift;
		
		# Cross-board post citation
		$line=~s!&gtgtgt;/([A-Za-z0-9-]+)/([0-9]+)!
			my $res=get_cb_post($1,$2);
			if($res) { '<a href="'.get_cb_reply_link($1,$$res{num},$$res{parent}).'" onclick="highlight('.$1.')" class="postlink">&gt;&gt;&gt;/'.$1.'/'.$2.'</a>' }
			else { "<span class=\"quote\">&gt;&gt;&gt;/$1/$2</span>"; }
		!ge;
		
		# Cross-board link
		$line=~s!&gtgtgt;/([A-Za-z0-9-]+)/!
			if(table_exists($1."_comments")) { '<a href="http://'.DOMAIN.'/'.$1.'/" class="postlink">&gt;&gt;&gt;/'.$1.'/</a>' }
			else { "<span class=\"quote\">&gt;&gt;&gt;/$1/</span>"; }
		!ge;

		# Normal post citation
		$line=~s!&gtgt;([0-9]+)!
			my $res=get_post($1);
			if($res) { '<a href="'.getPrintedReplyLink($$res{num},$$res{parent}).'" onclick="highlight('.$1.')" class="postlink">&gt;&gt;'.$1.'</a>' }
			else { "<span class=\"quote\">&gt;&gt;$1</span>"; }
		!ge;
		
		return $line;
	};

	if(ENABLE_WAKABAMARK) { $comment=do_wakabamark($comment,$handler) }
	else { $comment="<p>".simple_format($comment,$handler)."</p>" }

	# restore >>1 references hidden in code blocks
	$comment=~s/&gtgt(gt)?;/'&gt;&gt;'.($1?'&gt;':'')/ge;
	
	my $blocktag=0;
	
	if(ENABLE_WAKABAMARK){
		# new spoiler code (can't put it in 'do_wakabamark' because of 'do_spans' messing with the order of tags
		if($comment=~/.*\[spoiler\].*/){
			$comment=~s/\[spoiler\]*/\<span class\=\'spoiler\'\>/g;
			$comment=~s/\[\/spoiler\]*/\<\/span\>/g;
			$comment=~s/\<span class\=\'spoiler\'\>\<br \/\>/\<span class\=\'spoiler\'\>/g;
			$blocktag=1;
		}
		
		# code tags
		if($comment=~/.*\[code\].*/){
			$comment=~s/\[code\]*/\<pre class\=\'prettyprint\'\>/g;
			$comment=~s/\[\/code\]*/\<\/pre\>/g;
			$comment=~s/\<pre class\=\'prettyprint\'\>\<br \/\>/\<pre class\=\'prettyprint\'\>/g;
			$blocktag=1;
		}
		
		# s-jis
		if($comment=~/.*\[sjis\].*/){
			$comment=~s/\[sjis\]*/\<span class\=\'aa\'\>/g;
			$comment=~s/\[\/sjis\]*/\<\/span\>/g;
			$comment=~s/\<span class\=\'aa\'\>\<br \/\>/\<span class\=\'aa\'\>/g;
			$blocktag=1;
		}
		
		# fix formatting for above functions
		if($blocktag==1){
			$comment=~s/\<br \/\>\<\/span\>/\<\/span\>/g;
		}
	}

	return $comment;
}

sub simple_format($@){
	my ($comment,$handler)=@_;
	return join "<br />",map
	{
		my $line=$_;

		# make URLs into links
		$line=~s{(https?://[^\s<>"]*?)((?:\s|<|>|"|\.|\)|\]|!|\?|,|&#44;|&quot;)*(?:[\s<>"]|$))}{\<a href="$1"\>$1\</a\>$2}sgi;

		# colour quoted sections if working in old-style mode.
		$line=~s!^(&gt;.*)$!\<span class="unkfunc"\>$1\</span\>!g unless(ENABLE_WAKABAMARK);

		$line=$handler->($line) if($handler);

		$line;
	} split /\n/,$comment;
}

sub encode_string($){
	my ($str)=@_;

	return $str unless($has_encode);
	return encode(CHARSET,$str,0x0400);
}

sub make_anonymous($$){
	my ($ip,$time)=@_;

	return S_ANONAME unless(SILLY_ANONYMOUS);

	my $string=$ip;
	$string.=",".int($time/86400) if(SILLY_ANONYMOUS=~/day/i);
	$string.=",".$ENV{SCRIPT_NAME} if(SILLY_ANONYMOUS=~/board/i);

	srand unpack "N",hide_data($string,4,"silly",SECRET);

	return cfg_expand("%G% %W%",
		W => ["%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%","%O%%E%","%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%","%O%%E%","%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%"],
		B => ["B","B","C","D","D","F","F","G","G","H","H","M","N","P","P","S","S","W","Ch","Br","Cr","Dr","Bl","Cl","S"],
		I => ["b","d","f","h","k","l","m","n","p","s","t","w","ch","st"],
		V => ["a","e","i","o","u"],
		M => ["ving","zzle","ndle","ddle","ller","rring","tting","nning","ssle","mmer","bber","bble","nger","nner","sh","ffing","nder","pper","mmle","lly","bling","nkin","dge","ckle","ggle","mble","ckle","rry"],
		F => ["t","ck","tch","d","g","n","t","t","ck","tch","dge","re","rk","dge","re","ne","dging"],
		O => ["Small","Snod","Bard","Billing","Black","Shake","Tilling","Good","Worthing","Blythe","Green","Duck","Pitt","Grand","Brook","Blather","Bun","Buzz","Clay","Fan","Dart","Grim","Honey","Light","Murd","Nickle","Pick","Pock","Trot","Toot","Turvey"],
		E => ["shaw","man","stone","son","ham","gold","banks","foot","worth","way","hall","dock","ford","well","bury","stock","field","lock","dale","water","hood","ridge","ville","spear","forth","will"],
		G => ["Albert","Alice","Angus","Archie","Augustus","Barnaby","Basil","Beatrice","Betsy","Caroline","Cedric","Charles","Charlotte","Clara","Cornelius","Cyril","David","Doris","Ebenezer","Edward","Edwin","Eliza","Emma","Ernest","Esther","Eugene","Fanny","Frederick","George","Graham","Hamilton","Hannah","Hedda","Henry","Hugh","Ian","Isabella","Jack","James","Jarvis","Jenny","John","Lillian","Lydia","Martha","Martin","Matilda","Molly","Nathaniel","Nell","Nicholas","Nigel","Oliver","Phineas","Phoebe","Phyllis","Polly","Priscilla","Rebecca","Reuben","Samuel","Sidney","Simon","Sophie","Thomas","Walter","Wesley","William"],
	);
}

sub make_id_code($$$){
	my ($ip,$time,$link)=@_;

	return EMAIL_ID if($link and DISPLAY_ID=~/link/i);
	return EMAIL_ID if($link=~/sage/i and DISPLAY_ID=~/sage/i);

	return resolve_host(get_ip(USE_CLOUDFLARE)) if(DISPLAY_ID=~/host/i);
	return get_ip(USE_CLOUDFLARE) if(DISPLAY_ID=~/ip/i);

	my $string="";
	$string.=",".int($time/86400) if(DISPLAY_ID=~/day/i);
	$string.=",".$ENV{SCRIPT_NAME} if(DISPLAY_ID=~/board/i);

	return mask_ip(get_ip(USE_CLOUDFLARE),make_key("mask",SECRET,32).$string) if(DISPLAY_ID=~/mask/i);

	return hide_data($ip.$string,6,"id",SECRET,1);
}

sub get_post($){
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return $sth->fetchrow_hashref();
}

sub get_cb_post($$){
	my ($board,$thread)=@_;
	my ($sth);
	
	return if $board=~/[^A-Za-z0-9-]/;
	
	$board=$board."_comments";
	
	$sth=$dbh->prepare("SELECT num, parent FROM $board WHERE num=?;") or return;
	$sth->execute($thread) or return;

	return $sth->fetchrow_hashref();
}

sub get_parent_post($){
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? AND parent=0;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return $sth->fetchrow_hashref();
}

sub sage_count($){
	my ($parent)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE parent=? AND NOT ( timestamp<? AND ip=? );") or make_error(S_SQLFAIL);
	$sth->execute($$parent{num},$$parent{timestamp}+(NOSAGE_WINDOW),$$parent{ip}) or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub get_file_size($){
	my ($file)=@_;
	my (@filestats,$size);

	@filestats=stat $file;
	$size=$filestats[7];

	make_error(S_TOOBIG) if($size>MAX_KB*1024);
	make_error(S_TOOBIGORNONE) if($size==0); # check for small files, too?

	return($size);
}

sub process_file($$$$){
	my ($file,$uploadname,$time,$nsfw)=@_;
	my %filetypes=FILETYPES;

	# make sure to read file in binary mode on platforms that care about such things
	binmode $file;

	# analyze file and check that it's in a supported format
	my ($ext,$width,$height)=analyze_image($file,$uploadname);

	my $known=($width or $filetypes{$ext});

	make_error(S_BADFORMAT) unless(ALLOW_UNKNOWN or $known);
	make_error(S_BADFORMAT) if(grep { $_ eq $ext } FORBIDDEN_EXTENSIONS);
	make_error(S_TOOBIG) if(MAX_IMAGE_WIDTH and $width>MAX_IMAGE_WIDTH);
	make_error(S_TOOBIG) if(MAX_IMAGE_HEIGHT and $height>MAX_IMAGE_HEIGHT);
	make_error(S_TOOBIG) if(MAX_IMAGE_PIXELS and $width*$height>MAX_IMAGE_PIXELS);

	# generate random filename - fudges the microseconds
	my $filebase=$time.sprintf("%03d",int(rand(1000)));
	my $filename=IMG_DIR.$filebase.'.'.$ext;
	my $thumbnail=THUMB_DIR.$filebase."s.jpg";
	$filename.=MUNGE_UNKNOWN unless($known);

	# do copying and MD5 checksum
	my ($md5,$md5ctx,$buffer);

	# prepare MD5 checksum if the Digest::MD5 module is available
	eval 'use Digest::MD5 qw(md5_hex)';
	$md5ctx=Digest::MD5->new unless($@);

	# copy file
	open (OUTFILE,">>$filename") or make_error(S_NOTWRITE);
	binmode OUTFILE;
	while (read($file,$buffer,1024)) # should the buffer be larger?
	{
		print OUTFILE $buffer;
		$md5ctx->add($buffer) if($md5ctx);
	}
	close $file;
	close OUTFILE;

	if($md5ctx) # if we have Digest::MD5, get the checksum
	{
		$md5=$md5ctx->hexdigest();
	}
	else # otherwise, try using the md5sum command
	{
		my $md5sum=`md5sum $filename`; # filename is always the timestamp name, and thus safe
		($md5)=$md5sum=~/^([0-9a-f]+)/ unless($?);
	}

	if($md5) # if we managed to generate an md5 checksum, check for duplicate files
	{
		my $sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE md5=?;") or make_error(S_SQLFAIL);
		$sth->execute($md5) or make_error(S_SQLFAIL);

		if(my $match=$sth->fetchrow_hashref()){
			unlink $filename; # make sure to remove the file
			make_error(sprintf(S_DUPE,get_reply_link($$match{num},$$match{parent})));
		}
	}

	# do thumbnail
	my ($tn_width,$tn_height,$tn_ext);

	if(!$width) # unsupported file
	{
		if($filetypes{$ext}) # externally defined filetype
		{
			open THUMBNAIL,$filetypes{$ext};
			binmode THUMBNAIL;
			($tn_ext,$tn_width,$tn_height)=analyze_image(\*THUMBNAIL,$filetypes{$ext});
			close THUMBNAIL;

			# was that icon file really there?
			if(!$tn_width) { $thumbnail=undef }
			else { $thumbnail=$filetypes{$ext} }
		}
		else
		{
			$thumbnail=undef;
		}
	}
	elsif($width>MAX_W or $height>MAX_H or THUMBNAIL_SMALL){
		if($width<=MAX_W and $height<=MAX_H){
			$tn_width=$width;
			$tn_height=$height;
		}
		else
		{
			$tn_width=MAX_W;
			$tn_height=int(($height*(MAX_W))/$width);

			if($tn_height>MAX_H){
				$tn_width=int(($width*(MAX_H))/$height);
				$tn_height=MAX_H;
			}
		}

		if(STUPID_THUMBNAILING) { $thumbnail=$filename }
		else
		{
			$thumbnail=undef unless(make_thumbnail($filename,$thumbnail,$nsfw,$tn_width,$tn_height,THUMBNAIL_QUALITY,CONVERT_COMMAND));
		}
	}
	else
	{
		$tn_width=$width;
		$tn_height=$height;
		$thumbnail=$filename;
	}

	if($filetypes{$ext}) # externally defined filetype - restore the name
	{
		my $newfilename=$uploadname;
		$newfilename=~s!^.*[\\/]!!; # cut off any directory in filename
		$newfilename=IMG_DIR.$newfilename;

		unless(-e $newfilename) # verify no name clash
		{
			rename $filename,$newfilename;
			$thumbnail=$newfilename if($thumbnail eq $filename);
			$filename=$newfilename;
		}
		else
		{
			unlink $filename;
			make_error(S_DUPENAME);
		}
	}

        if(ENABLE_LOAD)
        {       # only called if files to be distributed across web     
                $ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;
		my $root=$1;
                system(LOAD_SENDER_SCRIPT." $filename $root $md5 &");
        }


	return ($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height);
}

#
# Deleting
#

sub delete_stuff($$$$@){
	my ($password,$fileonly,$archive,$admin,@posts)=@_;
	my ($post,@session);

	@session = check_password($admin) if($admin);
	
	make_error(S_BADDELPASS) unless($password or $admin); # refuse empty password immediately

	# no password means delete always
	$password="" if($admin);
	$archive = 0 unless($admin); # security fix

	foreach $post (@posts){
		delete_post($post,$password,$fileonly,$archive,@session);
	}

	# update the cached HTML pages
	build_cache();

	if($admin){ make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT); }
	else
	{ make_http_forward(HTML_SELF,ALTERNATE_REDIRECT); }
}

sub delete_post($$$$;$){
	my ($post,$password,$fileonly,$archiving,@session)=@_;
	my ($sth,$row,$res,$reply);
	my $thumb=THUMB_DIR;
	my $archive=ARCHIVE_DIR;
	my $src=IMG_DIR;
	my $hasimage = 0;

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($post) or make_error(S_SQLFAIL);

	if($row=$sth->fetchrow_hashref()){
		make_error(S_BADDELPASS) if($password and $$row{password} ne $password);

		unless($fileonly){
			# log posts deleted by staff
			if($password eq ""){
				logAction("deletepost",$post,@session);
				my $time = time();
				$sth=$dbh->prepare("INSERT INTO ".SQL_DELETED_TABLE." VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);") or make_error($dbh->errstr);
				$sth->execute($$row{num},$$row{parent},$$row{timestamp},$$row{lasthit},$$row{ip},$$row{name},$$row{trip},$$row{email},$$row{subject},$$row{comment},$$row{image},$$row{size},$$row{md5},$$row{width},$$row{height},$$row{filename},@session[0],$time,BOARD_DIR) or make_error($dbh->errstr);
			}
		
			# remove files from comment and possible replies
			$sth=$dbh->prepare("SELECT image,thumbnail FROM ".SQL_TABLE." WHERE num=? OR parent=?") or make_error(S_SQLFAIL);
			$sth->execute($post,$post) or make_error(S_SQLFAIL);

			while($res=$sth->fetchrow_hashref()){
				system(LOAD_SENDER_SCRIPT." $$res{image} &") if(ENABLE_LOAD);
	
				if($archiving){
					# archive images
					rename $$res{image}, ARCHIVE_DIR.$$res{image};
					rename $$res{thumbnail}, ARCHIVE_DIR.$$res{thumbnail} if($$res{thumbnail}=~/^$thumb/);
				}
				else
				{
					# delete images if they exist
					unlink $$res{image};
					unlink $$res{thumbnail} if($$res{thumbnail}=~/^$thumb/);
				}
			}

			# remove post and possible replies
			$sth=$dbh->prepare("DELETE FROM ".SQL_TABLE." WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
			$sth->execute($post,$post) or make_error(S_SQLFAIL);
			
			# remove reports associated with the post
			$sth=$dbh->prepare("DELETE FROM ".SQL_REPORT_TABLE." WHERE postnum=? AND board=?;") or make_error(S_SQLFAIL);
			$sth->execute($post,BOARD_DIR) or make_error(S_SQLFAIL);
		}
		else # remove just the image and update the database
		{
			logAction("deletefile",$post,@session);
			if($$row{image}){
				$hasimage = 1;
				system(LOAD_SENDER_SCRIPT." $$row{image} &") if(ENABLE_LOAD);

				# remove images
				unlink $$row{image};
				unlink $$row{thumbnail} if($$row{thumbnail}=~/^$thumb/);

				$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET size=0,md5=null,thumbnail=null WHERE num=?;") or make_error(S_SQLFAIL);
				$sth->execute($post) or make_error(S_SQLFAIL);
			}
		}

		# fix up the thread cache
		if(!$$row{parent}){
			unless($fileonly) # removing an entire thread
			{
				if($archiving){
					my $captcha = CAPTCHA_SCRIPT;
					my $line;

					open RESIN, '<', RES_DIR.$$row{num}.PAGE_EXT;
					open RESOUT, '>', ARCHIVE_DIR.RES_DIR.$$row{num}.PAGE_EXT;
					while($line = <RESIN>){
						$line =~ s/img src="(.*?)$thumb/img src="$1$archive$thumb/g;
						if(ENABLE_LOAD){
							my $redir = REDIR_DIR;
							$line =~ s/href="(.*?)$redir(.*?).html/href="$1$archive$src$2/g;
						}
						else
						{
							$line =~ s/href="(.*?)$src/href="$1$archive$src/g;
						}
						$line =~ s/src="[^"]*$captcha[^"]*"/src=""/g if(ENABLE_CAPTCHA);
						print RESOUT $line;	
					}
					close RESIN;
					close RESOUT;
				}
				unlink RES_DIR.$$row{num}.PAGE_EXT;
			}
			else # removing parent image
			{
				if(($fileonly)&&($hasimage==0)){
					make_error("Put that in your milk!");
				}
				else{
					build_thread_cache($$row{num});
				}
			}
		}
		else # removing a reply, or a reply's image
		{
			if(($fileonly)&&($hasimage==0)){
				make_error("Put that in your milk!");
			}
			else{
				build_thread_cache($$row{parent});
			}
		}
	}
	#make_error($post);
}



#
# Admin interface
#

sub make_admin_login(){
	make_http_header();
	print encode_string(ADMIN_LOGIN_TEMPLATE->());
}

sub make_admin_post_panel($){
	my ($admin)=@_;
	my ($sth,$row,@posts,$size,$rowtype);

	my @session = check_password($admin);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." ORDER BY lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	$size=0;
	$rowtype=1;
	while($row=get_decoded_hashref($sth)){
		if(!$$row{parent}) { $rowtype=1; }
		else { $rowtype^=3; }
		$$row{rowtype}=$rowtype;

		$size+=$$row{size};

		push @posts,$row;
	}

	make_http_header();
	print encode_string(POST_PANEL_TEMPLATE->(admin=>$admin,posts=>\@posts,session=>\@session,size=>$size));
}

sub make_admin_ban_panel($){
	my ($admin)=@_;
	my ($sth,$row,@bans,$prevtype);

	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq "janitor";

	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' OR type='wordban' OR type='whitelist' OR type='trust' ORDER BY type ASC,num ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		$$row{divider}=1 if($prevtype ne $$row{type});
		$prevtype=$$row{type};
		$$row{rowtype}=@bans%2+1;
		push @bans,$row;
	}

	make_http_header();
	print encode_string(BAN_PANEL_TEMPLATE->(admin=>$admin,session=>\@session,bans=>\@bans));
}

sub make_admin_proxy_panel($){
	my ($admin)=@_;
	my ($sth,$row,@scanned,$prevtype);

	my @session = check_password($admin);
	make_error(S_CLASS) unless @session[1] eq "admin";

	proxy_clean();

	$sth=$dbh->prepare("SELECT * FROM ".SQL_PROXY_TABLE." ORDER BY timestamp ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	while($row=get_decoded_hashref($sth)){
		$$row{divider}=1 if($prevtype ne $$row{type});
		$prevtype=$$row{type};
		$$row{rowtype}=@scanned%2+1;
		push @scanned,$row;
	}

	make_http_header();
	print encode_string(PROXY_PANEL_TEMPLATE->(admin=>$admin,session=>\@session,scanned=>\@scanned));
}

sub make_admin_spam_panel($){
	my ($admin)=@_;
	my @spam_files=SPAM_FILES;
	my @spam=read_array($spam_files[0]);

	my @session = check_password($admin);
	make_error(S_CLASS) unless @session[1] eq "admin";

	make_http_header();
	print encode_string(SPAM_PANEL_TEMPLATE->(admin=>$admin,session=>\@session,
	spamlines=>scalar @spam,
	spam=>join "\n",map { clean_string($_,1) } @spam));
}

sub make_sql_dump($){
	my ($admin)=@_;
	my ($sth,$row,@database);

	my @session = check_password($admin);
	make_error(S_CLASS) unless @session[1] eq "admin";

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE.";") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	while($row=get_decoded_arrayref($sth)){
		push @database,"INSERT INTO ".SQL_TABLE." VALUES('".
		(join "','",map { s/\\/&#92;/g; $_ } @{$row}). # escape ' and \, and join up all values with commas and apostrophes
		"');";
	}

	make_http_header();
	print encode_string(SQL_DUMP_TEMPLATE->(admin=>$admin,session=>\@session,
	database=>join "<br />",map { clean_string($_,1) } @database));
}

sub make_sql_interface($$$){
	my ($admin,$nuke,$sql)=@_;
	my ($sth,$row,@results);

	my @session = check_password($admin);
	
	if (@session[1] eq 'admin'){
		if($sql){
			make_error(S_WRONGPASS) if($nuke ne NUKE_PASS); # check nuke password

			my @statements=grep { /^\S/ } split /\r?\n/,decode_string($sql,CHARSET,1);

			foreach my $statement (@statements){
				push @results,">>> $statement";
				if($sth=$dbh->prepare($statement)){
					if($sth->execute()){
						while($row=get_decoded_arrayref($sth)) { push @results,join ' | ',@{$row} }
					}
					else { push @results,"!!! ".$sth->errstr() }
				}
				else { push @results,"!!! ".$sth->errstr() }
			}
		}

		make_http_header();
		print encode_string(SQL_INTERFACE_TEMPLATE->(admin=>$admin,nuke=>$nuke,session=>\@session,
		results=>join "<br />",map { clean_string($_,1) } @results));
	}
	else{
		make_error(S_CLASS);
	}
}

sub make_admin_post($){
	my ($admin)=@_;

	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq "janitor";
	
	make_http_header();
	print encode_string(ADMIN_POST_TEMPLATE->(admin=>$admin,session=>\@session));
}

sub do_login($$$$$){
	my ($user,$password,$nexttask,$savelogin,$admincookie)=@_;
	my ($crypt,$dengus,$time,$lastip,$sth,$loglogin);

	$time=time();
	$lastip = get_ip(USE_CLOUDFLARE);
	
	if($password and $user){
		$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
		$sth->execute($user) or make_error($sth->errstr);
		$dengus=get_decoded_hashref($sth);
		
		if($$dengus{pass} eq $password){
			$crypt=crypt_password($user.$password);
			$loglogin = 1;
		}
	}
	elsif($admincookie){
		$user=substr($admincookie,0,index($admincookie,":"));
		
		$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
		$sth->execute($user) or make_error($sth->errstr);
		$dengus=get_decoded_hashref($sth);
	
		if ($admincookie eq $user.":".crypt_password($$dengus{user}.$$dengus{pass})){
			$crypt = crypt_password($$dengus{user}.$$dengus{pass}); # BECAUSE FUCK YOU THAT'S WHY
			$nexttask="mpanel"; # BECAUSE FUCK YOU THAT'S WHY AGAIN
		}
	}
	
	if($crypt){
		if($savelogin and $nexttask ne "nuke"){
			make_cookies(wakaadmin=>$user.":".$crypt,
			-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>time+365*24*3600);
		}
		
		$sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET lastdate=?,lastip=? WHERE user=?;") or make_error(S_SQLFAIL);
		$sth->execute($time,$lastip,$user) or make_error($sth->errstr);

		if($loglogin) { logAction("login","",$crypt) }
		make_http_forward(get_script_name()."?task=$nexttask&admin=$crypt",ALTERNATE_REDIRECT);
	}
	else{
		logAction("attemptlogin","");
		make_admin_login();
	}
}

sub do_logout($){
	my ($type)=@_;
	
	if($type eq "admin"){
		make_cookies(wakaadmin=>"",-expires=>1);
		make_http_forward(get_script_name()."?task=admin",ALTERNATE_REDIRECT);
	}
	elsif($type eq "pass"){
		make_cookies(wakapass=>"",-expires=>1);
		make_http_forward("http://".DOMAIN,ALTERNATE_REDIRECT);
	}
	else{
		make_http_forward("http://".DOMAIN,ALTERNATE_REDIRECT);
	}
}

sub do_rebuild_cache($){
	my ($admin)=@_;
	my @session = check_password($admin);
	
	logAction("rebuildcache","",@session);
	
	if (@session[1] eq "janitor"){
		make_error(S_CLASS);
	}

	unlink glob RES_DIR.'*';

	repair_database();
	build_thread_cache_all();
	build_cache();

	#make_http_forward_new(HTML_SELF,ALTERNATE_REDIRECT,"site"); # this was supposed to do the redirect in another frame, but it isn't working
	make_http_forward("http://".DOMAIN."/".BOARD_DIR."/wakaba.pl?task=mpanel&admin=$admin",ALTERNATE_REDIRECT);
}

sub add_admin_entry($$$$$$){
	my ($admin,$type,$comment,$ival1,$ival2,$sval1,$ref)=@_;
	my ($sth,$time);
	$time=time();

	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq "janitor";
	logAction($type,$ival1."<>".$ival2."<>".$sval1,@session);
	
	$comment=clean_string(decode_string($comment,CHARSET));
	make_error("gotta fix this");

	$sth=$dbh->prepare("INSERT INTO ".SQL_ADMIN_TABLE." VALUES(null,?,?,?,?,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($type,$comment,$ival1,$ival2,$sval1,@session[0],$time,1) or make_error(S_SQLFAIL);
	
	#if($ref){
	#	make_http_forward(get_script_name()."?admin=$admin&task=viewthread&num=$ref",ALTERNATE_REDIRECT);
	#}
	
	if($type='ipban'){
		# clear all ban requests for the banned ip
		$sth=$dbh->prepare("DELETE FROM ".SQL_BANREQUEST_TABLE." WHERE ip=? AND board=?;") or make_error(S_SQLFAIL);
		$sth->execute($ival1,BOARD_DIR) or make_error(S_SQLFAIL);
		
		# redirects to the ip page
		make_http_forward(get_script_name()."?admin=$admin&task=ippage&ip=".$ival1,ALTERNATE_REDIRECT);
	}
	
	make_http_forward(get_script_name()."?admin=$admin&task=bans",ALTERNATE_REDIRECT);
}

sub remove_admin_entry($$){
	my ($admin,$num)=@_;
	my ($sth);

	my @session = check_password($admin);
	logAction("removeadminentry",$num,@session);
	
	if (@session[1] eq "janitor"){
		make_error(S_CLASS);
	}

	$sth=$dbh->prepare("DELETE FROM ".SQL_ADMIN_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);

	make_http_forward(get_script_name()."?admin=$admin&task=bans",ALTERNATE_REDIRECT);
}

sub delete_all($$$){
	my ($admin,$ip,$mask)=@_;
	my ($sth,$row,@posts);

	logAction("deleteall",$ip,$admin);

	$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE ip & ? = ? & ?;") or make_error(S_SQLFAIL);
	$sth->execute($mask,$ip,$mask) or make_error(S_SQLFAIL);
	while($row=$sth->fetchrow_hashref()) { push(@posts,$$row{num}); }

	delete_stuff('',0,0,$admin,@posts);
}

sub update_spam_file($$){
	my ($admin,$spam)=@_;

	my @session = check_password($admin);
	logAction("updatespam","",@session);
	
	if (@session[1] ne "admin"){
		make_error(S_CLASS);
	}

	my @spam=split /\r?\n/,$spam;
	my @spam_files=SPAM_FILES;
	write_array($spam_files[0],@spam);

	make_http_forward(get_script_name()."?admin=$admin&task=spam",ALTERNATE_REDIRECT);
}

sub do_nuke_database($$){
	my ($nukepass,$admin)=@_;

	# check_password does not work anymore for this because of multi-user support
	checkNukePassword($nukepass,NUKE_PASS);
	logAction("nuke","",$admin);

	init_database();
	#init_admin_database();
	#init_proxy_database();

	# remove images, thumbnails and threads
	unlink glob IMG_DIR.'*';
	unlink glob THUMB_DIR.'*';
	unlink glob RES_DIR.'*';

	build_cache();
	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
}

sub clear_notifications($$){
	my ($user,$type)=@_;
	my ($time,$row,$sth);
	my %types = ("msgs","newmsgs","reports","newreports","banrequests","newbanreqs");
	
	$sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET ".$types{$type}."=0 WHERE user=?;") or make_error($dbh->errstr);
	$sth->execute($user) or make_error($dbh->errstr);
}

sub check_password($){
	my ($admin)=@_; # $password is useless now
	my ($dengus,$sth,@session);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE.";") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	
	while($dengus=get_decoded_hashref($sth)){
		if($admin eq crypt_password($$dengus{user}.$$dengus{pass})){
			@session[0] = $$dengus{user};
			@session[1] = $$dengus{class};
			@session[2] = $$dengus{newmsgs};
			@session[3] = $$dengus{newreports};
			@session[4] = $$dengus{newbanreqs};
			@session[5] = $$dengus{lastdate};
			
			return @session;
		}
	}

	make_error(S_WRONGPASS);
}

sub checkNukePassword($$){
	my ($admin,$password)=@_;

	return if($admin eq NUKE_PASS);
	return if($admin eq crypt_password($password));

	logAction("failnuke","");
	make_error(S_WRONGPASS);
}

sub crypt_password($){
	my $crypt=hide_data((shift).get_ip(USE_CLOUDFLARE),9,"admin",SECRET,1);
	$crypt=~tr/+/./; # for web shit
	return $crypt;
}



#
# Page creation utils
#

sub make_http_header(){
	# >2012 >xhtml
	#print "Content-Type: ".get_xhtml_content_type(CHARSET,0)."\n";
	print "Content-Type: text/html; charset=utf-8 \n";
	print "\n";
}

sub make_json_header(){
	print "Content-Type: application/json; charset=utf-8 \n";
	print "\n";
}

sub make_error($){
	my ($error)=@_;

	make_http_header();
	print encode_string(ERROR_TEMPLATE->(error=>$error));

	if(!$use_fastcgi and $dbh){
		$dbh->{Warn}=0;
		$dbh->disconnect();
	}

	# could print even more data, really.
	if(ERRORLOG){
		$error=~s/"/\\"/g;
		open ERRORFILE,'>>'.ERRORLOG;
		printf ERRORFILE '%s - %s - "%s" "%s"'."\n", get_ip(USE_CLOUDFLARE), scalar localtime, $ENV{HTTP_USER_AGENT}, $error;
		close ERRORFILE;
	}

	# delete temp files
	stop_script();
}

sub stop_script(){
	if($use_fastcgi) { next FASTCGI; }
	else { exit; }
}

sub get_script_name(){
	return $ENV{SCRIPT_NAME};
}

sub get_secure_script_name(){
	return 'https://'.$ENV{SERVER_NAME}.$ENV{SCRIPT_NAME} if(USE_SECURE_ADMIN);
	return $ENV{SCRIPT_NAME};
}

sub expand_image_filename($){
	my $filename=shift;

	return expand_filename(clean_path($filename)) unless ENABLE_LOAD;

	my ($self_path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;
	my $src=IMG_DIR;
	$filename=~/$src(.*)/;
	return $self_path.REDIR_DIR.clean_path($1).'.html';
}

sub get_reply_link($$){
	my ($reply,$parent)=@_;

	return expand_filename(RES_DIR.$parent.PAGE_EXT).'#'.$reply if($parent);
	return expand_filename(RES_DIR.$reply.PAGE_EXT);
}

# for rewritten links
sub getPrintedReplyLink($$){
	my ($reply,$parent)=@_;

	return expand_filename(RES_DIR.$parent).'#'.$reply if($parent);
	return expand_filename(RES_DIR.$reply);
}

sub get_cb_reply_link($$$){
	my ($board,$reply,$parent)=@_;

	return get_reply_link($reply,$parent) if($board eq SQL_TABLE);
	return expand_filename("../$board/".RES_DIR.$parent).'#'.$reply if($parent);
	return expand_filename("../$board/".RES_DIR.$reply);
}

sub get_page_count(;$){
	my $total=(shift or count_threads());
	return int(($total+IMAGES_PER_PAGE-1)/IMAGES_PER_PAGE);
}

sub get_filetypes(){
	my %filetypes=FILETYPES;
	$filetypes{gif}=$filetypes{jpg}=$filetypes{png}=1;
	return join ", ",map { uc } sort keys %filetypes;
}

sub dot_to_dec($){
	return unpack('N',pack('C4',split(/\./, $_[0]))); # wow, magic.
}

sub dec_to_dot($){
	return join('.',unpack('C4',pack('N',$_[0])));
}

sub parse_range($$){
	my ($ip,$mask)=@_;

	$ip=dot_to_dec($ip) if($ip=~/^\d+\.\d+\.\d+\.\d+$/);

	if($mask=~/^\d+\.\d+\.\d+\.\d+$/) { $mask=dot_to_dec($mask); }
	elsif($mask=~/(\d+)/) { $mask=(~((1<<$1)-1)); }
	else { $mask=0xffffffff; }

	return ($ip,$mask);
}

#
# Database utils
#

sub init_database(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_TABLE.";") if(table_exists(SQL_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Post number, auto-increments
	"parent INTEGER,".			# Parent post for replies in threads. For original posts, must be set to 0 (and not null)
	"timestamp INTEGER,".		# Timestamp in seconds for when the post was created
	"lasthit INTEGER,".			# Last activity in thread. Must be set to the same value for BOTH the original post and all replies!
	"ip TEXT,".					# IP number of poster, in integer form!

	"date TEXT,".				# The date, as a string
	"name TEXT,".				# Name of the poster
	"trip TEXT,".				# Tripcode (encoded)
	"email TEXT,".				# Email address
	"subject TEXT,".			# Subject
	"password TEXT,".			# Deletion password (in plaintext) 
	"comment TEXT,".			# Comment text, HTML encoded.

	"image TEXT,".				# Image filename with path and extension (IE, src/1081231233721.jpg)
	"size INTEGER,".			# File size in bytes
	"md5 TEXT,".				# md5 sum in hex
	"width INTEGER,".			# Width of image in pixels
	"height INTEGER,".			# Height of image in pixels
	"thumbnail TEXT,".			# Thumbnail filename with path and extension
	"tn_width TEXT,".			# Thumbnail width in pixels
	"tn_height TEXT,".			# Thumbnail height in pixels
	
	"sticky TINYINT,".			# A sticky
	"permasage TINYINT,".		# Permasage
	"locked TINYINT,".			# Locked threads
	"filename TEXT,".			# The original filename
	"tnmask TINYINT,".			# Whether or not the thumbnail is masked with a spoiler or something to that effect
	"staffpost TINYINT,".		# Whether or not the post was made by a staff member. 1=admin, 2=mod, 3=dev, and 4=vip
	"passnum INTEGER".			# If a post was made with a pass, its number is stored here
	
	
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub init_admin_database(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_ADMIN_TABLE.";") if(table_exists(SQL_ADMIN_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_ADMIN_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Entry number, auto-increments
	"type TEXT,".				# Type of entry (ipban, wordban, etc)
	"comment TEXT,".			# Comment for the entry
	"private TEXT,".			# Private ban info
	"ival1 TEXT,".				# Integer value 1 (usually IP)
	"ival2 TEXT,".				# Integer value 2 (usually netmask)
	"sval1 TEXT,".				# String value 1
	"fromuser TEXT,".			# User that made the ban
	"publicfromuser TEXT,".		# Username displayed to the banned user (useful for IRC nicks and that sorta thing)
	"duration INTEGER,".		# Ban duration
	"perm TINYINT,".			# Ban duration
	"scope TEXT,".				# Ban scope
	"postnum INTEGER,".			# Post number citation
	"board TEXT,".				# Board the above post was on
	"warning TINYINT,".			# If the ban is a warning or not
	"timestamp INTEGER,".		# When the ban was made
	"active TINYINT".			# Whether or not the ban is active

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub initDeletedDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_DELETED_TABLE.";") if(table_exists(SQL_DELETED_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_DELETED_TABLE." (".

	"indexnum ".get_sql_autoincrement().",".	# Post number, auto-increments
	"num INTEGER,".				# Parent post for replies in threads. For original posts, must be set to 0 (and not null)
	"parent INTEGER,".			# Parent post for replies in threads. For original posts, must be set to 0 (and not null)
	"timestamp INTEGER,".		# Timestamp in seconds for when the post was created
	"lasthit INTEGER,".			# Last activity in thread. Must be set to the same value for BOTH the original post and all replies!
	"ip TEXT,".					# IP number of poster, in integer form!
	"name TEXT,".				# Name of the poster
	"trip TEXT,".				# Tripcode (encoded)
	"email TEXT,".				# Email address
	"subject TEXT,".			# Subject
	"comment TEXT,".			# Comment text, HTML encoded.
	"image TEXT,".				# Image filename with path and extension (IE, src/1081231233721.jpg)
	"size INTEGER,".			# File size in bytes
	"md5 TEXT,".				# md5 sum in hex
	"width INTEGER,".			# Width of image in pixels
	"height INTEGER,".			# Height of image in pixels
	"filename TEXT,".			# The original filename
	"deletedby TEXT,".			# 
	"deletedtime INTEGER,".		# 
	"board TEXT".				# 
	
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub initLogDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_LOG_TABLE.";") if(table_exists(SQL_LOG_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_LOG_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Post number, auto-increments
	"user TEXT,".
	"action TEXT,".
	"object TEXT,".	
	"board TEXT,".
	"time INTEGER,".
	"ip TEXT".			
	
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub initPassDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_PASS_TABLE.";") if(table_exists(SQL_PASS_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_PASS_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Post number, auto-increments
	"token TEXT,".						# On 4chan this would probably be used for checking if Stripe processed a vald payment
										# Here, its just a bunch of hashed shit
	"pin INTEGER,".						# A 'randomly' generated pin
	"ip TEXT,".							# A "serialized" array of the last IPs to log in
	"lasthit INTEGER,".					# The last time the user logged on. If 3 months pass without another logon, the pass will be deactivated
	"lastswitch INTEGER,".				# The last time the user logged on. If 3 months pass without another logon, the pass will be deactivated
	"timestamp INTEGER,".				# DOB
	"email TEXT,".						# The owner's email address
	"approved TINYINT,".				# Whether or not the pass is approved. All passes are manually approved based on post history or something
	"banned TINYINT".					# Whether or not the pass is banned
	
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub initUserDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_USER_TABLE.";") if(table_exists(SQL_USER_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_USER_TABLE." (".

	"user TEXT,".
	"pass TEXT,".
	"email TEXT,".
	"class TEXT,".
	"lastip TEXT,".
	"lastdate INTEGER,".
	"newmsgs TINYINT,".
	"newreports TINYINT,".
	"newbanreqs TINYINT".

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub initMessageDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_MESSAGE_TABLE.";") if(table_exists(SQL_MESSAGE_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_MESSAGE_TABLE." (".

	"touser TEXT,".
	"fromuser TEXT,".
	"message TEXT,".
	"num ".get_sql_autoincrement().",".
	"parent INTEGER,".
	"timestamp INTEGER,".
	"lasthit INTEGER,".
	"wasread TINYINT".

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error($sth->errstr);
}

sub initReportDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_REPORT_TABLE.";") if(table_exists(SQL_REPORT_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_REPORT_TABLE." (".

	"num ".get_sql_autoincrement().",".
	"postnum INTEGER,".
	"parent TINYINT,".
	"board TEXT,".
	"fromip TEXT,".
	"timestamp INTEGER,".
	"vio TINYINT,".
	"spam TINYINT,".
	"illegal TINYINT".

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error($sth->errstr);
}

sub initBanRequestDatabase(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_BANREQUEST_TABLE.";") if(table_exists(SQL_BANREQUEST_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_BANREQUEST_TABLE." (".

	"num ".get_sql_autoincrement().",".
	"postnum INTEGER,".
	"postparent INTEGER,".
	"board TEXT,".
	"ip TEXT,".
	"reason TEXT,".
	"reason2 TEXT,".
	"fromuser TEXT,".
	"timestamp INTEGER".

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error($sth->errstr);
}

sub init_proxy_database(){
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_PROXY_TABLE.";") if(table_exists(SQL_PROXY_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_PROXY_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Entry number, auto-increments
	"type TEXT,".				# Type of entry (black, white, etc)
	"ip TEXT,".				# IP address
	"timestamp INTEGER,".			# Age since epoch
	"date TEXT".				# Human-readable form of date 

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub repair_database(){
	my ($sth,$row,@threads,$thread);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	while($row=$sth->fetchrow_hashref()) { push(@threads,$row); }

	foreach $thread (@threads){
		# fix lasthit
		my ($upd);

		$upd=$dbh->prepare("UPDATE ".SQL_TABLE." SET lasthit=? WHERE parent=?;") or make_error(S_SQLFAIL);
		$upd->execute($$thread{lasthit},$$thread{num}) or make_error(S_SQLFAIL." ".$dbh->errstr());
	}
}

sub get_sql_autoincrement(){
	return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT' if(SQL_DBI_SOURCE=~/^DBI:mysql:/i);
	return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite:/i);
	return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite2:/i);

	make_error(S_SQLCONF); # maybe there should be a sane default case instead?
}

sub trim_database(){
	my ($sth,$row,$order);

	if(TRIM_METHOD==0) { $order='num ASC'; }
	else { $order='lasthit ASC'; }

	if(MAX_AGE) # needs testing
	{
		my $mintime=time()-(MAX_AGE)*3600;

		$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0 AND timestamp<=$mintime;") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		while($row=$sth->fetchrow_hashref()){
			delete_post($$row{num},"",0,ARCHIVE_MODE);
		}
	}

	my $threads=count_threads();
	my ($posts,$size)=count_posts();
	my $max_threads=(MAX_THREADS or $threads);
	my $max_posts=(MAX_POSTS or $posts);
	my $max_size=(MAX_MEGABYTES*1024*1024 or $size);

	while($threads>$max_threads or $posts>$max_posts or $size>$max_size){
		$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0 ORDER BY $order LIMIT 1;") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		if($row=$sth->fetchrow_hashref()){
			my ($threadposts,$threadsize)=count_posts($$row{num});

			delete_post($$row{num},"",0,ARCHIVE_MODE);

			$threads--;
			$posts-=$threadposts;
			$size-=$threadsize;
		}
		else { last; } # shouldn't happen
	}
}

sub table_exists($){
	my ($table)=@_;
	my ($sth);

	return 0 unless($sth=$dbh->prepare("SELECT * FROM ".$table." LIMIT 1;"));
	return 0 unless($sth->execute());
	return 1;
}

sub count_threads(){
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub count_posts(;$$){
	my ($parent,$countimages)=@_;
	my ($sth,$where);

	$where="WHERE parent=$parent or num=$parent" if($parent);
	$sth=$dbh->prepare("SELECT count(*),sum(size) FROM ".SQL_TABLE." $where;") or make_error(S_SQLFAIL) unless ($countimages);
	$sth=$dbh->prepare("SELECT count(*),sum(size),count(image) FROM ".SQL_TABLE." $where;") or make_error(S_SQLFAIL) if ($countimages);
	$sth->execute() or make_error(S_SQLFAIL);

	return $sth->fetchrow_array();
}

sub thread_exists($){
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE num=? AND parent=0;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub get_decoded_hashref($){
	my ($sth)=@_;

	my $row=$sth->fetchrow_hashref();

	if($row and $has_encode){
		for my $k (keys %$row) # don't blame me for this shit, I got this from perlunicode.
		{ defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$k}; }
	}

	return $row;
}

sub get_decoded_arrayref($){
	my ($sth)=@_;

	my $row=$sth->fetchrow_arrayref();

	if($row and $has_encode){
		# don't blame me for this shit, I got this from perlunicode.
		defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;
	}

	return $row;
}

# not database utils

sub moveThread($$$$){
	my ($admin,$from,$to,$parentpost)=@_;
	make_error("Not yet implemented");
	make_error(thread_exists($from));
	
	logAction("movethread","",$admin);
	
	return;
}

sub movePost($$$$){
	my ($admin,$from,$to,$post)=@_;
	make_error("Not yet implemented");
	logAction("movepost","",$admin);
	return;
}

sub toggle_sticky($$$){
	my ($admin,$num,$jimmies)=@_;
	my ($sth);
	my @session = check_password($admin);
	
	logAction("sticky",$num,@session);
	
	make_error(S_CLASS) unless @session[1] ne 'janitor';

	if($jimmies eq 'unrustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET sticky=1 WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}
	elsif($jimmies eq 'rustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET sticky=NULL WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}
	
	$sth->execute($num,$num) or make_error(S_SQLFAIL);

	do_rebuild_cache($admin);
}

sub toggle_permasage($$$){
	my ($admin,$num,$jimmies)=@_;
	my ($sth);
	my @session = check_password($admin);
	
	logAction("permasage",$num,@session);
	
	make_error(S_CLASS) unless @session[1] ne 'janitor';
	
	if($jimmies eq 'unrustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET permasage=1 WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}
	elsif($jimmies eq 'rustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET permasage=NULL WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}

	$sth->execute($num,$num) or make_error(S_SQLFAIL);

	do_rebuild_cache($admin);
}

sub toggle_lock($$$){
	my ($admin,$num,$jimmies)=@_;
	my ($sth);
	my @session = check_password($admin);
	
	logAction("close",$num,@session);
	
	make_error(S_CLASS) unless @session[1] ne 'janitor';
	
	if($jimmies eq 'unrustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET locked=1 WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}
	elsif($jimmies eq 'rustled'){
		$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET locked=NULL WHERE parent=? OR (num=? AND parent=0)") or make_error(S_SQLFAIL);
	}
	
	$sth->execute($num,$num) or make_error(S_SQLFAIL);
	
	do_rebuild_cache($admin);
}

sub make_add_user($){
	my ($admin)=@_;
	my @session = check_password($admin);
	
	make_error(S_CLASS) unless @session[1] eq "admin"; # lol perl style
	make_http_header();
	print encode_string(REGISTER_TEMPLATE->(admin=>$admin,session=>\@session));
}

sub make_manage_users($){
	my ($admin)=@_;
	my (@users,$row);
	my @session = check_password($admin);
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE) or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @users,$row;
	}
	
	make_http_header();
	print encode_string(MANAGE_USERS_TEMPLATE->(admin=>$admin,session=>\@session,users=>\@users));
}

sub add_user($$$$$){
	my ($admin,$user,$pass,$email,$class)=@_;
	my @session = check_password($admin);
	
	logAction("adduser",$user,@session);
	
	make_error(S_CLASS) unless @session[1] eq "admin";
	
	$user=clean_string(decode_string($user,CHARSET));
	$pass=clean_string(decode_string($pass,CHARSET));
	$email=clean_string(decode_string($email,CHARSET));
	
	make_error("Invalid Class") unless $class=~m/(admin|mod|janitor|vip)/;
	make_error(S_CLASS) unless @session[1] eq "admin";
	
	my $sth=$dbh->prepare("INSERT INTO ".SQL_USER_TABLE." VALUES(?,?,?,?,NULL,NULL,NULL,NULL,NULL);") or make_error(S_SQLFAIL);
	$sth->execute($user,$pass,$email,$class) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=manageusers",ALTERNATE_REDIRECT);
}

sub remove_user($$){
	my ($user,$admin)=@_;
	my @session = check_password($admin);
	
	logAction("removeuser",$user,@session);
	
	make_error(S_CLASS) unless @session[1] eq "admin";
	$user=clean_string(decode_string($user,CHARSET));
	
	my $sth=$dbh->prepare("DELETE FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
	$sth->execute($user) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=manageusers",ALTERNATE_REDIRECT);
}

sub make_edit_user($$){
	my ($admin,$user)=@_;
	my @session = check_password($admin);
	
	# dat security
	if (@session[1] ne "admin"){
		if (@session[0] ne $user){ make_error("ya turkey")};
	}
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
	$sth->execute($user) or make_error(S_SQLFAIL);
	my $dengus=get_decoded_hashref($sth);
	
	make_http_header();
	if($user) { print encode_string(EDIT_USER_TEMPLATE->(admin=>$admin,user=>$user,session=>\@session,userinfo=>$dengus)) }
	else { print encode_string(EDIT_USER_TEMPLATE->(admin=>$admin,user=>@session[0],session=>\@session,userinfo=>$dengus)) }
}

sub update_user_details($$$$$$){
	my ($user,$oldpass,$newpass,$email,$class,$admin)=@_;
	my @session = check_password($admin);
	my ($sth);
	
	logAction("edituser",$user,@session);
	
	$oldpass=clean_string(decode_string($oldpass,CHARSET));
	$newpass=clean_string(decode_string($newpass,CHARSET));
	$user=clean_string(decode_string($user,CHARSET));
	$email=clean_string(decode_string($email,CHARSET));
	$class=clean_string(decode_string($class,CHARSET));
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
	$sth->execute($user) or make_error(S_SQLFAIL);
	my $dengus=get_decoded_hashref($sth);
	
	if(@session[1] eq "admin"){
		# protect admins from other admins (if there are other admins for whatever reason)
		if(($$dengus{class} eq "admin") and ($$dengus{user} ne @session[0])) { make_error("ya turkey") }
		elsif(($oldpass ne $$dengus{pass}) and ($$dengus{user} eq @session[0]) and ($newpass)) { make_error("Your old password was incorrect") } # don't let admins change own password without entering their old pass
	}
	else{
		if($$dengus{user} ne @session[0]) { make_error("ya turkey") }
		if(($$dengus{pass} ne $oldpass) and ($newpass)) { make_error("Your old password was incorrect") }
	}
	
	# keep original values if user input is null
	$newpass=$$dengus{pass} unless $newpass;
	$email=$$dengus{email} unless $email;
	$class=$$dengus{class} unless $class;
		
	$sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET pass=?,class=?,email=? WHERE user=?") or make_error(S_SQLFAIL);
	$sth->execute($newpass,$class,$email,$user) or make_error(S_SQLFAIL);
	
	if($$dengus{user} eq @session[0]) { make_http_forward(get_script_name()."?admin=$admin&task=logout&type=admin",ALTERNATE_REDIRECT) }
	else { make_http_forward(get_script_name()."?admin=$admin&task=manageusers",ALTERNATE_REDIRECT) }
}

sub make_compose_message($$$){
	my ($admin,$parentmsg,$to)=@_;
	my @session = check_password($admin);
	
	make_http_header();
	print encode_string(COMPOSE_MESSAGE_TEMPLATE->(admin=>$admin,session=>\@session,parentmsg=>$parentmsg,to=>$to));
}

sub make_view_message($$){
	my ($admin,$num)=@_;
	my @session = check_password($admin);
	my (@messages,$row);
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_MESSAGE_TABLE." WHERE num=? OR parent=? ORDER BY timestamp ASC;") or make_error(S_SQLFAIL);
	$sth->execute($num,$num) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @messages,$row;
	}
	
	my $threadLength = scalar @messages;
	
	# Unread/Read logic
	if ($threadLength==1){
		if(($messages[0]{wasread}==0)&&($messages[0]{touser} eq @session[0])){
			$sth=$dbh->prepare("UPDATE ".SQL_MESSAGE_TABLE." SET wasread=1 WHERE num=?") or make_error(S_SQLFAIL);
			$sth->execute($num) or make_error($sth->errstr);
		}
	}
	else{
		if(($messages[0]{wasread}==0)&&($messages[$threadLength-1]{touser} eq @session[0])){
			$sth=$dbh->prepare("UPDATE ".SQL_MESSAGE_TABLE." SET wasread=1 WHERE num=?") or make_error(S_SQLFAIL);
			$sth->execute($num) or make_error($sth->errstr);
		}
	}
	
	make_http_header();
	print encode_string(VIEW_MESSAGE_TEMPLATE->(admin=>$admin,session=>\@session,messages=>\@messages,num=>$num));
}

sub send_message($$$$$$){
	my ($admin,$msg,$to,$parentmsg,$isnote,$noformat,$email)=@_;
	my @session = check_password($admin);
	my $from=@session[0];
	my $time=time();
	
	$msg=format_comment(clean_string(decode_string($msg,CHARSET))) unless $noformat;
	$to=clean_string(decode_string($to,CHARSET));
	
	if ($parentmsg>0){
		# gets the msgs parent
		my $sth=$dbh->prepare("SELECT * FROM ".SQL_MESSAGE_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
		$sth->execute($parentmsg) or make_error($sth->errstr);
		my $dengus=get_decoded_hashref($sth);
		
		# $to is empty for some crazy reason
		if($$dengus{fromuser} ne @session[0]){
			$to=$$dengus{fromuser};
		}
		else{
			$to=$$dengus{touser};
		}
		
		# writes the message
		$sth=$dbh->prepare("INSERT INTO ".SQL_MESSAGE_TABLE." VALUES(?,?,?,null,?,?,null,null);") or make_error(S_SQLFAIL);
		$sth->execute($to,$from,$msg,$parentmsg,$time) or make_error(S_SQLFAIL);
		
		# updates parent msgs lasthit
		$sth=$dbh->prepare("UPDATE ".SQL_MESSAGE_TABLE." SET lasthit=?,wasread=null WHERE num=?") or make_error(S_SQLFAIL);
		$sth->execute($time,$$dengus{num}) or make_error(S_SQLFAIL);
		
		# gets the recipients email
		$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
		$sth->execute($to) or make_error($sth->errstr);
		$email=get_decoded_hashref($sth);
		$email=$$email{email};
	}
	else{
		my $sth=$dbh->prepare("INSERT INTO ".SQL_MESSAGE_TABLE." VALUES(?,?,?,null,null,?,?,null);") or make_error(S_SQLFAIL);
		$sth->execute($to,$from,$msg,$time,$time) or make_error(S_SQLFAIL);
		
		# gets the recipients email
		$sth=$dbh->prepare("SELECT * FROM ".SQL_USER_TABLE." WHERE user=?;") or make_error(S_SQLFAIL);
		$sth->execute($to) or make_error($sth->errstr);
		$email=get_decoded_hashref($sth);
		$email=$$email{email};
	}
	
	# gives the user a new message notification
	my $sth=$dbh->prepare("UPDATE ".SQL_USER_TABLE." SET newmsgs=1 WHERE user=?") or make_error(S_SQLFAIL);
	$sth->execute($to) or make_error(S_SQLFAIL);
	
	# send an email to the message recipient
	send_email(
		$email,
		"cameron\@".DOMAIN,
		$from." sent you a message","You've recieved a new message from ".$from.". Login to the ".SITE_NAME." management panel to view it."
	);
	
	if($isnote){
		make_http_forward(get_script_name()."?admin=$admin&task=ippage&ip=".$to,ALTERNATE_REDIRECT) unless $isnote==2; # if it equals two its probably a ban request or some other type of message that doesn't need a redirect at all
	}
	else{
		make_http_forward(get_script_name()."?admin=$admin&task=inbox",ALTERNATE_REDIRECT);
	}
}

sub make_inbox($){
	my ($admin)=@_;
	my (@messages,$row);
	my @session = check_password($admin);
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_MESSAGE_TABLE." WHERE (touser=? OR fromuser=?) AND (parent IS NULL) ORDER BY lasthit DESC;") or make_error(S_SQLFAIL);
	$sth->execute(@session[0],@session[0]) or make_error($sth->errstr);
	
	while($row=get_decoded_hashref($sth)){
		if(($$row{fromuser} eq @session[0])&&($$row{lasthit}>$$row{timestamp})){
			push @messages,$row;
		}
		elsif($$row{touser} eq @session[0]){
			push @messages,$row;
		}
	}
	
	clear_notifications(@session[0],"msgs");
	
	make_http_header();
	print encode_string(INBOX_TEMPLATE->(admin=>$admin,session=>\@session,messages=>\@messages));
}

sub make_thread($$){
	my ($admin,$thread)=@_;
	my ($sth,$row,@thread,@postnumbers,@reportedposts);

	my @session = check_password($admin);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? OR parent=? ORDER BY num ASC;") or make_error(S_SQLFAIL);
	$sth->execute($thread,$thread) or make_error(S_SQLFAIL);

	while($row=get_decoded_hashref($sth)) { push(@thread,$row); }
	
	# incredibly inefficient report stuff
	foreach my $post (@thread){
		push @postnumbers, $$post{num};
	}
	
	my $statement = "SELECT * FROM ".SQL_REPORT_TABLE." WHERE postnum IN (" . join( ',', map { "?" } @postnumbers ) . ") ORDER BY num DESC";
	$sth=$dbh->prepare($statement) or make_error($dbh->errstr);
	$sth->execute(@postnumbers) or make_error($dbh->errstr);
	
	while($row=get_decoded_hashref($sth)){
		push(@reportedposts,$row);
	}
	
	foreach my $post (@thread){
		foreach my $reportedpost (@reportedposts){
			if($$reportedpost{postnum}==$$post{num}){
				$$post{reported}=1;
			}
		}
	}

	make_error(S_NOTHREADERR) if($thread[0]{parent});
	make_http_header();
	
	print encode_string(ADMIN_PAGE_TEMPLATE->(
		thread=>$thread,
		postform=>(ALLOW_TEXT_REPLIES or ALLOW_IMAGE_REPLIES),
		image_inp=>ALLOW_IMAGE_REPLIES,
		textonly_inp=>0,
		dummy=>$thread[$#thread]{num},
		threads=>[{posts=>\@thread}],
		admin=>$admin,
		session=>\@session
	));
}

sub make_page($$){
	my ($admin,$page)=@_;
	my ($sth,$row,@threads,$total,$filename,@postnumbers);
	my @session = check_password($admin);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	
	$row=get_decoded_hashref($sth);
	push @postnumbers,$$row{num};

	my @threads;
	my @thread=($row);

	while($row=get_decoded_hashref($sth)){
		if(!$$row{parent}){
			push @postnumbers,$$row{num};
			push @threads,{posts=>[@thread]};
			@thread=($row); # start new thread
		}
		else
		{
			push @postnumbers,$$row{num};
			push @thread,$row;
		}
	}
	push @threads,{posts=>[@thread]};
	
	# grabs reported posts
	my $statement = "SELECT * FROM ".SQL_REPORT_TABLE." WHERE (parent IS NULL) AND postnum IN (" . join( ',', map { "?" } @postnumbers ) . ") ORDER BY num DESC";
	$sth=$dbh->prepare($statement) or make_error($dbh->errstr);
	$sth->execute(@postnumbers) or make_error($dbh->errstr);
	
	my @reportedposts;

	while($row=get_decoded_hashref($sth)){
		push @reportedposts, $row;
	}
	
	my $total=get_page_count(scalar @threads);
	my @pagethreads;
	
	@pagethreads=splice @threads,(IMAGES_PER_PAGE * $page),IMAGES_PER_PAGE;
	
	foreach my $thread (@pagethreads){
		# split off the parent post, and count the replies and images
		my ($parent,@replies)=@{$$thread{posts}};
		my $replies=@replies;
		my $images=grep { $$_{image} } @replies;
		my $curr_replies=$replies;
		my $curr_images=$images;
		my $max_replies=REPLIES_PER_THREAD;
		
		# only display one reply if the thread is stickied
		if($$parent{sticky}==1){
			$max_replies=1;
		}
		
		my $max_images=(IMAGE_REPLIES_PER_THREAD or $images);

		# drop replies until we have few enough replies and images
		while($curr_replies>$max_replies or $curr_images>$max_images){
			my $post=shift @replies;
			$curr_images-- if($$post{image});
			$curr_replies--;
		}

		# write the shortened list of replies back
		$$thread{posts}=[$parent,@replies];
		$$thread{omit}=$replies-$curr_replies;
		$$thread{omitimages}=$images-$curr_images;

		# abbreviate the remaining posts and append report status
		foreach my $post (@{$$thread{posts}}){
			foreach my $reportedpost (@reportedposts){
				if($$reportedpost{postnum}==$$post{num}){
					$$post{reported}=1;
				}
			}
			my $abbreviation=abbreviate_html($$post{comment},MAX_LINES_SHOWN,APPROX_LINE_LENGTH);
			if($abbreviation){
				$$post{comment}=$abbreviation;
				$$post{abbrev}=1;
			}
		}
	}

	# make the list of pages
	my @pages=map +{ page=>$_ },(0..$total-1);

	foreach my $p (@pages){
		if($$p{page}==0) { $$p{filename}=get_script_name()."?admin=$admin&task=viewthreads&page=0" } # first page
		else { $$p{filename}=get_script_name()."?admin=$admin&task=viewthreads&page=".$$p{page} }
		if($$p{page}==$page) { $$p{current}=1 } # current page, no link
	}

	make_http_header();
	
	print encode_string(ADMIN_PAGE_TEMPLATE->(
		postform=>(ALLOW_TEXTONLY or ALLOW_IMAGES),
		image_inp=>ALLOW_IMAGES,
		textonly_inp=>(ALLOW_IMAGES and ALLOW_TEXTONLY),
		pages=>\@pages,
		admin=>$admin,
		session=>\@session,
		threads=>\@pagethreads
	));
}

sub make_ip_page($$){
	my ($ip,$admin)=@_;
	my @session = check_password($admin);
	my ($sth,$row,@bans,@posts,@requested,@notes,$prevtype,$host);
	
	make_error(S_CLASS) unless @session[1] ne 'janitor';
	$host = gethostbyaddr inet_aton($ip),AF_INET or $ip;

	# get bans and other stuff for this ip
	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE ival1=? AND (type='ipban' OR type='wordban' OR type='whitelist' OR type='trust') ORDER BY type ASC,num ASC;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		$$row{divider}=1 if($prevtype ne $$row{type});
		$prevtype=$$row{type};
		$$row{rowtype}=@bans%2+1;
		push @bans,$row;
	}
	
	# get ban requests for this ip
	$sth=$dbh->prepare("SELECT * FROM ".SQL_BANREQUEST_TABLE." WHERE ip=?") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @requested,$row;
	}
	
	# get posts for ip
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE ip=? ORDER BY sticky DESC,lasthit DESC,CASE parent WHEN 0 THEN num ELSE parent END ASC,num ASC;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @posts,$row;
	}
	
	# get notes for ip
	$sth=$dbh->prepare("SELECT * FROM ".SQL_MESSAGE_TABLE." WHERE touser=? ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @notes,$row;
	}

	make_http_header();
	print encode_string(IP_PAGE_TEMPLATE->(
		admin=>$admin,
		ip=>$ip,
		host=>$host,
		session=>\@session,
		bans=>\@bans,
		notes=>\@notes,
		posts=>\@posts,
		requested=>\@requested
	));
}

sub view_deleted_post($$){
	my($admin,$num)=@_;
	my($sth,@post,$row,$parent);
	my @session = check_password($admin);
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_DELETED_TABLE." WHERE num=? AND board=?;") or make_error($dbh->errstr);
	$sth->execute($num,BOARD_DIR) or make_error($dbh->errstr);
	
	while($row=get_decoded_hashref($sth)){
		push @post,$row;
	}
	
	if(scalar(@post)==0){
		$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?") or make_error($dbh->errstr);
		$sth->execute($num) or make_error($dbh->errstr);
		
		while($row=get_decoded_hashref($sth)){
			if($$row{parent}==0){
				$parent=$num;
			}
			else{
				$parent=$$row{parent};
			}
		}
		
		make_http_forward(get_script_name()."?admin=$admin&task=viewthread&num=".$parent."#".$num,ALTERNATE_REDIRECT);
	}
	
	make_http_header();
	print encode_string(DELETED_POST_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		post=>\@post
	));
}

sub update_ban($$$$$){
	my($admin,$num,$ip,$reason,$active)=@_;
	my @session = check_password($admin);
	
	logAction("updateban",dec_to_dot $ip,@session);
	make_error(S_CLASS) unless @session[1] ne 'janitor';
	
	if($active==0 or $active==1){
		my $sth=$dbh->prepare("UPDATE ".SQL_ADMIN_TABLE." SET active=? WHERE num=?") or make_error(S_SQLFAIL);
		$sth->execute($active,$num) or make_error(S_SQLFAIL);
	}
	if($reason){
		my $sth=$dbh->prepare("UPDATE ".SQL_ADMIN_TABLE." SET comment=? WHERE num=?") or make_error(S_SQLFAIL);
		$sth->execute($reason,$num) or make_error(S_SQLFAIL);
	}
	
	make_http_forward(get_script_name()."?admin=$admin&task=ippage&ip=".$ip,ALTERNATE_REDIRECT);
}

sub make_edit_post($$){
	my ($admin,$num)=@_;
	my @session = check_password($admin);
	my ($row,@posts);
	
	make_error(S_CLASS) unless @session[1] eq 'admin';
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @posts,$row;
	}
	
	make_http_header();
	print encode_string(EDIT_POST_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		posts=>\@posts
	));
}

sub edit_post($$$$$$){
	my ($admin,$num,$comment,$subject,$name,$link,$trip)=@_;
	my @session = check_password($admin);
	make_error(S_CLASS) unless @session[1] eq 'admin';
	logAction("editpost",$num,@session);
	
	$comment=~s/^\s+//;
	$comment=~s/\s+$//;
	$comment=~s/\n\s*/ /sg;
	
	my $sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET comment=?,subject=?,name=?,email=?,trip=? WHERE num=?") or make_error(S_SQLFAIL);
	$sth->execute($comment,$subject,$name,$link,$trip,$num) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub logAction($$;@){
	my ($action,$object,@session)=@_;
	my ($time,$sth);
	
	if(!@session[0]){
		@session[0]=get_ip(USE_CLOUDFLARE);
	}
	elsif(!@session[1]){
		my $admin = @session[0];
		@session = check_password($admin);
	}
	else{
		# do nothing
	}

	$time=time();
	$sth=$dbh->prepare("INSERT INTO ".SQL_LOG_TABLE." VALUES(null,?,?,?,?,?,?);") or make_error($dbh->errstr);
	$sth->execute(@session[0],$action,$object,BOARD_DIR,$time,get_ip(USE_CLOUDFLARE)) or make_error($dbh->errstr);
}

sub make_view_log($){
	my ($admin)=@_;
	my ($row,$sth,@log);
	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq 'janitor';
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_LOG_TABLE." WHERE board=? ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		push @log,$row;
	}
	
	make_http_header();
	print encode_string(STAFF_LOG_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		log=>\@log
	));
}

sub make_pass_page(){
	make_http_header();
	print encode_string(REGISTER_PASS_TEMPLATE->(
		dengus=>"asdf"
	));
}

sub add_pass($$$){
	my ($email,$mailver,$accept)=@_;
	my ($token,$pin,$time,$sth,$row);
	
	$time=time();
	
	# clean up input
	make_error(S_UNUSUAL) if($email=~/[\n\r]/);
	make_error(S_TOOLONG) if(length($email)>MAX_FIELD_LENGTH);
	make_error("The two email fields do not match.") unless ($email eq $mailver);
	make_error("You did not accept the terms of use or terms of application.") unless ($accept==1);
	$email=clean_string(decode_string($email,CHARSET));
	
	# check for an existing pass
	$sth=$dbh->prepare("SELECT * FROM ".SQL_PASS_TABLE." WHERE email=? OR ip=?;") or make_error(S_SQLFAIL);
	$sth->execute($email,get_ip(USE_CLOUDFLARE)) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		if(length $$row{token}) { make_error("You already have a pass.") }
	}
	
	# check for bans
	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' AND (? & ival2 = ival1 & ival2) AND (active='1') ORDER BY num DESC;") or make_error(S_SQLFAIL);
	$sth->execute(dot_to_dec get_ip(USE_CLOUDFLARE)) or make_error(S_SQLFAIL);
	
	while($row=get_decoded_hashref($sth)){
		if ($$row{active}==1){
			make_error("You've been warned or banned. Check <a href='http://".DOMAIN."/banned/'>here</a> for details.");
		}
	}
	
	# generate pin and token
	$pin=int(rand(900000)+100000);
	$token=$time.dot_to_dec(get_ip(USE_CLOUDFLARE)).$pin.$email;
	$token=hide_data($token,9,"pass",SECRET,1);
	
	# insert the pass into the pass table
	my $sth=$dbh->prepare("INSERT INTO ".SQL_PASS_TABLE." VALUES(NULL,?,?,?,?,NULL,?,?,0,NULL);") or make_error(S_SQLFAIL);
	$sth->execute($token,$pin,get_ip(USE_CLOUDFLARE),$time,$time,$email) or make_error(S_SQLFAIL);
	
	# create cookie and log user in
	make_cookies(wakapass=>$pin."##".$token."##"."0",
	-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>$time+(60*60*24*30));
	
	# send an email
	send_email(
		$email,
		"cameron\@".DOMAIN,
		SITE_NAME." Pass Info",
		"Your pass is currently pending verification.\n\nToken: ".$token."\nPin: ".$pin."\n\nFor more info, visit http://".DOMAIN."/pass/"
	);
	
	# redirect to an info page
	make_http_header();
	print encode_string(PASS_SUCCESS_TEMPLATE->(
		pin=>$pin,
		token=>$token
	));
}

sub make_authorize_pass($){
	my($cookie)=@_;
	make_http_header();
	print encode_string(AUTHORIZE_PASS_TEMPLATE->(
		dengus=>$cookie
	));
}

sub authorize_pass($$$;$){
	my ($token,$pin,$remember,$noredirect)=@_;
	my ($sth,$row,$i,$time,$expiration,$verified);
	#$pin=clean_string(decode_string($pin,CHARSET));
	#$token=clean_string(decode_string($token,CHARSET));
	
	$sth=$dbh->prepare("SELECT * FROM ".SQL_PASS_TABLE." WHERE pin=?;") or make_error(S_SQLFAIL);
	$sth->execute($pin) or make_error(S_SQLFAIL);
	
	# check if pass is valid and trim ip list
	while($row=get_decoded_hashref($sth)){
		$time=time();
		make_error("Invalid pass") unless $token eq $$row{token};
		
		# checks if its been 30 minutes since the last ip authorized
		if((($$row{lastswitch}+1800) > $time) and ($$row{lastswitch}>0)){
			make_error("Another IP has authorized for this pass within the last 30 minutes.") unless ($$row{ip} eq get_ip(USE_CLOUDFLARE));
		}
		
		# checks if its been 31 days since the last post made with a pass
		if(($$row{lasthit}+2678000) < $time){
			my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET approved=0 WHERE pin=?;") or make_error(S_SQLFAIL);
			$sth->execute($pin) or make_error(S_SQLFAIL);
		}
		
		$verified=$$row{approved};
	}
	
	make_error("Invalid Pass") unless $time;
	
	# update ip list
	my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET ip=?, lastswitch=? WHERE pin=?;") or make_error(S_SQLFAIL);
	$sth->execute(get_ip(USE_CLOUDFLARE),$time,$pin) or make_error(S_SQLFAIL);
	
	# create cookie and log user in
	$expiration=$time+(60*60*24*30) if $remember;
	$expiration="session" if !$remember;
	make_cookies(wakapass=>$pin."##".$token."##".$verified,
	-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>$expiration) unless $noredirect;
	
	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT) unless $noredirect;
}

sub update_pass($$$;$){
	my($admin,$num,$action,$noredirect)=@_;
	my($value,$message,$sth,$row,$unapprove);
	my %types = ("ban","banned","unban","banned","verify","approved","unverfiy","approved");
	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq 'janitor';
	
	# get pass
	$sth=$dbh->prepare("SELECT * FROM ".SQL_PASS_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	
	# some spaghetti code
	if(($action eq "ban")or($action eq "verify")){
		$unapprove=",approved=0" unless $action eq "verify";
		my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET ".$types{$action}."=1".$unapprove." WHERE num=?;") or make_error(S_SQLFAIL);
		$sth->execute($num) or make_error(S_SQLFAIL);
		if($action eq "ban"){
			$message="Your pass was just banned.";
		}
		else{
			$message="Congratulation! Your pass was just verified by a ".SITE_NAME." staff member!";
		}
	}
	elsif(($action eq "unban")or($action eq "unverify")){
		my $sth=$dbh->prepare("UPDATE ".SQL_PASS_TABLE." SET ".$types{$action}."=? WHERE num=?;") or make_error(S_SQLFAIL);
		$sth->execute(0,$num) or make_error(S_SQLFAIL);
		if($action eq "unverify"){
			$message="Your pass was just disabled for inactivity. It will be eligible for renewal after you've made 5 more posts with it on.";
		}
		else{
			$message="Congratulation! Your pass was just unbanned by a ".SITE_NAME." staff member!";
		}
	}
	
	# send an email
	while($row=get_decoded_hashref($sth)){
		send_email(
			$$row{email},
			"cameron\@".DOMAIN,
			SITE_NAME." Pass Update",
			$message."\n\nToken: ".$$row{token}."\nPin: ".$$row{pin}."\n\nFor more info, visit http://".DOMAIN."/pass/"
		);
	}
	
	make_http_forward(get_script_name()."?admin=$admin&task=passlist",ALTERNATE_REDIRECT) unless $noredirect;
}

sub make_pass_list($){
	my ($admin)=@_;
	my (@unverified,@banned,@normal,$sth,$row);
	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] eq 'janitor';
	
	# grab all passes organized by last hit
	$sth=$dbh->prepare("SELECT * FROM ".SQL_PASS_TABLE." ORDER BY lasthit DESC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	
	# put unverified and banned ones in seperate arrays
	while($row=get_decoded_hashref($sth)){
		if($$row{approved}==0){
			push @unverified,$row;
		}
		elsif($$row{banned}==1){
			push @banned,$row;
		}
		else{
			push @normal,$row;
		}
	}
	
	make_http_header();
	print encode_string(PASS_LIST_TEMPLATE->(
		admin=>$admin,
		session=>\@session,
		normal=>\@normal,
		banned=>\@banned,
		unverified=>\@unverified
	));
}

sub clear_log($){
	my ($admin)=@_;
	my @session = check_password($admin);
	make_error(S_CLASS) if @session[1] ne 'admin';
	
	my $sth=$dbh->prepare("DELETE FROM ".SQL_LOG_TABLE." WHERE board=?;") or make_error(S_SQLFAIL);
	$sth->execute(BOARD_DIR) or make_error(S_SQLFAIL);
	
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub clear_deleted($){

}

sub view_deleted($){

}