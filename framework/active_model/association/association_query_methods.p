##############################################################################
#	Проксирование методов в ActiveRelation
##############################################################################

@CLASS
Association

@OPTIONS
partial
locals



##############################################################################
@static:GET_count[]
	^if($self is OneAssociation){
		$result[$self.data.count]
	}{
		$result[$self.RELATION.count]											^rem{ *** FIX: исключение для получения count значения поля из модели *** }
	}
#end @GET_count[]



##############################################################################
@static:GET_find[]
	$result[$self.RELATION.find]
#end @GET_find[]



##############################################################################
@static:GET_find_by_id[]
	$result[$self.RELATION.find_by_id]
#end @GET_find_by_id[]



##############################################################################
@static:GET_find_by_ids[]
	$result[$self.RELATION.find_by_ids]
#end @GET_find_by_ids[]



##############################################################################
@static:GET_find_first[]
	$result[$self.RELATION.find_first]
#end @GET_find_first[]



##############################################################################
@static:GET_find_by_param[]
	$result[$self.RELATION.find_by_param]
#end @GET_find_by_param[]



##############################################################################
@static:GET_plug[]
	$result[$self.RELATION.plug]
#end @static:GET_plug[]



##############################################################################
@static:GET_all[]
	$result[$self.RELATION.all]
#end @static:GET_all[]



##############################################################################
@static:GET_first[]
	$result[$self.RELATION.first]
#end @static:GET_first[]



##############################################################################
@static:GET_distinct[]
	$result[$self.RELATION.distinct]
#end @static:GET_distinct[]



##############################################################################
@static:GET_select[]
	$result[$self.RELATION.select]
#end @static:GET_select[]



##############################################################################
@static:GET_join[]
	$result[$self.RELATION.join]
#end @static:GET_join[]



##############################################################################
@static:GET_where[]
	$result[$self.RELATION.where]
#end @static:GET_where[]



##############################################################################
@static:GET_grouping[]
	$result[$self.RELATION.grouping]
#end @static:GET_grouping[]



##############################################################################
@static:GET_having[]
	$result[$self.RELATION.having]
#end @static:GET_having[]



##############################################################################
@static:GET_sort[]
	$result[$self.RELATION.sort]
#end @static:GET_sort[]



##############################################################################
@static:GET_resort[]
	$result[$self.RELATION.resort]
#end @static:GET_resort[]



##############################################################################
@static:GET_include[]
	$result[$self.RELATION.include]
#end @static:GET_include[]



##############################################################################
@static:GET_limit[]
	$result[$self.RELATION.limit]
#end @static:GET_limit[]



##############################################################################
@static:GET_offset[]
	$result[$self.RELATION.offset]
#end @static:GET_offset[]



##############################################################################
@static:GET_none[]
	$result[$self.RELATION.none]
#end @static:GET_none[]



##############################################################################
@static:GET_unscoped[]
	$result[$self.RELATION.unscoped]
#end @static:GET_unscoped[]
