##############################################################################
#	
##############################################################################

@CLASS
Page

@OPTIONS
locals

@BASE
ActiveModel



##############################################################################
@auto[]
	^BASE:auto[]	

	^field[url][
		$.type[string]
	]
	^field[state][
		$.type[int]
	]
	^field[dt_update][
		$.type[date]
	]
	^field[status][
		$.type[string]
	]
#end @auto[]



##############################################################################
@before_save[]
	^BASE:before_save[]
	
	$self.dt_update[^date::now[]]
	
#end @before_save[]
