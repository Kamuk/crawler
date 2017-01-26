##############################################################################
#	
##############################################################################

@CLASS
HasAndBelongsToManyAssociationMeta

@OPTIONS
locals

@BASE
ManyAssociationMeta



##############################################################################
@create[hOptions]
	^BASE:create[$hOptions]

	$self._association_foreign_key[$hOptions.association_foreign_key]
	$self._association_join_foreign_key[$hOptions.association_join_foreign_key]
	$self._foreign_key[$hOptions.foreign_key]
	$self._join_foreign_key[$hOptions.join_foreign_key]

	$self.join_table[$hOptions.join_table]

	^if(!def $self.join_table){
		^rem{ *** TODO: sort table by abc name *** }
		$self.join_table[${self.mapper.table_name}_${self.association_mapper.table_name}]
	}
#end @create[]



##############################################################################
@GET_association_foreign_key[]
	^if(!def $self._association_foreign_key){
		$self._association_foreign_key[$self.association_mapper.primary_key]
	}
	$result[$self._association_foreign_key]
#end @GET_association_foreign_key[]



##############################################################################
@GET_association_join_foreign_key[]
	^if(!def $self._association_join_foreign_key){
		$self._association_join_foreign_key[$self.association_foreign_key]
	}
	$result[$self._association_join_foreign_key]
#end @GET_association_join_foreign_key[]



##############################################################################
@GET_foreign_key[]
	^if(!def $self._foreign_key){
		$self._foreign_key[$self.mapper.primary_key]
	}
	$result[$self._foreign_key]
#end @GET_foreign_key[]



##############################################################################
@GET_join_foreign_key[]
	^if(!def $self._join_foreign_key){
		$self._join_foreign_key[$self.foreign_key]
	}
	$result[$self._join_foreign_key]
#end @GET_join_foreign_key[]



##############################################################################
@_implement[][result]
	^HasAndBelongsToManyAssociation::create[$self]
#end @_implement[]



##############################################################################
#	Возвращает ActiveRelation для данной модели
##############################################################################
@GET_mapper_relation[]
^Framework:oLogger.trace[am.as.get_relation]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name}{
	$result[^BASE:GET_mapper_relation[]]										^rem{ *** наследуемся от базовой *** }

	^result.merge[
		$.alias[$self.association_name]
		$.join_table[
			$.[$self.join_table][
				$.condition[`$self.association_name`.`$self.foreign_key` = `$self.join_table`.`$self.join_foreign_key`]
			]
		]
	]
}
#end @GET_mapper_relation[]



##############################################################################
@find_by_association[aObjects;hIncludes]
#	^Framework:oLogger.debug{Find by association "$association_name" from $association_mapper.class_name for ^foreach[$aObjects;object]{$object.id}[,]}

	^rem{ *** look at each model, posible associasion is alrady loaded *** }
	$objects[^array::create[]]
	^foreach[$aObjects;object]{
		^if(!$object.associations.[$association_name].is_loaded){^objects.add[$object]}
	}

	^rem{ *** load association only for unloaded models *** }
	^if($objects){	   		
   		$association_object[^self.mapper_relation.find[
#			$.alias[$self.association_name]
   			$.select[
   				$.[${self.association_name}_${self.association_foreign_key}][
   					$.name[$self.association_join_foreign_key]
   					$.table[$self.join_table]
   				]
   			]
   			$.condition[`$self.join_table`.`$self.association_join_foreign_key` IN (^foreach[$objects;object]{"$object.[$self.association_foreign_key]"}[,])]
   		][
			$.include[$hIncludes]
		]]
   		
   		$association_object[^association_object.hash[${self.association_name}_${self.association_foreign_key}][
   			$.type[array]
   		]]

		^rem{ *** initialize association for each object *** }
		^foreach[$objects;object]{
			^object.associations.[$self.association_name].init[$association_object.[$object.[$self.association_foreign_key]]]		^rem{ *** FIX: must be init be Relations *** }
		}
	}

	$result[]
#end @find_by_association[]



##############################################################################
@join_association[oQuery;hParam;sAlias]
^Framework:oLogger.trace[am.a.join_association]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name join by $sAlias ($hParam.alias) #$sWay}{

	^if(def $sAlias){
		$alias[$sAlias]
	}{
		$alias[$self.association_name]
	}
	$alias_relationship[${alias}_relationship]
	
	^rem{ *** join join_table *** }
	^oQuery.join_table[$alias_relationship][
		$.type[$hParam.type]
		$.table[$self.join_table]
		$.condition[^if(def $hParam.alias){`$hParam.alias`}{`$self.association_mapper.table_name`}.`$self.association_foreign_key` = `$alias_relationship`.`$self.association_join_foreign_key`]
	]
	
	^rem{ *** join model table of association *** }
	^oQuery.join_table[$alias][
		$.type[$hParam.type]
		$.table[$self.mapper.table_name]
		$.condition[`$alias_relationship`.`$self.join_foreign_key` = `$alias`.`$self.foreign_key`]
	]

	^oQuery.condition[^self.condition.match[(\b${self.association_name}|`${self.association_name}`)\.][gi]{`${alias}`.}]

	^oQuery.condition[$hParam.condition]
}
#end @join_association[]
