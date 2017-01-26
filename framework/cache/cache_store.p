##############################################################################
#	
##############################################################################

@CLASS
CacheStore

@OPTIONS
locals



##############################################################################
@GET[]
	$result(true)
#end @GET_DEFAULT[]



##############################################################################
@create[hParams]
	$self._path[$hParams.path]
	$self._time[^hParams.time.int(24 * 60 * 60)]
#end @create[]



##############################################################################
@GET_path[]
	$result[$self._path]
#end @GET_path[]



##############################################################################
@SET_path[sValue]
	$self._path[$sValue]
#end @SET_path[]



##############################################################################
@cache[sPath;uTime;jCode]
	^if(!def $uTime){
		$uTime[$self._time]
	}
	
	^if($uTime is date){
		$result[^MAIN:cache[${self.path}/${sPath};$uTime]{$jCode}]
	}{
		$result[^MAIN:cache[${self.path}/${sPath}]($uTime){$jCode}]
	}
#end @cache[]



##############################################################################
#	Метод изменяет время кеширования
##############################################################################
@time[uTime]
	^if($uTime is date){
		^MAIN:cache[$uTime]
	}{
		^MAIN:cache($uTime)
	}
#end @time[]



##############################################################################
@write[sName;jCode]
	
#end @write[]



##############################################################################
@expire[sPath]
	^try{
		^file:delete[${self.path}/${sPath}]
	}{
		$exception.handled($exception.type eq "file.missing")
	}
#end @expire[]