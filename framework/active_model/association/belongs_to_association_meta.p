##############################################################################
#	
##############################################################################

@CLASS
BelongsToAssociationMeta

@OPTIONS
locals

@BASE
OneAssociationMeta



##############################################################################
@create[hOptions]
	^BASE:create[$hOptions]

	$self._primary_key[$hOptions.primary_key]
	$self._foreign_key[$hOptions.foreign_key]
#end @create[]



##############################################################################
@GET_primary_key[]
	^if(!def $self._primary_key){
		$self._primary_key[$self.mapper.primary_key]
	}
	$result[$self._primary_key]
#end @GET_primary_key[]



##############################################################################
@GET_foreign_key[]
	^if(!def $self._foreign_key){
		$self._foreign_key[$self.mapper.primary_key]
	}
	$result[$self._foreign_key]
#end @GET_foreign_key[]



##############################################################################
@_implement[][result]
	^BelongsToAssociation::create[$self]
#end @_implement[]



##############################################################################
#	Возвращает ActiveRelation для данной модели
##############################################################################
@GET_mapper_relation[]
^Framework:oLogger.trace[am.as.get_relation]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name}{
	$result[^BASE:GET_mapper_relation[]]										^rem{ *** наследуемся от базовой *** }

	^result.merge[
		$.alias[$self.association_name]
	]
}
#end @GET_mapper_relation[]



##############################################################################
@find_by_association[aObjects;hIncludes]
#	^Framework:oLogger.debug{Find by association "$association_name" from $association_mapper.class_name for ^foreach[$aObjects;object]{$object.id}[,]}

	^rem{ *** look at each model, posible associasion is alrady loaded *** }
	$objects[^array::create[]]
	^aObjects.foreach[i;object]{
		^if(!$object.associations.[$association_name].is_loaded){^objects.add[$object]}
	}

	^rem{ *** load association only for unloaded models *** }
	^if($objects){		
		^rem{ *** FIX: object.foreign_key могут быть пустыми и запрос будет неверным *** }
		$association_object[^self.mapper_relation.find[
			$.condition[`$self.association_name`.`$self.primary_key` IN (^foreach[$objects;object]{"$object.[$self.foreign_key]"}[,])]
			$.group[`$self.association_name`.`$self.primary_key`]					^rem{ *** FIX: why group using? *** }
		][
			$.include[$hIncludes]
		]]
	
		$association_object[^association_object.hash[$self.primary_key]]

		^rem{ *** initialize association for each object *** }
		^foreach[$objects;object]{
			^object.associations.[$self.association_name].init[$association_object.[$object.[$self.foreign_key]]]
		}
	}

	$result[]
#end @find_by_association[]



##############################################################################
@join_association[oQuery;hParam;sAlias;sWay]
^Framework:oLogger.trace[am.as.join]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name join by $sAlias ($hParam.alias) #$sWay}{
	
	^if(def $sWay && ($sWay eq "back" || $sWay eq "revert")){
		$left_mapper[$self.mapper]
		$right_mapper[$self.association_mapper]
		
		$left_key[$self.primary_key]
		$right_key[$self.foreign_key]
	}{
		$left_mapper[$self.association_mapper]
		$right_mapper[$self.mapper]
		
		$left_key[$self.foreign_key]
		$right_key[$self.primary_key]
	}

	^if(def $hParam.alias){
		$association_alias[$hParam.alias]
	}{
		$association_alias[$left_mapper.table_name]
	}
	^if(def $sAlias){
		$alias[$sAlias]
	}{
		$alias[$self.association_name]
	}

	$join_condition[^SqlCondition::create[]]
	^join_condition.add[`$association_alias`.`^if(def $left_mapper.FIELDS.[$left_key]){$left_mapper.FIELDS.[$left_key].name}{$left_key}` = `$alias`.`$right_key`]
	^join_condition.add[$hParam.condition]
	^join_condition.add[^self.condition.match[(\b${self.association_name}|`${self.association_name}`)\.][gi]{`${alias}`.}]]

	^oQuery.join_table[$alias][
		$.table[$right_mapper.table_name]
		$.condition[$join_condition]
		$.type[$hParam.type]
	]
}
#end @join_association[]
