##############################################################################
@input_date[sName;dValue;hOptions]
^if($dValue is Model || $dValue is ActiveRelation || $dValue is OneAssociation){
	$result[^input_date[${dValue.model_name}.${sName};$dValue.attributes.[$sName];$hOptions]]
}{
	$result[^text_field[${sName}.day;^if(def $dValue){$dValue.day}][
		$hOptions
		$.size(1)
	]
	^text_field[${sName}.month;^if(def $dValue){$dValue.month}][
		$hOptions
		$.size(1)
	]
	^text_field[${sName}.year;^if(def $dValue){$dValue.year}][
		$hOptions
		$.size(3)
	]]
}
#end @input_date[]



##############################################################################
@input_time[sName;dValue;hOptions]
^if($dValue is Model || $dValue is ActiveRelation || $dValue is OneAssociation){
	$result[^input_time[${dValue.model_name}.${sName};$dValue.attributes.[$sName];$hOptions]]
}{
	$result[^text_field[${sName}.hour;^if(def $dValue){$dValue.hour}][
		$hOptions
		$.size(1)
	]
	:
	^text_field[${sName}.minute;^if(def $dValue){$dValue.minute}][
		$hOptions
		$.size(1)
	]
	:
	^text_field[${sName}.second;^if(def $dValue){$dValue.second}][
		$hOptions
		$.size(1)
	]]
}
#end @input_time[]



##############################################################################
@input_datetime[sName;dValue;hOptions]
	$result[^input_date[$sName;$dValue;$hOptions]&nbsp^;^input_time[$sName;$dValue;$hOptions]]
#end @input_datetime[]
