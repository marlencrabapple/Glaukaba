#!/usr/bin/perl

read(STDIN, $buffer,$ENV{'CONTENT_LENGTH'});
$buffer =~ tr/+/ /;
$buffer =~ s/\r/ /g;
$buffer =~ s/\n/ /g;
$buffer =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
$buffer =~ s/<!--(.|\n)*-->/ /g;
$buffer =~ tr/\\|[|]|<|!|"|$|{|}|*|#|'|>|||;|%/ /;
@pairs = split(/&/,$buffer);
foreach $pair(@pairs){
($key,$value)=split(/=/,$pair);
$formdata{$key}.="$value";
}
$post=$formdata{'Post'};
$reason=$formdata{'Reason'};

print "Content-type:text/html\n\n";

use POSIX qw/strftime/;

open (LOG, ">>reports.html");
print LOG strftime('<pre style="font-size: 12px;"><code>%Y-%b-%d %H:%M',localtime);
print LOG "<br />Submitted By. $ENV{HTTP_CF_CONNECTING_IP}<br />"; # HTTP_CF_CONNECTING_IP gets IPs properly with cloudflare
print LOG "No. $post<br />";
print LOG "Reason: $reason<br /></code></pre>";
close (LOG);

#my $url = "http://glauchan.org/glau/";

print "<script>document.write('<h1>Report Submitted. Redirecting in 5 seconds.</h1>');</script>";
#print "<script>setTimeout(window.location = 'http://glauchan.org/glau/',2000);</script>";
print "<script>self.close()</script>"; # changed for the new popup report form