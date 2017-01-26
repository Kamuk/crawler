##############################################################################
#	
##############################################################################

@CLASS
Model

@OPTIONS
locals
partial



##############################################################################
@static:GET_model_name[]
	$result[$self.META.model_name]
#end @GET_model_name[]



##############################################################################
@GET_class_name[]
	$result[$self.META.class_name]
#end @GET_class_name[]



##############################################################################
@static:GET_table_name[]
	^if(!def $self.META.table_name){
		$self.META.table_name[^string_transform[$self.class_name;classname_to_filename]]
	}
	
	$result[$self.META.table_name]
#end @GET_table_name[]



##############################################################################
@static:SET__table_name[sName]
	$self.META.table_name[$sName]
#end @SET__table_name[]



##############################################################################
@static:GET_primary_key[]
	^if(!def $self.META.primary_key){
		$self.META.primary_key[${table_name}_id]
	}

	$result[$self.META.primary_key]
#end @GET_primary_key[]



##############################################################################
@static:SET_primary_key[sKey]
	$self.META.primary_key[$sKey]
#end @SET_primary_key[]



##############################################################################
@static:SET__primary_key[sKey]
	$self.META.primary_key[$sKey]
#end @SET__primary_key[]



##############################################################################
@static:_init[hData]
^oLogger.trace[m.init]{Init model $self.class_name}{
	$result[^reflection:create[$self.class_name;create;$hData]]
}
#end @_init[]






##############################################################################
@static:count[uParam;uParam2]
^oLogger.trace[fw.m.find]{Model count of $class_name}{
	$result[^self._count_by_param[$uParam;$uParam2]]
}{
	$.Params[$uParam]
	$.Params2[$uParam2]
}
#end @count[]



##############################################################################
@static:find_by_id[iId;uParam]
^oLogger.trace[m.find]{Model find_by_id of $class_name}{
	$result[^self._find_by_id[$iId;$uParam]]
}{
	$.Id[$iId]
	$.Params[$uParam]
}
#end @find_by_id[]



##############################################################################
@static:find_by_ids[uIds;uParam][id]
^oLogger.trace[m.find]{Model find_by_ids of $class_name}{
	^if(^is_array[$uIds]){
		$result[^self._find_by_ids[^foreach[$uIds;id]{$id}[,];$uParam]]
	}{
		$result[^self._find_by_ids[$uIds;$uParam]]
	}
}{
	$.Ids[$uIds]
	$.Params[$uParam]
}
#end @find_by_ids[]



##############################################################################
@static:find_first[uParam;uParam2]
^oLogger.trace[m.find]{Model find_first of $class_name}{
	^if($uParam is int || $uParam is double){
		$result[^self._find_by_id[$uParam;$uParam2]]
	}{
		$result[^self._find_first[$uParam;$uParam2]]
	}
}{
	$.Params[$uParam]
	$.Params2[$uParam2]
}
#end @find_first[]



##############################################################################
@static:find_by_attributes[hAttributes;uParams]
^oLogger.trace[m.find]{Model _find_by_attributes of $class_name}{
	$result[^self._find_by_attributes[$hAttributes;$uParams]]
}
#end @find_by_attributes[]



##############################################################################
@static:find_by_param[uParam;uParam2]
^oLogger.trace[m.find]{Model _find_by_param of $class_name}{
	$result[^self._find_by_param[$uParam;$uParam2]]
}
#end @find_by_params[]



##############################################################################
#	^Model:find(10)
#	^Model:find[10,12,13]
#	
#	.select
#	.condition
#	.from
#	.joins
#	.include
#	.group
#	.having
#	.order
#	.limit
#	.offset
##############################################################################
@static:find[uId;uParam]
^oLogger.trace[m.find]{Model find of $class_name}{
	^switch[$uId.CLASS_NAME]{
		^case[int;double]{
			$result[^self.find_by_id[$uId;$uParam]]
			
			^if(!$result){
				^throw[RecordNotFound;$class_name#RecordNotFound;Record not found]
			}
		}

		^case[string]{
			$uId[^uId.trim[]]
			
			^if(def $uId){
				$result[^self.find_by_ids[$uId;$uParam]]
			}{
				$result[^self.find_by_param[$uParam]]
			}
		}

		^case[DEFAULT]{
			^if(^is_array[$uId]){
				$result[^self.find_by_ids[$uId;$uParam]]
			}{
				^if(!def $uParam){
					$result[^self.find_by_param[$uId]]
				}{
					$result[^self.find_by_param[$uId;$uParam]]
				}
			}
		}
	}
}{
	$.Params[$uId]
	$.Params2[$uParam]
}
#end @find[]



##############################################################################
#	TODO: rename to save_all and meka save use it method (for DRY)
##############################################################################
@static:insert_all[aModels;hDataDuplicate]
	$result(true)
	
	^foreach[$aModels;model]{
		^rem{ *** если уже в фазе сохранения - повторно не вызываем *** }
		^if(!$model.is_valid){
			^throw_inspect[^model.errors.array[]]
		}
		^if(!($model is $self.CLASS_NAME)){
			^throw_inspect[invalid model for save]
		}

		$model._in_save(true)
		
		$model.__is_new($model.is_new)	^rem{ *** temp var for is_new flag *** }

		^model.before_save[]
		^if($model.__is_new){
			^model.before_create[]
		}{
			^model.before_update[]
		}
	}
	
	^self._insert_all[$aModels;$hDataDuplicate]

	^foreach[$aModels;model]{
		$model._created(false)
		$model._changed(false)

		^rem{ *** фаза сохранения заканчивается после записи в БД,
			      если будет вызван повторный save - он внесет изменения в БД *** }
		$model._in_save(false)
	
		^if($model.__is_new){
			^model.after_create[]
		}{
			^model.after_update[]
		}
		^model.after_save[]

		$model.attributes_was[$NULL]
	}
#end @insert_all[]



##############################################################################
@static:update_all[hData;hParam]
	$hData[^hash::create[$hData]]

	$result(true)
	^if(def $hData){
		^_update_all[$hData;^hash::create[$hParam]]
	}
#end @update_all[]



##############################################################################
@static:delete_all[hParam]
	$result(true)
	^_delete_all[^hash::create[$hParam]]
#end @delete_all[]



##############################################################################
@static:destroy_all[hParam]
	$result(true)
	^_destroy_all[^hash::create[$hParam]]
#end @destroy[]
