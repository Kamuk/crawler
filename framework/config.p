##############################################################################
#	Конфигурационный класс
#	Только статическое использование
##############################################################################

@CLASS
CONFIG

@OPTIONS
locals



##############################################################################
@auto[]
	$self.request_charset[UTF-8]
	$self.response_charset[UTF-8]

	$self.sRootPath[/..]

	$self.sApplicationPath[$self.sRootPath/app]
	$self.sControllerPath[$self.sApplicationPath/controllers]
	$self.sModelPath[$self.sApplicationPath/models]
	$self.sMailPath[$self.sApplicationPath/mailer]
	$self.sViewPath[$self.sApplicationPath/views]
#	$self.sViewLayoutPath[layouts]
#	$self.sLayoutPath[$self.sViewPath/$self.sViewLayoutPath]
	$self.sHelpersPath[$self.sApplicationPath/helpers]
	$self.sConfigPath[$self.sRootPath/config]
	$self.sEnvironmentPath[$self.sConfigPath/env]
	$self.sScriptPath[$self.sRootPath/script]
	$self.sMigrationPath[$self.sRootPath/migration]
	$self.sEXEPath[$self.sRootPath/exe]
	$self.sFrameworkPath[$self.sRootPath/framework]
	$self.sFrameworkLibPath[$self.sFrameworkPath/classes]
	$self.sProfilingPath[$self.sFrameworkPath/profiling]
	$self.sLibPath[$self.sRootPath/classes]
	$self.sLogPath[$self.sRootPath/log]
	$self.sTempPath[$self.sRootPath/tmp]
	$self.sCachePath[$self.sTempPath/cache]
	$self.sCacheTime[
		$.routing(60 * 60)
	]
	$self.sPublicPath[$self.sRootPath/www]
	
#	$self.sRootPath[^request:document-root.mid(0;^request:document-root.length[] - ^self.sPublicPath.length[])]
#	$self.sRootPath[^self.sRootPath.trim[end;/]]
#	$request:document-root[$self.sRootPath]

	^rem{ *** TODO: check availible formats *** }
	$self.AvailableFormats[html, xml]

	$self.debug_level(0)
	$self.profiling(false)														^rem{ *** включить профилирование запросов *** }
#end @auto[]