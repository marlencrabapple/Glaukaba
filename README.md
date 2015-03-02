Glaukaba
========

## Intro ##
Glaukaba is a Wakaba (an imageboard script) fork with many additional features and enhancements. As of July 2013, its stable enough to run without any security or major usability issues when configured properly. Try it out for yourself and let me know.

## Abridged Setup Guide ##
1. Make a directory for each board you plan on creating, and copy every *file* and the /include directory in Glaukaba's root except for globalconfig.pl and spam.txt into each directory.
2. Make three directories (/src, /res, and /thumb) in each board's directory.
3. Download Glaukaba-JS and move glaukaba-main.js and glaukaba-extra.js into the /js directory in your site's root directory.
4. Make sure globalconfig.pl and spam.txt are in your site's root, one level above each board.
5. Edit globalconfig.pl each board's config.pl to your liking.
6. Set some reasonable permissions.
7. If you want to use FastCGI, enable it in globalconfig.pl, and use spawn-fcgi to get the processes for your board running.
8. Find the exact center of your living residence and occupy the space until forced to explain yourself to someone.
9. Run wakaba.pl in each board directory from your browser of choice and pray that it works.
	
## Example Installation ##
A semi-current version (usually a few commits behind) of this software is in use on https://www.glauchan.org and a live demo with a public moderator account will be available at http://onlinebargainshrimptoyourdoor.com at some point in the future.

## Issues ##
- Single board installations will require a bit of tinkering. Then again, so will any installation.
- This software is only in use on three sites (that I know of), so there's not much I can do to vouch for this software's usability.
- SQLite support isn't perfect.
- A current list of issues and fixes is available https://www.glauchan.org/meta/res/410

## Notable Features ##
This is a list of features I believe make Glaukaba stand out from other free imageboard scripts.
- A JSON API for easy application development and reduced bandwidth usage
- Searchable/Sortable Catalog
- reCAPTCHA support
- An extensive inline extension
- Mobile interface
- *Its not Kusaba X*
- Anything you've come to expect after being spoiled by 4chan's new-found interest in improving their software
- A complete list of features can be found at http://onlinebargainshrimptoyourdoor.com/2012/07/22/glaukaba/ and https://www.glauchan.org/meta/res/410

## Support ##
Free support is available via email on https://www.glauchan.org/meta/res/410 or by emailing me at mrmanager@glauchan.org.
