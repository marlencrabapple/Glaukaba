use encoding "shift-jis";

use constant S_HOME => 'ホーム';
use constant S_ADMIN => '管理用';
use constant S_RETURN => '掲示板に戻る';
use constant S_POSTING => 'レス送信モード';

use constant S_NAME => 'おなまえ';
use constant S_EMAIL => 'E-mail';
use constant S_SUBJECT => '題　　名';
use constant S_SUBMIT => '送信する';
use constant S_COMMENT => 'コメント';
use constant S_UPLOADFILE => '添付File';
use constant S_NOFILE => '画像なし';
use constant S_CAPTCHA => '検証';
use constant S_PARENT => 'スレ';
use constant S_DELPASS => '削除キー';
use constant S_DELEXPL => '(記事の削除用。英数字で8文字以内)';
use constant S_SPAMTRAP => 'Leave these fields empty (spam trap): ';

use constant S_THUMB => 'サムネイルを表示しています.クリックすると元のサイズを表示します.';
use constant S_HIDDEN => 'Image reply hidden, click name for full image.';
use constant S_NOTHUMB => 'No<br />thumbnail';
use constant S_PICNAME => '画像タイトル：';
use constant S_REPLY => '返信';
use constant S_OLD => 'このスレは古いので、もうすぐ消えます。';
use constant S_ABBR => 'レス%d件省略。全て読むには返信ボタンを押してください。';
use constant S_ABBRIMG => 'レス%d,%d件省略。全て読むには返信ボタンを押してください。';
use constant S_ABBRTEXT => '省略されました・・全てを読むには<a href="%s">ここ</a>を押してください';

use constant S_REPDEL => '【記事削除】';
use constant S_DELPICONLY => '画像だけ消す';
use constant S_DELKEY => '削除キー';
use constant S_DELETE => '削除';

use constant S_PREV => '前のページ';
use constant S_FIRSTPG => '最初のページ';
use constant S_NEXT => '次のページ';
use constant S_LASTPG => '最後のページ';

use constant S_WEEKDAYS => ('日','月','火','水','木','金','土');

use constant S_MANARET => '掲示板に戻る';
use constant S_MANAMODE => '管理モード';

use constant S_MANALOGIN => 'Manager Login';
use constant S_ADMINPASS => 'Admin password:';

use constant S_MANAPANEL => '記事削除';
use constant S_MANABANS => 'Bans';
use constant S_MANAPROXY => 'Proxy Panel';
use constant S_MANASPAM => 'スパム';
use constant S_MANASQLDUMP => 'SQL Dump';
use constant S_MANASQLINT=> 'SQL Interface';
use constant S_MANAPOST => '管理人投稿';
use constant S_MANAREBUILD => 'キャッシュの再構築';
use constant S_MANANUKE => 'Nuke board';
use constant S_MANALOGOUT => 'Log out';									# 
use constant S_MANASAVE => 'Remember me on this computer';				# Defines Label for the login cookie checbox
use constant S_MANASUB => ' 認証';

use constant S_NOTAGS => 'タグがつかえます';

use constant S_MPDELETEIP => 'Delete all';
use constant S_MPDELETE => '削除する';
use constant S_MPARCHIVE => 'Archive';
use constant S_MPRESET => 'リセット';
use constant S_MPONLYPIC => '画像だけ消す';
use constant S_MPDELETEALL => 'Del all';
use constant S_MPBAN => 'Ban';
use constant S_MPTABLE => '<th>Post No.</th><th>Time</th><th>Subject</th>'.
                          '<th>Name</th><th>Comment</th><th>IP</th>';
use constant S_IMGSPACEUSAGE => '【 画像データ合計 : <b>%d</b> KB 】';

use constant S_BANTABLE => '<th>Type</th><th>Value</th><th>Comment</th><th>Action</th>';
use constant S_BANIPLABEL => 'IP';
use constant S_BANMASKLABEL => 'Mask';
use constant S_BANCOMMENTLABEL => 'Comment';
use constant S_BANWORDLABEL => 'Word';
use constant S_BANIP => 'Ban IP';
use constant S_BANWORD => 'Ban word';
use constant S_BANWHITELIST => 'Whitelist';
use constant S_BANREMOVE => 'Remove';
use constant S_BANCOMMENT => 'Comment';
use constant S_BANTRUST => 'No captcha';
use constant S_BANTRUSTTRIP => 'Tripcode';

use constant S_PROXYTABLE => '<th>Type</th><th>IP</th><th>Expires</th><th>Date</th>'; # Explains names for Proxy Panel
use constant S_PROXYIPLABEL => 'IP';
use constant S_PROXYTIMELABEL => 'Seconds to live';
use constant S_PROXYREMOVEBLACK => 'Remove';
use constant S_PROXYWHITELIST => 'Whitelist';
use constant S_PROXYDISABLED => 'Proxy detection is currently disabled in configuration.';
use constant S_BADIP => 'Bad IP value';

use constant S_SPAMEXPL => 'This is the list of domain names Wakaba considers to be spam.<br />'.
                           'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&format=wakaba">here</a>, '.
                           'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.';
use constant S_SPAMSUBMIT => 'Save';
use constant S_SPAMCLEAR => 'Clear';
use constant S_SPAMRESET => 'Restore';

use constant S_SQLNUKE => 'Nuke password:';
use constant S_SQLEXECUTE => 'Execute';

use constant S_TOOBIG => 'アップロードに失敗しました<br />サイズが大きすぎます<br />'.MAX_KB.'Kバイトまで';
use constant S_TOOBIGORNONE => 'アップロードに失敗しました<br />画像サイズが大きすぎるか、<br />または画像がありません。';
use constant S_REPORTERR => '該当記事がみつかりません';
use constant S_UPFAIL => 'アップロードに失敗しました<br />サーバがサポートしていない可能性があります';
use constant S_NOREC => 'アップロードに失敗しました<br />画像ファイル以外は受け付けません';
use constant S_NOCAPTCHA => 'Error: No verification code on record - it probably timed out.';
use constant S_BADCAPTCHA => '不正な検証コードが入力されました';
use constant S_BADFORMAT => 'Error: File format not supported.';
use constant S_STRREF => '拒絶されました(str)';
use constant S_UNJUST => '不正な投稿をしないで下さい(post)';
use constant S_NOPIC => '画像がありません';
use constant S_NOTEXT => '何か書いて下さい';
use constant S_TOOLONG => '本文が長すぎますっ！';
use constant S_NOTALLOWED => '管理人以外は投稿できません';
use constant S_UNUSUAL => '異常です';
use constant S_BADHOST => '拒絶されました(host)';
use constant S_BADHOSTPROXY => 'Error: Proxy is banned for being open.';				# Returns error for banned proxy ($badip string)
use constant S_RENZOKU => '連続投稿はもうしばらく時間を置いてからお願い致します';
use constant S_RENZOKU2 => '画像連続投稿はもうしばらく時間を置いてからお願い致します';
use constant S_RENZOKU3 => '連続投稿はもうしばらく時間を置いてからお願い致します';
use constant S_PROXY => 'ＥＲＲＯＲ！　公開ＰＲＯＸＹ規制中！！(%d)';
use constant S_DUPE => 'アップロードに失敗しました<br />同じ画像があります (<a href="%s">link</a>)';
use constant S_DUPENAME => 'Error: A file with the same name already exists.';
use constant S_NOTHREADERR => 'スレッドがありません';
use constant S_BADDELPASS => '該当記事が見つからないかパスワードが間違っています';
use constant S_WRONGPASS => 'パスワードが違います';
use constant S_NOTWRITE => 'を書けません<br />';
use constant S_SPAM => 'スパムを投稿しないで下さい';					# Returns error when detecting spam

use constant S_SQLCONF => '接続失敗';
use constant S_SQLFAIL => 'sql失敗';

use constant S_REDIR => 'If the redirect didn\'t work, please choose one of the following mirrors:';    # Redir message for html in REDIR_DIR

#define(S_ANONAME, '名無し');
#define(S_ANOTEXT, '本文なし');
#define(S_ANOTITLE, '無題');
#use constant S_MPTITLE => '削除したい記事のチェックボックスにチェックを入れ、削除ボタンを押して下さい。';
#define(S_MDTABLE1, '<th>削除</th><th>記事No</th><th>投稿日</th><th>題名</th>');
#define(S_MDTABLE2, '<th>投稿者</th><th>コメント</th><th>ホスト名</th><th>添付<br />(Bytes)</th><th>md5</th>');

no encoding;
1;
