##############################################################################
#	
##############################################################################

@CLASS
ActiveRelation

@OPTIONS
locals
partial



##############################################################################
@_count[]
^Environment:oLogger.trace[ar._count]{^inspect[$self] : _count}{
	$query[^self._query[int]]
	
	$table_alias[^if(def $self.CRITERIA.alias){$self.CRITERIA.alias}{$self.MAPPER.model_name}]
	
	^rem{ *** column with primary_key *** }
	^query.column[item_count;COUNT(^self.CRITERIA.print_distinct[] `$table_alias`.`$self.MAPPER.primary_key`)]
	
	^rem{ *** FIX: принудительно указываем limit & offset т.к. он мог быть в oCriteria *** }
	^query.merge[
		$.limit(1)
		$.offset(0)
	]

	$result[^query.execute[]]
}
#end @_count[]



##############################################################################
@_find[]
^Framework:oLogger.trace[ar._find]{^inspect[$self] : _find}{
	$result[^self.to_query.execute[]]
}
#end @_find[]



##############################################################################
@_plug[]
	$query[^self._query[plug]]
	
	$result[^query.execute[]]
#end @_plug[]



##############################################################################
#	Метод возвращает подготовленный SqlQuery для выполнения запроса
#	FIX: Метод изменяет CRITERIA что может привести к некорректной работе
##############################################################################
@_query[sQueryType][alias;params;field;class]
^Environment:oLogger.trace[ar._query]{^inspect[$self]}{
	$query[^oSqlBuilder.select[$sQueryType]]
	
	$table_alias[^if(def $self.CRITERIA.alias){$self.CRITERIA.alias}{$self.MAPPER.model_name}]

	$joined_associations[
		$.[$table_alias][$self.MAPPER]
	]

	^rem{ *** join associations *** }
	$associations_for_join[^hash::create[$self.CRITERIA._join_association]]
	^associations_for_join.foreach[alias;params]{
		^if(!def $params.name){^continue[]}
		
		^self.CRITERIA._join_association.delete[$alias]							^rem{ *** удаляем ассоциацию из criteria, т.к. она уже была присоединена через# join_table *** }
																				^rem{ *** иначе при повторном обрщении к to_sql будет exception в двойным join *** }

		$parts[^params.name.split[.;lh]]

		^if(!def $parts.1){
			^rem{ *** ассоциация 1-ого уровня *** }
			$association[$self.MAPPER.ASSOCIATIONS.[$params.name]]

			^if(def $table_alias){
				$params[^hash::create[$params]]
				$params.alias[$table_alias]
			}
		}{
			^rem{ *** вложенная ассоциация *** }
			$association[$joined_associations.[$parts.0].ASSOCIATIONS.[$parts.1]]

			^if(^params.name.match[\.]){
				$params.alias[$parts.0]
			}
			^if(^alias.match[\.]){
				$alias[$parts.1]
			}
		}

		^if(!def $association){
			^throw[parser.runtime;$alias;no assosiation]
		}

		$joined_associations.[$alias][$association.mapper]
		^association.join_association[$self.CRITERIA;$params;$alias]			^rem{ *** добавляем в criteria условия join ассоциации *** }
	}

	^rem{ *** TODO: group by if join table *** }
	^rem{ *** FIX: replace to DISTINCT *** }
	^rem{ ***  && !$criteria._group *** }
	^if($self.CRITERIA._join){
		^self.CRITERIA.distinct(true)
#		$table_alias[^if(def $criteria.alias){$criteria.alias}{$self.table_name}]
#		^criteria.group[`$table_alias`.`$self.primary_key`]
	}
		
	^if(def $self._base){
		^rem{ *** если есть базовый, то берем основу от него *** }
		$base_query[^self._base._query[$sQueryType]]
		^query.merge[$base_query._criteria]
	}{
		^if($sQueryType ne "int" && $sQueryType ne "plug"){
			^rem{ *** column with primary_key *** }
			^query.column[$self.MAPPER.primary_key;$table_alias;$self.MAPPER.primary_key]

			^rem{ *** columns from current model *** }
			^self.MAPPER.FIELDS.foreach[alias;field]{
				^query.column[$alias;$table_alias;$field.name]
			}

			^rem{ *** FIX: what is? *** }
			^rem{ *** columns from inherited class *** }
			^if(def $self.MAPPER.inherited_from){
				^self.MAPPER.inherited_from.FIELDS.foreach[alias;field]{
					^query.column[$alias;$self.MAPPER.inherited_from.table_name;$field.name]
				}
			}
		}
	
		^rem{ *** table (source) of data *** }
		^if(def $self.MAPPER.inherited_from){
			^query.from[$self.MAPPER.inherited_from.table_name]

			^query.join[$table_alias][
				$.table[$self.MAPPER.table_name]
				$.condition[`$self.MAPPER.inherited_from.table_name`.`$self.MAPPER.inherited_from.primary_key` = `$table_alias`.`$self.MAPPER.primary_key`]
			]
		}{
			^query.from[$self.MAPPER.table_name;$table_alias]
		}
		
		^if(def $self.MAPPER.FIELDS.type && $self.MAPPER.table_name ne $self.MAPPER.model_name){
			^query.condition[`${table_alias}`.`type` IN (^foreach[$self.MAPPER.CHILD_CLASSES;class]{"$class.CLASS_NAME"}[,])]	^rem{ *** накладываем условие для Single Table Inheritance если есть field "type" *** }
		}
		^if(!$self._unscoped && def $self.MAPPER.SCOPES.default_scope){
			^query.merge[$self.MAPPER.SCOPES.default_scope.CRITERIA]			^rem{ *** наследуем default_scope *** }
		}
	}

	^rem{ *** объединяем критерии поиска *** }
	^query.merge[$self.CRITERIA]
	
	$result[$query]
}
#end @_query[]



##############################################################################
@GET_to_query[]
^Environment:oLogger.trace[ar.to_query]{^inspect[$self]}{
	$result[^self._query[]]
}
#end @to_query[]



##############################################################################
@GET_to_sql[]
	$result[$self.to_query.to_sql]
#end @GET_to_sql[]
