##############################################################################
#	
##############################################################################

@CLASS
RouteRule

@OPTIONS
locals



##############################################################################
@auto[]
	$self._spec_charset[^table::create{from	to
^$	\^$
?	\?
+	\+
*	\*
.	\.
(	\(
)	\)
[	\[
]	\]}]

	$self.VARS_REGEXP[^hash::create[]]				^rem{ *** хеш для скомпилированных правил для var *** }

	$self.DEFAULT_VARNAME_RULE[[\w\-]*\w+]
	$self.DEFAULT_VAR_RULE[[\w\-]+]
	
	$self.SPEC_OPTIONS[^table::create{name
default
requirement
var
pattern
regxp_pattern
is_named}]
#end @auto[]



##############################################################################
@create[sPattern;hOptions]
	$self._is_prepared(false)

	$self.is_application(false)
	$self.is_named(false)

	$self._name[]
	$self._namespace[]
	$self._base_url[]
	
	$self._pattern[^sPattern.trim[right;/]]
	$self._pattern_regexp[]
	
	$self._requirement[^hash::create[$hOptions.requirement]]					^rem{ *** хеш регулярок для переменных для замены *** }
	$self._defaults[^hash::create[$hOptions.default]]							^rem{ *** хеш обязательных переменных *** }
	^if(!$self._defaults){
		$self._defaults[
			$.action(false)
			$.id(false)
			$.format(false)
		]
	}

	$self._vars[]																^rem{ *** таблица переменных *** }
	
	$self._params[^hash::create[$hOptions]]										^rem{ *** массив действий, других переменных *** }
	
#	$self.rules[^array::create[]]
#end @create[]



##############################################################################
@GET_pattern[]
	$result[$self._pattern]
#end @GET_pattern[]



##############################################################################
@GET_pattern_regexp[]
	^prepare[]
	$result[$self._pattern_regexp]
#end @GET_regexp_pattern[]



##############################################################################
@GET_params[]
	$result[$self._params]
#end @GET_params[]



##############################################################################
@GET_vars[]
	^prepare[]
	$result[$self._vars]
#end @GET_vars[]



##############################################################################
@GET_defaults[]
	^prepare[]
	$result[$self._defaults]
#end @GET_defaults[]



##############################################################################
#	1. экранировать спец. символы
#	2. заменить переменные на соответствующие шаблоны
##############################################################################
@prepare[]
	^if(!$self._is_prepared){
		$pattern[$self._pattern]
		$pattern[^pattern.replace[$self._spec_charset]]

		$self._vars[^pattern.match[:($self.DEFAULT_VARNAME_RULE)][ig]]			^rem{ *** вычисляем переменные в правиле *** }
		$self._vars[^self._vars.hash[1]]
		
		$vars[$self._vars]
		^vars.foreach[name;var]{
			^if(!$self.VARS_REGEXP.[$var.1]){
				$self.VARS_REGEXP.[$var.1][^regex::create[([^^\w()])?:${var.1}]]		^rem{ *** компилируем регулярное выражение для переменной *** }
			}
						
			$self._defaults.[$var.1](^self._defaults.[$var.1].bool(true))		^rem{ *** обязательная переменная *** }
			
			$is_req($self._defaults.[$var.1])
			$pattern[^pattern.match[$self.VARS_REGEXP.[$var.1]][]{^if(def $match.1){${match.1}^if(!$is_req){?}}^if(def $self._requirement.[$var.1]){($self._requirement.[$var.1])}{($self.DEFAULT_VAR_RULE)}^if(!$is_req){?}}]
		}
		$pattern[$pattern/?]

		$self._pattern_regexp[$pattern]
		
		$self._is_prepared(true)
	}
#end @prepare[]



##############################################################################
@path_for[hOptions;hDefaultOptions;hValues]
#	$hOptions[^hash::create[$hOptions]]
#	$hDefaultOptions[^hash::create[$hDefaultOptions]]

	$result[$self.pattern]

	^rem{ *** for home "/" pattern *** }
	^if(!def $result){
		$result[/]
	}

	^if($hValues is void){
		$values[^compile_vars[$hOptions;$hDefaultOptions]]
	}{
		$values[$hValues]
	}
	
	$defaults[^hash::create[$self.defaults]]

	$vars[$self.vars]
	^vars.foreach[name;var]{
		^defaults.delete[$var.1]

		$is_req($self.defaults.[$var.1])
		$value[$values.[$var.1]]

		^rem{ *** clear $.action[index] because this default value *** }
		^if(!$is_req && $var.1 eq "action" && $value eq "index"){
			$value[]
		}

		$result[^result.match[$self.VARS_REGEXP.[$var.1]][]{^if($is_req || def $value){$match.1}^apply-taint[uri][$value]}]	^rem{ *** вставляем переменные в pattern *** }
	}

	^rem{ *** добавляем обязательные переменные в hOptions *** }
	^rem{ *** check default var that not contained in pattern *** }
	^rem{ *** include all default var in hOptions for next including in url *** }
	^defaults.foreach[key;value]{
		^if($value && !def $hOptions.[$key]){
			$hOptions.[$key][^if($value is bool){$hDefaultOptions.[$key]}{$value}]	^rem{ *** FIX: from self.params ??? *** }
		}
	}

	$anchor[$hOptions.anchor]

	^rem{ *** add other options as GET param *** }
	^hOptions.sub[
		^hash::create[$vars]
		$.controller(true)
		$.action(true)
#		$.id(true)
		$.anchor(true)
	]

	^if(def $self._base_url){
		$result[/${self._base_url}$result]
	}
	
	^if(^result.match[^^/([^^\.]+?[^^/])^$]){
		$result[${result}/]
	}

	^if(def $hOptions){
#		$result[$result?^hOptions.foreach[attr;value]{$attr=^untaint[uri]{$value}}[&]]
		$attr[^_compile_url_attr[$hOptions]]

		^if(def $attr){
			$result[$result?$attr]
		}
	}

	^if(def $anchor){
		$result[$result#$anchor]
	}
#end @path_for[]



##############################################################################
#	Метод собирает параметры их Входящих и из Текущего вызова
#	по правилу первой встречи входящего параметра
##############################################################################
@compile_vars[hOptions;hDefaultOptions]
	$result[^hash::create[]]
	
	$_use_default(true)	^rem{ *** используем перемененные из стандартных до тех пор пока не встретится 1 переменная из входящих *** }

	$vars[$self.vars]
	^vars.foreach[name;var]{
		^if($_use_default && $hOptions.[$var.1] is void){
			$value[$hDefaultOptions.[$var.1]]
		}{
			$_use_default(false)
			$value[$hOptions.[$var.1]]
		}
		
		^if(!def $value){
			$value[$self.params.[$var.1]]
		}

		$result.[$var.1][$value]
	}
	
	^rem{ *** TODO: оставшиеся переменные из Входящих / Стандартных ? *** }
#end @compile_vars[]



##############################################################################
@_compile_url_attr[hAttributes;sNamePrefix][locals]
	^switch[$hAttributes.CLASS_NAME]{
		^case[string]{
			$attr_name[^if(def $sNamePrefix){${sNamePrefix}}]
			$result[^if(!($hAttributes is void)){$attr_name=^apply-taint[uri][$hAttributes]}]
		}
		^case[DEFAULT]{
			$result[^hAttributes.foreach[attr;value]{^switch[$value.CLASS_NAME]{
				$attr_name[^if(def $sNamePrefix){${sNamePrefix}.}$attr]

				^case[array]{^value.foreach[i;val]{^_compile_url_attr[$val;${attr_name}[]]}[&]}
				^case[hash]{^_compile_url_attr[$value;$attr_name]}
				^case[date]{^_compile_url_attr[ $.year[$value.year] $.month[$value.month] $.day[$value.day] $.hour[$value.hour] $.minute[$value.minute] ][$attr_name]}
				^case[DEFAULT]{^if($attr eq "nameless"){$nameless[$value]^continue[]}($attr eq "qtail"){$qtail[$value]^continue[]}^if(!($value is void)){$attr_name=^apply-taint[uri][$value]}}
			}}[&]]
		}
	}
	
	^if(def $nameless){$result[${nameless}^if(def $result){&$result}]}
	^if(def $qtail){$result[?${qtail}]}
#end @_compile_url_attr[]



##############################################################################
#	Метод возвращает хеш роутинга для запроса sPath
#	Если правило не соответствует запросу, то возвращается пустой hash
##############################################################################
@route[sPath]
	$result[^hash::create[]]

	$res[^sPath.match[^^^taint[as-is][${self.pattern_regexp}]^$][i']]

	^rem{ *** правило совпало => наше правило *** }
	^if($res){
		$result[^hash::create[]]

		^rem{ *** удаляем все системные переменные из переменных правила *** }
		^self.params.foreach[k;v]{
			^if(!^self.SPEC_OPTIONS.locate[name;$k]){
				$result.[$k][$v]
			}
		}
	
		^rem{ *** собираем переменные из результата парсинга правила *** }
		$line(1)
		^self.vars.foreach[name;var]{
			$is_req($self.defaults.[$var.1])

			^if($is_req || def $res.[$line]){
				$result.[$var.1][$res.[$line]]	^rem{ *** получам переменную с i-ой переменной *** }
				^rem{ *** FIX: это сомнительное решение при наличии необязательных переменных *** }
			}

			^line.inc[]
		}

		^if(!def $result.action){
			$result.action[index]
		}
	}
#end @route[]
