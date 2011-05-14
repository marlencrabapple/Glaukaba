#!/usr/bin/perl -w

#
# This is the only option. The password is used by the server to transmit data.
# Change CHANGEME to a password of your choice, preferrably one you don't use
# anywhere else.

use constant PASSWORD => 'CHANGEME';

# Don't change anything beyond this line.
#
# -----------------------------------------------------------------------------

# TODO: Current security is plaintext.
#       Filename check is utterly idiotic (default policy is open)


use strict;

use CGI::Carp qw(fatalsToBrowser);
use CGI;



#
# Prototypes
#

sub post_file($$$);
sub delete_file($$);
sub print_status($);
sub check_password($);




#
# Global init
#

{
	die if (PASSWORD eq 'CHANGEME');	# prevent fools from hurting themselves

	my $query = new CGI;
	my $task = $query->param("task"); 

	if ($task eq "post")
	{
		my $password = $query->param("pass");
		my $file = $query->param("file");
		my $md5 = $query->param("md5");

		post_file($password,$file,$md5);
	}
	elsif ($task eq "delete")
	{
		my $password = $query->param("pass");
		my $file = $query->param("file");

		delete_file($password, $file);
	}
	else
	{
		print_status("TERM");
	}
}


#
# Functions
#

sub post_file($$$)
{
	my ($password, $file, $hash) = @_;
	my ($md5, $md5ctx, $buffer);

	check_password($password);
	print_status("TERM") if (-e "$file" or $file=~/\.\./ or $file=~/^(\/|\\)/);	
	
	# prepare MD5 checksum if the Digest::MD5 module is available
	eval 'use Digest::MD5 qw(md5_hex)';
	$md5ctx = Digest::MD5->new unless($@);

	# copy file
	binmode $file;
	open (OUTFILE, ">", "$file") or print_status("TERM");
	binmode OUTFILE;
	while (read($file, $buffer, 1024)) # should the buffer be larger?
	{
		print OUTFILE $buffer or print_status("TERM");
		$md5ctx->add($buffer) if($md5ctx);
	}
	close $file;
	close OUTFILE;

	if($md5ctx) # if we have Digest::MD5, get the checksum
	{
		$md5 = $md5ctx->hexdigest();
	}
	else # otherwise, try using the md5sum command
	{
		my $md5sum = `md5sum $file`; # filename is always the timestamp name, and thus safe
		$md5 = $md5sum=~/^([0-9a-f]+)/ unless($?);
	}

	if ($hash ne "" and $hash ne $md5) # check only if hash provided
	{
		unlink $file;
		print_status("RESEND");
	}

	print_status("OK");
}



sub delete_file($$)
{
	my ($password, $file) =@_;

	check_password($password);

	print_status("TERM") unless (-e "$file"); # don't want to give attackers too much leeway

	# Rudimentary checking
	unless ($file eq $ENV{SCRIPT_NAME} or $file=~/\.\./ or $file=~/^(\/|\\)/)
	{
		unlink $file; 
	}
	else
	{
		print_status("TERM");
	}

	print_status("OK");
}



sub print_status($)
{
	my ($status) = @_;

        print "Content-Type: text/html\n\n";
        print "<html><body>$status</body></html>\n";

	exit;
}



sub check_password($)
{
	my ($password) = @_;

	print_status("TERM") unless($password eq PASSWORD);
}

