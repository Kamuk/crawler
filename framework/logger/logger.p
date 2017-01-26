##############################################################################
#
##############################################################################

@CLASS
Logger

@OPTIONS
partial
locals



##############################################################################
@auto[]
	$self.SEVERITY[^enum::create[
		$.UNKNOWN[7]
		$.FATAL[6]
		$.ERROR[5]
		$.WARN[4]
		$.INFO[3]
		$.DEBUG[2]
		$.TRACE[1]
		$.ANY[0]
	]]
	
	$self.TEXT_INDENT[    ]
#end @auto[]



##############################################################################
@format_severity[uSeverity;sType][_column]
	$result[$self.SEVERITY.[$uSeverity]]
	
	^if(!def $result){
		$result[$self.SEVERITY.[UNKNOWN]]
	}
#end @format_severity[]



##############################################################################
@GET[]
	$result[$logdev]
#end @GET[]



##############################################################################
@GET_level[]
	$result[$_level]
#end @GET_level[]



##############################################################################
@SET_level[sLevel]
	$self._level[$sLevel]
#end @SET_level[]



##############################################################################
@GET_progname[]
	$result[$self._progname]
#end @GET_progname[]



##############################################################################
@SET_progname[sProgName]
	$self._progname[$sProgName]
#end @SET_progname[]



##############################################################################
@GET_logdev[]
	$result[$_logdev]
#end @GET_logdev[]



##############################################################################
@create[oLogDev;oLevel]
	^if(def $oLevel){
		$self.level[$self.SEVERITY.[$oLevel]]
	}{
		$self.level[$self.SEVERITY.[ERROR]]
	}
	$self.progname[]

	^if($oLogDev is LogDevice){
		$self._logdev[$oLogDev]
	}{
		^use[logdev.p]
		$self._logdev[^LogDevice::create[$oLogDev]]
	}
	
	$self._indent(0)
#end @create[]



##############################################################################
@format_message[sSeverity;dDateTime;sProgName;sMessage]
#	$result[^format_severity[$sSeverity;level]	[^dDateTime.gmt-string[] #${status:pid}]	^format_severity[$sSeverity;name] -- ${sProgName}: ${sMessage}]
#	$result[^console_text_line[$sProgName](25)	[^console_text_line[^eval($status:rusage.utime)[%.3f]](6)/^console_text_line[^eval($status:rusage.stime)[%.3f]](6)]	[^console_text_line[$status:memory.used](6)/^console_text_line[$status:memory.free](6)]	${sMessage}]
	$result[$status:pid	$self._indent	$sProgName	^for[i](0;$self._indent){$self.TEXT_INDENT}^sMessage.match[^#0A][gi]{ }]
#end @format_message[]



##############################################################################
@add[sSeverity;sProgName;sMessage;jCode;hParams][result]
	^if(!def $sSeverity){
		$sSeverity[UNKNOWN]
	}

	^if(^format_severity[$sSeverity] >= ^format_severity[$self.level]){
		^self._indent.inc[]
			
		^if(!def $sProgName){
			$sProgName[$progname]
		}
		^if(!def $sMessage){
			$sMessage[$sProgName]
			$sProgName[$progname]
		}

		^logdev.append{^format_message[$sSeverity;^date::now[];$sProgName][$sMessage]}

		^if(^format_severity[DEBUG] >= ^format_severity[$self.level] && $hParams){
			^hParams.foreach[name;params]{
				^logdev.append{^format_message[$sSeverity;^date::now[];$sProgName][  ${name}: ^inspect[$params]]}
			}
		}

		^if($CONFIG:profiling){
			^Rusage:log[$sProgName;$sMessage]{
				$result[$jCode]
			}[$hParams]
		}{
			$result[$jCode]
		}

		^self._indent.dec[]
	}{
		$result[$jCode]
	}
#end @add[]



##############################################################################
@flush[]
	^logdev.flush[]
#end @flush[]



##############################################################################
@trace[progname;message;jCode;hParams][result]
	^add[TRACE]{$progname;$message}{$jCode}{$hParams}
#end @trace[]



##############################################################################
@debug[progname;message;jCode;hParams][result]
	^add[DEBUG]{$progname;$message}{$jCode}{$hParams}
#end @debug[]



##############################################################################
@info[progname;message;jCode;hParams][result]
	^add[INFO]{$progname;$message}{$jCode}{$hParams}
#end @info[]



##############################################################################
@warn[progname;message;jCode;hParams][result]
	^add[WARN]{$progname;$message}{$jCode}{$hParams}
#end @warn[]



##############################################################################
@error[progname;message;jCode;hParams][result]
	^add[ERROR]{$progname;$message}{$jCode}{$hParams}
#end @error[]



##############################################################################
@fatal[progname;message;jCode;hParams][result]
	^add[FATAL]{$progname;$message}{$jCode}{$hParams}
#end @fatal[]
