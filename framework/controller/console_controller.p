##############################################################################
#	
##############################################################################

@CLASS
ConsoleController

@OPTIONS
locals

@BASE
Controller



##############################################################################
@create[]
	^BASE:create[]
#end @create[]



##############################################################################
@process[hParams]
	^BASE:process[$hParams]

	^log_processing[]
	$result[^run[]]
	^log_after_processing[]
#end @process[]



##############################################################################
@assign_shortcuts[hParams]
	^BASE:assign_shortcuts[$hParams]
	
	^rem{ *** инициализируем params из argv аргументов командной строки *** }
	$argv[$request:argv]
	^if($argv){
		^rem{ *** начинаем со 2, т.к.
			      0 - имя запускаемого файла,
			      1 - имя пути для роутинга
			*** }
		^for[i](2;$argv - 1){
			$self.params.[^eval($i - 2)][$argv.[$i]]
		}
	}
	
	^rem{ *** инициализируем params из nameless значений формы, если есть *** }
	$nameless_form[$form:tables.nameless]
	^if($nameless_form){
		^nameless_form.menu{
			$self.params.[^nameless_form.offset[]][$nameless_form.field]
		}
	}
#end @assign_shortcuts[]



##############################################################################
@run[]
	$result[]
#end @run[]



##############################################################################
@log_processing[][dt]
	$dt[^date::now[]]
	
	^if($oLogger){
		^oLogger.info{Processing ${controller_class_name}#run (for $env:REMOTE_ADDR at ^dt.sql-string[]) [CONSOLE]}
		^oLogger.info{	Parameters: ^inspect[$filtred_params]}
#		^oLogger.info{	Forms: ^inspect[$forms]}
	}
#end @log_processing[]



##############################################################################
@log_after_processing[]
	^if($oLogger){
		^oLogger.info{Completed in ^Rusage:total.utime.format[%.5f] ($Rusage:total.memory) | DB: ^_stat.sql.utime.format[%.5f] (^eval($_stat.sql.utime / ^if($Rusage:total.utime){$Rusage:total.utime}{1} * 100)[%.0f]%) ($_stat.sql.memory) | 0 [$request:argv.0]}
	}
#end @log_after_processing[]



##############################################################################
@GET_is_not_found_availible[][_action]
	$_action[$self.action_name]

	$self.action_name[not_found]
	$result($self.aNotFound is junction)
	
	$self.action_name[$_action]
#end @GET_is_not_found_availible[]