##############################################################################
@auto[filepath]
	$self.path[^file:fullpath[^file:dirname[$filepath]]]
#	^throw_inspect[$self.path]
#end @auto[]



##############################################################################
@profiling[]
	$result[^include[${CONFIG:sProfilingPath}/profiling.phtml]]
#end @profiling[]
