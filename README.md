Glaukaba

========

## Intro ##

Glaukaba is a Wakaba fork with additional features in use on Glauchan. As of this commit, it may be suitable for seamless enough usage on other sites. Try it out for yourself and let me know.

## Abridged Setup Guide ##
	Create a directory for each board You plan on using, and copy every file in Glaukaba's root except for globalconfig.pl and spam.txt into each directory.
	Download Glaukaba-JS and move glaukaba-main.js and glaukaba-extra.js into your /js directory.
	Create three directories (/src, /res, and /thumb) in each board's directory
	Setup URL rewriting in an .htaccess file or your HTTP server's configuration files so each board's pages and threads inside of /res are accesible without their extensions.
	Make sure globalconfig.pl, spam.txt, and the included directories are exactly one level above each board.
	Edit globalconfig.pl each board's config.pl to your liking.
	Set some reasonable permissions.
	Run wakaba.pl in each board from the browser and pray that it works.
	
## Example Installation ##

A semi-current version of this software is in use on http://www.glauchan.org and a live demo with a public moderator account is available at http://sandbox.onlinebargainshrimptoyourdoor.com.

## Issues ##

	Single board installations will require tinkering
	This software has only one known production installation on the entire world wide web, so this software isn't exactly tried and proven.