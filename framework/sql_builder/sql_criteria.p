##############################################################################
#	
##############################################################################

@CLASS
SqlCriteria

@OPTIONS
locals



##############################################################################
@GET[type]
	$result(true)
#end @GET[]



##############################################################################
@create[uParam]
	$self._distinct(false)
#	$self._column[^table::create{name	alias	table}]
	$self._column[^hash::create[]]
	$self._from[
		$.table[]
		$.alias[]
	]

#	^table::create{table	conditions	alias	type}
	$self._join[^hash::create[]]
	$self._condition[^SqlCondition::create[]]
	$self._group[^table::create{expr	type}]
	$self._having[^SqlCondition::create[]]

	$self._order[^table::create{expr	type}]
	
	$self._limit(0)
	$self._offset(0)
	
	^self.merge[$uParam]
#end @create[]



##############################################################################
@GET_table[]
	$result[$self._from.table]
#end @GET_table[]



##############################################################################
@GET_alias[]
	$result[$self._from.alias]
#end @GET_alias[]



##############################################################################
@SET_alias[value]
	$self._from.alias[$value]
#end @SET_alias[]



##############################################################################
@merge[uCriteria]
	^switch[$uCriteria.CLASS_NAME]{
		^rem{ *** merge with SqlCondition *** }
		^case[string;SqlCondition]{
			^self.condition[$uCriteria]
		}
		
#		^case[AMCriteria]{}


		^rem{ *** merge with SqlCriteria *** }
		^case[AMCriteria;SqlCriteria]{
			^self.distinct[$uCriteria._distinct]
			^self.column[$uCriteria._column]
			^if(def $uCriteria._from.table || def $uCriteria._from.alias){
				^self.from[$uCriteria._from]
			}
			^self.join[$uCriteria._join]
			^self.condition[$uCriteria._condition]
			^self.group[$uCriteria._group]
			^self.having[$uCriteria._having]
			^self.order[$uCriteria._order]
			^if($uCriteria._limit){
				^self.limit[$uCriteria._limit]
			}
			^if($uCriteria._offset){
				^self.offset[$uCriteria._offset]
			}
		}

		
		^rem{ *** merge with hash *** }
		^case[hash]{
			^if(def $uCriteria.distinct){
				^self.distinct($uCriteria.distinct)
			}
			^if(def $uCriteria.alias){
				$self.alias[$uCriteria.alias]
			}
			^rem{ *** TODO: depricate it *** }
			^if(^uCriteria.contains[select]){
				^self.column[$uCriteria.select]
			}
			^if(^uCriteria.contains[column]){
				^self.column[$uCriteria.column]
			}
			^if(^uCriteria.contains[from]){
				^self.from[$uCriteria.from]
			}
			^if(^uCriteria.contains[join]){
				^self.join[$uCriteria.join]
			}
			^rem{ *** TODO: depricate it *** }
			^if(^uCriteria.contains[join_table]){
				^self.join[$uCriteria.join_table]
			}
			^if(^uCriteria.contains[condition]){
				^self.condition[$uCriteria.condition]
			}
			^if(^uCriteria.contains[group]){
				^self.group[$uCriteria.group]
			}
			^if(^uCriteria.contains[having]){
				^self.having[$uCriteria.having]
			}
			^if(^uCriteria.contains[order]){
				^self.order[$uCriteria.order]
			}
			^if(^uCriteria.contains[limit]){
				^self.limit[$uCriteria.limit]
			}
			^if(^uCriteria.contains[offset]){
				^self.offset[$uCriteria.offset]
			}
		}
		
		^case[DEFAULT]{
			^if(def $uCriteria){
				^throw[parser.runtime;merge;Uncknown type of criteria ($uCriteria.CLASS_NAME present)]
			}
		}
	}

	$result[]
#end @merge[]



##############################################################################
@distinct[uValue]
	$self._distinct(^uValue.bool(false))
#end @distinct[]



##############################################################################
@print_distinct[]
	$result[^if($self._distinct){DISTINCT }]
#end @print_distinct[]



##############################################################################
@column[uAlias;sTable;sName][i;column]
	^switch[$uAlias.CLASS_NAME]{
		^case[table]{
			^uAlias.menu{
				^self.column[$uAlias.alias][$uAlias.table][$uAlias.name]
			}
		}
	
		^case[array]{
			^uAlias.foreach[i;column]{^self.column[$column]}
		}

		^case[hash]{
			^uAlias.foreach[alias;params]{
				^switch[$params.CLASS_NAME]{
					^case[hash]{
						^if(def $params.table){
							^self.column[$alias;$params.table;^if(def $params.name){$params.name}{$alias}]
						}{
							^self.column[$alias;$params.name]
						}
					}

					^case[bool]{
						^self.column[$alias]					
					}

					^case[DEFAULT]{
						^self.column[$alias;$params]
					}
				}
			}
		}
	
		^case[DEFAULT]{
			^if(!def $sTable && !def $sName){
				$column_name[$uAlias]
			}
			^if(def $sTable && def $sName){
				$table_name[$sTable]
				$column_name[$sName]
			}
			^if(def $sTable && !def $sName){
				$column_name[$sTable]
			}
			
			$self._column.[^if($column_name ne $uAlias){$uAlias}{$column_name}][
				$.name[$column_name]
				$.table[$table_name]
			]
		}
	}

	$result[]
#end @column[]



##############################################################################
@print_column[]
	^if(!$_column){
		$result[*]
	}{
		$result[^_column.foreach[alias;colum]{^if(def $colum.table){`${colum.table}`.`${colum.name}`}{$colum.name}^if(def $alias){ AS `$alias`}}[,^#0A]]
	}
#end @print_column[]



##############################################################################
@from[sTable;sAlias]
	^switch[$sTable.CLASS_NAME]{
		^case[hash]{
			^if(def $sTable.table && def $_from.table){
				^throw[parser.runtime;from;from already specify]
			}

			^if(def $sTable.table){
				$_from.table[$sTable.table]
			}
			^if(def $sTable.alias && $sTable.table ne $sTable.alias){
				$_from.alias[$sTable.alias]
			}
		}

		^case[DEFAULT]{
			^if(def $_from.table){
				^throw[parser.runtime;from;from already specify]
			}

			$_from.table[$sTable]
			^if(def $sAlias && $sTable ne $sAlias){
				$_from.alias[$sAlias]
			}
		}
	}

	$result[]
#end @from[]



##############################################################################
@print_from[]
	$result[FROM `$_from.table`^if(def $_from.alias){ AS `$_from.alias`}]
#end @print_from[]



##############################################################################
@join[uName;hParam][params;join;alias]
	$params[^hash::create[$hParam]]
	
	^switch[$uName.CLASS_NAME]{
		^rem{ *** uName is hash *** }
		^case[hash]{
			^uName.foreach[alias;params]{
				^if(def $self._join.[$alias]){
					^throw[parser.runtime;join $alias;equals alias for join table]
				}
				
				^switch[$params.CLASS_NAME]{
					^case[hash]{
						$self._join.[$alias][
							$.table[^if(def $params.table){$params.table}{$alias}]
							$.alias[$alias]
							$.condition[^SqlCondition::create[]]
							$.type[$params.type]
						]

						^self._join.[$alias].condition.add[$params.condition]
					}

					^case[bool]{
						$self._join.[$alias][
							$.table[$alias]
							$.alias[$alias]
							$.condition[^SqlCondition::create[]]
							$.type[]
						]						
					}

					^case[DEFAULT]{
						$self._join.[$alias][
							$.table[^if(def $params){$params}{$alias}]
							$.alias[$alias]
							$.condition[^SqlCondition::create[]]
							$.type[]
						]
					}
				}
			}
		}
		
		^rem{ *** $uName is alias *** }
		^case[DEFAULT]{
			$alias[$uName]
			
			^if(def $self._join.[$alias]){
				^throw[parser.runtime;join $alias;equals alias for join table]
			}
			
			$self._join.[$alias][
				$.table[^if(def $params.table){$params.table}{$alias}]
				$.alias[$alias]
				$.condition[^SqlCondition::create[]]
				$.type[$params.type]
			]
		
			^self._join.[$alias].condition.add[$params.condition]
		}
	}

	$result[]
#end @join[]



##############################################################################
@print_join[][i;join]
	$result[^_join.foreach[i;join]{^_print_join[$join]}[^#0A]]
#end @print_join[]



##############################################################################
@_print_join[uJoin]
	^if($uJoin is hash){
		$result[^switch[$uJoin.type]{
			^case[right]{RIGHT JOIN}
			^case[left]{LEFT JOIN}
			^case[DEFAULT]{JOIN}
		}]

		$result[$result `$uJoin.table`^if(def $uJoin.alias){ AS `$uJoin.alias`}^if($uJoin.condition){ ON $uJoin.condition.to_sql}]
	}{
		$result[JOIN $uJoin]
	}
#end @_print_join[]



##############################################################################
@condition[uCondition]
	^self._condition.add[$uCondition]
	$result[]
#end @condition[]



##############################################################################
@print_condition[]
	^if($self._condition){
		^if(def $self.alias){
			$result[WHERE ^self._condition.to_sql.match[(\b${self.table}|`${self.table}`)\.][gi]{`${self.alias}`.}]
		}{
			$result[WHERE $self._condition.to_sql]
		}
	}{
		$result[]
	}
#end @print_condition[]



##############################################################################
@group[sColumn;sType]
	^switch[$sColumn.CLASS_NAME]{
		^case[table]{
			^self._group.join[$sColumn]
		}

		^case[DEFAULT]{
			^self._group.append{$sColumn	$sType}			
		}
	}

	$result[]
#end @group[]



##############################################################################
@print_group[]
	^if($self._group){
		^if(def $self.alias){
			$result[GROUP BY ^self._group.menu{^self._group.expr.match[(\b${self.table}|`${self.table}`)\.][gi]{`${self.alias}`.}^if(def $self._group.type){ $self._group.type}}[,^#0A]]
		}{
			$result[GROUP BY ^self._group.menu{$self._group.expr^if(def $self._group.type){ $self._group.type}}[,^#0A]]
		}
	}{
		$result[]
	}
#end @print_group[]



##############################################################################
@having[uCondition]
	^self._having.add[$uCondition]
	$result[]
#end @having[]



##############################################################################
@print_having[]
	^if($self._having){
		^if(def $self.alias){
			$result[HAVING ^self._having.to_sql.match[(\b${self.table}|`${self.table}`)\.][gi]{`${self.alias}`.}]
		}{
			$result[HAVING $self._having.to_sql]
		}
	}{
		$result[]
	}
#end @print_having[]



##############################################################################
@order[sColumn;sType]
	^if(def $sColumn){
		^switch[$sColumn.CLASS_NAME]{
			^case[table]{
				^self._order.join[$sColumn]
			}

			^case[DEFAULT]{
				^self._order.append{$sColumn	$sType}			
			}
		}
	}

	$result[]
#end @order[]



##############################################################################
@reorder[sColumn;sType]
	$self._order[^table::create{expr	type}]									^rem{ *** clear order *** }
	
	^self.order[$sColumn;$sType]
	$result[]
#end @reorder[]



##############################################################################
@print_order[]
	^if($self._order){
		^if(def $self.alias){
			$result[ORDER BY ^self._order.menu{^self._order.expr.match[(\b${self.table}|`${self.table}`)\.][gi]{`${self.alias}`.}^if(def $self._order.type){ $self._order.type}}[,^#0A]]
		}{
			$result[ORDER BY ^self._order.menu{$self._order.expr^if(def $self._order.type){ $self._order.type}}[,^#0A]]
		}
	}{
		$result[]
	}
#end @print_order[]



##############################################################################
@limit[iLimit]
	$self._limit($iLimit)
	$result[]
#end @limit[]



##############################################################################
@offset[iOffset]
	$self._offset($iOffset)
	$result[]
#end @offset[]
