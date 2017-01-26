##############################################################################
#	
##############################################################################

@CLASS
Route

@OPTIONS
locals



##############################################################################
@GET_is_not_found_availible[]
	$result(^_routing_name.contains[not_found])
#end @GET_is_not_found_availible[]



##############################################################################
@current_rule[]
	$result[$_rule]
#end @current_rule[]



##############################################################################
@create[sName;sNamespace;sBaseURL]
	$self._name[$sName]
	$self._namespace[$sNamespace]
	$self._base_url[$sBaseURL]

	$self._count(0)
	$self._routing[^hash::create[]]
	$self._routing_name[^hash::create[]]
	$self._routing_application[^hash::create[]]

	$self._rule[^hash::create[]]	^rem{ *** текущее правило *** }
#end @create[]



##############################################################################
@path_for[hOptions;hDefaultOptions][locals]
	$hOptions[^hash::create[$hOptions]]
	$hDefaultOptions[^hash::create[$hDefaultOptions]]

	$result[]
	
	$application_specified(def $hOptions.application)
	$application[^if($hOptions.application is "void"){$hDefaultOptions.application}{$hOptions.application}]

#	$application[^if(def $hOptions.application){$hOptions.application}{$hDefaultOptions.application}]

	^if(def $application){
		^hOptions.delete[application]
		^hDefaultOptions.delete[application]

		^rem{ *** TODO: fix it for RouteRule *** }
		$result[/${self._routing_application.[$application]._namespace}^self._routing_application.[$application].path_for[$hOptions;$hDefaultOptions]]
	}{
		^hOptions.delete[application]
		^hDefaultOptions.delete[application]

		^for[i](0;$self._count - 1){
			$rule[$self._routing.$i]
			$compile(true)
			$_use_default(true)

			^rem{ *** Ищем самое подходящее правило только в НЕИМЕНОВАННЫХ
				      т.к. именованные могут срабатывать практически всегда *** }
		
			^rem{ *** Самым подходящим считается правило, необходимые переменные
				      для которого совпадают с переданными переменными *** }

			^if($rule is Route || $rule.is_named){^continue[]}

			^rem{ *** add controller to var for default rule *** }
			$vars[
				$.controller[ $.1[controller] ]
			]
			^vars.add[$rule.vars]

			^rem{ *** проходимся по переменным из правила *** }
			^vars.foreach[name;var]{
				$is_req($rule.defaults.[$var.1])

				^if($_use_default && $hOptions.[$var.1] is void){
					$value[$hDefaultOptions.[$var.1]]
				}{					
					$_use_default(false)
					$value[$hOptions.[$var.1]]
				}
				
				^if(!def $value){
					$value[$rule.params.[$var.1]]
				}
				
				^if($is_req && !def $value){
					$compile(false)
					^break[]
				}
			}
			
			^rem{ *** если правило подошло и в прафиле есть прямое указание на контроллер, то проверяем наличие этого контроллера в параметрах пути/стандартных параметрах *** }
			^if($compile && def $rule.params.controller && ((def $hOptions.controller && $rule.params.controller ne $hOptions.controller) || (!def $hOptions.controller && $rule.params.controller ne $hDefaultOptions.controller))){
				^continue[]
			}
			^if($compile && def $rule.params.action && def $hOptions.action && $rule.params.action ne $hOptions.action){
				^continue[]
			}

			^rem{ *** TODO: а если переменных в options больше? то это params *** }

			^if($compile){
				$result[^rule.path_for[$hOptions;$hDefaultOptions]]
				^break[]
			}
		}
	}
#end @path_for[]



##############################################################################
@named_path_for[sName;hOptions;hDefaultOptions][locals]
	$hOptions[^hash::create[$hOptions]]
	$hDefaultOptions[^hash::create[$hDefaultOptions]]

	$application_specified(def $hOptions.application)
	$application[^if($hOptions.application is "void"){$hDefaultOptions.application}{$hOptions.application}]

	^if(def $application){
		^hOptions.delete[application]
		^hDefaultOptions.delete[application]

		^try{
			$result[/${self._routing_application.[$application]._namespace}^self._routing_application.[$application].named_path_for[$sName;$hOptions;$hDefaultOptions]]
		}{
			^if(!$application_specified && $exception.source eq "named_path_for"){
				$exception.handled(true)
				
				$rule[$self._routing_name.[$sName]]
				
				^if(def $rule){
					$result[^rule.path_for[$hOptions;$hDefaultOptions]]
				}{
					^throw[parser.runtime;named_path_for;Uncknown named route '$sName']
					$result[]
				}
			}
		}
	}{
		^hOptions.delete[application]
		^hDefaultOptions.delete[application]
		
		$rule[$self._routing_name.[$sName]]
		
		^if(def $rule){
			$result[^rule.path_for[$hOptions;$hDefaultOptions]]
		}{
			^throw[parser.runtime;named_path_for;Uncknown named route '$sName']
			$result[]
		}
	}
#end @named_path_for[]



##############################################################################
@named_route[sName;hDefaultOptions]
	$result[^hash::create[]]
	
	^rem{ *** TODO: application *** }

	$hDefaultOptions[^hash::create[$hDefaultOptions]]

	$application_name[$hDefaultOptions.application]

	^if(def $application_name){
		^hDefaultOptions.delete[application]
		
		$application[$self._routing_application.[$application]]
		^if(def $application){
			$result[^application.named_route[$sName]]
		}{
			^throw[parser.runtime;named_path_for;Uncknown application '$application_name']
			$result[]
		}
	}{
		$rule[$self._routing_name.[$sName]]
		^if(def $rule){
			$result[^rule.params.intersection[
				$.controller(true)
				$.action(true)
#				$.id(true)
			]]
			^rem{ *** добавляем указание на application *** }
			$result[^result.union[
				$.application[$self._name]
			]]
		}{
			^throw[parser.runtime;named_path_for;Uncknown named route '$sName']
			$result[]
		}
	}
#end @named_route[]



##############################################################################
#	Метод возвращает Controller & Action по пути sPath в соответсвии с имеющимися правилами
##############################################################################
@route[sPath]
	^if(def $self._namespace){
		^if(^sPath.match[^^/$self._namespace/] || ^sPath.match[^^/$self._namespace^$]){
			$sPath[^sPath.match[^^/$self._namespace][i]{}]

			$result[^self._route[$sPath]]

			^rem{ *** добавляем указание на application *** }
			$result[^result.union[
				$.application[$self._name]
			]]
		}{
			$result[]
		}
	}{
		$result[^self._route[$sPath]]
	}
#end @route[]



##############################################################################
@_route[sPath]
	^for[i](0;$self._count - 1){
		$rule[$self._routing.$i]

		$result[^rule.route[$sPath]]

		^if($result){
			$self._rule[$rule]		^rem{ *** set rule as current_rule *** }
			^break[]
		}
	}
#end @_route[]



##############################################################################
#	Метод возвращает параметры роутинга для not_found
##############################################################################
@route_not_found[][rule]
	$result[^self.named_route[not_found]]
#end @route_not_found[]



##############################################################################
@application[sNamespace;sName;oRouter][rule]
	^if(!def $sName){
		$sName[$sNamespace]
	}
	
	^if(def $oRouter){
		$rule[$oRouter]
	}{
		$rule[^Route::create[$sName;$sNamespace]]

		^rem{ *** init routes *** }
		$self.oMap[$rule]
		^rem{ *** FIX: вынести отсюда задание пути до приложения *** }
		^include[$CONFIG:sRootPath/$sName/config/routes.p]
		$self.oMap[]
	}

	$self._routing.[$self._count][$rule]
	$self._routing_application.[$sName][$rule]

	^self._count.inc[]
#end @application[]



##############################################################################
@connect[sName;sPattern;hOptions][rule]
	^if(!def $hOptions && $sPattern is hash){
		$hOptions[$sPattern]
		$sPattern[$sName]
		$sName[]
	}
	^if(!def $sPattern){
		$sPattern[$sName]
		$sName[]
	}
	
	$rule[^RouteRule::create[$sPattern;$hOptions]]

#	$rule[^hash::create[$hOptions]]
#	$rule.pattern[^sPattern.trim[right;/]]
#			
#	^if(!^rule.contains[default]){
#		$rule.default[
#			$.action(false)
#			$.id(false)
#			$.format(false)
#		]
#	}

	^if(def $sName){
		$rule._name[$sName]
		$rule.is_named(true)
		$self._routing_name.[$sName][$rule]
	}
	
	$self._routing.[$self._count][$rule]
	
	^self._count.inc[]
#end @connect[]



##############################################################################
@root[hOptions]
	^self.connect[root][/][$hOptions]
#end @root[]



##############################################################################
#	Метод инициализирует правило роутинга для not_found
##############################################################################
@not_found[hOptions]
	^self.connect[not_found;/404/][$hOptions]
#end @not_found[]



##############################################################################
@cache[jCode]
	$result[]
	
	$route_cache_file[$CONFIG:sCachePath/route.map.^file:md5[$CONFIG:sConfigPath/routes.p]]
	$route_cache_exist(-f $route_cache_file)

	^cache[$CONFIG:sCachePath/route.cache]($CONFIG:sCacheTime.routing * ^if($route_cache_exist){1}{0}){
		$result[$jCode]
	
		$router[^serialize[;$self]]
		^router.save[$route_cache_file]

		$cache_expired(true)
	}{
		^rem{ *** TODO: Пишем в лог проблему с генерацией роутинга *** }
		^if($route_cache_exist){
			$exception.handled(true)
		}
	}

	^if(!$cache_expired && $route_cache_exist){
		^rem{ *** читаем роутинг из кеша *** }
		$rules[^file::load[text;$route_cache_file]]
		^unserialize[$rules.text]
	}
#end @cache[]



##############################################################################
@rule_serialize[key;rule;params] 
	$result[^json:string[
		^if(def $rule._name){
			$.name[$rule._name]
		}
		$.pattern[$rule._pattern]
#		$.requirement[$rule._requirement]
#		$.default[$rule._default]
		$.params[$rule._params]
	][
		$.indent(true)
	]]
#end @route_serialize[]



##############################################################################
@app_unserialize[rules]
	^rules.foreach[code;rule]{
		^if(def $rule.routing){
			$router[^Route::create[$rule.name;$rule.namespace]]
			^router.app_unserialize[$rule.routing]

			^self.application[$rule.namespace;$rule.name;$router]
		}{
			^self.connect[$rule.name;^if($rule.name eq "root"){/}{$rule.pattern};$rule.params]
		}
	}
#end @app_unserialize[]



##############################################################################
@unserialize[string]
	$router[^json:parse[^taint[as-is][$string]]]
	
	^app_unserialize[$router.routing]
#end @unserialize[]



##############################################################################
@serialize[key;route;params]
	$result[^json:string[
		$.name[$route._name]
		$.namespace[$route._namespace]
		$.routing[$route._routing]
	][
		$.indent(true)
		$.Route[$serialize]
		$.RouteRule[$rule_serialize]
	]]
#end @serialize[]
