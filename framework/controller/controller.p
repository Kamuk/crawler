##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
locals
partial

@BASE
Application



##############################################################################
@auto[]
	^rem{ *** include default helpers *** }
	^include[$CONFIG:sFrameworkPath/view/helpers/text_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/num_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/url_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/redirect_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/tag_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/formtag_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/form_helper.p]
	^include[$CONFIG:sFrameworkPath/view/helpers/date_helper.p]
	
	^rem{ *** create params hash *** }	
	$self._params[^hash::create[]]
#end @auto[]



##############################################################################
@create[]
	^BASE:create[]
	
	$self.parameter_filter[]
#end @create[]



##############################################################################
@process[hParams]
	^assign_shortcuts[$hParams]
	$result[]
#end @process[]



##############################################################################
@assign_shortcuts[hParams]
	$self.params[$hParams]
#end @assign_shortcuts[]
