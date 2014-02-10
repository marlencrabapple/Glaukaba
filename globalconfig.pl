#use constant DOMAIN => '';				# Don't include http:// or any trailing slashes
#use constant SITE_NAME => '';

#use constant BOARDS => [
#	{
#		name  => "",					# The name you want to appear in the site's public navigation
#		dir     => "",					# Don't include any slashes
#		public      => 1				# Set to 0 if you don't want the board to appear in the site's public navigation
#	},
#	{
#		name  => "",
#		dir     => "",
#		public      => 1
#	},
#	{
#		name  => "",
#		dir     => "",
#		public      => 1
#		lastboard => 1
#	}
#];

# This is completely optional

#use constant LINKS => [
#	{
#		name => "@",
#		url => "https://twitter.com/mysiteofficial",
#		rel => "me",
#		lastlink => 1
#	}
#];

#use constant SQL_DBI_SOURCE => 'DBI:mysql:database=CHANGEME;host=CHANGEME';
#use constant SQL_USERNAME => '';
#use constant SQL_PASSWORD => '';
##use constant SQL_DBI_SOURCE => 'dbi:SQLite:dbname=wakaba.sql';		# DBI data source string (SQLite version, put database filename in here)

# Chances are you won't have to edit anything past here.

#use constant USE_TEMPFILES => 1;
#use constant JS_FILE => 'glaukaba-main.js';				# Location of the js file
#use constant EXTRA_JS_FILE => 'glaukaba-extra.js';			# Location of the optional feature js file
#use constant CSS_DIR => '/css/boards/';
#use constant CONVERT_COMMAND => 'convert';					# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)
#use constant CONVERT_COMMAND => '/usr/X11R6/bin/convert';
use constant SPAM_FILES => ('../spam.txt');					# Go to http://wakaba.c3.cx/antispam/spam.txt for an updated list							
1;
