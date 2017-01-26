##############################################################################
@form_tag[uURL;hOptions;*args]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.method[post]
		^if(def $uURL){
			$.action[^url_for[$uURL]]
		}
	]]
	$jBody{^args.foreach[k;v]{$v}[^;]}
	
	^if(^hOptions.multipart.bool(false)){
		$hOptions.enctype[multipart/form-data]
		^hOptions.delete[multipart]
	}
	
	$result[^content_tag[form;${jBody};$hOptions]]
#end @form_tag[]



##############################################################################
@field_set_tag[uLegend;hOptions;jBody]
	$result[^content_tag[legend;${uLegend}${jBody};$hOptions]]
#end @field_set_tag[]



##############################################################################
@label_tag[sName;sText;hOptions]
	$hOptions[^hash::create[$hOptions]]

	$result[^content_tag[label;^if(def $sText){$sText}{$sName};^hOptions.union[$.for[$sName]]]]
#end @label_tag[]



##############################################################################
@text_field_tag[sName;sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^tag[input;^hOptions.union[$.type[text] $.id[$sName] $.name[$sName] $.value[$sValue]]]]
#end @text_field_tag[]



##############################################################################
@hidden_field_tag[sName;sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^text_field_tag[$sName;$sValue;^hOptions.union[$.type[hidden]]]]
#end @hidden_field_tag[]



##############################################################################
@password_field_tag[sName;sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^text_field_tag[$sName;$sValue;^hOptions.union[$.type[password]]]]
#end @password_field_tag[]



##############################################################################
@file_field_tag[sName;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^text_field_tag[$sName;;^hOptions.union[$.type[file]]]]
#end @file_field_tag[]



##############################################################################
@check_box_tag[sName;sValue;bChecked;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.type[checkbox]
		$.id[$sName]
		$.name[$sName]
		$.value[$sValue]
		^if($bChecked){$.checked(true)}
	]]

	$result[^tag[input;$hOptions]]
#end @check_box_tag[]



##############################################################################
@radio_button_tag[sName;sValue;bChecked;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.type[radio]
		$.id[$sName]
		$.name[$sName]
		$.value[$sValue]
		^if($bChecked){$.checked(true)}
	]]

	$result[^tag[input;$hOptions]]
#end @radio_button_tag[]



##############################################################################
@text_area_tag[sName;sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^content_tag[textarea;^taint[html][$sValue];^hOptions.union[ $.id[$sName] $.name[$sName] ]]]
#end @text_area_tag[]




##############################################################################
@select_tag[sName;jOptionsTags;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^content_tag[select;$jOptionsTags;^hOptions.union[ $.id[$sName] ^if(def $sName){$.name[$sName]} ]]]
#end @select_tag[]



##############################################################################
@grouped_options_for_select[hOption;uSelected;hOptions]
	^if($hOption){
		^hOption.foreach[label;aOptions]{
			<optgroup label="$label">
				^options_for_select[$aOptions;$uSelected;$hOptions]
			</optgroup>
		}
	}
#end @grouped_options_for_select[]



##############################################################################
@options_for_select[aOptions;uSelected;hOptions][id;value;name;options;selected;disabled]
	$result[]
	
	$hOptions[^hash::create[$hOptions]]
	$selected[^hash::create[]]
	$disabled[^hash::create[]]
	
	^rem{ *** преобразуем uSelected в хеш *** }
	^if(def $uSelected){
		^switch[$uSelected.CLASS_NAME]{
			^case[array]{
				$selected[^uSelected.hash[]]
			}
				
			^case[hash;enum]{
				$selected[$uSelected]
			}

			^case[DEFAULT]{
				$selected.[$uSelected](true)
			}
		}
	}
	
	^rem{ *** преобразуем hOptions.disabled в хеш *** }
	^if($hOptions.disabled){
		^switch[$hOptions.disabled.CLASS_NAME]{
			^case[array]{
				$disabled[^hOptions.disabled.hash[]]
			}
				
			^case[hash;enum]{
				$disabled[$hOptions.disabled]
			}

			^case[DEFAULT]{
				$disabled.[$hOptions.disabled](true)
			}
		}
	}
	
	^aOptions.foreach[id;value]{
		^if($value is Model || $value is ActiveRelation){
			$id[$value.id]
		}
		
		$result[$result^option_for_select[$id;$value;$selected;$hOptions]]
	}
#end @options_for_select[]



##############################################################################
@option_for_select[sId;uValue;uSelected;hOptions][options;selected;disabled;name]
	$hOptions[^hash::create[$hOptions]]
	$selected[^hash::create[]]
	$disabled[^hash::create[]]

	^rem{ *** преобразуем uSelected в хеш *** }
	^if(def $uSelected){
		^switch[$uSelected.CLASS_NAME]{
			^case[array]{
				$selected[^uSelected.hash[]]
			}
			
			^case[hash;enum]{
				$selected[$uSelected]
			}
			
			^case[bool]{
				$selected.[$sId][$uSelected]
			}

			^case[DEFAULT]{
				$selected.[$uSelected](true)
			}
		}
		
		^hOptions.delete[selected]
	}

	^rem{ *** преобразуем hOptions.disabled в хеш *** }
	^if(def $hOptions.disabled){
		^switch[$hOptions.disabled.CLASS_NAME]{
			^case[array]{
				$disabled[^hOptions.disabled.hash[]]
			}
			
			^case[hash]{
				$disabled[$hOptions.disabled]
			}

			^case[DEFAULT]{
				$disabled.[$hOptions.disabled](true)
			}
		}
		
		^hOptions.delete[disabled]
	}
	
	$options[
		$.value[$sId]
	]
	^options.add[$hOptions]

	^if($selected.[$sId]){
		$options.selected[selected]
	}
	^if($disabled.[$sId]){
		$options.disabled[disabled]
	}

	^if($uValue is hash){
		$name[^if(!def $uValue.name){$sId}{$uValue.name}]
		^options.add[$uValue]
	}{
		$name[^if(!def $uValue){$sId}{$uValue}]
	}

	$result[^content_tag[option;$name;$options]]
#end @option_for_select[]



##############################################################################
@submit_tag[sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$result[^tag[input;^hOptions.union[$.type[submit] $.value[$sValue]]]]
#end @submit_tag[]



##############################################################################
@button_tag[sValue;hOptions]
	$hOptions[^hash::create[$hOptions]]
	^if(def $hOptions.confirm){
		$hOptions.onclick[if (confirm ('$hOptions.confirm')) { ^if(def $hOptions.onclick){$hOptions.onclick}{return true^;} } else { return false^; }]
		^hOptions.delete[confirm]
	}
	$result[^content_tag[button;$sValue;$hOptions]]
#end @button_tag[]



##############################################################################
#	TODO: try to find image on "images" dir in PublicPath
@image_submit_tag[sSource;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.type[image]
		$.src[$sSource]
	]]

	$result[^tag[input;$hOptions]]
#end @image_submit_tag[]