##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
partial



##############################################################################
@before_filter[sMethodName;hParams]
	$hParams[^hash::create[$hParams]]

	^_before_filters.add[
		$.name[$sMethodName]
		$.method[$self.$sMethodName]

		$.only[$hParams.only]
		$.exclude[^if(def $hParams.exclude){$hParams.exclude}{$hParams.expect}]
	]
#end @before_filter[]



##############################################################################
@skip_before_filter[sMethodName;hParams]
	$hParams[^hash::create[$hParams]]

	$_skip_before_filters.[$sMethodName][
		$.only[$hParams.only]
		$.exclude[^if(def $hParams.exclude){$hParams.exclude}{$hParams.expect}]
	]
#end @skip_before_filter[]



##############################################################################
#@after_filter[sMethodName;hParams]
#	^rem{ *** TODO: add this *** }	
#end @after_filter[]