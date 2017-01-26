##############################################################################
#	
##############################################################################

@CLASS
Framework

@OPTIONS
partial



##############################################################################
@use_application[sName]
	$_app_name[^if(def $sName){$sName}{app}]

	^MAIN:CLASS_PATH.append{$CONFIG:sRootPath/$_app_name/controllers}
#	^MAIN:CLASS_PATH.append{$CONFIG:sRootPath/$_app_name/helpers}
	^MAIN:CLASS_PATH.append{$CONFIG:sRootPath/$_app_name/models}
	^MAIN:CLASS_PATH.append{$CONFIG:sRootPath/$_app_name/mailer}
	^MAIN:CLASS_PATH.append{$CONFIG:sRootPath/$_app_name/views/mailer}

	^include_application[$_app_name]
#end @use_application[]



##############################################################################
@include_application[sName]
	^use[$CONFIG:sRootPath/$sName/application.p]
	^if(-f "$CONFIG:sRootPath/$sName/helpers/^Controller:_contoller_helper_name[application]"){
		^include[$CONFIG:sRootPath/$sName/helpers/^Controller:_contoller_helper_name[application]][$Controller:CLASS]
	}
#end @include_application[]



##############################################################################
@instance_application[sName]
	^if($sName ne "app"){
		$result[^process{^^^Application:_application_class_name[$sName]::create[]}]
	}{
		$result[^ApplicationController::create[]]
	}
#end @instance_application[]



##############################################################################
@include_controller[sName]
	^if(-f "$CONFIG:sRootPath/$_app_name/controllers/^Controller:_contoller_file_name[$sName]"){
		^use[$CONFIG:sRootPath/$_app_name/controllers/^Controller:_contoller_file_name[$sName]]
	}{
		^throw[framework.controller;^Controller:_contoller_file_name[$sName];Controller '^Controller:_contoller_file_name[$sName]' not found]
	}
	^if(-f "$CONFIG:sRootPath/$_app_name/helpers/^Controller:_contoller_helper_name[$sName]"){
		^include[$CONFIG:sRootPath/$_app_name/helpers/^Controller:_contoller_helper_name[$sName]][$Controller:CLASS}]
	}
#end @include_controller[]



##############################################################################
@instance_controller[sName]
	$result[^process{^^^Controller:_controller_class_name[$sName]::create[]}]
#end @instance_controller[]



##############################################################################
#	Метод подключает необходимые для модели классы
#	и создает одноименную переменную для массовой работы с моделью
##############################################################################
@include_model[sName][class_name]
	$class_name[^string_transform[$sName;filename_to_classname]]
		
	^if(!def $$class_name){
		^if(-f "$CONFIG:sModelPath/${sName}_mapper.p"){
			^use[$CONFIG:sModelPath/${sName}_mapper.p]
		}
		^use[$CONFIG:sModelPath/${sName}.p]
	
		$$class_name[^process{^^${class_name}::create_base[]}]
	}
#end @include_model[]
