##############################################################################
#
##############################################################################

@CLASS
Application

@OPTIONS
partial

@BASE
Environment



##############################################################################
@auto[]
	^rem{ *** перекрываем метод, чтобы не вызывался из Framework повторно *** }
#end @auto[]



##############################################################################
@_application_name[sApplication]
	$result[^if(def $sApplication){$sApplication}{app}]
#end @_application_name[]



##############################################################################
@_application_file_name[sApplication]
	$result[^string_transform[^sApplication.match[Application(Controller)?^$][i]{};classname_to_filename]]
#end @_application_file_name[]



##############################################################################
@_application_class_name[sApplication]
	$result[^string_transform[$sApplication;filename_to_classname]Application]
#end @_application_class_name[]



##############################################################################
@create[][_environment_path]
#	$_app_name[^_application_file_name[$self.CLASS_NAME]]
	$_base_path[$CONFIG.sRootPath/^if(def $_app_name){$_app_name}{app}]

	$_environment_path[$_base_path/config/environment.p]
	^if(-f $_environment_path){
		^include[$_environment_path][$Environment:CLASS]
	}
#end @create[]
