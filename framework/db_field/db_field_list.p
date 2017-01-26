##############################################################################
#	
##############################################################################

@CLASS
DBFieldList

@OPTIONS
partial



##############################################################################
@GET_DEFAULT[sName][result]
	^if(^sName.pos[_]){
		$self._fields.[$self._i].[$sName]
	}
#end @GET_DEFAULT[]






##############################################################################
@create[hData]
	$_count(0)
	$_fields[^hash::create[]]

	^if(def $hData){
		^self.add[$hData]
	}
#end @create[]



##############################################################################
@add[uData][i;sName;hData]
	^switch[$uData.CLASS_NAME]{
		^case[hash]{
			^for[i](0;^uData._count[] - 1){
				$_fields.[$_count][^DBField::create[
					$uData.[$i]
					^if(!def $uData.[$i].attribute_name){
						$.attribute_name[$uData.[$i].name]
					}
				]]
				^_count.inc[]
			}
		}

		^case[DBField]{
			$_fields.[$_count][$uData]
			^_count.inc[]
		}
		
		^rem{ *** FIX: должно добавляться, а не заменяться *** }
		^case[DBFieldList]{
			$_fields[$uData._fields]
			$_count($uData._count)
		}

		^case[DEFAULT]{
			^throw[parser.runtime;$uData.CLASS_NAME;Argument must by "DBField" or hash]
		}
	}
#end @add[]



##############################################################################
@menu[jCode;jSeparator]
	$result[^for[_i](0;$self._count - 1){$jCode}{$jSeparator}]
	$_i[$NULL]
#end @menu[]