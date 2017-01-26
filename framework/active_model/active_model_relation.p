##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
#	Возвращает ActiveRelation для данной модели
##############################################################################
@static:GET_model_relation[]
^Framework:oLogger.trace[am.model_relation]{$self.CLASS_NAME}{
	$result[^ActiveRelation::create[$self.CLASS]]
	
#	$result.CRITERIA.alias[$self.model_name]									^rem{ *** добавляем alias по-умолчанию на имя класса (не таблицы) *** }
}
#end @static:GET_model_relation[]
