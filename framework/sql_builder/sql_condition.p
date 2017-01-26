##############################################################################
#	
##############################################################################

@CLASS
SqlCondition



##############################################################################
@GET[]
	$result($_conditions)
#end @GET[]



##############################################################################
@create[bType]
	$_join_type(^bType.bool(true))
	$_conditions[^array::create[]]
#end @create[]



##############################################################################
@add[sField;sValue;sFunction][_condition]
	^if($sField is SqlCondition){
		^if($sField){
			^_conditions.add[$sField]
		}
	}{
		$sField[^sField.trim[]]

		^if($sValue is void){
			$_condition[$sField]
		}{
			$_condition[
				$.field[$sField]
				$.value[$sValue]
				$.function[$sFunction]
			]
		}

		^if(def $sField){
			^_conditions.add[$_condition]
		}
	}

	$result[]
#end @add[]



##############################################################################
@GET_to_string[][locals]
	$result[^_conditions.foreach[i;condition]{^prepare_condition[$condition]}[ ^if($_join_type){AND}{OR} ]]
#end @GET_to_string[]



##############################################################################
@GET_to_sql[]
	$result[$self.to_string]
#end @GET_to_sql[]



##############################################################################
@prepare_condition[uCondition]
	^switch[$uCondition.CLASS_NAME]{
		^case[SqlCondition]{
			$result[($uCondition.to_sql)]
#			^if($uCondition > 1 && !$_join_type){$result[($result)]}
		}
		
		^case[hash]{
			^switch[$uCondition.function]{
				^case[DEFAULT]{
					$result[$uCondition.field ^if(def $uCondition.function){$uCondition.function}{=} ^inspect[$uCondition.value]]
				}
			}
		}

		^case[DEFAULT]{
			$result[($uCondition)]
		}
	}
#end @prepare_condition[]