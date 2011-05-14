#!/usr/bin/perl 
# TODO: * is parallelizing the connections a good idea or not?
#         - larger bandwidth spike
#         - more dependencies or more work
#         - but faster
#       * is the weighted selection of redir host working properly?
#         - aka: do identical hashes always unroll in the same order?
#       * is using strings_en.pl a good idea?
#         - greater overhead
#         - more files to edit when changing from strings_en.pl, if not overwritten

use strict;
use LWP;


use lib '.';
BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }
BEGIN { require "strings_en.pl"; }


# Constants
use constant URL => 0;		# LOAD_HOSTS array ref
use constant PASS => 1;		# ditto
use constant BANDWIDTH => 2;	# ditto

use constant RETRIES => 3;	# max retries for sending file
use constant MIN_TIMEOUT => 10;	# in seconds

use constant FILENAME => 0;	# ARGV ref
use constant DIR => 1;		# ditto
use constant MD5 => 2;		# ditto


# Prototypes
sub sendfile($$$$%);
sub deletefile($$);
sub generate_redir($$%);




#
# Main
#

{
	my ($file, $filename, %goodhosts);

	# set initial values
	$file = $ARGV[FILENAME];	# file to send


	my $img = IMG_DIR;
	$file =~ /$img(.*)/;
	$filename = $1;

	# initialize user agent
	my $ua = LWP::UserAgent->new;
	$ua->agent("Wakaba");
	$ua->max_size(2048); 

	if (@ARGV == 1)
	{	# we're deleting files
		unlink REDIR_DIR.$filename.".html";

		$ua->timeout(MIN_TIMEOUT);
		deletefile($ua, $filename);
	}
	elsif (@ARGV == 0)
	{
		print LOAD_SENDER_SCRIPT . " <file to send/delete> <root> <md5>\n";
	}
	else
	{	# we're sending files
		die "File not found." unless (-e $file);
		srand();	# randomize timer
		
		$goodhosts{$ARGV[DIR].$file} = LOAD_LOCAL;	# first file host (the local)
		generate_redir($filename, LOAD_LOCAL, %goodhosts);	# initial redir file

		$ua->timeout(MIN_TIMEOUT + (stat($file))[7] / LOAD_KBRATE);	# determine max timeout based on filesize
		sendfile($ua, $file, $filename, $ARGV[MD5], %goodhosts);
	}
}




#
# Send file to list of hosts
#

sub sendfile($$$$%)
{
	my ($ua, $file, $filename, $md5, %goodhosts) = @_;
	my @load_hosts = LOAD_HOSTS;
	my $total = LOAD_LOCAL;
	my $retry = RETRIES;

	# send file to each host
	for (my $count=0; $count != @load_hosts; $count++) {
		my $url = $load_hosts[$count]->[URL];
		my $pass = $load_hosts[$count]->[PASS];

		# post data
		my $response = $ua->post($url,
			Content_Type =>	'form-data',
			Content      =>	[ task  => 'post',
					pass => $pass,
					md5 => $md5,
					file   => [$file],
			]);

		# was the posting successful?
		if ($response->decoded_content =~ /<body>OK<\/body>/)
		{
			$url =~ /(.*\/).*/;
			my $hosturl = $1;

			$goodhosts{$hosturl.$filename} = $load_hosts[$count]->[BANDWIDTH]; # **
			$total += $load_hosts[$count]->[BANDWIDTH];
			$retry = RETRIES;

			generate_redir($filename, $total, %goodhosts);
		}
		# did receiver request a resend? Go for another round if not too many resends
		elsif ($response->decoded_content =~ /<body>RESEND<\/body>/)
		{	
			if ($retry != 0)
			{
				$retry--;
				redo;
			}
			else
			{
				$retry = RETRIES;
			}
		}
		# Was the post bad?
		elsif ($response->decoded_content =~ /<body>TERM<\/body>/)
		{
			$retry = RETRIES;
		}
	}
	generate_redir($filename, $total, %goodhosts);
}




#
# Delete the file on remote hosts
#

sub deletefile($$)
{
	my ($ua, $filename) = @_;
        my @load_hosts = LOAD_HOSTS;

        # send delete request to each host
        for (my $count=0; $count != @load_hosts; $count++) {
                my $url = $load_hosts[$count]->[URL];
                my $pass = $load_hosts[$count]->[PASS];

                # post data
                $ua->post($url,
                        Content_Type => 'form-data',
                        Content      => [ task  => 'delete',
                                        pass => $pass,
                                        file   => $filename,
                        ]);
	}
}




#
# Generates the redir file
#

sub generate_redir($$%)
{
	my ($filename, $total, %goodhosts) = @_;
	my $redir_text = S_REDIR;
	my $num = rand $total;
	my $sum = 0;
	my $selection;
	
	foreach my $key (sort keys %goodhosts) 
	{
		if ($num <= $goodhosts{$key} + $sum)
		{
			$selection = $key;
			last;
		}
		$sum += $goodhosts{$key};
	}

	open FILE, ">", REDIR_DIR.$filename.".html";

#---------------------------------------------------
	print FILE <<HEAD; 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="Refresh" content="1; $selection">
<meta name="MSSmartTagsPreventParsing" content="TRUE" />
</head>
<body>
$redir_text<br />
HEAD
#---------------------------------------------------

	my $i = 0;
	foreach my $host (keys %goodhosts)
	{
		print FILE "<a href=\"$host\">-- $i --</a><br />\n";
		$i++;

	}
	print FILE "</body></html>\n";

	close FILE;
}
