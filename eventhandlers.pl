# The following are examples of event handlers.
# Don't mess with these unless you know what you're doing.
# Completely comment out or delete an event handler, including its subroutine to properly disable it.
# $query is an object containing any and all data sent to the server via GET or POST. (http://perldoc.perl.org/CGI.html#SETTING-THE-VALUE(S)-OF-A-NAMED-PARAMETER%3a)

use constant EVENT_HANDLERS => {
	before_post_processing => sub {
		my ($board,$query) = @_;
		$query->param('field1','fuck you') unless $query->param('admin');
	},
	after_post_processing => sub {
		my ($board,$query,$parent,$name,$email,$subject,$comment,$originalcomment,$filename,$uploadname,$thumbnail,$tnmask,$password,$id,$time,$ajax,$noko) = @_;
		
		$name =~ s/fuck/hack/ unless $query->param('admin');
		
		# These are the variables that can be modified in this function. Don't change what's returned.
		# The event handler will fail unless all 6 of the following variables are returned.
		# A post object of sorts would probably make more sense, but I'm too lazy to try.
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
		$str =~ s/([Pp])ass/ssa$1/g if($str =~ /<title>Pastor Erickson's Miney Miney Tiny Time Town - @{[ SITE_NAME ]}<\/title>/);
		return $str;
	},
	on_pass_application => sub {
		my ($board,$query,$pin,$token,$email,$ip) = @_;
		
		# you can redirect users to a paypal donate page, interface with a payment gateway's api, etc.
		make_http_forward('http://www.google.com',ALTERNATE_REDIRECT);
		return 0;
	}
};



#
# Defaults. Don't touch these.
#
eval q{
EVENT_HANDLERS->{before_post_processing} = sub {
return 0;
}
}unless(EVENT_HANDLERS->{before_post_processing});

eval q{
EVENT_HANDLERS->{after_post_processing} = sub {
return 0;
}
}unless(EVENT_HANDLERS->{after_post_processing});

eval q{
EVENT_HANDLERS->{after_post} = sub {
return 0;
}
}unless(EVENT_HANDLERS->{after_post});

eval q{
EVENT_HANDLERS->{before_template_formatted} = sub {
return @_;
}
}unless(EVENT_HANDLERS->{before_template_formatted});

eval q{
EVENT_HANDLERS->{after_template_formatted} = sub {
return @_;
}
}unless(EVENT_HANDLERS->{after_template_formatted});

eval q{
EVENT_HANDLERS->{on_pass_application} = sub {
return @_;
}
}unless(EVENT_HANDLERS->{on_pass_application});

1;
