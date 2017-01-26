##############################################################################
#	
##############################################################################

@CLASS
ConsoleLimitedController

@OPTIONS
locals

@BASE
ConsoleController



##############################################################################
@create[]
	^BASE:create[]
#end @create[]



##############################################################################
@process[hParams]
	$result[]

	^lock_process{
		$result[^BASE:process[$hParams]]
	}
#end @process[]



##############################################################################
@GET_task_name[]
	$result(^form:nameless.int(^request:argv.2.int(0)))
#end @GET_task_name[]



##############################################################################
@lock_process[jCode]
	$file_lock[$CONFIG:sTempPath/lock/${self.controller_name}_${self.task_name}]

	^try{
		^file:lock[$file_lock]{$result[$jCode]}
	}{
		^if($exception.type eq "file.lock" && ^exception.source.match[$file_lock^$][n]){
			$exception.handled(true)

			^rem{ *** TODO: write to log and result null *** }
#			$result[Process #$process_id already run]
			$result[]
		}
	}
#end @lock_process[]
