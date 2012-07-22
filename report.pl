#!/usr/bin/perl
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 

my $buffer;

#read(STDIN, $buffer,$ENV{'CONTENT_LENGTH'});
$buffer = $ENV{'QUERY_STRING'};

$buffer =~ tr/+/ /;
$buffer =~ s/\r/ /g;
$buffer =~ s/\n/ /g;
$buffer =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
$buffer =~ s/<!--(.|\n)*-->/ /g;
$buffer =~ tr/\\|[|]|<|!|"|$|{|}|*|#|'|>|||;|%/ /;

@pairs = split(/&/,$buffer);

foreach $pair(@pairs){
	($key,$value) = split(/=/,$pair);
	$formdata{$key}.= "$value";
}

$post = $formdata{'Post'};
$reason = $formdata{'Reason'};

print "Content-type:text/html\n\n";

use POSIX qw/strftime/;

open (LOG, ">>reports.html");
print LOG strftime('<pre style="font-size: 12px; border-bottom: 1px LightGrey solid; width: 340px; padding: 10px; padding-bottom: 5px;"><code>%Y-%b-%d %H:%M',localtime);
print LOG "<br />Submitted By. $ENV{HTTP_CF_CONNECTING_IP}<br />"; # HTTP_CF_CONNECTING_IP gets IPs properly with cloudflare
print LOG "No. $post<br />";
print LOG "<span style='word-wrap: break-word; display: block; width: 340px;'>Reason: $reason</span><br /></code></pre>";
close (LOG);

#my $url = "http://glauchan.org/glau/";

#print "<script>alert('".$buffer."');</script>"
print "<script>document.write('<h1>Report Submitted. Redirecting in 5 seconds.</h1>');</script>";
print "<script>self.close()</script>"; # changed for the new popup report form