use constant S_OEKPAINT => 'Painter: ';									# Describes the oekaki painter to use
use constant S_OEKSOURCE => 'Source: ';							# Describes the source selector
use constant S_OEKNEW => 'New image';							# Describes the new image option
use constant S_OEKMODIFY => 'Modify No.%d';						# Describes an option to modify an image
use constant S_OEKX => 'Width: ';									# Describes x dimension for oekaki
use constant S_OEKY => 'Height: ';									# Describes y dimension for oekaki
use constant S_OEKSUBMIT => 'Paint!';									# Oekaki button used for submit
use constant S_OEKIMGREPLY => 'Reply';

use constant S_OEKIMGREPLY => 'Reply';
use constant S_OEKREPEXPL => 'Picture will be posted as a reply to thread <a href="%s">%s</a>.';

use constant S_OEKTOOBIG => 'The requested dimensions are too large.';
use constant S_OEKTOOSMALL => 'The requested dimensions are too small.';
use constant S_OEKUNKNOWN => 'Unknown oekaki painter requested.';
use constant S_HAXORING => 'Stop hax0ring the Gibson!';

use constant S_OEKPAINTERS => [
	{ painter=>"shi_norm", name=>"Shi Normal" },
	{ painter=>"shi_pro", name=>"Shi Pro" },
	{ painter=>"shi_norm_selfy", name=>"Shi Normal+Selfy" },
	{ painter=>"shi_pro_selfy", name=>"Shi Pro+Selfy" },
];

1;
