##############################################################################
#	
##############################################################################

@CLASS
OneAssociation

@OPTIONS
locals

@BASE
Association



##############################################################################
@GET_DEFAULT[sName][result]
	$self.data.[$sName]
#end @GET_DEFAULT[]



##############################################################################
@SET_DEFAULT[sName;sValue]
	^if(def $self.data){
		$self.data.[$sName][$sValue]
	}
#end @SET_DEFAULT[]



##############################################################################
@GET_instance[][result]
	$self.data
#end @GET_instance[]



##############################################################################
@GET_object[][result]
	$self.data
#end @GET_object[]







##############################################################################
@create[oAssociationMeta]
	^BASE:create[$oAssociationMeta]
#end @create[]



##############################################################################
@_init[hData]
	^rem{ *** initialize only if specify primary_key for object *** }
	^rem{ *** this need because if loading in JOIN mode data can set to void *** }
	^if(def $hData){
		$self._data[$hData]
	}{
		$self._data[^self.meta.mapper_relation.none[]]
	}
#end @_init[]



##############################################################################
@_destroy_dependent_delete[]
	^if($self.instance && !^self.instance.delete[]){}
#end @_destroy_dependent_delete[]



##############################################################################
@_destroy_dependent_destroy[]
	^if($self.instance && !^self.instance.destroy[]){}
#end @_destroy_dependent_destroy[]



##############################################################################
@touch_association[]
	^if($oLogger){
		^oLogger.trace{$self.association_mapper.CLASS_NAME: call touch by ${self.mapper.CLASS_NAME}:${self.touch_method}}
	}
	$method[$self.touch_method]
	^if($self.object){
		^self.object.[$method][]
	}
#end @touch_association[]



##############################################################################
@GET_is_valid_native[]
	^foreach[^hash::create[$self._listeners];model]{
		^if($model._go_save && !$model.is_valid){
			$result(false)
		}
	}
#end @GET_is_valid_native[]



##############################################################################
@GET_errors_native[]
	$result[^ModelErrors::create[]]
	^foreach[^hash::create[$self._listeners];model]{
		^if(!$model._go_save){^continue[]}
		^result.join[$model.errors_native][$self.association_name][$self.association_name]
	}
#end @GET_errors_native[]
