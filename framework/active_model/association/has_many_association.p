##############################################################################
#
##############################################################################

@CLASS
HasManyAssociation

@OPTIONS
locals

@BASE
ManyAssociation



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
	$result($self._is_loaded)
#end @GET_is_loaded[]



##############################################################################
@GET_foreign_key_present[]
	^rem{ *** !$self.foreign_instance.is_new или $self.foreign_instance.[$self.primary_key] ??? *** }
	$result(def $self.foreign_instance.[$self.primary_key])
#end @GET_foreign_key_present[]



##############################################################################
@load[]
^Framework:oLogger.trace[am.as]{$self.CLASS_NAME: load}{
	^if($self.foreign_instance && $self.foreign_key_present){
		^self._load[]
	}{
		^self.init[]															^rem{ *** инициализация пустой *** }
	}
}
#end @load[]



##############################################################################
@__relation[]
	$result[$self.meta.mapper_relation]
	^result.merge[
		$.condition[`$self.association_name`.`^if(def $self.association_mapper.FIELDS.[$self.foreign_key]){$self.association_mapper.FIELDS.[$self.foreign_key].name}{$self.foreign_key}` = "$self.foreign_instance.[$self.primary_key]"]
	]
#end @__relation[]



##############################################################################
@_load[]
	^self.init[$self.RELATION]
#end @_load[]



##############################################################################
@_destroy_dependent_delete[]
	^if($self.list){
		^foreach[$self.list;model]{
			^if(!^model.delete[]){}
		}

		^self._init[]
	}
#end @_destroy_dependent_delete[]



##############################################################################
@_destroy_dependent_destroy[]
	^self.clear[]
#end @_destroy_dependent_destroy[]



##############################################################################
@_destroy_dependent_nulled[][condition]
	$condition[^SqlCondition::create[]]
	^condition.add[`$self.association_name`.`^if(def $self.association_mapper.FIELDS.[$self.foreign_key]){$self.association_mapper.FIELDS.[$self.foreign_key].name}{$self.foreign_key}` = "$self.foreign_instance.[$self.primary_key]"]
	^condition.add[$self.condition]

	^rem{ *** обновляем значения  *** }
	^if(!^mapper.update_all[
		$.[_$foreign_key][^mapper.FIELDS.[$foreign_key].value[]]
	][
		$.alias[$association_name]
		$.condition[$condition]
	]){}

	^self._init[]
#end @_destroy_dependent_nulled[]



##############################################################################
@build[hData;bNoListeners]
#	^if($self.foreign_instance.is_new && !def $self.foreign_instance.[$self.primary_key]){
#		^throw_inspect[Can't build object by associaiton]
#	}
		
	$result[^self.mapper._init[
		$.[$self.foreign_key][$self.foreign_instance.[$self.primary_key]]
	]]
	
	^result.update[$hData]
	
	^if(def $self.meta.inverse_of_name && def $result.CLASS.ASSOCIATIONS.[$self.meta.inverse_of_name]){
		^result.associations.[$self.meta.inverse_of_name].init[$self.foreign_instance]			^rem{ *** инициируем обратную ассоциацию через inverse_of *** }
	}
	
	^if(^bNoListeners.bool(true) && $self.foreign_instance.is_new){
		^self.wait_save[$result]												^rem{ *** ожидаем получение id для обновления *** }
	}
#end @build[]



##############################################################################
@update[uModels]
	^self.before_save[]

	^switch[$uModels.CLASS_NAME]{
		^case[array;ActiveRelation]{
			^rem{ *** TODO: удаляем лишние записи в зависимости от связи nulled|destroy|delete *** }
			$models_for_delete[]

			^throw_inspect[УДАЛИТЬ лишние записи]

			^rem{ *** вставляем новые записи *** }
			$r[^self.mapper.insert_all[$uModels][
				$.[_$self.foreign_key][$self.foreign_instance.[$self.primary_key]]
			]]

			^self.init[$uModels]
		}

		^case[DEFAULT]{
			^throw[parser.runtime;update;can't update has_many association by $uModels.CLASS_NAME]
		}
	}

	^self.after_save[]
#end @update[]



##############################################################################
@wait_save[oObject]
	^BASE:wait_save[$self.foreign_instance]
	^oObject.wait_save[$self]
#end @wait_save[]



##############################################################################
@save_native[]
	^foreach[^hash::create[$self._listeners];model]{
		^model.update_attribute[$self.foreign_key]($self.foreign_instance.[$self.primary_key])
	}

	$result[^BASE:save_native[]]
#end @save_native[]



##############################################################################
@update_dependent_associations[]
	^rem{ *** не трубет обновления, т.к. связь у той модели *** }
#end @update_dependent_associations[]
