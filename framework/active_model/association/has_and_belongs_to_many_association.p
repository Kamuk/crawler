##############################################################################
#	
##############################################################################

@CLASS
HasAndBelongsToManyAssociation

@OPTIONS
locals

@BASE
ManyAssociation



#	^rem{ *** FIX: во всех запросах делать объединение через промежуточную таблицу! и подключать обе таблицы *** }
#	^rem{ *** т.к. в запросе могут быть параметры фильтрации по данным *** }


##############################################################################
@GET_association_foreign_key[]
	$result[$self.meta.association_foreign_key]
#end @GET_association_foreign_key[]



##############################################################################
@GET_association_join_foreign_key[]
	$result[$self.meta.association_join_foreign_key]
#end @GET_association_join_foreign_key[]



##############################################################################
@GET_foreign_key[]
	$result[$self.meta.foreign_key]
#end @GET_foreign_key[]



##############################################################################
@GET_join_foreign_key[]
	$result[$self.meta.join_foreign_key]
#end @GET_join_foreign_key[]



##############################################################################
@GET_join_table[]
	$result[$self.meta.join_table]
#end @GET_join_table[]



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
	^rem{ *** !$self.foreign_instance.is_new *** }
	$result(def $self.foreign_instance.[$self.association_foreign_key])
#end @GET_foreign_key_present[]



##############################################################################
@load[]
	^if($self.foreign_instance && $self.foreign_key_present){
		^self._load[]
	}{
		^self.init[^array::create[]]
	}
#end @load[]



##############################################################################
@__relation[]
	$result[$self.meta.mapper_relation]
	^result.merge[
#		$.alias[$self.association_name]
#		$.join_table[
#			$.[$self.join_table][
#				$.condition[`$self.association_name`.`$self.foreign_key` = `$self.join_table`.`$self.join_foreign_key`]
#			]
#		]
		$.condition[`$self.join_table`.`$self.association_join_foreign_key` = "$self.foreign_instance.[$self.association_foreign_key]"]
	]
#end @__relation[]



##############################################################################
@_load[]
	^self.init[$self.RELATION]
#end @_load[]



##############################################################################
#	Delete all link on association in join table
##############################################################################
@_clear[][model]
	^Framework:oSql.void{
		DELETE FROM
			`$self.join_table`
		WHERE
			`$self.join_table`.`$self.association_join_foreign_key` = $self.foreign_instance.[$self.association_foreign_key] AND
			`$self.join_table`.`$self.join_foreign_key` IN (^foreach[$self.list;model]{"$model.[$self.foreign_key]"}[,])
	}
#end @_clear[]



##############################################################################
@_destroy_dependent_delete[]
	^if($self.list){
		^foreach[$self.list;model]{
			^if(!^model.delete[]){}
		}
		^self.clear[]
	}
#end @_destroy_dependent_delete[]



##############################################################################
@_destroy_dependent_destroy[]
	^if($self.list){
		^foreach[$self.list;model]{
			^if(!^model.destroy[]){}
		}
		^self.clear[]
	}
#end @_destroy_dependent_destroy[]



##############################################################################
@_destroy_dependent_nulled[]
	^_destroy_dependent_default[]
#end @_destroy_dependent_nulled[]



##############################################################################
@_destroy_dependent_default[]
	^self.clear[]
#end @_destroy_dependent_default[]



##############################################################################
@add[oModel]
	^if($self.foreign_instance.is_new){
		^throw_inspect[$self.foreign_instance]
		^self.wait_save[$self.foreign_instance]
	}

	^if($oModel is array){
		^rem{ *** TODO: add check for mapper CLASS_NAME *** }
		
		^self.before_save[]

		^rem{ *** insert association record in join_table *** }
		^Framework:oSql.void{
			INSERT IGNORE INTO
				`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
			VALUES
				^foreach[$oModel;model]{("$self.foreign_instance.[$self.association_foreign_key]", "$model.[$self.foreign_key]")}[, ]
		}
	}{
		^if(
			!($oModel is $self.mapper.CLASS_NAME) &&
			!($oModel is OneAssociation && $oModel.mapper is $self.mapper.CLASS_NAME) &&
			!($oModel is ActiveRelation && $oModel.MAPPER is $self.mapper.CLASS_NAME)
		){
			^throw[parser.runtime;$oModel.CLASS_NAME;Association $self.association_name can be associated only with $self.mapper.CLASS_NAME]
		}
		
		^self.before_save[]

		^rem{ *** insert association record in join_table *** }
		^Framework:oSql.void{
			INSERT IGNORE INTO
				`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
			VALUES
				("$self.foreign_instance.[$self.association_foreign_key]", "$oModel.[$self.foreign_key]")
		}
	}
	
	$self._is_loaded(false)														^rem{ *** сбрасываем ассоциацию для последующего переполучения данных *** }

	^self.after_save[]
#end @add[]



##############################################################################
@update[uModels]
	^switch[$uModels.CLASS_NAME]{
		^case[array;ActiveRelation;HasManyAssociation;HasAndBelongsToManyAssociation]{
			^self.init[$uModels]												^rem{ *** BUG: если придет array, то методы поиска перестанут работать совсем... *** }
						
			^if($self.foreign_instance.is_new){
				^self.wait_save[$self.foreign_instance]
			}{
				^self.before_save[]

				^rem{ *** удаляем отсутствующие элементы *** }
				^Framework:oSql.void{
					DELETE FROM
						`$self.join_table`
					WHERE
						`$self.join_table`.`$self.association_join_foreign_key` = "$self.foreign_instance.[$self.association_foreign_key]"
						^if($uModels){
							AND `$self.join_table`.`$self.join_foreign_key` NOT IN (^foreach[$uModels;model]{"$model.[$self.foreign_key]"}[,])
						}
				}

				^rem{ *** добавляем новые *** }
				^if($uModels){
					^Framework:oSql.void{
						INSERT IGNORE INTO
							`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
						VALUES
							^foreach[$uModels;model]{("$self.foreign_instance.[$self.association_foreign_key]", "$model.[$self.foreign_key]")}[, ]
					}
				}

				^self.after_save[]
			}
		}

		^case[DEFAULT]{
			^throw[parser.runtime;update;can't update has_and_belongs_to_many association by $uModels.CLASS_NAME]
		}
	}
#end @update[]



##############################################################################
@remove[oModel]
	^if(!($oModel is $mapper.CLASS_NAME)){
		^throw[parser.runtime;$oModel.CLASS_NAME;Association $association_name can be associated only with $mapper.CLASS_NAME (^inspect[$oModel])]
	}
	
	^self.before_save[]

	^rem{ *** insert association record in join_table *** }
	^Framework:oSql.void{
		DELETE FROM
			`$self.join_table`
		WHERE
			^if($foreign_instance){
				`$self.association_join_foreign_key` = "$self.foreign_instance.[$self.association_foreign_key]" AND
			}
			`$self.join_foreign_key` = "$oModel.[$self.foreign_key]"
	}
	
	$self._is_loaded(false)														^rem{ *** сбрасываем ассоциацию для последующего переполучения данных *** }

#	^rem{ *** remove model from list *** }
#	^self.list.remove[$oModel]

	^self.after_save[]
#end @remove[]



##############################################################################
@update_dependent_associations[]
	^rem{ *** не требует обновления, т.к. все связи в промежуточной таблице *** }
	^rem{ *** TODO: добавить обновление ассоциаций при изминении связей *** }
#end @update_dependent_associations[]



##############################################################################
@wait_save[oObject]
	^BASE:wait_save[$oObject]
#end @wait_save[]



##############################################################################
@save_native[]
	^self.update[$self._data]

	$result[^BASE:save_native[]]
#end @save_native[]
