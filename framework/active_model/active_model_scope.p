##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
@static:scope[sName;uParam]
	^if($self.SCOPES.[$sName]){
		^throw[parser.runtime;DublicateScope;Can't create two scope with match name "$sName" for ${self.CLASS_NAME}.]
	}
	
	$self.SCOPES.[$sName][$self.model_relation]
	^self.SCOPES.[$sName].merge[$uParam]									^rem{ *** TODO: поддержку произвольной функции с входными аргументами *** }
	
	^rem{ *** find method for attribute *** }
	$method_name[${sName}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.scope]{create find scope method for $sName}{
			^process[$self]{@static:${method_name}[uParam1^;uParam2]
				^$result[^^self.SCOPES.${sName}.clone[^$uParam1]]
				^^result.merge[^$uParam2]
				^rem{ *** TODO: добавить множество аргументов *** }
			}
		}
	}
#end @scope[]



##############################################################################
#	Наложение scope на область кода по-умолчанию
##############################################################################
@static:with_scope[sName;jCode]
	^if(!$self.SCOPES.[$sName]){
		^throw[parser.runtime;NoScope;Can't with_scope of "$sName" for ${self.CLASS_NAME}.]
	}
	
	^throw_inspect[TODO]
	
	$scope[^AMCriteria::create[]]
	^scope.merge[$self.SCOPES.[$sName]]

	^self.SCOPES_WITH.add[$scope]
	$scope_id($self.SCOPES_WITH._count - 1)
	
	$result[$jCode]

	^self.SCOPES_WITH.delete($scope_id)
#end @with_scope[]



##############################################################################
@static:default_scope[uParam]
	$self.SCOPES.default_scope[$self.model_relation]
	
	^rem{ *** TODO: поддержку произвольной функции с входными аргументами *** }

	^self.SCOPES.[default_scope].merge[$uParam]
#end @static:default_scope[]
