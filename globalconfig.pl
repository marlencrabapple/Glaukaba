#use constant DOMAIN => '';
#use constant SITE_NAME => '';
#use constant PATH = '';	# The path from the server's root directory to here, e.g. /var/www/www.mychan.com/htdocs/

#use constant BOARDS => [
#	{
#		name  => "Summer Glau",
#		dir     => "glau",
#		public      => 1
#	},
#	{
#		name  => "Site Discussion",
#		dir     => "meta",
#		public      => 1
#	},
#	{
#		name  => "Development Board",
#		dir     => "test",
#		public      => 0
#	}
#];

#use constant SQL_DBI_SOURCE => 'DBI:mysql:database=CHANGEME;host=CHANGEME';
#use constant SQL_USERNAME => '';
#use constant SQL_PASSWORD => '';
##use constant SQL_DBI_SOURCE => 'dbi:SQLite:dbname=wakaba.sql';	# DBI data source string (SQLite version, put database filename in here)
#use constant USE_TEMPFILES => 1;

#use constant JS_FILE => '/glaukaba-main-test.js';					# Location of the js file
#use constant EXTRA_JS_FILE => 'glaukaba-extra-test.js';			# Location of the optional feature js file
#use constant CSS_DIR => '/css/boards/';
#use constant CONVERT_COMMAND => 'convert -limit memory 1mb -limit map 2mb';		# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)
#use constant CONVERT_COMMAND => '/usr/X11R6/bin/convert';
#use constant SPAM_FILES => ('spam.txt');							# Spam definition files, as a Perl list.
																	# Hints: * Set all boards to use the same file for easy updating.
																	#        * Set up two files, one being the official list from
																	#          http://wakaba.c3.cx/antispam/spam.txt, and one your own additions.