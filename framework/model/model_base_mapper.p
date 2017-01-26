##############################################################################
#	
##############################################################################

@CLASS
Model

@OPTIONS
locals
partial



##############################################################################
@static:_count_by_param[uParam]
	$criteria[^SqlCriteria::create[$uParam]]

	$result[^self._count[$criteria]]
#end @_count_by_param[]



##############################################################################
#	iId - id искомой модели
#	uParam - дополнительные параметры (hash, SqlCriteria)
##############################################################################
@static:_find_by_id[iId;uParam]
^oLogger.trace[m.find]{Model _find_by_id of $class_name}{
	$criteria[^SqlCriteria::create[]]
	^criteria.condition[^if(def $uParam && def $uParam.alias){`$uParam.alias`}{`$self.table_name`}.`$self.primary_key` = $iId]
	^criteria.merge[$uParam]

	$result[^self._find_first[$criteria]]
}{
	$.ID[$iId]
	$.Params[$uParam]
}
#end @_find_by_id[]



##############################################################################
#	sId - id искомых моделей (строка, разделитель ",")
#	uParam - дополнительные параметры (hash, SqlCriteria)
##############################################################################
@static:_find_by_ids[sId;uParam]
^oLogger.trace[m.find]{Model _find_by_ids of $class_name}{
	$criteria[^SqlCriteria::create[]]
	^criteria.condition[^if(def $uParam && def $uParam.alias){`$uParam.alias`}{`$self.table_name`}.`$self.primary_key` IN ($sId)]
	^criteria.merge[$uParam]
	
	$object[^self._find[$criteria]]

	$result[^array::create[]]
	^object.menu{
		^result.add[^_init[$object.fields](!def $criteria._column)]
	}
}{
	$.IDs[$sId]
	$.Params[$uParam]
}
#end @_find_by_ids[]



##############################################################################
#	uParam - параметры поиска (hash, SqlCriteria)
##############################################################################
@static:_find_first[uParam;uParam2]
^oLogger.trace[m.find]{Model _find_first of $class_name}{
	$criteria[^SqlCriteria::create[$uParam]]
	^criteria.limit(1)
	^if(def $uParam2){
		^criteria.merge[$uParam2]
	}
	
	$object[^self._find[$criteria]]

	^if(!$object){
		$result[$NULL]
	}{
		$result[^_init[$object.fields](!def $criteria._column)]
	}
}{
	$.Params[$uParam]
}
#end @_find_first[]



##############################################################################
@static:_find_by_attributes[hAttributes;uParam]
^oLogger.trace[m.find]{Model _find_by_attributes of $class_name}{
	$criteria[^SqlCriteria::create[$uParam]]
	
	^hAttributes.foreach[alias;value]{
		$field[$self.FIELDS.[$alias]]

		^if(def $field){
			^criteria.condition[$field.name = ^field.prepare_value[$value]]
		}
	}
	
	$object[^self._find[$criteria]]
	
	$result[^array::create[]]
	^object.menu{
		^result.add[^_init[$object.fields](!def $criteria._column)]
	}
}{
	$.Attributes[$hAttributes]
	$.Params[$uParam]
}
#end @_find_by_attributes[]



##############################################################################
@static:_find_by_param[uParam;uParam2]
^oLogger.debug[m.find]{Model _find_by_param of $class_name}{
	$criteria[^SqlCriteria::create[$uParam]]
	^if(def $uParam2){
		^criteria.merge[$uParam2]
	}

	$object[^self._find[$criteria]]
	
	$result[^array::create[]]
	^object.menu{
		^result.add[^_init[$object.fields](!def $criteria._column)]
	}
}{
	$.Params[$uParam]
	$.Params2[$uParam2]
}
#end @_find_by_param[]



##############################################################################
@_update[]
	^rem{ *** FIXME: what update if primary = false *** }
	^self.CLASS._update_all[$self.attributes][
		$.condition[`${self.table_name}`.`$self.primary_key` = $self.id]
	][$self]
#end @_update[]



##############################################################################
@_delete[]
	^rem{ *** FIXME: what delete if primary = false *** }
	^self.CLASS._delete_all[
		$.condition[`${self.table_name}`.`$self.primary_key` = $self.id]
	]
#end @_delete[]



##############################################################################
#	Более оптимизированный вариант
#	^foreach[$objects;object]{^object._destroy[]}
#	^self.delete_all[^foreach[$objects;object]{$object.id}[,]]
##############################################################################
@static:_destroy_all[hParam][objects;object]
	$objects[^self.find[$hParam]]
	^foreach[$objects;object]{$r(^object.destroy[])}
#end @_destroy_all[]
