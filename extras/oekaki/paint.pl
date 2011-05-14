#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use CGI;

use lib '.';
BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }
BEGIN { require "strings_en.pl"; }
BEGIN { require "oekaki_style.pl"; }
BEGIN { require "oekaki_config.pl"; }
BEGIN { require "oekaki_strings_en.pl"; }



my $query=new CGI;

my $oek_painter=$query->param("oek_painter");
my $oek_x=$query->param("oek_x");
my $oek_y=$query->param("oek_y");
my $oek_parent=$query->param("oek_parent");
my $oek_src=$query->param("oek_src");
my $ip=$ENV{REMOTE_ADDR};

make_error(S_HAXORING) if($oek_x=~/[^0-9]/ or $oek_y=~/[^0-9]/ or $oek_parent=~/[^0-9]/);
make_error(S_HAXORING) if($oek_src and !OEKAKI_ENABLE_MODIFY);
make_error(S_HAXORING) if($oek_src=~m![^0-9a-zA-Z/\.]!);
make_error(S_OEKTOOBIG) if($oek_x>OEKAKI_MAX_X or $oek_y>OEKAKI_MAX_Y);
make_error(S_OEKTOOSMALL) if($oek_x<OEKAKI_MIN_X or $oek_y<OEKAKI_MIN_Y);

my $time=time;

if($oek_painter=~/shi/)
{
	my $mode;
	$mode="pro" if($oek_painter=~/pro/);

	my $selfy;
	$selfy=1 if($oek_painter=~/selfy/);

	print "Content-Type: text/html; charset=Shift_JIS\n";
	print "\n";

	print OEKAKI_PAINT_TEMPLATE->(
		oek_painter=>clean_string($oek_painter),
		oek_x=>clean_string($oek_x),
		oek_y=>clean_string($oek_y),
		oek_parent=>clean_string($oek_parent),
		oek_src=>clean_string($oek_src),
		ip=>$ip,
		time=>$time,
		mode=>$mode,
		selfy=>$selfy
	);
}
else
{
	make_error(S_OEKUNKNOWN);
}



sub make_error($)
{
	my ($error)=@_;

	print "Content-Type: ".get_xhtml_content_type()."\n";
	print "Status: 500 $error\n";
	print "\n";

	print ERROR_TEMPLATE->(error=>$error);

	exit;
}
