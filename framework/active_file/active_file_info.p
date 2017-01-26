##############################################################################
#	
##############################################################################

@CLASS
ActiveFileInfo

@OPTIONS
locals



##############################################################################
@create[path;name]
	$self._src[$path]
	$self._name[$name]
	
	$self._exist_loaded(false)
	$self._exist(false)
	
	$self._stat_loaded(false)
	$self._stat[]
	
	$self._file_loaded(false)
	$self._file[]
#end @create[]



##############################################################################
@GET[sMode] 
	^switch[$sMode]{ 
		^case[bool;expression]{$result($self.exist)}
		^case[def]{$result(true)}
		^case[file]{$result[$self.file]}
		^case[DEFAULT]{^throw_inspect[ActiveFileInfo: unsupported mode '$sMode']}
	}
#end @GET[]



##############################################################################
@GET_DEFAULT[sName]
	^throw_inspect[ActiveFileInfo: no attribute for '$sName']
#end @GET_DEFAULT[]



##############################################################################
@GET_src[]
	$result[$self._src]
#end @GET_src[]



##############################################################################
@GET_exist[]
	^if(!$self._exist_loaded){
		$self._exist_loaded(true)		
		$self._exist(-f $self.src)
	}

	$result[$self._exist]
#end @GET_exist[]



##############################################################################
@GET_stat[]
	^if(!$self._stat_loaded){
		$self._stat_loaded(true)
		^try{
			$self._stat[^file::stat[$self.src]]
		}{
			$exception.handled(true)
		}
	}

	$result[$self._stat]
#end @GET_stat[]



##############################################################################
@GET_file[]
	^if(!$self._file_loaded){
		$self._file_loaded(true)
		^try{
			$self._file[^file::load[binary;$self.src][$self.name]]
		}{
			$exception.handled(true)
		}
	}

	$result[$self._file]
#end @GET_file[]



##############################################################################
@GET_name[]
	$result[$self._name]
#end @GET_name[]



##############################################################################
@GET_size[]
	$result[$self.stat.size]
#end @GET_size[]



##############################################################################
@GET_cdate[]
	$result[$self.stat.cdate]
#end @GET_cdate[]



##############################################################################
@GET_mdate[]
	$result[$self.stat.mdate]
#end @GET_mdate[]



##############################################################################
@GET_adate[]
	$result[$self.stat.adate]
#end @GET_adate[]
