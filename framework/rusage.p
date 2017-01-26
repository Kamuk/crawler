##############################################################################
#
##############################################################################

@CLASS
Rusage



##############################################################################
@SET_limit[iLimit]
	$_limit(^iLimit.int($_limit))
#end @SET_limit[]



##############################################################################
@GET_stat[]
	$result[$_stat]
#end @GET_stat[]



##############################################################################
@GET_total[]
	$result[^calculate[$_begin;^_measure[]]]
	$result.utime($status:rusage.utime)
#end @GET_total[]



##############################################################################
@GET_logs[]
	$result[$self._logs]
#end @GET_logs[]



##############################################################################
@auto[]
	$_begin[^_measure[]]
	$_limit(2048)
	$_stat[
		$.calls(0)
		$.compact(0)
		$.memory[
			$.begin($_begin.memory.used)
			$.end(0)
			$.collected(0)
		]
		$.collected[^hash::create[]]
		$.points[^hash::create[]]
	]
	$_logs[^hash::create[]]
	$_log[$self]																^rem{ *** текущий указатель на весь лог = корень *** }
#end @auto[]



###########################################################################
@compact[bForce][result;iPrevUsed]
	^_stat.calls.inc(1)

	^if(^bForce.bool(false) || !$_stat.memory.end || ($_limit && ($status:memory.used - $_stat.memory.end) > $_limit)){
		^_stat.compact.inc(1)
		$iPrevUsed($status:memory.used)
		^memory:compact[]
		^_stat.memory.collected.inc($iPrevUsed - $status:memory.used)
		$_stat.memory.end($status:memory.used)
	}
#end @compact[]



##############################################################################
@_measure[]
	$result[
		$.rusage[$status:rusage]
		$.memory[$status:memory]
	]
#end @_measure[]



###########################################################################
# measure time/memory usage while running $jCode code
@measure[sVarName;jCode][hBegin;hEnd]
	^try{
		$hBegin[^_measure[]]
	}{
		$exception.handled(true)
	}

	$result[$jCode]

	^try{
		$hEnd[^_measure[]]
	}{
		$exception.handled(true)
	}

	$caller.[$sVarName][^calculate[$hBegin;$hEnd]]
#end @measure[]



##############################################################################
@log[command;message;jCode;params][prev;logs;i;log;stat]
	$prev[$self._log]
		
	$i($prev.logs)

	$prev.logs.[$i][
		$.command[$command]
		$.msg[$message]
		$.params[$params]
		$.stat[$self.total]
		$.profile[]
		$.logs[^hash::create[]]
	]
	$log[$prev.logs.[$i]]
	
	$self._log[$log]															^rem{ *** заменяем указатель на текущий на новый *** }
	
	^Rusage:measure[stat]{
		$result[$jCode]
	}
	
	$self._log[$prev]															^rem{ *** возвращаем указатель после выполнения *** }
	
	$log.profile[$stat]
#end @log[]



##############################################################################
#	Метод калькулирует все вызовы времени выполнения определенного кода
#	и сохраняет их в _stat под именем sName
#	флаг bNoCollectedTwice - позволяет не учитывать сбор вложенных вызововов для сбора по разным значениям
##############################################################################
@collect[sName;jCode;bNoCollectedTwice][stat]
	^if(!^bNoCollectedTwice.bool(true) || !$self._collected){
		^if(!def $self.stat.collected.[$sName]){
			$self.stat.collected.[$sName][^self.calculate_empty[]]
		}

		^self.measure[stat]{
			$self._collected(true)
			$result[$jCode]
		}
	
		$stat.calls(1)
		^self.add[$self.stat.collected.[$sName];$stat]
		
		$self._collected(false)
	}{
		$result[$jCode]
	}
#end @collect[]



##############################################################################
@benchmark[iIteration;sVarName;jCode][i;stat]
	^self.measure[stat]{^for[i](0;$iIteration){$jCode}}

	$caller.[$sVarName][$stat]
#end @benchmark[]



##############################################################################
@calculate_empty[]
	$result[
		$.calls(0)
		$.time(0)
		$.utime(0)
		$.stime(0)
		$.memory_block(0)
		$.memory(0)
		$.memory_used(0)
		$.memory_free(0)
	]
#end @calculate_empty[]



##############################################################################
# .time - 'dirty' execution time (second)
# .utime - 'pure' execution time (second)
# .memory - used memory (KB)
# .memory_block - used memory (blocks)
##############################################################################
@calculate[begin;end]
	$result[
		$.time((^end.rusage.tv_sec.double[] - ^begin.rusage.tv_sec.double[]) + (^end.rusage.tv_usec.double[] - ^begin.rusage.tv_usec.double[]) / 1000000)
		$.utime($end.rusage.utime - $begin.rusage.utime)
		$.stime($end.rusage.stime - $begin.rusage.stime)
		$.memory_block($end.rusage.maxrss - $begin.rusage.maxrss)
		^if($begin.memory){
			$.memory($end.memory.used - $begin.memory.used)
			$.memory_used($end.memory.used - $begin.memory.used)
			$.memory_free($end.memory.free - $begin.memory.free)
		}
	]
#end @calculate[]



##############################################################################
@add[begin;new]
	^begin.calls.inc($new.calls)
	^begin.time.inc($new.time)
	^begin.utime.inc($new.utime)
	^begin.stime.inc($new.stime)
	^begin.memory_block.inc($new.memory_block)
	^if($begin.memory){
		^begin.memory.inc($new.memory)
		^begin.memory_used.inc($new.memory_used)
		^begin.memory_free.inc($new.memory_free)
	}
#end @add[]
