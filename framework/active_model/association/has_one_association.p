##############################################################################
#	
##############################################################################

@CLASS
HasOneAssociation

@OPTIONS
locals

@BASE
OneAssociation



##############################################################################
@GET_primary_key[]
	$result[$self.meta.primary_key]
#end @GET_primary_key[]



##############################################################################
@GET_foreign_key[]
	$result[$self.meta.foreign_key]
#end @GET_foreign_key[]



##############################################################################
@create[oAssociationMeta]
	^BASE:create[$oAssociationMeta]
#end @create[]






##############################################################################
@GET_is_loaded[]
	^rem{ *** если не загружена или изменился id связи *** }
	$result(
		$self._is_loaded &&
		(!$self._data || ($self.foreign_instance && $self.foreign_instance.[$self.primary_key] eq $self._data.[$self.foreign_key]))
	)
#end @GET_is_loaded[]



##############################################################################
@GET_foreign_key_present[]
	$result(def $self.foreign_instance.[$self.primary_key])
#end @GET_foreign_key_present[]



##############################################################################
#	^rem{ *** TODO: add hParams with $.include option *** }
@load[]
^Framework:oLogger.trace[am.as]{^inspect[$self]: load}{
	^if($self.foreign_instance && $self.foreign_key_present){
		^self._load[]
	}{
		^self.init[]
	}
}
#end @load[]



##############################################################################
@__relation[]
	$result[$self.meta.mapper_relation]
	^result.merge[
		$.condition[`$self.association_name`.`$self.foreign_key` = "$self.foreign_instance.[$self.primary_key]"]
	]
#end @__relation[]



##############################################################################
@_load[]
	^self.init[$self.RELATION]
#end @_load[]



##############################################################################
@build[hData;bNoListeners]
	$result[^self.mapper._init[]]

	^result.update[$hData]
	
	^self.init[$result]

	^rem{ *** TODO: think about this code *** }
	^self.instance.update_attribute[$self.foreign_key]($result.[$self.primary_key])
#end @build[]



##############################################################################
@update[oObject]
	^rem{ *** TODO: Обновление на сброс, когда oObject = void *** }
	^if(def $oObject){
		^if(
			!($oObject is $self.mapper.CLASS_NAME) &&
			!($oObject is $self.CLASS_NAME && $oObject.mapper is $self.mapper.CLASS_NAME) &&
			!($oObject is ActiveRelation && $oObject.MAPPER is $self.mapper.CLASS_NAME)
		){
			^throw[ErrorParameter;ErrorUpdateAssociation;Can't update $self.meta.class_name association by ${oObject.CLASS_NAME}.]
		}

		^self.before_save[]

		^self.init[$oObject]

		^rem{ *** TODO: think about this code *** }
		^self.instance.update_attribute[$foreign_key]($foreign_instance.[$self.primary_key])

		^self.after_save[]
	}
#end @update[]



##############################################################################
@update_dependent_associations[]
	^rem{ *** не трубует обновления, т.к. связь у той модели *** }
#end @update_dependent_associations[]