##############################################################################
#
##############################################################################

@USE
/../framework/rusage.p
/../framework/framework.p



##############################################################################
@main[][result]
	^use[$CONFIG:sFrameworkPath/migration/framework_db.p]
	^Framework:run[$request:argv.1]
#end @main[]
