##############################################################################
@throw_inspect[uParams;sComment]
	^throw[InspectObject.^if($uParams is junction){junction}{$uParams.CLASS_NAME};^inspect{$uParams};^if(!def $sComment && ^is[$uParams;Model] && ^reflection:dynamical[$uParams]){^inspect[$uParams.attributes]}{$sComment}]
#end @throw_inspect[]



##############################################################################
@inspect[uParams][result]
	^if($uParams is junction){
		$result[junction]
	}{
		^switch[$uParams.CLASS_NAME]{
			^case[regex]{$result[$uParams.pattern]}
			^case[xdoc]{$result[^inspect_xdoc[$uParams]]}
			^case[xnode]{$result[^inspect_xnode[$uParams]]}
			^case[bool]{$result[^inspect_bool[$uParams]]}
			^case[array]{$result[^inspect_array[$uParams]]}
			^case[hash;hashfile]{$result[^inspect_hash[$uParams]]}
			^case[table]{$result[^inspect_table[$uParams]]}
			^case[date]{$result["^uParams.sql-string[]"]}
			^case[int;double]{$result[$uParams]}
			^case[string]{$result["^uParams.trim[]"]}
			^case[void]{$result[void]}
			^case[DEFAULT]{
				^if($uParams._inspect is junction){
					$result[^uParams._inspect[]]
				}{
					$result[$uParams.CLASS_NAME]
				}
			}
		}
	}
#end @inspect[]



##############################################################################
@inspect_xdoc[xParams]
	$result[^xParams.string[]]
#end @inspect_xdoc[]



##############################################################################
@inspect_xnode[xNode][list;node;i]
	^switch($xNode.nodeType){
		^case($xdoc:ATTRIBUTE_NODE){
			$result[$xNode.nodeValue]
		}

		^case($xdoc:ELEMENT_NODE){
			$result[^hash::create[]]
			
			$list[^xNode.select[*]]
			
			^for[i](0;$list-1){
				$node[$list.$i]
				$result.[$node.nodeName][^inspect_xnode[$node]]
			}
			
			^if($list){
				$result[^inspect[$result]]
			}{
				$result[^xNode.selectString[string(.)]]
			}
		}

		^case($xdoc:TEXT_NODE){
			$result[$xNode.nodeValue]
		}

		^case($xdoc:DOCUMENT_NODE){
			$result[^inspect_xnode[$xNode.documentElement]]
		}

		^case[DEFAULT]{
			^throw_inspect[(DEF) $xNode.nodeName = $xNode.nodeType]
		}
	}
#end @inspect_xnode[]



##############################################################################
@inspect_bool[bParams]
	$result[^if($bParams){true}{false}]
#end @inspect_bool[]



##############################################################################
@inspect_table[tParams]
	$result[[^tParams.menu{^inspect[$tParams.fields]}[, ]]]
#end @inspect_bool[]



##############################################################################
@inspect_array[aArray][locals]
	$result[[ ^aArray.foreach[key;value]{^inspect[$value]}[, ] ]]
#end @inspect_array[]



##############################################################################
@inspect_hash[hParams][locals]
#	$keys[^hParams._keys[key]]
#	^keys.sort{$keys.key}

#	$result[{ ^keys.menu{"$keys.key" => ^inspect[$hParams.[$keys.key]]}[, ] }]
	$result[{^hParams.foreach[key;value]{"$key" => ^inspect[$value]}[, ]}]
#end @inspect_hash[]



##############################################################################
@inspect_errors[aErrors][field]
	$result[[^aErrors.foreach[key;value]{$field[^value.field.split[,;;name]]{"code": "$value.code", "field": [^field.menu{"$field.name"}[,]], "msg": "$value.msg"}}[,]]]
#end @inspect_errors[]