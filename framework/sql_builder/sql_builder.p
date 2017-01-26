##############################################################################
#	
##############################################################################

@CLASS
SqlBuilder

@OPTIONS
partial

@USE
sql_condition.p
sql_criteria.p



##############################################################################
@create[oSql]
	$SqlBuilder:_sql[$oSql]
#end @create[]



##############################################################################
@execute[hParam]
	$hParam[^hash::create[$hParam]]
	$result[^_sql.$_query_type{^_query[]}[^_param[$hParam]]]
#end @execute[]



##############################################################################
@select[sType]
	^use[select_sql_builder.p]
	$result[^SelectSqlBuilder::create[$sType]]
#end @select[]



##############################################################################
#@insert[][result]
#	^InsertSqlBuilder::create[$self]
#end @insert[]



##############################################################################
#@update[][result]
#	^UpdateSqlBuilder::create[$self]
#end @update[]



##############################################################################
#@delete[][result]
#	^DeleteSqlBuilder::create[$self]
#end @delete[]