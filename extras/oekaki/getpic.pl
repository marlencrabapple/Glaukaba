#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use lib '.';
BEGIN { require 'oekaki_config.pl'; }

my $metadata=<STDIN>;
my $oek_ip;

if($metadata=~/^S[0-9]{8}(.*)[0-9]{8}$/) { $oek_ip=$1; }
else { $oek_ip=$ENV{REMOTE_ADDR}; }

die unless($oek_ip=~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/);

my $tmpname=TMP_DIR.$oek_ip.'.png';

open FILE,">$tmpname" or die("Couldn't write to directory");

binmode FILE;
binmode STDIN;

my $buffer;
while(read(STDIN,$buffer,1024)) { print FILE $buffer; }

close FILE;

print "Content-Type: text/plain\n";
print "\n";
print "ok";
