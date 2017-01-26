##############################################################################
#
##############################################################################

@CLASS
TransactionWebController

@OPTIONS
locals

@BASE
WebController



##############################################################################
@process[hParams]
	^rem{ *** Запускаем транзакцию *** }
	^oSql.transaction{
		$result[^BASE:process[$hParams]]
	}
#end @process[]
