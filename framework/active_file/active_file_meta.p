##############################################################################
#	
##############################################################################

@CLASS
ActiveFileMeta

@OPTIONS
locals



##############################################################################
@create[hParams]
	$self._meta[^hash::create[$hParams]]
#end @create[]



##############################################################################
@GET_field[]
	$result[$self._meta.field]
#end @GET_field[]



##############################################################################
@GET_file_name[]
	$result[$self._meta.file_name]
#end @GET_file_name[]



##############################################################################
@GET_is_deletable[]
	$result[$self._meta.is_deletable]
#end @GET_is_deletable[]