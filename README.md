Glaukaba
========

## Intro ##

Glaukaba is a Wakaba fork with additional features in use on Glauchan. As of December 2012, it may be suitable for seamless usage on your own site. Try it out for yourself and let me know.

## Abridged Setup Guide ##
1. Create a directory for each board You plan on using, and copy every file (no directories except /include) in Glaukaba's root except for globalconfig.pl and spam.txt into each directory.
2. Download Glaukaba-JS and move glaukaba-main.js and glaukaba-extra.js into your /js directory.
3. Create three directories (/src, /res, and /thumb) in each board's directory
4. Setup URL rewriting in an .htaccess file or your HTTP server's configuration files so each board's pages and threads inside of /res are accesible without their extensions.
5. Make sure globalconfig.pl, spam.txt, and the included directories are exactly one level above each board.
6. Edit globalconfig.pl each board's config.pl to your liking.
7. Set some reasonable permissions.
8. If you want to use FastCGI, enable it in globalconfig.pl, and use spawn-fcgi to get the processes for your board running.
9. Run wakaba.pl in each board from the browser and pray that it works.
	
## Example Installation ##

A semi-current version of this software is in use on http://www.glauchan.org and a live demo with a public moderator account will be available at http://sandbox.onlinebargainshrimptoyourdoor.com at some point in the future.

## Issues ##

- Single board installations will require a bit of tinkering. Then again, so will any installation.
- This software has only one known production installation on the entire world wide web, so this software isn't exactly tried and proven.
- URL rewriting isn't optional yet.
- SQLite support isn't perfect.
- FastCGI seems to work, but that's only because I haven't tested it enough to see it not work.