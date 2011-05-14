use constant S_HOME => 'Start';										# Forwards to home page
use constant S_ADMIN => 'Management';									# Forwards to Management Panel
use constant S_RETURN => 'Zurueck';									# Returns to image board
use constant S_POSTING => 'Beitragsmodus: Antworten';					# Prints message in red bar atop the reply screen

use constant S_NAME => 'Name';										# Describes name field
use constant S_EMAIL => 'E-mail';									# Describes e-mail field
use constant S_SUBJECT => 'Titel';								# Describes subject field
use constant S_SUBMIT => 'Abschicken';									# Describes submit button
use constant S_COMMENT => 'Kommentar';								# Describes comment field
use constant S_UPLOADFILE => 'Datei';								# Describes file field
use constant S_NOFILE => 'Keine Datei';									# Describes file/no file checkbox
use constant S_CAPTCHA => 'Verifikation';							# Describes captcha field
use constant S_PARENT => 'Parent';									# Describes parent field on admin post page
use constant S_DELPASS => 'Passwort';								# Describes password field
use constant S_DELEXPL => '(Passwort benoetigt zum Loeschen)';		# Prints explanation for password box (to the right)
use constant S_SPAMTRAP => 'Leave these fields empty (spam trap): ';

use constant S_THUMB => 'Thumbnail angezeigt, Bild anklicken fuer Vollgroesse.';	# Prints instructions for viewing real source
use constant S_HIDDEN => 'Antwort mit Bild versteckt, Namen anklicken fuer das ganze Bild.';	# Prints instructions for viewing hidden image reply
use constant S_NOTHUMB => 'Kein<br />thumbnail';								# Printed when there's no thumbnail
use constant S_PICNAME => 'Datei: ';											# Prints text before upload name/link
use constant S_REPLY => 'Antwort';											# Prints text for reply link
use constant S_OLD => 'Fuers Loeschen markiert (alt).';							# Prints text to be displayed before post is marked for deletion, see: retention
use constant S_ABBR => '%d Beitraege ausgespart. Zum Anzeigen auf Antwort klicken.';			# Prints text to be shown when replies are hidden
use constant S_ABBRIMG => '%d Beitraege und %d Bilder ausgespart. Zum Anzeigen auf Antwort klicken.';						# Prints text to be shown when replies and images are hidden
use constant S_ABBRTEXT => 'Kommentar zu lang. <a href="%s">Hier</a> klicken fuer den gesamten Text.';

use constant S_REPDEL => 'Beitrag loeschen ';							# Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => 'Nur die Datei';							# Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Passwort ';								# Prints text next to password field for deletion (left)
use constant S_DELETE => 'Loeschen';									# Defines deletion button's name

use constant S_PREV => 'Zurueck';									# Defines previous button
use constant S_FIRSTPG => 'Zurueck';								# Defines previous button
use constant S_NEXT => 'Vorwaerts';										# Defines next button
use constant S_LASTPG => 'Vorwaerts';									# Defines next button

use constant S_WEEKDAYS => ('Son','Mon','Die','Mit','Don','Fre','Sam');	# Defines abbreviated weekday names.

use constant S_MANARET => 'Zurueck';										# Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
use constant S_MANAMODE => 'Manager Modus';								# Prints heading on top of Manager page

use constant S_MANALOGIN => 'Manager Login';								# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_ADMINPASS => 'Admin Passwort:';							# Prints login prompt

use constant S_MANAPANEL => 'Management Panel';								# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_MANABANS => 'Banne';										# Defines Bans Panel button
use constant S_MANAPROXY => 'Proxy Panel';
use constant S_MANASPAM => 'Spam';										# Defines Spam Panel button
use constant S_MANASQLDUMP => 'SQL Dump';									# Defines SQL dump button
use constant S_MANASQLINT => 'SQL Interface';								# Defines SQL interface button
use constant S_MANAPOST => 'Manager Beitrag';								# Defines Manager Post radio button--allows the user to post using HTML code in the comment box
use constant S_MANAREBUILD => 'Caches neu erstellen';							# 
use constant S_MANANUKE => 'Brett in die Luft jagen';								# 
use constant S_MANALOGOUT => 'Log out';									# 
use constant S_MANASAVE => 'Remember me on this computer';				# Defines Label for the login cookie checbox
use constant S_MANASUB => 'Zackzack';											# Defines name for submit button in Manager Mode

use constant S_NOTAGS => 'HTML-tags erlaubt. Es findet keine Formatierung statt, fuer Absaetze und Zeilenumbrueche muss HTML verwendet werden.'; # Prints message on Management Board

use constant S_MPDELETEIP => 'Alles loeschen';
use constant S_MPDELETE => 'Loeschen';									# Defines for deletion button in Management Panel
use constant S_MPARCHIVE => 'Archive';
use constant S_MPRESET => 'Reset';										# Defines name for field reset button in Management Panel
use constant S_MPONLYPIC => 'Nur die Datei';								# Sets whether or not to delete only file, or entire post/thread
use constant S_MPDELETEALL => 'Alles&nbsp;loeschen';							# 
use constant S_MPBAN => 'Bann';											# Sets whether or not to delete only file, or entire post/thread
use constant S_MPTABLE => '<th>Beitrag Nr.</th><th>Zeit</th><th>Titel</th>'.
                          '<th>Name</th><th>Kommentar</th><th>IP</th>';	# Explains names for Management Panel
use constant S_IMGSPACEUSAGE => '[ Benutzter Platz: %d KB ]';				# Prints space used KB by the board under Management Panel

use constant S_BANTABLE => '<th>Typ</th><th>Wert</th><th>Kommentar</th><th>Aktion</th>'; # Explains names for Ban Panel
use constant S_BANIPLABEL => 'IP';
use constant S_BANMASKLABEL => 'Maske';
use constant S_BANCOMMENTLABEL => 'Kommentar';
use constant S_BANWORDLABEL => 'Wort';
use constant S_BANIP => 'IP bannen';
use constant S_BANWORD => 'Wort bannen';
use constant S_BANWHITELIST => 'Whitelist';
use constant S_BANREMOVE => 'Entfernen';
use constant S_BANCOMMENT => 'Kommentar';
use constant S_BANTRUST => 'No captcha';
use constant S_BANTRUSTTRIP => 'Tripcode';

use constant S_PROXYTABLE => '<th>Type</th><th>IP</th><th>Expires</th><th>Date</th>'; # Explains names for Proxy Panel
use constant S_PROXYIPLABEL => 'IP';
use constant S_PROXYTIMELABEL => 'Seconds to live';
use constant S_PROXYREMOVEBLACK => 'Remove';
use constant S_PROXYWHITELIST => 'Whitelist';
use constant S_PROXYDISABLED => 'Proxy detection is currently disabled in configuration.';
use constant S_BADIP => 'Bad IP value';

use constant S_SPAMEXPL => 'Dies ist die Liste von Domainnamen, die Wakaba als Spam betrachtet.<br />'.
                           'Eine aktuelle Version ist <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&format=wakaba">here</a> zu finden, '.
                           'die <code>spam.txt</code>-datei kann aber auch direkt <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a> heruntergeladen werden.';
use constant S_SPAMSUBMIT => 'Speichern';
use constant S_SPAMCLEAR => 'Loeschen';
use constant S_SPAMRESET => 'Wiederherstellen';

use constant S_SQLNUKE => 'Passwort zum in die Luft jagen:';
use constant S_SQLEXECUTE => 'Ausfuehren';

use constant S_TOOBIG => 'Dieses Bild ist zu gross, um hochgeladen zu werden!';
use constant S_TOOBIGORNONE => 'Entweder ist das Bild zu gross oder existiert nicht. Tja.';
use constant S_REPORTERR => 'Fehler: Kann Antwort nicht finden.';					# Returns error when a reply (res) cannot be found
use constant S_UPFAIL => 'Fehler: Upload fehlgeschlagen.';							# Returns error for failed upload (reason: unknown?)
use constant S_NOREC => 'Fehler: Kann Aufzeichnung nicht finden.';						# Returns error when record cannot be found
use constant S_NOCAPTCHA => 'Fehler: Kein Verifikationscode aufgezeichnet - wahrscheinlich zu spaet angekommen.';	# Returns error when there's no captcha in the database for this IP/key
use constant S_BADCAPTCHA => 'Fehler: Falscher Verifikationscode.';		# Returns error when the captcha is wrong
use constant S_BADFORMAT => 'Fehler: Dateiformat wird nicht unterstuetzt.';			# Returns error when the file is not in a supported format.
use constant S_STRREF => 'Fehler: String abgelehnt.';							# Returns error when a string is refused
use constant S_UNJUST => 'Fehler: Ungueltiger POST.';								# Returns error on an unjust POST - prevents floodbots or ways not using POST method?
use constant S_NOPIC => 'Fehler: Keine Datei ausgewaehlt.';							# Returns error for no file selected and override unchecked
use constant S_NOTEXT => 'Fehler: Kein Text eingegeben.';							# Returns error for no text entered in to subject/comment
use constant S_TOOLONG => 'Fehler: Feld ist zu lang.';							# Returns error for too many characters in a given field
use constant S_NOTALLOWED => 'Fehler: Beitraege sind nicht erlaubt.';					# Returns error for non-allowed post types
use constant S_UNUSUAL => 'Fehler: Abnormale Antwort.';							# Returns error for abnormal reply? (this is a mystery!)
use constant S_BADHOST => 'Fehler: Host ist gebannt.';							# Returns error for banned host ($badip string)
use constant S_BADHOSTPROXY => 'Error: Proxy is banned for being open.';				# Returns error for banned proxy ($badip string)
use constant S_RENZOKU => 'Fehler: Flut entdeckt, Beitrag abgelehnt.';			# Returns error for $sec/post spam filter
use constant S_RENZOKU2 => 'Fehler: Flut entdeckt, Datei abgelehnt.';		# Returns error for $sec/upload spam filter
use constant S_RENZOKU3 => 'Fehler: Flut entdeckt.';						# Returns error for $sec/similar posts spam filter.
use constant S_PROXY => 'Fehler: Proxy entdeckt auf Port %d.';				# Returns error for proxy detection.
use constant S_DUPE => 'Fehler: Die Datei wurde bereits <a href="%s">hier</a> hochgeladen.';	# Returns error when an md5 checksum already exists.
use constant S_DUPENAME => 'Fehler: Eine Datei mit demselben Namen existiert bereits.';	# Returns error when an filename already exists.
use constant S_NOTHREADERR => 'Fehler: Angegebener Thread existiert nicht.';	# Returns error when a non-existant thread is accessed
use constant S_BADDELPASS => 'Fehler: Passwort stimmt nicht.';					# Returns error for wrong password (when user tries to delete file)
use constant S_WRONGPASS => 'Fehler: Management Passwort stimmt nicht.';		# Returns error for wrong password (when trying to access Manager modes)
use constant S_VIRUS => 'Fehler: Moeglicherweise mit einem Virus infizierte Datei.';				# Returns error for malformed files suspected of being virus-infected.
use constant S_NOTWRITE => 'Fehler: Kann nicht in das Verzeichnis schreiben.';				# Returns error when the script cannot write to the directory, the chmod (777) is wrong
use constant S_SPAM => 'Spammer sind hier nicht willkommen.';					# Returns error when detecting spam

use constant S_SQLCONF => 'SQL Verbindungsfehler';							# Database connection failure
use constant S_SQLFAIL => 'Schwerwiegendes SQL Problem!';							# SQL Failure

use constant S_REDIR => 'If the redirect didn\'t work, please choose one of the following mirrors:';    # Redir message for html in REDIR_DIR

1;

