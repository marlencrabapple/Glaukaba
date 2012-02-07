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

open (LOG, ">>reports.txt");
print LOG "Submitted By. $ENV{REMOTE_ADDR}\n";
print LOG "No. $post\n";
print LOG "Reason: $reason\n\n";
close (LOG);

my $url = "http://glauchan.ax.lt/glau/";

print "<script>document.write('<h1>Report Submitted. Redirecting.</h1>');</script>";
print "<script>setTimeout(window.location = 'http://glauchan.ax.lt/glau/',2000);</script>";