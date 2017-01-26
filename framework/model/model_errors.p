##############################################################################
#	
##############################################################################

@CLASS
ModelErrors



##############################################################################
@GET[]
	$result($_status)
#end @GET[]





##############################################################################
#	name - псевдоимя для поиска сообщения об ошибке во внешнем массиве
#	fields - поля, участвующие в возникновении ошибки
#	message - стандартное сообщение об ошибке
##############################################################################
@create[]
	$self._status[^table::create{name	field	message	source}]
#end @create[]



##############################################################################
@append[sError;uFields;sMsg;sSource]
	^self._status.append{$sError	$uFields	$sMsg	$sSource}
#end @append[]



##############################################################################
@join[oErrors;prefix;source]
	^oErrors._status.menu{
		^self.append[^if(def $prefix){${prefix}.}${oErrors._status.name};$oErrors._status.field;$oErrors._status.message;$oErrors._status.source]
	}
#end @join[]



##############################################################################
@clear[]
	^self.create[]
#end @clear[]



##############################################################################
@decode[]
	^_status.menu{$_status.name}[, ]
#end @decode[]



##############################################################################
@array[]
	$result[^array::create[]]
	
	^self._status.menu{
		^result.add[
			$.code[$_status.name]
			$.field[$_status.field]
			$.msg[^if(def $_status.message){$_status.message}{$_status.name}]
			^if(def $_status.source){$.source[$_status.source]}
		]
	}
#end @array[]
