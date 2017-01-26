##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
partial



##############################################################################
@_contoller_file_name[sController]
	$result[^string_transform[$sController;decode]_controller.p]
#end @_contoller_file_name[]



##############################################################################
@_contoller_helper_name[sController]
	$result[^string_transform[$sController;decode]_helpers.p]
#end @_contoller_file_name[]



##############################################################################
@_controller_class_name[sController]
	$result[^string_transform[$sController]Controller]
#end @_controller_class_name[]



##############################################################################
@_controller_name[sControllerClassName]
	$result[^sControllerClassName.match[Controller^$][i]{}]
	$result[^string_transform[$result;decode]]
#end @_controller_name[]



##############################################################################
@_action_method_name[sAction]
	$result[a^string_transform[$sAction]]
#end @_action_method_name[]



##############################################################################
@_action_name[sActionMethodName]
	$result[^sActionMethodName.match[^^a][i]{}]
	$result[^string_transform[$result;decode]]
#end @_action_name[]



##############################################################################
@_template_name[sAction;sController]
	$result[^if(def $sController){$sController}{$controller_name}/^if(def $sAction){$sAction}{$action_name}]
#end @_template_name[]



##############################################################################
@_filter_parameters[hParams;uFilter][keys]
	^if(!def $uFilter){$uFilter[$self.parameter_filter]}

	^switch[$uFilter.CLASS_NAME]{
		^case[hash]{
			$result[^hash::create[$hParams]]
			^result.sub[$uFilter]
		}
		^case[table]{
			$result[^_filter_parameters[$hParams;^uFilter.hash[key;key][$.type[string]]]]
		}
		^case[string]{
			^if(^uFilter.pos[,] >= 0){
				$result[^uFilter.match[\s][gi]{}]
				$result[^_filter_parameters[$hParams;^result.split[,;v;key]]]
			}{
				$result[^hash::create[$hParams]]
				^result.delete[$uFilter]
			}
		}
		^case[DEFAULT]{
			$result[^hash::create[$hParams]]
		}
	}
	
	^rem{ *** delete all parameters that name start of "_" *** }
	$keys[^result._keys[name]]
	$keys[^keys.select(^keys.name.pos[_] == 0)]
	^result.sub[^keys.hash[name]]
#end @_filter_parameters[]



##############################################################################
@_form_names[sPrefix]
	$result[^array::create[]]

	$form_names[^table::create{field_name	prefix	postfix	0	1	2	3	4	5	6	7	8	9}]
	^form:fields.foreach[field_name;v]{
		$nameparts[^field_name.split[.][lh]]
		$nameparts[$nameparts.fields]

		$is_array[^nameparts.0.match[\[\]^$]]
		$name[^nameparts.0.match[\[\]^$][i]{}]								^rem{ *** убираем [] с конца строки *** }
		
		$prefix[$nameparts.0]
		$postfix[^field_name.mid(^prefix.length[])]
		$postfix[^postfix.trim[left;.]]
		
		^form_names.append{$field_name	$prefix	$postfix	$nameparts.0	$nameparts.1	$nameparts.2	$nameparts.3	$nameparts.4	$nameparts.5	$nameparts.6	$nameparts.7	$nameparts.8	$nameparts.9}
		
		^result.add[
			$.name[$field_name]
#			$.prefix[$prefix]
#			$.postfix[$postfix]
			^for[i](0;9){
				$.[$i][$nameparts.[$i]]
			}
		]
	}
	
#	$result[^form_names.hash[prefix][ $.type[table] $.distinct(true) ]]
#end @_form_names[]



##############################################################################
@_params_genereate[aForms;iIndex;iIndexValue]
	^if($iIndex > 0){
		$prefix[$aForms.0.[^eval($iIndex - 1)]]
	}
	
	$array_regexp[\[\]^$]

	^if($iIndex && $aForms == 1 && $aForms.0.[$iIndex] is void){
		$form[$aForms.0]
		$name[$form.name]

		$values[$form:tables.[$name]]
		$files[$form:files.[$name]]

		^if(!^prefix.match[$array_regexp]){
			^if(def $values){
				^values.offset[set]($iIndexValue)
				$result[$values.field]
			}
			^if(def $files){
				$result[$files.[$iIndexValue]]
			}
		}{
			^if(def $values){
				$result[^array::create[^values.hash{^values.offset[]}[field][ $.type[string] ]]]
			}
			^if(def $files){
				$result[$files]
			}
		}
	}{
		$f[^aForms.hash[$iIndex][ $.type[array] ]]
		
		^if(^prefix.match[\[\]^$]){
			$result[^array::create[]]

			$values[^table::create[$form:tables.[$aForms.0.name]]]					^rem{ *** количество элементов в массиве равно количеству значений первого значения формы *** }
			^values.menu{
				$item[^hash::create[]]
				^result.add[$item]

				^f.foreach[prefix;parts]{
					$item.[^prefix.match[$array_regexp][]{}][^_params_genereate[$parts]($iIndex + 1)(^values.offset[])]
				}
			}
		}{
			$result[^hash::create[]]
			
			^f.foreach[prefix;parts]{
				$result.[^prefix.match[$array_regexp][]{}][^_params_genereate[$parts]($iIndex + 1)($iIndexValue)]
			}
		}
	}
#end @_params_genereate[]



##############################################################################
@_prepare_forms[][f;keys]
	$f[^_form_names[]]
	$result[^_params_genereate[$f;0]]
	
	^rem{ *** delete all parameters that name start of "_" *** }
	$keys[^result._keys[name]]
	$keys[^keys.select(^keys.name.pos[_] == 0)]
	^result.sub[^keys.hash[name]]
#end @_prepare_forms[]



##############################################################################
#	listing helpers folder and include all helpers by sPatternName (* - include all)
##############################################################################
@include_helpers[sPatternName][files]
	^if($sPatternName eq "*"){
		$sPatternName[.*]
	}

	^rem{ *** подключаем хелперы из стандратного приложения *** }
	^if($_app_name ne "app"){
		$files[^file:list[$CONFIG:sRootPath/app/helpers;^^${sPatternName}_helpers\.p^$]]
		^files.menu{^include[$CONFIG:sRootPath/app/helpers/$files.name][$Controller:CLASS]}
	}
	^if(def $sPatternName){
		$files[^file:list[$CONFIG:sRootPath/$_app_name/helpers;^^${sPatternName}_helpers\.p^$]]
		^files.menu{^include[$CONFIG:sRootPath/$_app_name/helpers/$files.name][$Controller:CLASS]}
	}
#end @include_helpers[]
