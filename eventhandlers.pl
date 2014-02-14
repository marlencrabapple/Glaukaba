# The following are examples of event handlers.
# Don't mess with this unless you know what you're doing.
# $query is an object containing any and all data sent to the server via GET or POST. (http://perldoc.perl.org/CGI.html#SETTING-THE-VALUE(S)-OF-A-NAMED-PARAMETER%3a)

use constant EVENT_HANDLERS => {
	before_post_processing => sub {
		my ($board,$query) = @_;
		$query->param('field1','fuck you');
		return 0;
	},
	after_post_processing => sub {
		my ($board,$query,$parent,$name,$email,$subject,$comment,$originalcomment,$filename,$uploadname,$thumbnail,$tnmask,$password,$id,$time,$ajax) = @_;
		
		$name =~ s/fuck/hack/;
		
		# these are the variables that can be modified in this function. don't change what's returned
		# note: this can probably be done via references as well unless i've completely misunderstood them all this time
		#		a post object of sorts would make sense too, i guess
		return ($name,$email,$subject,$comment,$originalcomment,$id);
	},
	after_post => sub {
		my ($board,$query,$parent,$num,$name,$email,$subject,$comment,$originalcomment,$filename,$uploadname,$thumbnail,$tnmask,$password,$id,$time,$ajax) = @_;
		
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
		}
		
		exit_script();
		return 0;
	},
	before_template_formatted => sub {
		my ($board,$board,$query,$templatedata) = @_;
		return 0;
	},
	after_template_formatted => sub {
		my ($board,$query,$templatedata,$formattedtemplate) = @_;
		return 0;
	},
	on_pass_application => sub {
		my ($board,$query,$passnum,$token,$email,$ip) = @_;
		return 0;
	}
};

1;
