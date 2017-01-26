##############################################################################
#	
##############################################################################

@CLASS
ActiveImageMeta

@OPTIONS
locals


@BASE
ActiveFileMeta



##############################################################################
@create[hParams]
	^BASE:create[$hParams]
	
	$self._images[^hash::create[$hParams]]
	^self._images.delete[is_deletable]
#end @create[]



##############################################################################
@GET_DEFAULT[name][result]
	^if($self._images.[$name]){
		$self._images.[$name]
	}
#end @GET_DEFAULT[]



##############################################################################
@GET_image[]
	$result[$self._images]
#end @GET_image[]



##############################################################################
@foreach[sVarName;sVarMeta;jCode]
	$result[^self._images.foreach[name;meta]{$caller.[$sVarName][$name]$caller.[$sVarMeta][$meta]$jCode}]
#end @foreach[]
