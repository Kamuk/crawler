##############################################################################
#	
##############################################################################

@CLASS
HasManyThroughAssociationMeta

@OPTIONS
locals

@BASE
ManyAssociationMeta



##############################################################################
#	Ассоциация-прокси между моделями
##############################################################################
@GET_proxy_association[]
	$result[$self.association_mapper.ASSOCIATIONS.[$self.through]]				^rem{ *** ассоциация от класса-владельца *** }
#end @GET_proxy_association[]



##############################################################################
#	Меппер ассоциации-прокси
##############################################################################
@GET_proxy_mapper[]
	$result[$self.proxy_association.mapper]
#end @GET_proxy_mapper[]



##############################################################################
#	Конечная ассоциация для проксирования
##############################################################################
@GET_mapper_association[]
	$result[$self.proxy_mapper.ASSOCIATIONS.[$self.association_proxy_name]]
#end @GET_mapper_association[]



##############################################################################
@GET_class_name[]
	$result[$self.mapper_association.class_name]
#end @GET_class_name[]



##############################################################################
@SET_class_name[sValue]
	$result[]
#end @SET_class_name[]



##############################################################################
@GET_primary_key[]
	$result[$self.proxy_association.primary_key]
#end @GET_primary_key[]



##############################################################################
@GET_foreign_key[]
	$result[$self.proxy_association.foreign_key]
#end @GET_foreign_key[]



##############################################################################
@create[hOptions]
	^BASE:create[$hOptions]
#end @create[]



##############################################################################
@_implement[][result]
	^HasManyThroughAssociation::create[$self]
#end @_implement[]



##############################################################################
#	Возвращает ActiveRelation для данной модели
##############################################################################
@GET_mapper_relation[]
^Framework:oLogger.trace[am.as.get_relation]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name}{
	$result[^BASE:GET_mapper_relation[]]										^rem{ *** наследуемся от базовой *** }

	^result.merge[
		$.alias[$self.association_name]
#		$.join[$self.association_through.association_name]
	]
	
#	^throw_inspect[$self.proxy_association][^json:string[$self.proxy_association]]
#	^throw_inspect[$self.proxy_mapper]

#	^throw_inspect[$self.mapper_association][^json:string[$self.mapper_association]]
#	^throw_inspect[$self.mapper]

#	^throw_inspect[$self][^json:string[$self]]	

	$criteria[^AMCriteria::create[]]
	^self.mapper_association.join_association[$criteria; $.alias[$self.association_name] ;$self.through][back]
	
#	TODO: нужно попытаться реализовать через рекурсивный вызов join_associaion		
#	^self.join_association[$criteria; $.alias[$self.association_name] ][][back]

	^result.merge[$criteria]
	
	^rem{ *** рекурсивно собираем join_table от proxy_association *** }
	^if(def $self.proxy_association.through){
#		^throw_inspect[$self.proxy_association][^inspect[$self.proxy_association.mapper_relation.CRITERIA._join]]
		^result.merge[
			$.join_table[$self.proxy_association.mapper_relation.CRITERIA._join]
		]
			
#		^self.proxy_association.join_association[$criteria; $.alias[$self.through] ;$self.proxy_association.through ($self.through)][back]
	}
}
#end @GET_mapper_relation[]



##############################################################################
@find_by_association[aObjects;hIncludes]
#	^Framework:oLogger.debug{Find by association "$association_name" from $association_mapper.class_name for ^foreach[$aObjects;object]{$object.id}[,]}

	^rem{ *** look at each model, posible associasion is alrady loaded *** }
	$objects[^array::create[]]
	^foreach[$aObjects;object]{
		^if(!$object.associations.[$self.association_name].is_loaded){^objects.add[$object]}
	}

	^rem{ *** load association only for unloaded models *** }
	^if($objects){
		$association_object[^self.mapper_relation.find[
			$.select[
				$.[${self.association_name}_${self.foreign_key}][
					$.name[$self.foreign_key]
					$.table[^if(def $self.through){$self.through}{$self.association_name}]
				]
			]
			$.condition[^if(def $self.through){`$self.through`}{`$self.association_name`}.`$self.foreign_key` IN (^foreach[$objects;object]{"$object.[$self.primary_key]"}[,])]
		][
			$.include[$hIncludes]
		]]

		$association_object[^association_object.hash[${self.association_name}_${self.foreign_key}][
			$.type[array]
		]]

		^rem{ *** initialize association for each object *** }
		^foreach[$objects;object]{
			^object.associations.[$self.association_name].init[$association_object.[$object.[$self.primary_key]]]			^rem{ *** FIX: must be init be Relations *** }
		}
	}

	$result[]
#end @find_by_association[]



##############################################################################
@join_association[oQuery;hParam;sAlias;sWay]
^Framework:oLogger.trace[am.as.join]{$self.CLASS_NAME "$self.association_name" from $self.association_mapper.class_name join by $sAlias ($hParam.alias) #$sWay}{
	^if(def $sWay && ($sWay eq "back" || $sWay eq "revert")){
		$left[$self.mapper_association]
		$right[$self.proxy_association]
		
		$left_mapper[$left.mapper]
		$right_mapper[$right.mapper]
		
#		$left_mapper[$self.mapper]
#		$right_mapper[$self.association_mapper]
		

	}{
#		$left_mapper[$self.association_mapper]
#		$right_mapper[$self.mapper]
		
		$left[$self.proxy_association]
		$right[$self.mapper_association]
		
		$left_mapper[$left.mapper]
		$right_mapper[$right.mapper]
	}
	
	^if(def $hParam.alias){
		$association_alias[$hParam.alias]
	}{
		$association_alias[$mapper_association.table_name]
	}
	^if(def $sAlias){
		$alias[$sAlias]
	}{
		$alias[$self.association_name]
	}
	
#	^throw_inspect[$hParam]
	
#	^throw_inspect[$proxy_association][^json:string[$proxy_association]]
#	^throw_inspect[$association_alias]

	^self.proxy_association.join_association[$oQuery; $.alias[$association_alias] $.type[$hParam.type] ;${alias}_${self.through}][$sWay]
	^self.mapper_association.join_association[$oQuery; $.alias[${alias}_${self.through}] $.type[$hParam.type] $.condition[^self.replace_condition[$alias]] ;$alias][$sWay]
	
#	^throw_inspect[$oQuery._join]
}
#end @join_association[]


##############################################################################
@replace_condition[alias]
	$result[^self.condition.match[(\b${self.association_name}|`${self.association_name}`)\.][gi]{`${alias}`.}]
	$result[^self.condition.match[(\b${self.through}|`${self.through}`)\.][gi]{`${alias}_${self.through}`.}]
#end @replace_condition[]