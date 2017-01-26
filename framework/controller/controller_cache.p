##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
partial



##############################################################################
@cache_action[sActionName;hParams]
	$hParams[^hash::create[$hParams]]
	
	^if($self._cache_actions.[$sActionName]){
		^throw[cache_action;DoubleActionCache]
	}

	$self._cache_actions.[$sActionName][
		$.action[$sActionName]

		$.time[$hParams.time]
		$.suffix[$hParams.suffix]
		
		$.key_generator[$hParams.key_generator]
		
		^if(def $hParams.store){
			$.store[$hParams.store]
		}
	]
#end @cache_action[]
