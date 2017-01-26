##############################################################################
#	
##############################################################################

@CLASS
DBField

@OPTIONS
locals
partial


##############################################################################
@auto[]
	$self._now[^date::now[]]
#end @auto[]



##############################################################################
@create[hData]
	^rem{ *** аттрибут *** }
	$self._name[^if(def $hData.name){$hData.name}{$hData.alias}]
	
	^rem{ *** alias *** }
	$self._alias[$hData.alias]

	^rem{ *** тип данных *** }
	$self._type[$hData.type]

	^rem{ *** TODO: create DataType by $_type *** }
#	$_data_type[^DataType::create[$_name;$hData.options]]

	$self._length(^hData.length.int(255))
	$self._not_null(^hData.not_null.bool(false))
	
	$self._is_protected[^hData.is_protected.bool(false)]
#end @create[]



##############################################################################
@GET_system_type[]
	$result[^switch[$self.type]{
		^case[int]{int}
		^case[string;text]{string}
		^case[date;datetime]{date}
		^case[DEFAULT]{$self.type}
	}]
#end @GET_system_type[]



##############################################################################
@init[uData]
	^if(def $uData || $self.not_null){
		$result[^DBField:prepare_value[$self._type;$uData]]
	}{
		$result[]
	}
#end @init[]



##############################################################################
@value[sData]
	$result[^switch[$self.type]{
		^case[double]{^if(def $sData){^sData.format[%f]}{DEFAULT}}
		^case[int]{^if(def $sData){^sData.int[]}{DEFAULT}}
		^case[bool]{^if(def $sData){^sData.int[]}{DEFAULT}}
		^case[date;datetime]{^if(def $sData){"^sData.sql-string[]"}{DEFAULT}}
		^case[DEFAULT]{^if(def $sData){"^taint[sql][$sData]"}{DEFAULT}}
	}]
#end @value[]



##############################################################################
@prepare_value_old[uData]
	$result[^switch[$uData.CLASS_NAME]{
		^case[double]{^if(def $uData){^uData.double[]}{DEFAULT}}
		^case[int]{^if(def $uData){^uData.int[]}{DEFAULT}}
		^case[bool]{^if(def $uData){^uData.int[]}{DEFAULT}}
		^case[date]{^if(def $uData){"^uData.sql-string[]"}{DEFAULT}}
		^case[DEFAULT]{^if(def $uData){"^taint[sql][$uData]"}{DEFAULT}}
	}]
#end @prepare_value_old[]



##############################################################################
@static:prepare_value[sType;uData]
	^switch[$sType]{
		^case[double]{
			^rem{ *** храним double в виде форматированной строки,
				      т.к. возникают проблемы с округлением при передаче
				      значения без круглых скобок *** }
			$result[^uData.replace[,;.]]
			$result(^result.double[])
			$result[^result.format[%f]]
			$result[^result.match[(?:\.0+|(\.\d+?)0+)^$][]{$match.1}]
		}
		^case[int]{
			$result(^uData.int[])
		}
		^case[bool]{
			$result(^uData.bool[])
		}
		^case[date;datetime]{
			^switch[$uData.CLASS_NAME]{
				^case[hash]{
					^if(def $uData.year || def $uData.month || def $uData.day || def $uData.hour || def $uData.minute){
						$result[^date::create(^if(^uData.year.int($_now.year) > 99){^uData.year.int($_now.year)}{^math:floor($_now.year / 100)^eval(^uData.year.int(0))[%02.0f]};^uData.month.int($_now.month);^uData.day.int($_now.day);^uData.hour.int(0);^uData.minute.int(0);^uData.second.int(0))]
					}{
						$result[]
					}
				}
				^case[string]{
					^rem{ *** для пустых дат создавать пустое значение *** }
					^if($uData eq "0000-00-00 00:00:00" || $uData eq "0000-00-00"){
						$result[]
					}{
						^if(^uData.double(0)){
							$result[^date::create($uData)]
						}{
							$result[^date::create[$uData]]
						}
					}
				}
				^case[DEFAULT]{
					$result[^date::create[$uData]]
				}
			}
		}
		^case[DEFAULT]{
			$result[$uData]
		}
	}
#end @prepare_value[]



##############################################################################
@sql-string[uData]
	$result[^switch[$uData.CLASS_NAME]{
		^case[double]{^if(def $uData){^uData.double[]}{0}}
		^case[int]{^if(def $uData){^uData.int[]}{0}}
		^case[bool]{^if(def $uData){^uData.int[]}{0}}
		^case[date]{^if(def $uData){"^uData.sql-string[]"}{"0000-00-00"}}
		^case[DEFAULT]{^if(def $uData){"^taint[sql][$uData]"}{""}}
	}]
#end @sql-string[]



##############################################################################
#	Метод возвращает true - если значения идентичны и false в противном случае
##############################################################################
@compare_value[uOldData;uNewData]
	^switch[$self.type]{
		^case[bool]{$result($uOldData == ^uNewData.bool(false))}
		^case[int;double]{$result($uOldData == ^uNewData.double(0))}
		^case[date;datetime]{$result(^self.init[$uOldData] == ^self.init[$uNewData])}
		^case[DEFAULT]{$result($uOldData eq $uNewData)}
	}
#end @compare_value[]