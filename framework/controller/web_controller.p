##############################################################################
#	
##############################################################################

@CLASS
WebController

@OPTIONS
locals

@BASE
Controller



##############################################################################
@auto[]
	$self.DEFAULT_RENDER_STATUS_CODE(200)
	$self.DEFAULT_REDIRECT_STATUS_CODE(302)
	$self.DEFAULT_RENDER_FORMAT[html]

	^include[$CONFIG.sFrameworkPath/status_codes.p]
#end @auto[]



##############################################################################
@create[]
	^BASE:create[]

	$self.parameter_filter[request_uri, auth]

	$self._forms[^hash::create[]]
	
	^rem{ *** filters *** }
	$self._before_filters[^array::create[]]
	$self._after_filters[^array::create[]]
	$self._skip_before_filters[^hash::create[]]
	
	$self._cache_actions[^hash::create[]]
	
	$self.layout(true)

	^rem{ *** View object *** }
	$self.oView[^View::create[$_base_path/views]]
#end @create[]



##############################################################################
@process[hParams][rusage]
	^rem{ *** set phase as "process" = 1 *** }
	$self._cur_phase(1)
	
	^try{	
		^oLogger.trace[controller.web.assign_names][Assign params]{
			^BASE:process[$hParams]
			^assign_names[]
		}

		^Rusage:measure[rusage]{
			$result[^perform_action[]]
		}
	
		^if($self.postprocess is junction){
			$result[^postprocess[$result]]
		}
	}{
		
	}{
		^rem{ *** use Russage:add because $_stat.process can be negative value by "sql" decrement *** }
		^Rusage:add[$_stat.process;$rusage]

		^log_after_processing[]
	}
#end @process[]



##############################################################################
@init[]
	$result[]
#end @init[]



##############################################################################
@assign_shortcuts[hParams]
	^BASE:assign_shortcuts[$hParams]

	$self.forms[^_prepare_forms[]]
	^forms.sub[
		$.controller(true)
		$.action(true)
	]
	
	^rem{ *** union params & forms *** }
	^params.add[$forms]

	^if(def $params.format){
		$oView.format[$params.format]
	}
	
	^rem{ *** change default render format for oView *** }
	^if(def $form:_format){
		$params.format[$form:_format]
		$oView.format[$form:_format]
	}
#end @assign_shortcuts[]



##############################################################################
@assign_names[]
	^if(!def $params.action){
		$params.action[index]
	}

	$self.action_name[$params.action]
#end @assign_names[]



##############################################################################
@log_processing[][dt]
	$dt[^date::now[]]

	^if($oLogger){
		^oLogger.info[process]{Processing ${controller_class_name}#${action_name} (for $env:REMOTE_ADDR at ^dt.sql-string[]) [$env:REQUEST_METHOD]}{ }[
			$.Params[$filtred_params]
		]
	}
#end @log_processing[]



##############################################################################
@log_after_processing[]
	$self._stat.process[
		$.time($_stat.process.time - $_stat.render.time)
		$.utime($_stat.process.utime - $_stat.render.utime)
		$.memory_block($_stat.process.memory_block - $_stat.render.memory_block)
		$.memory($_stat.process.memory - $_stat.render.memory)
	]

	^if($oLogger){
		^use[FileSystem.p]
		$memory_size_format[
			$.sSpace[ ]
		]

		$total[^Rusage:total.time.format[%.5f] / ^Rusage:total.utime.format[%.5f] / ^FileSystem:printFileSize($Rusage:total.memory * 1000)[$memory_size_format]]
		$process[^_stat.process.time.format[%.5f] / ^_stat.process.utime.format[%.5f] / (^eval($_stat.process.time / $Rusage:total.time * 100)[%.0f]%) / ^FileSystem:printFileSize($_stat.process.memory * 1000)[$memory_size_format]]
		$render[^_stat.render.time.format[%.5f] / ^_stat.render.utime.format[%.5f] (^eval($_stat.render.time / $Rusage:total.time * 100)[%.0f]%) / ^FileSystem:printFileSize($_stat.render.memory * 1000)[$memory_size_format]]
		$db[^_stat.sql.utime.format[%.5f] / ^_stat.sql.time.format[%.5f] (^eval($_stat.sql.time / $Rusage:total.time * 100)[%.0f]%) ^FileSystem:printFileSize($_stat.sql.memory * 1000)[$memory_size_format]]
		
		^oLogger.info[process]{Completed in $total | Process: $process | Rendering: $render | DB: $db | $response:status [http://${env:HTTP_HOST}${sRequest}]}
	}
#end @log_after_processing[]



##############################################################################
@perform_bofore_filter[][locals]
^oLogger.debug[filter]{Filtering...}{
	$result[]

	^_before_filters.foreach[i;filter]{
		^if(def $filter.only){
			$only[^split_string_to_params[$filter.only;action]]
			^if(!^only.locate[action;$action_name]){^continue[]}
		}
		^if(def $filter.exclude){
			$exclude[^split_string_to_params[$filter.exclude;action]]
			^if(^exclude.locate[action;$action_name]){^continue[]}
		}
		
		$skip_filter[$_skip_before_filters.[$filter.name]]
		^if($skip_filter){
			^rem{ *** skip always *** }
			^if(!def $skip_filter.only && !def $skip_filter.exclude){
				^continue[]
			}

			^rem{ *** skip by only *** }
			^if(def $skip_filter.only){
				$only[^split_string_to_params[$skip_filter.only;action]]
				^if(^only.locate[action;$action_name]){^continue[]}
			}
			^rem{ *** skip by expect *** }
			^if(def $skip_filter.exclude){
				$exclude[^split_string_to_params[$skip_filter.exclude;action]]
				^if(!^exclude.locate[action;$action_name]){^continue[]}
			}
		}
		
		^oLogger.debug[filter.before][Before filter: $filter.name]{
			$result[^filter.method[]]
		}[
			$.Params[$filter]
		]
		
		^rem{ *** если произошла обработка - прекращаем выполнение *** }
		^if($self.performed){^break[]}
	}
}
#end @perform_bofore_filter[]



##############################################################################
@perform_cache[jCode]
	$cache[$self._cache_actions.[$self.action_name]]

	^rem{ *** TODO: add MD5 checksum for params: ^math:md5[^inspect[$params]] *** }
	
	^if($cache){
		^if(def $cache.store){
			$store[$[$cache.store]]
		}{
			$store[$oCacheStore]
		}
		
		^if(def $cache.key_generator){
			$key[^self.[$cache.key_generator][]]
		}{
			$key[${self.controller_name}/${self.action_name}${cache.suffix}]
		}

		$result[^store.cache[$key;$cache.time]{$jCode^if($self.performed_redirect){^store.time(0)}}]
	}{
		$result[$jCode]
	}
#end @perform_cache[]



##############################################################################
@catch_exeption[exception]
	
#end @catch_exeption[]



#############################################################################
@perform_action[sAction;sMissingAction][i;filter]
	^if(def $sAction){
		$self.action_name[$sAction]
	}
	
	^try{
		^if($self.$action_method_name is junction){
			^log_processing[]
			$result[^perform_bofore_filter[]]

			^if(!$self.performed){
				^init[]
				$result[^perform_cache{^perform_default_render{^self.$action_method_name[]}}]
			}
		}{
			^rem{ *** try to find template for this action *** }
			^if(!$template.is_exist){
				^if(!def $sMissingAction){
					$self.DEFAULT_RENDER_STATUS_CODE(404)
	 				$result[^perform_cache{^perform_default_render{^perform_action[not_found;$action_name]}}]
				}{
					^log_processing[]
					$self.action_name[$sMissingAction]
					^throw[UnknownAction;$action_method_name;No action responded to $action_name on $controller_class_name]
				}
			}{
				^log_processing[]
				$result[^perform_bofore_filter[]]

				^if(!$self.performed){
					^init[]
					$result[^perform_default_render[]]
				}
			}
		}
	}{
		^if($exception.type eq "fw.interupt.redirect"){
			$exception.handled(true)
		}($exception.type eq "fw.interupt.render"){
			$exception.handled(true)
		}{
			$result[^catch_exeption[$exception]]
			^if($exception.handled){
				$result[^perform_default_render[$result]]
			}
		}
	}

	$result[$result]
#end @perform_action[]



##############################################################################
@perform_default_render[jCode]
	$result[$jCode]
	
	^if(!$self.performed){
		$result[^default_render[]]
	}
#end @perform_default_render[]



##############################################################################
@default_render[][result]
	^render[]
#end @default_render[]
