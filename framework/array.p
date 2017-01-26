##############################################################################
#	
##############################################################################

@CLASS
array

@OPTIONS
locals



##############################################################################
@GET[type]
	^switch[$type]{
		^case[double;bool]{
			$result($self._count)
		}
		
		^case[DEFAULT;hash]{
			$result[$self._array]
		}
	}
#end @GET[]



##############################################################################
@GET_DEFAULT[uIndex]
	^if(^uIndex.int(-1) >= 0){
		$result[$self._array.$uIndex]
	}{
#		$result[]
		$result[$self._array.[$self._cur].[$uIndex]]
	}
#end @GET_DEFAULT[]



##############################################################################
@SET_DEFAULT[uIndex;uValue]
	^if($self._iterator_start){
		$result[$self._array.[$self._cur].[$uIndex][$uValue]]
	}{
		^if(^uIndex.int(-1) >= 0){
			$result[$self._array.[$uIndex][$uValue]]
		}{
			$result[$self._array.[$self._cur].[$uIndex][$uValue]]
		}
	}
#end @SET_DEFAULT[]



##############################################################################
@GET_items[]
	$result[$_array]
#end @GET_items[]



##############################################################################
@create[*args][args]
	$self._iterator_start(false)
	$self._cur(0)
	$self._count(0)
	$self._array[^hash::create[]]
	
	^if($args){
		^switch($args){
			^case(0){}

			^rem{ *** 1 аргумент *** }
			^case(1){
				$uValue[$args.0]
				^switch[$uValue.CLASS_NAME]{
					^case[HasManyAssociation;HasAndBelongsToManyAssociation]{
						^self.join[$uValue]
					}
					
					^case[array]{
						$self._count($uValue._count)
						$self._array[^hash::create[$uValue._array]]
					}

					^case[hash]{
						^uValue.foreach[key;val]{^self.add[$val]}
					}
					
					^case[table]{
						^uValue.menu{^self.add[$uValue.fields]}
					}
					
					^case[string;int;double;date]{
						^self.add[$uValue]
					}
					
					^case[void]{
						^rem{ *** ничего не создаем и ошибку не выкидываем *** }
					}

					^case[DEFAULT]{
						^throw[ErrorConstructorParameter;ErrorConstructorParameter;Can't create array by $uValue.CLASS_NAME]
					}
				}
			}

			^rem{ *** множественный конструктор через ; *** }
			^case[DEFAULT]{
				^args.foreach[key;val]{^self.add[$val]}
			}
		}
	}
#end @create[]



##############################################################################
@GET_count[][result]
	$self._count
#end @GET_count[]



##############################################################################
@add[uValue]
	$self._array.[$self._count][$uValue]
	^self._count.inc[]
	$result[]
#end @add[]



##############################################################################
@delete[iKey]
	^if(def ^self._array.contains[$iKey]){
		^for[i]($iKey + 1;$self._count){
			$self._array.[^eval($i - 1)][$self._array.[$i]]
		}

		^self._array.sub[
			$.[^eval($self._count - 1)](true)
		]
		^self._count.dec[]
	}

	$result[]
#end @delete[]



##############################################################################
@join[aArray][i;value]
	^if($aArray){
		^aArray.foreach[i;value]{^self.add[$value]}
	}

	$result[]
#end @join[]



##############################################################################
#@menu[jCode;jSeparatorCode][i]
#	^if($_count){
#		$result[^for[i](0;$_count - 1){$jCode}{$jSeparatorCode}]
#	}{
#		$result[]
#	}
#end @menu[]



#############################################################################
@foreach[sKeyName;sValueName;jCode;jSeparatorCode][i;_oldKey;_oldVal]
	$self._iterator_start(true)

	$_oldKey[$caller.$sKeyName]
	$_oldVal[$caller.$sValueName]

	^if($self._count){
#		$result[^for[i](0;$self._count - 1){$caller.$sKeyName($i)$caller.$sValueName[$self._array.[$i]]$jCode}{$jSeparatorCode}]
		$result[^self._array.foreach[k;v]{$self._cur($k)$caller.$sKeyName($k)$caller.$sValueName[$v]$jCode}{$jSeparatorCode}]
		$self._cur(0)
	}{
		$result[]
	}

	$caller.$sKeyName[$_oldKey]
	$caller.$sValueName[$_oldVal]
	
	$self._iterator_start(false)
end @foreach[]



##############################################################################
@GET__foreach[]
	$result[^reflection:method[$self._array;foreach]]
#end @GET_foreach[]



##############################################################################
@hash[uKey;hParam][locals]
	$hParam[^hash::create[$hParam]]

	$result[^hash::create[]]
	
	^switch[$hParam.type]{
		^case[map]{
			$result[^self.map[$uKey;$hParam.name]]
		}
		^case[array]{
			^self._foreach[i;value]{
				^if(def $hParam.value){
					$caller.[$hParam.value][$value]
				}
				
				^if($uKey is junction || $hParam.bJunction){
					$key[$uKey]
				}{
					^if(!def $uKey){
						$key[$value]
					}{
						$key[$value.$uKey]
					}
				}

				^if(!def $result.[$key]){
					$result.[$key][^array::create[]]
				}
				^result.[$key].add[$value]
			}
		}
		
		^case[DEFAULT;hash]{
			^self._foreach[i;value]{
				^if(def $hParam.value){
					$caller.[$hParam.value][$value]
				}

				^if($uKey is junction || $hParam.bJunction){
					$key[$uKey]
				}{
					^if(!def $uKey){
						$key[$value]
					}{
						$key[$value.$uKey]
					}
				}

				$result.[$key][$value]
			}
		}
	}
#end @hash[]



##############################################################################
@tree[*args]
	^if(!$args){
		^throw[parser.runtime;tree;key for tree array must be specify]
	}
	
	$key_count($args)

	^rem{ *** если последний аргумент не строка, значит это опции преобразования *** }
	^if(!($args.[^eval($key_count - 1)] is string)){
		$options[$args.[^eval($key_count - 1)]]
		^args.delete[^eval($key_count - 1)]
	}

	$result[^self._tree[$args;$options]]
#end @tree[]



##############################################################################
@_tree[hKeys;hOptions]
	^if($hKeys > 1){
		$result[^self.hash[$hKeys.0][ $.type[array] ]]

		^result.foreach[key;values]{
			$result.[$key][^values._tree[
				^hKeys.foreach[k;v]{
					^if($k == 0){^continue[]}
					$.[^eval($k - 1)][$v]
				}
			][$hOptions]]
		}
	}{
		$result[^self.hash[$hKeys.0][$hOptions]]
	}
#end @_tree[]



##############################################################################
@map[uKey;uValue;hParam][i;v;key;value]
	^if(!def $uKey){
		^throw[parser.runtime;map;key for map array must be specify]
	}
	
	$result[^hash::create[]]
	
	^self._foreach[i;v]{
		$self._cur($i)
		$key[^if($uKey is junction){$uKey}{$v.$uKey}]
		^if(!def $uValue){
			$value[$v]
		}{
			$value[^if($uValue is junction || $hParam.bJunction){$uValue}{$v.$uValue}]
		}

		$result.[$key][$value]
	}
	$self._cur(0)
#end @map[]



##############################################################################
@array[uValue;hParam]
	$result[^array::create[]]

	^self._foreach[i;v]{
		$self._cur($i)
		^result.add[^if($uValue is junction || $hParam.bJunction){$uValue}{$v.$uValue}]
	}
	$self._cur(0)
#end @array[]



##############################################################################
#@sort[jBody;sDirection]
#	^if($body is junction){
#		^self._list.sort{$body}[$sDirection]
#	}{
#		^self._list.sort($body)[$sDirection]
#	}
#end @sort[]



##############################################################################
@revert[]
	$result[^array::create[]]
#	$result._count($self._count)
		
	^self._foreach[i;val]{
		$k($self._count - $i - 1)
		^result.add[$self._array.[$k]]
	}
#end @revert[]



##############################################################################
@sort[sField;sDirection]
#	$sort_table[^table::create{id	func}]
#	
#	^self._foreach[i;val]{
#		^sort_table.append{$i	^eval($val.[$sField])}
#	}
#	^sort_table.sort($sort_table.func)[$sDirection]
#	
#	$result[^array::create[]]
#	^sort_table.menu{
#		^result.add[$self._array.[$sort_table.id]]
#	}
	
	$result[^array::create[]]
	^result.join[$self]
	
	^for[j](0;$self._count - 2){
		^for[i](0;$self._count - $j - 2){
			^if(
				($sDirection eq "desc" && $result._array.[$i].[$sField] < $result._array.[^eval($i + 1)].[$sField]) ||
				($sDirection ne "desc" && $result._array.[$i].[$sField] > $result._array.[^eval($i + 1)].[$sField])
			){
				$e[$result._array.[$i]]
				$result._array.[$i][$result._array.[^eval($i + 1)]]
				$result._array.[^eval($i + 1)][$e]
			}
		}
	}
#end @sort[]
