##############################################################################
#	
##############################################################################

@CLASS
FormBuilder

@OPTIONS
locals



##############################################################################
@create[sName;oObject;hOptions;oView]
	$self._name[$sName]
	$self._object[$oObject]
	$self._options[$hOptions]
	
	$self._template[$caller.CLASS]
	^if($oView){
		$self._template[$oView]
	}
#end @create[]



##############################################################################
@GET_object[]
	$result[$self._object]
#end @GET_object[]



##############################################################################
@fields_for[uRecordName;uRecordObject;hOptions;sForm;*args][name;as;object;options;form;item;builder;_code_from;_old_as;_old_form]
	$args[^hash::create[$args]]

	^if($uRecordName is string){
		$name[$uRecordName]
		$as[$name]
		
		^if($uRecordObject is hash){
			$object[$caller.[$uRecordName]]
			^if(!$object){
				$object[$self.object.[$uRecordName]]
			}
			$options[^hash::create[$uRecordObject]]
			$form[$hOptions]
			$_code_from(4)
		}($uRecordObject is string){
			$object[$caller.[$uRecordName]]
			^if(!$object){
				$object[$self.object.[$uRecordName]]
			}
			$form[$uRecordObject]
			$_code_from(3)
		}{
			$object[$uRecordObject]

			^if($hOptions is hash){
				$options[^hash::create[$hOptions]]
				$form[$sForm]
				$_code_from(5)
			}{
				$form[$hOptions]
				$_code_from(4)
			}
		}
		^if(^is_array[$object] || $object is ManyAssociation){
			$name[${name}[]]
		}
	}{
		$object[$uRecordName]
		$name[$object.model_name]
		$as[$name]
		
		^if(^is_array[$object] || $object is ManyAssociation){
			$name[${object.0.model_name}[]]
			$as[$object.0.model_name]
		}

		^if($uRecordObject is hash){
			$options[^hash::create[$uRecordObject]]
			$form[$hOptions]
			$_code_from(4)
		}{
			$form[$uRecordObject]
			$_code_from(3)
		}
	}
	^if(def $options.as){
		$as[$options.as]
	}
	
	$_old_form[$caller.$form]
	$_old_as[$caller.$as]

	^if(^is_array[$object] || $object is ManyAssociation){
		^foreach[$object;item]{
			$builder[^FormBuilder::create[${self._name}.$name;$item;$options][$self._template]]
			$caller.[$form][$builder]
			$caller.[$as][$item]
			$result[$result^if($_code_from <= 3){$hOptions}^if($_code_from <= 4){$sForm}^args.foreach[k;v]{$v}[^;]]
		}
	}{
		$builder[^FormBuilder::create[${self._name}.$name;$object;$options][$self._template]]
		$caller.[$form][$builder]
		$caller.[$as][$object]
		$result[^if($_code_from <= 3){$hOptions}^if($_code_from <= 4){$sForm}^args.foreach[k;v]{$v}[^;]]
	}
	
	$caller.[$form][$_old_form]
	$caller.[$as][$_old_as]
#end @fields_for[]



##############################################################################
@label[sName;sText;hOptions]
	$result[^self._template.label[${self._name}.$sName;$sText;$hOptions]]
#end @label[]



##############################################################################
@hidden_field[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.hidden_field[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @hidden_field[]



##############################################################################
@text_field[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.text_field[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @text_field[]



##############################################################################
@password_field[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.password_field[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @password_field[]



##############################################################################
@text_area[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.text_area[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @text_area[]



##############################################################################
@file_field[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.file_field[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @file_field[]



##############################################################################
@check_box_tag[sName;sValue;bChecked;hOptions]
	$result[^self._template.check_box_tag[${self._name}.$sName;$sValue;$bChecked;$hOptions]]
#end @check_box_tag[]


##############################################################################
@check_box[sName;bChecked;hOptions;sCheckedValue;sUncheckedValue]
	$result[^self._template.check_box[${self._name}.$sName;$bChecked;$hOptions;$sCheckedValue;$sUncheckedValue]]
#end @check_box[]



##############################################################################
@labeled_check_box[sName;sLabel;bChecked;hOptions;hCheckboxOptions;sCheckedValue;sUncheckedValue]
	$result[^self._template.labeled_check_box[${self._name}.$sName;$sLabel;$bChecked;$hOptions;$hCheckboxOptions;$sCheckedValue;$sUncheckedValue]]
#end @labeled_check_box[]



##############################################################################
@labeled_check_box_tag[sName;sId;uValue;sLabel;bChecked;hOptions;hCheckboxOptions]
	$result[^self._template.labeled_check_box_tag[${self._name}.$sName;${self._name}.$sId;$uValue;$sLabel;$bChecked;$hOptions;$hCheckboxOptions]]
#end @labeled_check_box_tag[]



##############################################################################
@radio_button[sName;uValue;bChecked;hOptions]
	$result[^self._template.radio_button[${self._name}.$sName;$uValue;$bChecked;$hOptions]]
#end @radio_button[]



##############################################################################
@labeled_radio_button[sName;uValue;sLabel;bChecked;hOptions;hButtonOptions]
	$result[^self._template.labeled_radio_button[${self._name}.$sName;$uValue;$sLabel;$bChecked;$hOptions;$hButtonOptions]]
#end @labeled_radio_button[]



##############################################################################
@select_tag[sName;jOptionsTags;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.select_tag[$sName]{$jOptionsTags}[^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @select_tag[]



##############################################################################
@input_date[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.input_date[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @input_date[]



##############################################################################
@input_time[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.input_time[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @input_time[]



##############################################################################
@input_datetime[sName;uValue;hOptions][options]
	$options[^hash::create[$hOptions]]
	$result[^self._template.input_datetime[$sName;^if(def $uValue){$uValue}{$self._object}][^options.union[ $.name[${self._name}.$sName] $.id[${self._name}.$sName] ]]]
#end @input_datetime[]
