##############################################################################
#	TODO: block @merge after load records = throw_exception
##############################################################################

@CLASS
ActiveRelation

@OPTIONS
locals
partial
dynamic

@BASE
Environment



##############################################################################
@_inspect[]
	$result[$self.CLASS_NAME ($self.MAPPER.CLASS_NAME)]
#end @_inspect[]



##############################################################################
@GET[type]
	^switch[$type]{
		^case[def]{
			$result(true)
		}

		^case[bool]{
			^if($self._is_counted){
				$result($self._data_count)
			}{
				$result($self.records)
			}
		}

		^case[DEFAULT;hash]{
			$result[$self.records]
		}
	}
#end @GET[]



##############################################################################
@GET_DEFAULT[sName]
^Environment:oLogger.trace[ar.GET]{^inspect[$self] : $sName}{
	$scope[$self.MAPPER.SCOPES.[$sName]]

	^if(def $scope){
		$result[^self.clone[$scope]]											^rem{ *** если в MAPPER объявлен такой scope то это обращение к нему *** }
		$result[$result.clone]
	}{
		$result[$self.records.[$sName]]
	}
}
#end @GET_DEFAULT[]



##############################################################################
@SET_DEFAULT[sName;uValue]
	$self.records.[$sName][$uValue]
	$result[]
#end @SET_DEFAULT[]



##############################################################################
@GET_MAPPER[]
	$result[$self._mapper]
#end @GET_MAPPER[]


##############################################################################
@GET_CRITERIA[]
	$result[$self._criteria]
#end @GET_CRITERIA[]



##############################################################################
@GET_records[]
	^if(!$self._is_loaded){
		^self._load[]
	}
	
	$result[$self._data]
#end @GET_records[]



##############################################################################
@_init[hFields]
^Environment:oLogger.trace[ar.init;_init $self.MAPPER.CLASS_NAME]{
	$result[^self.MAPPER.CLASS._init[$hFields](!def $self.CRITERIA._column)]
}
#end @_init[]



##############################################################################
@_load[]
^Environment:oLogger.trace[ar.load;load]{
	$self._is_loaded(true)

	$self._data[^array::create[]]

	^if(!$self._none){
		$objects[^self._find[]]

		^objects.menu{
			^self._data.add[^self._init[$objects.fields]]
		}{
			^if(^objects.offset[] % 50 == 0){^Rusage:compact[]}
		}

#		^if($objects > 100){^Rusage:compact[]}

		^self.MAPPER._load_association[$self._data;$self.CRITERIA._include]		^rem{ *** load include association *** }
	}
}
#end @_load[]



##############################################################################
@create[oMapper]
	$self._mapper[$oMapper]
	$self._base[]
	$self._criteria[^AMCriteria::create[]]
	
	$self._is_counted(false)
	$self._is_loaded(false)
	$self._cur_position(0)
	$self._data[^array::create[]]
	$self._data_count(0)
	
	$self._none(false)
	$self._unscoped(false)
#end @create[]



##############################################################################
@reset[]
	$self._is_counted(false)
	$self._is_loaded(false)
	$self._cur_position(0)
	$self._data[^array::create[]]
	$self._data_count(0)
#end @reset[]



##############################################################################
@unscoped[uParam1;uParam2]
^Framework:oLogger.trace[ar.unscoped]{^inspect[$self]}{
	$result[^reflection:create[$self.CLASS_NAME;create;$self.MAPPER]]
	$result._unscoped(true)
	^result.merge[$uParam1]
	^result.merge[$uParam2]
}
#end @unscoped[]



##############################################################################
@clone[uParam]
^Framework:oLogger.trace[ar.clone]{^inspect[$self] : ^inspect[$self.CRITERIA.alias]}{
	$result[^reflection:create[$self.CLASS_NAME;create;$self.MAPPER]]
#	$result._base[$self]
	^result.merge[$self.CRITERIA]
	^result.merge[$uParam]

#	$result.CRITERIA.alias[$self.CRITERIA.alias]								^rem{ *** alais наследуем *** }
	
	$result._unscoped($self._unscoped)
	$result._none($self._none)
}
#end @clone[]



##############################################################################
@merge[uParam]
^Framework:oLogger.trace[ar.merge]{^inspect[$self]}{
	^self.CRITERIA.merge[$uParam]

#	$result[$self]
	$result[]
}{
	$.uParam[$uParam]
}
#end @merge[]



##############################################################################
@plug[uParam;uParam2]
^Framework:oLogger.trace[ar.plug]{^inspect[$self]}{
	^if(def $uParam || def $uParam2){
		$relation[^self.clone[$uParam]]
		^relation.merge[$uParam2]

		$result[^relation.plug[]]
	}{		
		$result[^array::create[]]

		^if(!$self._none){
			$objects[^self._plug[]]
			^objects.menu{
				^result.add[$objects.fields]
			}
		}
	}
}
#end @plug[]



##############################################################################
@count[uParam;uParam2]
^Framework:oLogger.trace[ar.count]{^inspect[$self]}{
	^if(def $uParam || def $uParam2){
		$relation[^self.clone[$uParam]]
		^relation.merge[$uParam2]

		$result[^relation.count[]]
	}{
		^if($self._is_loaded){
			$result($self.records)
		}{
			^if(!$self._is_counted){
				$self._is_counted(true)
				$self._data_count(^self._count[])
			}
			
			$result($self._data_count)
		}
	}
}
#end @count[]



##############################################################################
@find[uParam;uParam2]
^Framework:oLogger.trace[ar.find]{^inspect[$self] : ^inspect[$uParam]}{
	^if(def $uParam || def $uParam2){
		^switch[$uParam.CLASS_NAME]{
			^case[int;double]{
				$result[^self.find_by_id[$uParam;$uParam2]]
				
				^if(!$result){
					^throw[RecordNotFound;$self.MAPPER.CLASS_NAME#RecordNotFound;Record not found]
				}
			}

			^case[string]{
				$uParam[^uParam.trim[]]

				^if(def $uParam){
					$result[^self.find_by_ids[$uParam;$uParam2]]
				}{
					$result[^self.find_by_param[$uParam2]]
				}
			}

			^case[DEFAULT]{
				^if(^is_array[$uParam]){
					$result[^self.find_by_ids[$uParam;$uParam2]]
				}{
					^if(!def $uParam2){
						$result[^self.find_by_param[$uParam]]
					}{
						$result[^self.find_by_param[$uParam;$uParam2]]
					}
				}
			}
		}
	}{
		$result[$self.records]
	}
}
#end @find[]



##############################################################################
@find_by_param[uParam;uParam2]
^Framework:oLogger.trace[ar.find.by_param]{^inspect[$self] : ^inspect[$uParam]}{
	$relation[^self.clone[$uParam]]
	^relation.merge[$uParam2]
	$result[^relation.find[]]
}
#end @find_by_param[]



##############################################################################
@find_by_id[iId;uParam]
^Framework:oLogger.trace[ar.find.by_id]{^inspect[$self] : ^inspect[$iId]}{
	^if($iId && !^self.MAPPER.is_model_in_cache[$iId] || $uParam){
		$relation[^self.where[^if(def $self.CRITERIA.alias){`$self.CRITERIA.alias`}{`$self.MAPPER.table_name`}.`$self.MAPPER.primary_key` = $iId]]
		^relation.merge[$uParam]
		$result[^relation.first[]]
		$result[$result.0]
	}{
		$result[^self.MAPPER.get_model_from_cache[$iId]]
	}
}
#end @find_by_id[]



##############################################################################
@find_by_ids[sId;uParam][id]
^Framework:oLogger.trace[ar.find.by_ids]{^inspect[$self] : ^inspect[$sId]}{
	^if(^is_array[$sId]){
		$sId[^foreach[$sId;id]{$id}[,]]
	}
	$relation[^self.where[^if(def $self.CRITERIA.alias){`$self.CRITERIA.alias`}{`$self.MAPPER.table_name`}.`$self.MAPPER.primary_key` IN ($sId)]]
	^relation.merge[$uParam]
	$result[^relation.find[]]
}
#end @find_by_ids[]



##############################################################################
@find_first[uParam;uParam2]
^Framework:oLogger.trace[ar.find.first]{^inspect[$self] : ^inspect[$uParam]}{
	^if($uParam is int || $uParam is double){
		$result[^self.find_by_id[$uParam;$uParam2]]
	}{
		$result[^self.first[][$uParam]]
		^result.merge[$uParam2]
		$result[$result.0]
	}
}
#end @find_first[]



##############################################################################
@first[iLimit;uParam]
^Framework:oLogger.trace[ar.first]{^inspect[$self]}{
	^if($self._is_loaded && !$uParam){
		$result[$self]															^rem{ *** TODO: copy to new relation with this data of 1 records *** }
	}{
		^rem{ *** load from DB *** }
		$relation[^self.limit(1)]
		^relation.merge[$uParam]

		^relation._load[]
		
		$result[$relation]
	}
}{
	$.Limit($iLimit)
}
#end @first[]



##############################################################################
@all[uParam;uParam2]
^Framework:oLogger.trace[ar.all]{^inspect[$self] : all with params: ^inspect[$uParam]}{
	^if(def $uParam || def $uParam2){
		$relation[^self.clone[$uParam]]
		^relation.merge[$uParam2]

		$result[$relation]
	}{
		$result[$self]
	}
}
#end @all[]
