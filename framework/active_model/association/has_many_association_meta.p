##############################################################################
#	
##############################################################################

@CLASS
HasManyAssociationMeta

@OPTIONS
locals

@BASE
ManyAssociationMeta



##############################################################################
@create[hOptions]
	^BASE:create[$hOptions]

	$self._primary_key[$hOptions.primary_key]
	$self._foreign_key[$hOptions.foreign_key]
#end @create[]



##############################################################################
@GET_primary_key[]
	^if(!def $self._primary_key){
		$self._primary_key[$self.association_mapper.primary_key]
	}
	$result[$self._primary_key]
#end @GET_primary_key[]



##############################################################################
@GET_foreign_key[]
	^if(!def $self._foreign_key){
		$self._foreign_key[$self.association_mapper.primary_key]
	}
	$result[$self._foreign_key]
#end @GET_foreign_key[]



##############################################################################
@_implement[][result]
	^HasManyAssociation::create[$self]
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
^Framework:oLogger.trace[as.has_many.find_by_association]{$self.CLASS_NAME "$self.association_name" for ^foreach[$aObjects;object]{$object.id}[,]}{
	^rem{ *** look at each model, posible associasion is alrady loaded *** }
	$objects[^array::create[]]
	^foreach[$aObjects;object]{
		^if(!$object.associations.[$self.association_name].is_loaded){^objects.add[$object]}	^rem{ *** load association only for unloaded models *** }
	}

	^if($objects){
		$records[^self.mapper_relation.find[
			^rem{ *** FIX: при наличии этого select модели не проверяются в кеше *** }
			$.select[
				$.[${self.foreign_key}][
					$.name[$self.foreign_key]
					$.table[$self.association_name]
				]
			]
			$.condition[`$self.association_name`.`$self.foreign_key` IN (^foreach[$objects;object]{"$object.[$self.primary_key]"}[,])]
		][
			$.include[$hIncludes]
		]]

		$association_object[^records.hash[${self.foreign_key}][
			$.type[array]
		]]
	
		^rem{ *** initialize association for each object *** }
		^foreach[$objects;object]{
			^object.associations.[$self.association_name].init[$association_object.[$object.[$self.primary_key]]]
		}
	}

	$result[]
}
#end @find_by_association[]



##############################################################################
@join_association[oQuery;hParam;sAlias;sWay]
^Framework:oLogger.trace[am.as.join]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name join by $sAlias ($hParam.alias) #$sWay}{

	^if(def $sWay && ($sWay eq "back" || $sWay eq "revert")){
		$left_mapper[$self.mapper]
		$right_mapper[$self.association_mapper]
	}{
		$left_mapper[$self.association_mapper]
		$right_mapper[$self.mapper]
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
	^join_condition.add[`$association_alias`.`^if(def $left_mapper.FIELDS.[$primary_key]){$left_mapper.FIELDS.[$primary_key].name}{$self.primary_key}` = `$alias`.`$self.foreign_key`]
	^join_condition.add[$hParam.condition]
	^join_condition.add[^self.condition.match[(\b${self.association_name}|`${self.association_name}`)\.][gi]{`${alias}`.}]]	^rem{ *** HINT: match = замена имени ассоциации в condition *** }

	^oQuery.join_table[$alias][
		$.table[$right_mapper.table_name]
		$.condition[$join_condition]
		$.type[$hParam.type]
	]
}
#end @join_association[]
