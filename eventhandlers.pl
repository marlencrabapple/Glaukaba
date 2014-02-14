# The following are examples of event handlers.
# Don't mess with these unless you know what you're doing.
# $query is an object containing any and all data sent to the server via GET or POST. (http://perldoc.perl.org/CGI.html#SETTING-THE-VALUE(S)-OF-A-NAMED-PARAMETER%3a)

use constant EVENT_HANDLERS => {
	before_post_processing => sub {
		my ($board,$query) = @_;
		$query->param('field1','fuck you') unless $query->param('admin');
	},
	after_post_processing => sub {
		my ($board,$query,$parent,$name,$email,$subject,$comment,$originalcomment,$filename,$uploadname,$thumbnail,$tnmask,$password,$id,$time,$ajax,$noko) = @_;
		
		$name =~ s/fuck/hack/ unless $query->param('admin');
		
		# these are the variables that can be modified in this function. don't change what's returned
		# note: this can probably be done via references as well unless i've completely misunderstood them all this time
		#		a post object of sorts would make sense too, i guess
		return ($name,$email,$subject,$comment,$originalcomment,$id);
	},
	after_post => sub {
		my ($board,$query,$num,$parent,$name,$email,$subject,$comment,$originalcomment,$filename,$uploadname,$thumbnail,$tnmask,$password,$id,$time,$ajax,$noko) = @_;
		
		if(!$ajax and !$query->param('admin')) {
			$num = get_post_num($time,$comment,$filename) if !$num;
			my $forwardto = $noko ? get_reply_link($num,$parent) : "http://".DOMAIN."/".BOARD_DIR."/";
			make_http_header();
			print encode_string(compile_template(MINIMAL_HEAD_INCLUDE.q{
				<h1 style="text-align:center">Post Successful!</h1>
				<script>
				setTimeout(function() {
					window.location = "<var $forwardto>";
				},2000);
				</script>
			}.NORMAL_FOOT_INCLUDE)->(
				title => 'Post Successful',
				forwardto => $forwardto
			));
			
			exit_script();
		}
	},
	before_template_formatted => sub {
		my (%templatevars) = @_;
		%templatevars->{title} = 'Pastor Erickson\'s Miney Miney Tiny Time Town' if %templatevars->{title} eq SITE_NAME . " Pass";
		
		return %templatevars;
	},
	after_template_formatted => sub {
		my ($str) = @_;
		$str =~ s/pass/ssap/g if($str =~ /<title>Pastor Erickson's Miney Miney Tiny Time Town<\/title>/);
		return $str;
	},
	on_pass_application => sub {
		my ($board,$query,$pin,$token,$email,$ip) = @_;
		
		# you can redirect users to a paypal donate page, interface with a payment gateway's api, etc.
		make_http_forward('http://www.google.com',ALTERNATE_REDIRECT);
		return 0;
	}
};

1;
