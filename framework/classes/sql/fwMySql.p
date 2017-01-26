##############################################################################
#	
##############################################################################

@CLASS
fwMySql

@OPTIONS
locals

@USE
MySqlComp.p

@BASE
MySqlComp



############################################################
@create[sConnectString;hParam]
	^BASE:create[$sConnectString;$hParam]
#	$self.oSqlInfo[^fwSqlInfo::create[]]
	
	$self._transaction(false)													^rem{ *** транзакция включена *** }
	$self._transaction_start(false)												^rem{ *** транзакция запущена *** }
#end @create[]



##############################################################################
@transaction[jCode][_in_transaction]
^Environment:oLogger.trace[sql.transaction]{Start transaction}{
	$_in_transaction($self._transaction)

	^self.transaction_start[]
	$result[$jCode]
	^self.transaction_commit[]	
	
	^if($_in_transaction){
		^self.transaction_start[]
	}
}
#end @transaction[]



##############################################################################
@transaction_start[]
	$self._transaction(true)
#end @transaction_start[]



##############################################################################
@transaction_commit[]
	^self.void{COMMIT}
	$self._transaction(false)
	$self._transaction_start(false)
#end @transaction_commit[]



##############################################################################
@transaction_rollback[]
	^if($self._transaction_start){
	^self.void{ROLLBACK}
	}
	$self._transaction_start(false)
#end @transaction_rollback[]



##############################################################################
@get_lock[sName;iTimeout]
	^self.int{SELECT GET_LOCK('$sName', ^iTimeout.int(0))}[ $.default(0) ]
#end @get_lock[]



##############################################################################
@release_lock[sName]
	^self.int{SELECT RELEASE_LOCK('$sName')}[ $.default(0) ]
#end @release_lock[]



###########################################################################
@_execute[jSql]
	^if($self._transaction && !$self._transaction_start){
		$self._transaction_start(true)
		^self.void{START TRANSACTION}
	}
	$result[^BASE:_execute{$jSql}]
#end @_execute[]



##############################################################################
@_measure[hOption;jSql]
^Environment:oLogger.debug[sql.${hOption.sType}][^_normalize[$hOption.sQuery]]{
	$result[^BASE:_sql[$hOption]{$jSql}]
}[
	^if($hOption.hSql){$.Params[$hOption.hSql]}
]
#end @_measure[]




###########################################################################
@_normalize[sQuery][result]
$result[$sQuery]
^if(def $result){
	$result[^result.match[\s+][g]{ }]
	$result[^result.match[\s(?=,)][g]{}]
	$result[^result.trim[]]
}
#end @_normalize[]
