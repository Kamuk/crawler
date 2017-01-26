##############################################################################
#	
##############################################################################

@CLASS
SelectSqlBuilder

@OPTIONS
locals
partial

@BASE
SqlBuilder



##############################################################################
#	.select
#	.condition
#	.from
#	.joins
#	.group
#	.having
#	.order
#	.limit
#	.offset
##############################################################################
@create[sType]
	$self._query_type[^if($sType eq "int"){int}{table}]
	$self._criteria[^SqlCriteria::create[]]
#end @create[]



##############################################################################
@merge[oCriteria]
	^self._criteria.merge[$oCriteria]
	$result[]
#end @merge[]



##############################################################################
@column[uAlias;sTable;sName]
	^_criteria.column[$uAlias;$sTable;$sName]
	$result[]
#end @column[]



##############################################################################
@from[sTable;sAlias]
	^_criteria.from[$sTable;$sAlias]
	$result[]
#end @from[]



##############################################################################
@join[uName;hParam]
	^_criteria.join[$uName;$hParam]
	$result[]
#end @join[]



##############################################################################
@condition[uCondition]
	^_criteria.condition[$uCondition]
	$result[]
#end @condition[]



##############################################################################
@group[sColumn;sType]
	^_criteria.group[$sColumn;$sType]
	$result[]
#end @group[]



##############################################################################
@having[uCondition]
	^_criteria.having[$uCondition]
	$result[]
#end @having[]



##############################################################################
@order[sColumn;sType]
	^_criteria.order[$sColumn;$sType]
	$result[]
#end @order[]



##############################################################################
@_query[]
	SELECT
		^_criteria.print_distinct[]
		^_criteria.print_column[]
		^_criteria.print_from[]
		^_criteria.print_join[]
		^_criteria.print_condition[]
		^_criteria.print_group[]
		^_criteria.print_having[]
		^_criteria.print_order[]
#end @_query[]



##############################################################################
@GET_to_sql[]
	$result[^self._query[]]
#end @GET_to_sql[]



##############################################################################
@_param[hParam]
	$result[
		^if($hParam.limit){
			$.limit($hParam.limit)
		}{
			^if($self._criteria._limit){
				$.limit($self._criteria._limit)
			}
		}
		^if($hParam.offset){
			$.offset($hParam.offset)
		}{
			^if($self._criteria._offset){
				$.offset($self._criteria._offset)
			}
		}
	]
#end @_param[]