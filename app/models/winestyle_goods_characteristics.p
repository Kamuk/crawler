##############################################################################
#	
##############################################################################

@CLASS
WinestyleGoodsCharacteristics

@OPTIONS
locals

@BASE
ActiveModel



##############################################################################
@auto[]
	^BASE:auto[]	

	^field[goods_id][
		$.type[int]
	]
	^field[code_characteristics][
		$.type[string]
	]
	^field[characteristics][
		$.type[string]
	]
	
#end @auto[]
