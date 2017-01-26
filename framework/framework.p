##############################################################################
#
##############################################################################

@CLASS
Framework

@OPTIONS
partial

@USE
environment.p
config.p

@BASE
Environment



##############################################################################
@auto[]
^Rusage:log[fw.auto]{ }{
	^use[$CONFIG:sFrameworkPath/framework_helpers.p]
	
	^use[$CONFIG:sFrameworkPath/view/helpers/text_helper.p]
	^use[$CONFIG:sFrameworkPath/view/helpers/num_helper.p]

	^rem{ *** current phase: 1 - process, 2 - render *** }
	$_cur_phase(0)

	^if($MAIN:CLASS_PATH is void){
		$MAIN:CLASS_PATH[^table::create{path}]
	}
}
#end @auto[]



##############################################################################
@autouse[sClassName]
^Environment:oLogger.trace[fw.use]{$sClassName}{
	^use[^string_transform[$sClassName;classname_to_filename].p]
	^Rusage:compact[]
}
#end @autouse[]



##############################################################################
@run[path;environment]
	$Environment:REQUEST_ID[^math:uuid[]]										^rem{ *** вычисляем UID запроса *** }
	
	^use[$CONFIG:sFrameworkPath/array.p]
	^use[$CONFIG:sFrameworkPath/enum.p]
	^use[$CONFIG:sFrameworkPath/lib.p]
	^use[$CONFIG:sFrameworkPath/inspect.p]

^Rusage:log[fw.run.env][Environment init]{
	^include[$CONFIG:sConfigPath/environment.p][$Environment:CLASS]				^rem{ *** подключаем стандартный конфиг *** }
	
	^environment_include[$environment]											^rem{ *** определяем окружение *** }
}[
	$.env[$environment]
]

	^rem{ *** включаем debug_mode *** }
	^if($CONFIG:debug_level){
		$MAIN:unhandled_exception[$self.unhandled_exception]
	}
	
	^rem{ *** автоматическое подключение классов *** }
	$MAIN:autouse[$self.autouse]

^Rusage:log[fw.configure][Configure]{
	^configure[]
}

^oLogger.trace[fw.include.app]{Include Application}{
	^rem{ *** use application *** }
	^use[${CONFIG:sFrameworkPath}/application/application.p]
}

^oLogger.trace[fw.include.controller]{Include controller}{
	^rem{ *** use controller and helpers *** }
	^use[${CONFIG:sFrameworkPath}/controller/controller.p]
	^use[${CONFIG:sFrameworkPath}/controller/controller_helpers.p]
	^use[${CONFIG:sFrameworkPath}/controller/controller_attributes.p]
	^use[${CONFIG:sFrameworkPath}/controller/controller_render.p]
	^use[${CONFIG:sFrameworkPath}/controller/controller_filter.p]
	^use[${CONFIG:sFrameworkPath}/controller/controller_cache.p]

	^Rusage:compact[]
}

#^oLogger.trace[fw.include.controller]{Include controllers}{
#	^rem{ *** use web & console controller *** }
#	^use[web_controller.p]	
#	^use[console_controller.p]
#	
#	^Rusage:compact[]
#}

^oLogger.trace[fw.include.model]{Include Model}{
	^rem{ *** use Model *** }
	^use[${CONFIG:sFrameworkPath}/model/model_errors.p]
	^use[${CONFIG:sFrameworkPath}/model/model.p]
	^use[${CONFIG:sFrameworkPath}/model/model_attributes.p]
	^use[${CONFIG:sFrameworkPath}/model/model_events.p]
	^use[${CONFIG:sFrameworkPath}/model/model_base.p]
	^use[${CONFIG:sFrameworkPath}/model/model_base_mapper.p]
	
#	^Rusage:compact[]
}

^oLogger.trace[fw.include.model.active]{Include ActiveModel}{
	^rem{ *** use ActiveModel *** }
	^use[${CONFIG:sFrameworkPath}/active_model/active_model.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_attributes.p]	
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_mapper.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_relation.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_query_methods.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_association.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_validator.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_scope.p]
	^use[${CONFIG:sFrameworkPath}/active_model/relation/active_relation.p]
	^use[${CONFIG:sFrameworkPath}/active_model/relation/active_relation_mapper.p]
	^use[${CONFIG:sFrameworkPath}/active_model/relation/active_relation_query_methods.p]
	^use[${CONFIG:sFrameworkPath}/active_model/association/association.p]
	^use[${CONFIG:sFrameworkPath}/active_model/active_model_criteria.p]
	
#	^Rusage:compact[]
}

^oLogger.trace[fw.include.model.db]{Include DBField}{
	^use[${CONFIG:sFrameworkPath}/db_field/db_field.p]
	^use[${CONFIG:sFrameworkPath}/db_field/db_field_attributes.p]
	^use[${CONFIG:sFrameworkPath}/db_field/db_field_list.p]
	
#	^Rusage:compact[]
}

^oLogger.trace[fw.include.view]{Include View}{
	^use[${CONFIG:sFrameworkPath}/view/view.p]
}

^oLogger.trace[fw.include.model.file]{Include ActiveFile & ActiveImage}{
	^use[${CONFIG:sFrameworkPath}/active_file/active_file_meta.p]
	^use[${CONFIG:sFrameworkPath}/active_file/active_file.p]

	^use[${CONFIG:sFrameworkPath}/active_file/active_image_meta.p]
	^use[${CONFIG:sFrameworkPath}/active_file/active_image.p]
}

	^rem{ *** client request uri *** }
	^if(def $path){
		$sRequest[$path]
	}{
		$sRequest[$form:_request]
	}
	$sRequest[^sRequest.trim[right;/]]
	$sRequest[^sRequest.lower[]]

	$result[^dispatche[$sRequest]]
	
	^if($oLogger){
		^rem{ *** вызываем сохранение лога в файл *** }
		^oLogger.flush[]
	}
	
	^if($CONFIG:profiling && $form:qtail eq "profiling"){
		^use[${CONFIG:sProfilingPath}/profiling.p]
		$result[${result}^profiling[]]
	}
#end @run[]



##############################################################################
@routes_include[][locals]
	^rem{ *** include routes *** }
#	^oMap.cache{
		^include[${CONFIG:sConfigPath}/routes.p]
#	}
#end @routes_include[]



##############################################################################
@environment_include[environment][env]
	^if(def $environment){
		$self.ENV[$environment]													^rem{ *** определяем из переданных параметров *** }
	}
	^if(!def $self.ENV && -f "$CONFIG:sConfigPath/env.cfg"){
		$env[^file::load[text;$CONFIG:sConfigPath/env.cfg]]						^rem{ *** определяем из файла *** }
		$self.ENV[^env.text.trim[]]
	}
	^if(!def $self.ENV){
		$self.ENV[production]													^rem{ *** по-умолчанию production *** }
	}

	^if(-f "$CONFIG:sEnvironmentPath/${self.ENV}.p"){
		^include[$CONFIG:sEnvironmentPath/${self.ENV}.p][$Environment:CLASS]
	}
#end @environment_include[]



##############################################################################
@dispatche[sRequest]
^oLogger.debug[fw.route]{Route request "$sRequest"}{
	^oLogger.trace[fw.route.include][Load routing]{
		^routes_include[]
	}
	^oLogger.trace[fw.route.routing][Routing]{
		$routes[^oMap.route[$sRequest]]
	}
}

^oLogger.info[process][Processing ${routes.controller}#${routes.action}]{
	$result[^execute[$routes]]
}[
	$.Route[$routes]
]
#end @dispatche[]



#############################################################################
@execute[hParams][hParams]
^oLogger.trace[process.app][Include application]{
	^use_application[$hParams.application]
}

^oLogger.trace[process.instance][Create controller instance]{
	^rem{ *** try find and include controller *** }
	^try{
		^include_controller[$hParams.controller]
		$oController[^instance_controller[$hParams.controller]] ^rem{ *** FIXME: потеря 0,05 сек на инициализацию контроллера *** }
	}{
		^rem{ *** отлавливем ошибки отсутствия контроллера и экшена в нем *** }
		$is_not_code_exception($exception.type eq "framework.controller")

		^rem{ *** execute not_found action or template of Application controller *** }
		^if($is_not_code_exception){
			$oController[^instance_application[$_app_name]]
			$exception.handled($oController.is_not_found_availible)

			^rem{ *** TODO: oMap can be other application, check this and standart application *** }
			^rem{ *** try route not_found *** }		
			^if(!$exception.handled && $oMap.is_not_found_availible){
				$hParams[^oMap.route_not_found[]]

				^include_controller[$hParams.controller]
				$oController[^instance_controller[$hParams.controller]]

				$exception.handled(true)
			}
		}
	}
}[
	$.Params[$hParams]
]

	^Rusage:compact[]

	$result[^oController.process[$hParams]]
#end @execute[]



##############################################################################
@_parseYML[sPath][locals]
	$result[^hash::create[]]

	$file[^file::load[text;$sPath]]
	$lines[^file.text.split[^#0A]]
	
	$cursor[$result]
	^lines.menu{
		$l[$lines.piece]

		^if(!def ^l.trim[] || ^l.pos[#] == 0){^continue[]}
	
		$det_pos[^l.pos[:]]
		
		^if(!$det_pos){
			^throw[config.parser;wrong format for $sPath]
		}
		
		$key[^l.mid(0;$det_pos)]
		$key_clear[^key.trim[]]

		$val[^l.mid($det_pos + 1)]
		$val_clear[^val.trim[]]

		^if(!def $val_clear){
			$result.[$key_clear][^hash::create[]]
			$cursor[$result.[$key_clear]]
		}{
			^if(^key.pos[	] != 0 && ^key.pos[ ] != 0){
				$cursor[$result]												^rem{ *** если ключ начинается с новой строки - то это новый хеш *** }
			}
			$cursor.[$key_clear][$val_clear]
		}
	}
#end @_parseYML[]



##############################################################################
@_parseSettings[sPath][locals]
	$result[^hash::create[]]

	$tFile[^table::load[nameless;$sPath]]
	$tFile[^tFile.select(def $tFile.0)]
	^tFile.menu{
		$result.[$tFile.0][$tFile.1]
	}	
#end @_parseSettings[]



##############################################################################
@configure[hParam][hDBCfg]
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/logger}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/application}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/cache}
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/controller}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/route}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/db_field}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/model}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/active_model}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/active_model/relation}
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/active_model/association}
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/active_file}
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/view}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/sql}
#	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/sql_builder}
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkPath/mailer}
		
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkLibPath}
	^MAIN:CLASS_PATH.append{$CONFIG:sLibPath}
	
	^MAIN:CLASS_PATH.append{$CONFIG:sModelPath}
#	^MAIN:CLASS_PATH.append{$CONFIG:sApplicationPath}	
	^MAIN:CLASS_PATH.append{$CONFIG:sControllerPath}
	^MAIN:CLASS_PATH.append{$CONFIG:sMailPath}

	^if(!$oLogger){
		^use[${CONFIG:sFrameworkPath}/logger/logger.p]
		$oLogger[^Logger::create[$CONFIG:sLogPath/info.log;$CONFIG:logger_level]]
	}

	^if(!$oCacheStore){
		^use[${CONFIG:sFrameworkPath}/cache/cache_store.p]
		$self.oCacheStore[^CacheStore::create[
			$.path[$CONFIG:sCachePath]
		]]
	}

	^rem{ *** Routing object *** }
	^use[${CONFIG:sFrameworkPath}/route/route.p]
	^use[${CONFIG:sFrameworkPath}/route/route_rule.p]	
	$oMap[^Route::create[]]

	^rem{ *** DB Config *** }
	^if(-f "${CONFIG:sConfigPath}/database.yml"){
		$hDBCfg[^_parseYML[${CONFIG:sConfigPath}/database.yml]]		
		$hDBCfg[$hDBCfg.[$self.ENV]]
		
		$hDBCfg.connectstring[${hDBCfg.username}:${hDBCfg.password}@${hDBCfg.host}^if(def $hDBCfg.port){:${hDBCfg.port}}/${hDBCfg.database}^if(def $hDBCfg.charset){?charset=${hDBCfg.charset}}]
	}
	^if(!$hDBCfg && -f "${CONFIG:sConfigPath}/database.cfg"){
		$hDBCfg[^_parseSettings[${CONFIG:sConfigPath}/database.cfg]]
	}

	^rem{ *** SQL object *** }
	^rem{ *** TODO: переделать SQL-прослойку классов *** }
	^rem{ *** подключаем и инициализируем Sql драйвер *** }
	^switch[^hDBCfg.adapter.lower[]]{
		^case[pgsql;oracle;odbc]{
			^throw[framework.configure;$hDBCfg.adapter;Type of database unsupported]
		}

		^case[mysql;DEFAULT]{
			^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkLibPath/sql}
			^use[fwMySql.p]
			$self.oSql[^fwMySql::create[mysql://${hDBCfg.connectstring}][
				$.bDebug($CONFIG:debug_level)
				$.sCacheDir[$CONFIG:sCachePath/sql]
			]]
		}
	}

	^rem{ *** SqlBuilder object *** }
	^use[${CONFIG:sFrameworkPath}/sql_builder/sql_builder.p]
	$self.oSqlBuilder[^SqlBuilder::create[$oSql]]
	
	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkLibPath/lib}
	^use[lib/Lib.p]

	^MAIN:CLASS_PATH.append{$CONFIG:sFrameworkLibPath/img}
	^rem{ *** use NConvert as oImage *** }
	^use[NConvert.p]
	$oImage[^NConvert::create[
		$.sScriptPath[$CONFIG:sEXEPath]
		$.sScriptName[nconvert]
		$.bRemoveMeta(true)
		$.iQuality[$CONFIG:iImgQuality]
	]]

	^if(def $CONFIG:request_charset){
		$request:charset[$CONFIG:request_charset]
	}
	^if(def $CONFIG:response_charset){
		$response:charset[$CONFIG:response_charset]
	}

	$response:content-type[
		$.value[text/html]
		$.charset[$response:charset]
	]
	
	$response:X-REQUEST-ID[
		$.value[$Environment:REQUEST_ID]										^rem{ *** подставляем в заголовок ID запроса *** }
	]
#end @configure[]



##############################################################################
@unhandled_exception[exception;stack]
	$oLogger[$Environment:oLogger]

	^if($oLogger){
		^oLogger.fatal{Unhandled Exception^if(def $exception.type){ ($exception.type) $exception.source}}
		^oLogger.fatal{$exception.comment}

		^if(def $exception.file){
			^oLogger.fatal{$exception.file (${exception.lineno}:$exception.colno)}
		}

		^if($stack){
			^stack.menu{^oLogger.fatal[$stack.name]{^console_text_line[$stack.file](110)	(${stack.lineno}:$stack.colno)}}
		}
		
		^rem{ *** вызываем сохранение лога в файл *** }
		^oLogger.flush[]
	}

	$result[^MAIN:unhandled_exception_debug[$exception;$stack]]
#end @unhandled_exception[]
