##############################################################################
@include[sFilename;oContext][fFile]
	$fFile[^file::load[text;$sFilename]]
	^process[^if(def $oContext){$oContext}{$caller.self}]{^untaint[as-is]{$fFile.text}}[
	   $.file[$sFilename]
	]
#end @include[]



##############################################################################
@test[uResult;jCode;sComment][_result;_test_result]
	$_result[$jCode]
	$_test_result($uResult eq $_result)

	$result[<span style="color: ^if($_test_result){green}{red}^;">[^if($_test_result){VALID}{FAILD}]</span>]
	$result[$result ${uResult}: <span style="color: ^if($_test_result){green}{red}^;">$_result</span>]
	^if(def $sComment){$result[$result <span style="color: #666^; font-style: italic^;">#$sComment</span>]}
#end @test[]



##############################################################################
#	Array: is hash with numerable keys $.0[] $.1[] etc.
@is_array[uArray]
	$result($uArray is array || $uArray is enum || ($uArray is hash && ^uArray.contains[0]))
#end @is_array[]




##############################################################################
@is[uVar;sType]
	$result($uVar is $sType || ($uVar is OneAssociation && $uVar.object is $sType))
#end @is[]



##############################################################################
@foreach[uArray;sValueName;jCode;jSeparatorCode][locals]
	$_oldVal[$caller.$sValueName]

	^switch(true){
		^case($uArray is array){
			$result[^uArray.foreach[i;uValue]{$caller.$sValueName[$uValue]$jCode}{$jSeparatorCode}]
		}

		^case($uArray is hash || $uArray is enum){
			$result[^uArray.foreach[key;uValue]{$caller.$sValueName[$uValue]$jCode}{$jSeparatorCode}]
#			$result[^for[i](0;^uArray._count[]-1){$caller.$sValueName[$uArray.[$i]]$jCode}{$jSeparatorCode}]
		}

		^case[DEFAULT]{
			$uArray[^hash::create[$uArray]]
			$result[^for[i](0;^uArray._count[]-1){$caller.$sValueName[$uArray.[$i]]$jCode}{$jSeparatorCode}]
			
#			^throw[parser.runtime;$uArray.CLASS_NAME;foreach need array (parameter #1)]
		}
	}

	$caller.$sValueName[$_oldVal]
#end @foreach[]



##############################################################################
#	Transform hash to inner hash (no nesting limit)
#	
#	$hHash[
#		$.name[name]
#		$.block[block]
#		$.block.name[block_name]
#		$.block.data[block_data]
#	]
#	$result[
#		$.name[name]
#		$.block[
#			$.block[block]
#			$.name[block_name]
#			$.data[block_data]
#		]
#	]
##############################################################################
@to_innerhash[hHash][n;v;data;nameparts;name]
	$result[^hash::create[]]

	^hHash.foreach[n;v]{
		$data[$result]
		$nameparts[^n.split[.]]

		^nameparts.menu{
			$name[$nameparts.piece]
			
			^if(^nameparts.line[] == ^nameparts.count[] && !^data.contains[$name]){
				^continue[]
			}
	
			^if(!^data.contains[$name]){
				$data.[$name][^hash::create[]]
			}{
				^if(!($data.[$name] is hash)){
					$data.[$name][
						$.[$name][$data.[$name]]
					]
				}
			}

			$data[$data.[$name]]
		}
		
		$data.[$name][$v]
	}
#end @to_innerhash[]
