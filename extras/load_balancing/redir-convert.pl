#!/usr/bin/perl
# Please run this script from a browser.


use strict;
use CGI;

BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }
BEGIN { require "wakautils.pl"; }



{
	my @files;

	# Get list of all files in src
	opendir(DIR, IMG_DIR);
	@files = readdir(DIR);
	closedir(DIR);

	foreach my $file (@files) 
	{
		generate_redir($file);
	}

	print "Content-Type: text/html\n\n";
	print "<html><body>\n";
	print "Done\n";
	print "</body></html>\n";
}



sub generate_redir($)
{
        my ($file) = @_;
	
	my $redir_file = REDIR_DIR . $file . '.html';

	unless (-e $redir_file)
	{
		my $url = expand_filename(IMG_DIR.$file);
		open FILE, ">", $redir_file;

		#---------------------------------------------------
		print FILE <<HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="Refresh" content="0; $url">
<meta name="MSSmartTagsPreventParsing" content="TRUE" />
</head>
<body>
<a href="$url">$url</a><br />
</body>
</html>
HTML
		#---------------------------------------------------
		close FILE;
	}
}
