##############################################################################
#	
##############################################################################

@CLASS
ActiveImageInfo

@OPTIONS
locals

@BASE
ActiveFileInfo



##############################################################################
@create[path]
	^BASE:create[$path]
	$self._measure_loaded(false)
	$self._measure[]	
#end @create[]



##############################################################################
@html[hAttrs]
	$hOptions[
		$.src[$self.src]
		$.width[$self.width]
		$.height[$self.height]
	]
	^hOptions.add[$hAttrs]
	$result[^Controller:tag[img][$hOptions]]
#end @html[]



##############################################################################
@GET_measure[]
	^if(!$self._measure_loaded){
		$self._measure_loaded(true)
		^try{
			$self._measure[^ActiveImage:_action_info[$self.src]]
		}{
			$exception.handled(true)
		}
	}
	
	$result[$self._measure]
#end @GET_measure[]



##############################################################################
@GET_width[]
	$result[$self.measure.width]
#end @GET_width[]



##############################################################################
@GET_height[]
	$result[$self.measure.height]
#end @GET_height[]
