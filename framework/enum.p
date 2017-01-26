##############################################################################
#	
##############################################################################

@CLASS
enum

@OPTIONS
locals



##############################################################################
@GET[type]
	^switch[$type]{
		^case[double;bool]{
			$result($self._by_name)
		}
		
		^case[DEFAULT;hash]{
			$result[$self._by_name]
		}
	}
#end @GET[]



##############################################################################
@GET_DEFAULT[uIndex]
	^if(^uIndex.int(-1) >= 0){
		$result[$self._by_code.[$uIndex]]
	}{
		$result[$self._by_name.[^uIndex.lower[]]]
	}
#end @GET_DEFAULT[]



##############################################################################
@create[hParams]
	$self._by_name[^hash::create[]]
	$self._by_code[^hash::create[]]
	
	^hParams.foreach[name;value]{
		$_name[^name.lower[]]
		$self._by_name.[$_name][$value]
		
		^switch[$value.CLASS_NAME]{
			^case[hash;array]{
				$self._by_code.[$value.id][$self._by_name.[$_name]]
			}
			^case[DEFAULT]{
				$self._by_code.[$value][$self._by_name.[$_name]]
			}
		}
	}
#end @create[]



##############################################################################
@GET_foreach[]
	$result[^reflection:method[$self._by_code;foreach]]
#end @GET_foreach[]



##############################################################################
@hash[uKey;hParam]
	$result[^array::create[$self._by_name]]
	$result[^result.hash[$uKey;$hParam]]
#end @hash[]



##############################################################################
@map[uKey;uValue]
	$result[^array::create[$self._by_name]]
	$result[^result.map[$uKey;$uValue]]
#end @map[]
