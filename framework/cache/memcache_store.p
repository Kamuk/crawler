##############################################################################
#	Хранилище кеша в memcache
##############################################################################

@CLASS
MemcacheStore

@OPTIONS
locals



##############################################################################
@GET[]
	$result(true)
#end @GET_DEFAULT[]



##############################################################################
@create[oMemcached;hParams]
	$self._path[$hParams.path]
	$self._timeout(30)
	$self._time[^hParams.time.int(24 * 60 * 60)]

	$self._memcached[$oMemcached]
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
	
#	$result[^self._memcached.mget]
	
	$key[^self.key[${self.path}/${sPath}]]
	$result[$self._memcached.[$key]]

	^if(!def $result){
		^while(!^self._memcached.add[${key}-lock][
			$.value[$self._timeout]
			$.expires($self._timeout)
		]){
			^for[i](1;$self._timeout * 5){ 
				^sleep(0.2)
				$result[$self._memcached.[$key]]
				^if(def $result){^break[]}
			}
		
			^if(def $result){ 
				^break[]
			}{
				^if(!$self._retry_on_timeout){ 
					^throw[$self.CLASS_NAME;Timeout while getting lock for key '$key']
				}
			}
		}
	}
	^if(!def $result){
		^try{
			$result[$jCode]
			$self._memcached.[$key][
				$.value[$result]
				$.expires($uTime)
			]
		}{
			
		}{
			^self._memcached.delete[${key}-lock]
		}
	}
#end @cache[]



##############################################################################
@expire[sPath]
	^self._memcached.delete[^key[${self.path}/${sPath}]]
#end @expire[]



##############################################################################
@clear[]
	^self._memcached.clear[]
#end @clear[]



##############################################################################
@key[sPath]
	$result[^math:md5[$sPath]]
#end @key[]
