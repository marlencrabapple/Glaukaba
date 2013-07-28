Glaukaba
========

## Intro ##
Glaukaba is a Wakaba fork with many additional features and enhancements. As of July 2013, its stable enough to run without any security or major usability issues when configured properly. Try it out for yourself and let me know.

## Abridged Setup Guide ##
1. Create a directory for each board You plan on using, and copy every file (no directories except /include) in Glaukaba's root except for globalconfig.pl and spam.txt into each directory.
2. Download Glaukaba-JS and move glaukaba-main.js and glaukaba-extra.js into your /js directory.
3. Create three directories (/src, /res, and /thumb) in each board's directory
4. Setup URL rewriting in an .htaccess file or your HTTP server's configuration files so each board's pages and threads inside of /res are accesible without their extensions.
5. Make sure globalconfig.pl, spam.txt, and the included directories are exactly one level above each board.
6. Edit globalconfig.pl each board's config.pl to your liking.
7. Set some reasonable permissions.
8. If you want to use FastCGI, enable it in globalconfig.pl, and use spawn-fcgi to get the processes for your board running.
9. Find the exact center of your living residence and occupy the space until noticed.
10. Run wakaba.pl in each board directory from your browser of choice and pray that it works.
	
## Example Installation ##
A semi-current version (sometimes a commit behind or ahead depending on the amount of changes between any two commits) of this software is in use on http://www.glauchan.org and a live demo with a public moderator account will be available at http://sandbox.onlinebargainshrimptoyourdoor.com at some point in the future.

## Issues ##
- Single board installations will require a bit of tinkering. Then again, so will any installation.
- This software is only in use on two sites, so there's not much I can do to vouch for this software's usability.
- SQLite support isn't perfect.
- FastCGI seems to work, but that's only because I haven't tested it enough to see it not work.
- A current list of issues and fixes is available http://www.glauchan.org/meta/res/410

## Notable Features ##
This is a list of features I believe make Glaukaba stand out from other free imageboard scripts.
- A JSON API for easy application development and reduced bandwidth usage
- Searchable Catalog
- reCAPTCHA support
- An extensive inline extension
- Mobile interface
- Its not Kusaba X
- Anything you've come to expect after being spoiled by 4chan's new-found interest in improving their site
A complete list of features can be found at http://onlinebargainshrimptoyourdoor.com/2012/07/22/glaukaba/ and http://www.glauchan.org/meta/res/410

## Support ##
Free support is available via email at mrmanager@glauchan.org and on http://www.glauchan.org/meta/res/410