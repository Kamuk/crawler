##############################################################################
#	Default routing
##############################################################################

	^rem{ *** default rule *** }
	^oMap.connect[/:controller/:action/:id.:format]

	^rem{ *** root rule *** }
	^oMap.root[
		$.controller[crawler]
	]

#	^rem{ *** not found rule *** }
#	^oMap.not_found[
#		$.controller[dispatche]
#		$.action[run]
#	]
