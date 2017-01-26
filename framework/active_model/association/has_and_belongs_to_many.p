##############################################################################
#	
##############################################################################

@CLASS
HasAndBelongsToManyAssociation

@OPTIONS
partial

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
@count[hParam][locals]
	$params[^hash::create[$hParam]]
	
	^rem{ *** aslias for table_name *** }
	$params.alias[$association_name]
	
	$alias_relationship[${association_name}_relationship]
	
	$params.join_table[
		$.[$alias_relationship][
			$.table[$join_table]
			$.condition[`$association_name`.`$foreign_key` = `$alias_relationship`.`$foreign_key`]
		]
	]
	
	$condition[^SqlCondition::create[]]

	^if($foreign_instance){
		^condition.add[`$alias_relationship`.`$association_foreign_key` = $foreign_instance.id]
	}
	^condition.add[$self.condition]
	^condition.add[$params.condition]
	
	$params.condition[$condition]

	$result[^mapper.count[$params]]
#end @count[]



###############################################################################
#@find_by_association[aObjects][locals;object]
##	^Framework:oLogger.debug{Find by association "$association_name" from $association_mapper.model_name for ^foreach[$aObjects;object]{$object.id}[,]}
#
#	^rem{ *** look at each model, posible associasion is alrady loaded *** }
#	$objects[^array::create[]]
#	^foreach[$aObjects;object]{
#		^if(!$object.[$association_name].is_loaded){^objects.add[$object]}
#	}
#
#	^rem{ *** load association only for unloaded models *** }
#	^if($objects){
#		$association_object[^_find_by_association[^foreach[$objects;object]{$object.$association_foreign_key}[,]]]
#
#		^rem{ *** initialize association for each object *** }
#		^foreach[$objects;object]{
#			^object.[$association_name].init[$association_object.[$object.$association_foreign_key]]
#		}
#	}
#
#	$result[]
##end @find_by_association[]
#
#
#
###############################################################################
#@_find_by_association[sIds][condition]
##	$criteria[^SqlCriteria::create[]]
##
##	^criteria.column[$association_foreign_key;$join_table;$association_foreign_key]
##
##	^criteria.join[$join_table]
##
##	^criteria.condition[`$association_name`.`$foreign_key` = `$join_table`.`$foreign_key`]
##	^criteria.condition[`$join_table`.`$association_foreign_key` IN ($sIds)]
##
##	^criteria.order[$order]
##
##	$result[^self.find[$criteria]]
#
#	$condition[^SqlCondition::create[]]
##	^condition.add[`$association_name`.`$foreign_key` = `$join_table`.`$foreign_key`]
#	^condition.add[`$join_table`.`$association_foreign_key` IN ($sIds)]
#
#	$result[^find[
#		$.select[
#			$.[$association_foreign_key][
#				$.name[$association_foreign_key]
#				$.table[$join_table]
#			]
#		]
##		$.join_table[$join_table]
#		$.condition[$condition]
##		$.group[$association_foreign_key]
#		$.order[$order]
#	]]
#	
#	$result[^result.hash[$association_foreign_key][
#		$.type[array]
#	]]
##end @_find_by_association[]
#
#
#
###############################################################################
#@join_association[oQuery;hParam;sAlias][locals]
#	^if(def $sAlias){
#		$alias[$sAlias]
#	}{
#		$alias[$association_name]
#	}
#	$alias_relationship[${alias}_relationship]
#	
#	^rem{ *** join join_table *** }	
#	^oQuery.join_table[$alias_relationship][
#		$.type[$hParam.type]
#		$.table[$join_table]
#		$.condition[^if(def $hParam.alias){`$hParam.alias`}{`$association_mapper.table_name`}.`$association_foreign_key` = `$alias_relationship`.`$association_foreign_key`]
#	]
#	
#	^rem{ *** join model table of association *** }
#	^oQuery.join_table[$alias][
#		$.type[$hParam.type]
#		$.table[$mapper.table_name]
#		$.condition[`$alias_relationship`.`$foreign_key` = `$alias`.`$foreign_key`]
#	]
#	
#	^oQuery.condition[$self.condition]
#
#	^oQuery.condition[$hParam.condition]
##end @join_association[]



##############################################################################
@_load[][locals]
	^rem{ *** FIXME: 2 condition: for join and for where *** }
	$condition[^SqlCondition::create[]]
	^condition.add[`$join_table`.`$association_join_foreign_key` = $self.foreign_instance.[$association_foreign_key]]
	^condition.add[$self.condition]
	
	^self.init[^mapper.find[
		$.alias[$association_name]
		$.join_table[
			$.[$join_table][
				$.condition[`$association_name`.`$foreign_key` = `$join_table`.`$join_foreign_key`]
			]
		]
		$.include[$include]
		$.condition[$condition]
		$.order[$order]
	]]
#end @_load[]



##############################################################################
#	Delete all link on association in join table
##############################################################################
@_clear[][model]
	^Framework:oSql.void{
		DELETE FROM
			`$join_table`
		WHERE
			`$join_table`.`$association_join_foreign_key` = $self.foreign_instance.[$association_foreign_key] AND
			`$join_table`.`$join_foreign_key` IN (^foreach[$self.list;model]{$model.id}[,])
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
	^if($oModel is array){
		^rem{ *** TODO: add check for mapper CLASS_NAME *** }

		^self.before_save[]

		^rem{ *** insert association record in join_table *** }
		^Framework:oSql.void{
			INSERT IGNORE INTO
				`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
			VALUES
				^foreach[$oModel;model]{($self.foreign_instance.[$self.association_foreign_key], $model.id)}[, ]
		}
	
		^rem{ *** join associated models in list *** }
		^if($self.is_loaded){
			^self.list.join[$oModel]
		}
	
		^self.after_save[]
	}{
		^if(!($oModel is $self.mapper.CLASS_NAME) && !($oModel is OneAssociation && $oModel.mapper is $self.mapper.CLASS_NAME)){
			^throw[parser.runtime;$oModel.CLASS_NAME;Association $self.association_name can be associated only with $self.mapper.CLASS_NAME]
		}
	
		^self.before_save[]

		^rem{ *** insert association record in join_table *** }
		^Framework:oSql.void{
			INSERT IGNORE INTO
				`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
			VALUES
				($self.foreign_instance.[$self.association_foreign_key], $oModel.id)
		}
	
		^rem{ *** add associated model in list *** }
		^if($self.is_loaded){
			^self.list.add[$oModel]
		}
	
		^self.after_save[]
	}
#end @add[]



##############################################################################
@update[uModels]
	^self.before_save[]

	^switch[$uModels.CLASS_NAME]{
		^case[array]{
			^rem{ *** удаляем отсутствующие элементы *** }
			^Framework:oSql.void{
				DELETE FROM
					`$self.join_table`
				WHERE
					`$self.join_table`.`$self.association_join_foreign_key` = $self.foreign_instance.[$self.association_foreign_key]
					^if($uModels){
						AND `$self.join_table`.`$self.join_foreign_key` NOT IN (^foreach[$uModels;model]{$model.id}[,])
					}
			}

			^rem{ *** добавляем новые *** }
			^if($uModels){
				^Framework:oSql.void{
					INSERT IGNORE INTO
						`$self.join_table` (`$self.association_join_foreign_key`, `$self.join_foreign_key`)
					VALUES
						^foreach[$uModels;model]{($self.foreign_instance.[$self.association_foreign_key], $model.id)}[, ]
				}
			}
			
			^self._init[$uModels]
		}

		^case[DEFAULT]{
			^throw[parser.runtime;update;can't update has_and_belongs_to_many association by $uModels.CLASS_NAME]
		}
	}
	
	^self.after_save[]
#end @update[]



##############################################################################
@remove[oModel]
	^if(!($oModel is $mapper.CLASS_NAME)){
		^throw[parser.runtime;$oModel.CLASS_NAME;Association $association_name can be associated only with $mapper.CLASS_NAME]
	}
	
	^self.before_save[]

	^rem{ *** insert association record in join_table *** }
	^Framework:oSql.void{
		DELETE FROM
			`$self.join_table`
		WHERE
			^if($foreign_instance){
				`$self.association_join_foreign_key` = $foreign_instance.id AND
			}
			`$self.join_foreign_key` = $oModel.id
	}

#	^rem{ *** remove model from list *** }
#	^self.list.remove[$oModel]

	^self.after_save[]
#end @remove[]



##############################################################################
@find[uId;hParam][locals]
#	^Framework:oLogger.debug{Find association "$association_name" from $association_mapper.model_name ($self.CLASS_NAME)}
#	^if(def $hParam){^Framework:oLogger.debug{	Id: ^inspect[$uId]}}
#	^Framework:oLogger.debug{	Params: ^inspect[$_params]}

	^switch[$uId.CLASS_NAME]{
		^case[int;double;string;array]{
			$params[^hash::create[$hParam]]
		}

		^case[DEFAULT]{
			^if(!def $hParam){
				$params[^hash::create[$uId]]
			}{
				$params[^hash::create[$hParam]]
			}
		}
	}
	
	^rem{ *** alias for table_name *** }
	$params.alias[$association_name]

	^rem{ *** FIXME: join include *** }
	$params.include[^if(def $params.include){$params.include^if(def $self.include){,}}$self.include]
	
	$params.join_table[
		$.[$join_table][
			$.condition[`$association_name`.`$foreign_key` = `$join_table`.`$join_foreign_key`]
		]
	]
	
	$condition[^SqlCondition::create[]]

	^rem{ *** FIXME: find for association *** }
	^if($foreign_instance){
		^condition.add[`$join_table`.`$association_join_foreign_key` = $self.foreign_instance.[$association_foreign_key]]
	}
	^condition.add[$self.condition]
	^condition.add[$params.condition]
	
	$params.condition[$condition]
	
	^if(!def $params.order){
		$params.order[$order]
	}
	
	^switch[$uId.CLASS_NAME]{
		^case[int;double]{
			$result[^mapper.find($uId)[$params]]
		}

		^case[string;array]{
			$result[^mapper.find[$uId;$params]]
		}

		^case[DEFAULT]{
			$result[^mapper.find[$params]]
		}
	}
#end @find[]


##############################################################################
@update_dependent_associations[]
	^rem{ *** не требует обновления, т.к. все связи в промежуточной таблице *** }
	^rem{ *** TODO: добавить обновление ассоциаций при изминении связей *** }
#end @update_dependent_associations[]