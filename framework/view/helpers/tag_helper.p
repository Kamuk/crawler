##############################################################################
@content_tag[sName;uContent;hOptions;bEscape]
	$result[^tag[$sName;$hOptions;true;$bEscape]$uContent^tag[/$sName;](true)]
#end @content_tag[]



##############################################################################
@tag[sName;hOptions;bOpen;bEscape]
	$result[<$sName^tag_options[$hOptions;$bEscape]^if(^bOpen.bool(false)){>}{ />}]
#end @tag[]



##############################################################################
@tag_options[hOptions;bEscape][name;value]
	$hOptions[^hash::create[$hOptions]]
	$result[^hOptions.foreach[name;value]{ ${name}="^if(^bEscape.bool(true)){^untaint[html]{^tag_options_inspect[$value]}}{$value}"}]
#end @tag_options[]



##############################################################################
@tag_options_inspect[uValue]
	^switch[$uValue.CLASS_NAME]{
		^case[bool]{$result[^if($uValue){true}{false}]}
		^case[DEFAULT]{$result[$uValue]}
	}
#end @tag_options_inspect[]