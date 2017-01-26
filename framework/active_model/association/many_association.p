##############################################################################
#	TODO:
#	 - присвоение нового значения (массив)
#	 - очистка
#	 - удаление элемента
#	 - добавление элемента
##############################################################################

@CLASS
ManyAssociation

@OPTIONS
locals

@BASE
Association



##############################################################################
@GET_DEFAULT[sName]
^Framework:oLogger.trace[am.as.GET]{^inspect[$self] : $sName}{
	$scope[$self.mapper.SCOPES.[$sName]]
		
	^if(def $scope){
		$result[$self.RELATION]
		$result[^result.clone[$scope]]											^rem{ *** если в MAPPER объявлен такой scope то это обращение к нему *** }
		$result[$result.clone]
	}{
		$result[$self.list.$sName]
	}
}
#end @GET_DEFAULT[]



##############################################################################
@GET_list[]
^Framework:oLogger.trace[am.as]{^inspect[$self]: GET_list}{
	$result[$self.data]
}
#end @GET_list[]






##############################################################################
@create[oAssociationMeta]
	^BASE:create[$oAssociationMeta]
#end @create[]



##############################################################################
@_init[hData]
^Framework:oLogger.trace[am.as]{^inspect[$self]: _init ^inspect[$hData]}{
	^if(def $hData){
		$self._data[$hData]
	}{
		$self._data[^self.meta.mapper_relation.none[]]
	}
}
#end @_init[]



##############################################################################
@clear[]
	^if($self.list){
		^self.before_save[]
		
		^self._clear[]
		
		^self.after_save[]
	}

	^rem{ *** reinitialize array *** }
	^self._init[]
#end @clear[]



##############################################################################
@_clear[][model]
	^rem{ *** destroy all associated models *** }
	^foreach[$self.list;model]{
		^if(!^model.destroy[]){}
	}
#end @_clear[]



##############################################################################
@touch_association[]
	^if($oLogger){
		^oLogger.trace{$self.association_mapper.CLASS_NAME: call touch ${self.mapper.CLASS_NAME}:${self.touch_method}}
	}

	$method[$self.touch_method]
	^foreach[^hash::create[$self.list];model]{
		^model.[$method][]
	}
#end @touch_association[]



##############################################################################
@GET_is_valid_native[][model]
	$result(true)
	
	^foreach[^hash::create[$self._listeners];model]{
		^if($model._go_save && !$model.is_valid){
			$result(false)
		}
	}
#end @GET_is_valid_native[]



##############################################################################
@GET_errors_native[][model]
	$result[^ModelErrors::create[]]
	^foreach[^hash::create[$self._listeners];model]{
		^if(!$model._go_save){^continue[]}
		^result.join[$model.errors_native][$self.association_name][$self.association_name]
	}
#end @GET_errors_native[]
