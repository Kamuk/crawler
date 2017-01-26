##############################################################################
#	
##############################################################################

@CLASS
BelongsToAssociation

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
	^rem{ *** при присвоении пустой ассоциации из include должна инициироваться *** }
	$result(
		$self._is_loaded
#		(!def $self.foreign_instance.[$self.foreign_key] && $self._data.is_new || $self.foreign_instance.[$self.foreign_key] eq $self._data.[$self.primary_key])
		&& (
			(def $self.foreign_instance.[$self.foreign_key] && !^self.foreign_instance.[$self.foreign_key].double(0))
			|| (def $self._data && $self.foreign_instance.[$self.foreign_key] eq $self._data.[$self.primary_key])
		)
	)
#end @GET_is_loaded[]



##############################################################################
@GET_foreign_key_present[]
	$result(def $self.foreign_instance.[$self.foreign_key])
#end @GET_foreign_key_present[]



##############################################################################
@load[]
	^if($self.foreign_instance && $self.foreign_key_present){
		^self._load[]
	}{
		^self.init[]
	}
#end @load[]



##############################################################################
@__relation[]
	$result[^self.meta.mapper_relation.where[`$self.association_name`.`$self.primary_key` = "$self.foreign_instance.[$self.foreign_key]"]]
#end @_relation[]



##############################################################################
@_load[]
	$relation[$self.meta.mapper_relation]
	
	^if($self.mapper.primary_key eq $self.primary_key){
		^self.init[^relation.find_by_id[$self.foreign_instance.[$self.foreign_key]]]		^rem{ *** FIX: используется для кеширования, но с relation перестало работать, т.к. Relation не умеет кешировать *** }
	}{
		^self.init[$self.RELATION]
	}
#end @_load[]



##############################################################################
@build[hData;bNoListeners]
#	^if($self.foreign_instance.is_new && !def $self.foreign_instance.[$self.primary_key]){
#		^throw_inspect[Can't build object by associaiton]
#	}

	$result[^self.mapper._init[]]												^rem{ *** не передаем никаких значений, т.к. они хранятся в foreign_instance *** }

	^result.update[$hData]
	
	^self.init[$result]
	
	^if(^bNoListeners.bool(true) && $result.is_new){
		^self.wait_save[$result]												^rem{ *** ожидаем получение id для обновления *** }
	}

	^rem{ *** TODO: think about this code *** }
	^self.foreign_instance.update_attribute[$self.foreign_key]($result.[$self.primary_key])
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
		
		^if($oObject.is_new){
			^self.wait_save[$oObject]											^rem{ *** ожидаем получение id для обновления *** }
		}

		^rem{ *** TODO: think about this code *** }
		^self.foreign_instance.update_attribute[$self.foreign_key]($oObject.[$self.primary_key])
		
		^self.after_save[]
	}
#end @update[]



##############################################################################
@wait_save[oObject]
	^BASE:wait_save[$oObject]
	^self.foreign_instance.wait_save[$self]
#end @wait_save[]



##############################################################################
@save_native[]
	^self.foreign_instance.update_attribute[$self.foreign_key]($self._data.[$self.primary_key])
	
#	^self.foreign_instance.remove_provider[$self]
#	^self.remove_listener[$self.foreign_instance]
	
	$result[^BASE:save_native[]]
#end @save_native[]



##############################################################################
@update_dependent_associations[]
	^rem{ *** принудительно получаем одиночные ассоциации,
		      т.к. они могут быть связаны через foreign_key,
		      но модель не получена *** }
	^rem{ *** $self.is_loaded &&  *** }
	^if($self.is_loaded && def $self.foreign_instance.[$self.foreign_key] && $self.object){
		^self.object.update_dependent_associations[]
	}
#end @update_dependent_associations[]
