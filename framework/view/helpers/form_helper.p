##############################################################################
@form_for[uRecord;hOptions;sForm;*args][options;object;name;builder]
	$options[^hash::create[$hOptions]]

	^if($uRecord is string){
		$object[$caller.[$uRecord]]
		$name[$uRecord]
	}{
		$object[$uRecord]
		$name[$uRecord.model_name]
	}
	^if(def $options.as){
		$name[$options.as]
	}
	$builder[^FormBuilder::create[$name;$object;$options]]
	$caller.[$sForm][$builder]

	$result[^form_tag[$options.url;$options.html]{^args.foreach[k;v]{$v}[^;]}]
#end @form_for[]



##############################################################################
@fields_for[uRecordName;uRecordObject;hOptions;sForm;*args][name;as;object;options;form;item;builder;_code_from;_old_as;_old_form]
	$args[^hash::create[$args]]

	^if($uRecordName is string){
		$name[$uRecordName]
		$as[$name]
		
		^if($uRecordObject is hash){
			$object[$caller.[$uRecordName]]
			$options[^hash::create[$uRecordObject]]
			$form[$hOptions]
			$_code_from(4)
		}($uRecordObject is string && def $uRecordObject){
			$object[$caller.[$uRecordName]]
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
			$builder[^FormBuilder::create[$name;$item;$options]]
			$caller.[$form][$builder]
			$caller.[$as][$item]
			$result[$result^if($_code_from <= 3){$hOptions}^if($_code_from <= 4){$sForm}^args.foreach[k;v]{$v}[^;]]
		}
	}{
		$builder[^FormBuilder::create[$name;$object;$options]]
		$caller.[$form][$builder]
		$caller.[$as][$object]
		$result[^if($_code_from <= 3){$hOptions}^if($_code_from <= 4){$sForm}^args.foreach[k;v]{$v}[^;]]
	}
	
	$caller.[$form][$_old_form]
	$caller.[$as][$_old_as]
#end @fields_for[]



##############################################################################
@decode_errors[aErrors][locals]
	$result[^aErrors.foreach[k;v]{<div>$v.msg</div>}]
#end @decode_errors[]



##############################################################################
@label[sName;sText;hOptions]
	$result[^label_tag[$sName;$sText;$hOptions]]
#end @label[]



##############################################################################
@text_field[sName;sValue;hOptions]
	^if($sValue is Model || $sValue is ActiveRelation || $sValue is OneAssociation){
		$result[^text_field_tag[${sValue.model_name}.${sName};$sValue.attributes.[$sName];$hOptions]]
	}{
		$result[^text_field_tag[$sName;$sValue;$hOptions]]
	}
#end @text_field[]



##############################################################################
@hidden_field[sName;sValue;hOptions]
	^if($sValue is Model || $sValue is ActiveRelation || $sValue is OneAssociation){
		$result[^hidden_field_tag[${sValue.model_name}.${sName};$sValue.attributes.[$sName];$hOptions]]
	}{
		$result[^hidden_field_tag[$sName;$sValue;$hOptions]]
	}
#end @hidden_field[]



##############################################################################
@password_field[sName;sValue;hOptions]
	^if($sValue is Model || $sValue is ActiveRelation || $sValue is OneAssociation){
		$result[^password_field_tag[${sValue.model_name}.${sName};;$hOptions]]
	}{
		$result[^password_field_tag[$sName;$sValue;$hOptions]]
	}
#end @password_field[]



##############################################################################
@text_area[sName;sValue;hOptions]
	^if($sValue is Model || $sValue is ActiveRelation || $sValue is OneAssociation){
		$result[^text_area_tag[${sValue.model_name}.${sName};$sValue.[$sName];$hOptions]]
	}{
		$result[^text_area_tag[$sName;$sValue;$hOptions]]
	}
#end @text_area[]



##############################################################################
@file_field[sName;sValue;hOptions]
	^if($sValue is Model || $sValue is ActiveRelation || $sValue is OneAssociation){
		$result[^file_field_tag[${sValue.model_name}.${sName};$hOptions]]
	}{
		$result[^file_field_tag[$sName;$hOptions]]
	}
#end @file_field[]



##############################################################################
@check_box[sName;bChecked;hOptions;sCheckedValue;sUncheckedValue]
	$result[^check_box_tag[$sName;^if(def $sCheckedValue){$sCheckedValue}{1};$bChecked;$hOptions]]
	$result[$result^hidden_field_tag[$sName;^if(def $sUncheckedValue){$sUncheckedValue}{0};$.id[${sName}_hidden]^if($hOptions && def $hOptions.disabled){$.disabled[$hOptions.disabled]}]]
#end @check_box[]



##############################################################################
@labeled_check_box[sName;sLabel;bChecked;hOptions;hCheckboxOptions;sCheckedValue;sUncheckedValue]
	$result[^label[$sName][^check_box[$sName;$bChecked;$hCheckboxOptions;$sCheckedValue;$sUncheckedValue] $sLabel][$hOptions]]
#end @labeled_check_box[]



##############################################################################
@labeled_check_box_tag[sName;sId;sValue;sLabel;bChecked;hOptions;hCheckboxOptions]
	$result[^label[$sId][^check_box_tag[$sName;$sValue;$bChecked;$hCheckboxOptions $.id[$sId] ] $sLabel][$hOptions]]
#end @labeled_check_box_tag[]



##############################################################################
@radio_button[sName;sValue;bChecked;hOptions]
	$result[^radio_button_tag[$sName;$sValue;$bChecked;$hOptions]]
#end @radio_button[]



##############################################################################
@labeled_radio_button[sName;sValue;sLabel;bChecked;hOptions;hButtonOptions][button_options]
	$button_options[^hash::create[$hButtonOptions]]
	$options[^hash::create[$hOptions]]
	$result[^label[$button_options.id][^radio_button[$sName;$sValue;$bChecked;^button_options.union[ $.id[${sName}.${sValue}] ]] $sLabel][^options.union[ $.for[${sName}.${sValue}] ]]]
#end @labeled_radio_button[]
