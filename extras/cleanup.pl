#!/usr/bin/perl



use strict;
use DBI;
BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }



my ($dbh, $sth, $res);
my ($filename, @files, %deleteable);



# Get list of all files in thumb
opendir(DIR, THUMB_DIR);
@files = readdir(DIR);
closedir(DIR);

foreach my $file (@files) 
{
	$filename = THUMB_DIR . $file;
	$deleteable{$filename} = 1 unless (-d $filename);
}



# Remove listed in DB from deletion list
$dbh=DBI->connect(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or die;
$sth=$dbh->prepare("SELECT thumbnail FROM ".SQL_TABLE) or die;
$sth->execute() or die;

my $thumb = THUMB_DIR;
while($res=$sth->fetchrow_hashref())
{
	$deleteable{$$res{thumbnail}} = 0 if ($$res{thumbnail}=~/^$thumb/);
}

$dbh->disconnect();



# Delete unnecessary thumbs
print "Content-Type: text/html\n\n";
print "<html><body>\n";
foreach my $file (keys %deleteable)
{
	if ($deleteable{$file} == 1) {
		print $file . "<br>\n";
		unlink $file;
	}
}
print "</body></html>\n";

