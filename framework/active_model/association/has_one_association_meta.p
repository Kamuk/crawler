##############################################################################
#	
##############################################################################

@CLASS
HasOneAssociationMeta

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
	^HasOneAssociation::create[$self]
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
	^foreach[$aObjects;object]{
		^if(!$object.associations.[$association_name].is_loaded){^objects.add[$object]}
	}

	^rem{ *** load association only for unloaded models *** }
	^if($objects){		
		$association_object[^self.mapper_relation.find[
			$.condition[`$self.association_name`.`$self.foreign_key` IN (^foreach[$objects;object]{"$object.[$self.primary_key]"}[,])]
		][
			$.include[$hIncludes]
		]]

		$association_object[^association_object.hash[$self.primary_key]]

		^rem{ *** initialize association for each object *** }
		^foreach[$objects;object]{
			^object.associations.[$self.association_name].init[$association_object.[$object.[$self.primary_key]]]
		}
	}

	$result[]
#end @find_by_association[]



##############################################################################
#	FIXME: if using global condition and many join for one association
#	that alias not equal a condition table name
##############################################################################
@join_association[oQuery;hParam;sAlias]
^Framework:oLogger.trace[am.as.join]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name join by $sAlias ($hParam.alias) #$sWay}{

	$join_condition[^SqlCondition::create[]]
	^join_condition.add[^if(def $hParam.alias){`$hParam.alias`}{`$self.association_mapper.table_name`}.`^if(def $self.association_mapper.FIELDS.[$self.foreign_key]){$self.association_mapper.FIELDS.[$self.foreign_key].name}{$self.foreign_key}` = ^if(def $sAlias){`$sAlias`}{`$self.association_name`}.`$self.primary_key`]
	^join_condition.add[$hParam.condition]
	^join_condition.add[$self.condition]
	
	^if(def $sAlias){
		$alias[$sAlias]
	}{
		$alias[$self.association_name]
	}

	^oQuery.join_table[$alias][
		$.table[$self.mapper.table_name]
		$.condition[$join_condition]
		$.type[$hParam.type]
	]
}
#end @join_association[]
