##############################################################################
#	
##############################################################################

@CLASS
fwSqlInfo

@BASE
SqlInfo



############################################################
@create[]
	^BASE:create[]
#end @create[]



##############################################################################
@storeQueryInfo[hOption;hQueryStat;uResult][locals]
	^BASE:storeQueryInfo[$hOption;$hQueryStat;$uResult]

	^if(def $hQueryStat){	
		$_status[
			$.time($hQueryStat.dTime / 1000)
			$.utime($hQueryStat.dUTime)
			$.memory_block($hQueryStat.iMemoryBlock)
			$.memory($hQueryStat.iMemoryKB)
		]
	}{
		$_status[^hash::create[]]
	}
	
	$_phase[^switch($Framework:_cur_phase){
		^case(2){render}
		^case(1){process}
	}]
	
	^rem{ *** FIXME: only if debug mode *** }
	^if(def $_phase){
		^Framework:_stat.[$_phase].time.dec($_status.time)
		^Framework:_stat.[$_phase].utime.dec($_status.utime)
		^Framework:_stat.[$_phase].memory_block.dec($_status.memory_block)
		^Framework:_stat.[$_phase].memory.dec($_status.memory)
	}

	^Rusage:add[$Framework:_stat.sql;$_status]

	^if($Framework:oLogger){
		^Framework:oLogger.debug[sql]{^_normalize[$hOption.sQuery]}
		^Framework:oLogger.debug{	Options: ^inspect[$.type[$hOption.sType] $.rows($hQuery.[$hStat.TOTAL.iCount].iRowsCount)]}
		^if(def $hQuery.[$hStat.TOTAL.iCount].sResult){
			^Framework:oLogger.debug{	Result: ^inspect[$hQuery.[$hStat.TOTAL.iCount].sResult]}
		}
		^Framework:oLogger.debug{Completed in ^_status.utime.format[%.5f] (^_status.time.format[%.5f])}
	}

	$result[]
#end @storeQueryInfo[]



###########################################################################
@_normalize[sQuery][result]
$result[$sQuery]
^if(def $result){
	$result[^result.match[\s+][g]{ }]
	$result[^result.match[\s(?=,)][g]{}]
	$result[^result.trim[]]
}
#end @_normalize[]