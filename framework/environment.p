##############################################################################
#	Класс для инициализции окружения переменных, просмотранства имен
##############################################################################

@CLASS
Environment

@OPTIONS
locals



##############################################################################
@auto[]
	$self.oImage[]
	$self.oSql[]
	$self.oSqlBuilder[]
	$self.oLogger[]
	$self.oMap[]
	$self.oMemcached[]
	$self.oCacheStore[]
#	$self.oController[]
#	$self.oView[]

	$self.sRequest[]
	
	^rem{ *** current application name *** }
	$self._app_name[]
	
	$self._stat[
		$.process[^Rusage:calculate_empty[]]
		$.render[^Rusage:calculate_empty[]]
		$.sql[^Rusage:calculate_empty[]]
	]
	
	$self.performed_render(false)
	$self.performed_redirect(false)
#end @auto[]



##############################################################################
@GET_CONFIG[]
	$result[$CONFIG:CLASS]
#end @GET_CONFIG[]