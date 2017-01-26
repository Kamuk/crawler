##############################################################################
#	Проксируем в ActiveRelation
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
@static:GET__count_by_param[]
	$result[$self.CLASS.model_relation.count]
#end @GET_count[]




##############################################################################
@static:GET_find[]
^oLogger.trace[am.find]{ActiveModel _find of $class_name}{
	$result[$self.CLASS.model_relation.find]
}
#end @GET_find[]



##############################################################################
@static:GET_find_by_id[]
^oLogger.trace[am.find]{ActiveModel _find_by_id of $self.CLASS_NAME}{
	$result[$self.CLASS.model_relation.find_by_id]
}
#end @GET_find_by_id[]



##############################################################################
@static:GET_find_by_ids[]
^oLogger.trace[am.find]{ActiveModel _find_by_ids of $class_name}{
	$result[$self.CLASS.model_relation.find_by_ids]
}
#end @GET_find_by_ids[]



##############################################################################
@static:GET_find_first[]
^oLogger.trace[am.find]{ActiveModel _find_first of $class_name}{	
	$result[$self.CLASS.model_relation.find_first]
}
#end @GET_find_first[]



##############################################################################
@static:GET_find_by_param[]
^oLogger.trace[am.find]{ActiveModel _find_by_param of $class_name}{
	$result[$self.CLASS.model_relation.find_by_param]
}
#end @GET_find_by_param[]



##############################################################################
@static:_find_by_attributes[hAttributes;uParam]
^oLogger.trace[am.find]{ActiveModel _find_by_attributes of $class_name}{	
	$relation[$self.CLASS.model_relation]

	$criteria[^SqlCriteria::create[$uParam]]
	^hAttributes.foreach[alias;value]{
		$field[$self.FIELDS.[$alias]]

		^if(def $field){
			^criteria.condition[$field.name = ^field.sql-string[$value]]
		}
	}
	^relation.merge[$criteria]

	$result[$relation]
}{
	$.Attributes[$hAttributes]
	$.Params[$uParam]
}
#end @_find_by_attributes[]



##############################################################################
@static:GET_plug[]
^oLogger.trace[am.find]{ActiveModel plug of $class_name}{
	$result[$self.CLASS.model_relation.plug]
}
#end @static:GET_plug[]



##############################################################################
@static:GET_find_each[]
^oLogger.trace[am.find_each]{ActiveModel find_each of $class_name}{
	$result[$self.CLASS.model_relation.find_each]
}
#end @static:GET_find_each[]



##############################################################################
@static:GET_all[]
^Framework:oLogger.trace[am.all]{$self.CLASS_NAME : all proxy to model_relation}{
	$result[$self.CLASS.model_relation.all]
}
#end @static:GET_all[]



##############################################################################
@static:GET_first[]
	$result[$self.CLASS.model_relation.first]
#end @static:GET_first[]



##############################################################################
@static:GET_distinct[]
	$result[$self.CLASS.model_relation.distinct]
#end @static:GET_distinct[]



##############################################################################
@static:GET_select[]
	$result[$self.CLASS.model_relation.select]
#end @static:GET_select[]



##############################################################################
@static:GET_join[]
	$result[$self.CLASS.model_relation.join]
#end @static:GET_join[]



##############################################################################
@static:GET_where[]
	$result[$self.CLASS.model_relation.where]
#end @static:GET_where[]



##############################################################################
@static:GET_grouping[]
	$result[$self.CLASS.model_relation.grouping]
#end @static:GET_grouping[]



##############################################################################
@static:GET_having[]
	$result[$self.CLASS.model_relation.having]
#end @static:GET_having[]



##############################################################################
@static:GET_sort[]
	$result[$self.CLASS.model_relation.sort]
#end @static:GET_sort[]



##############################################################################
@static:GET_include[]
	$result[$self.CLASS.model_relation.include]
#end @static:GET_include[]



##############################################################################
@static:GET_limit[]
	$result[$self.CLASS.model_relation.limit]
#end @static:GET_limit[]



##############################################################################
@static:GET_offset[]
	$result[$self.CLASS.model_relation.offset]
#end @static:GET_offset[]



##############################################################################
@static:GET_none[]
	$result[$self.CLASS.model_relation.none]
#end @static:GET_none[]



##############################################################################
@static:GET_unscoped[]
	$result[$self.CLASS.model_relation.unscoped]
#end @static:GET_unscoped[]
