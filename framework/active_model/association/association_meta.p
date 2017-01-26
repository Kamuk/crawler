##############################################################################
#	
##############################################################################

@CLASS
AssociationMeta

@OPTIONS
locals



##############################################################################
@auto[]
	$self.MAPPER_CLASS_OBJECT[^hash::create[]]
#end @auto[]



##############################################################################
#	.name - name of associationl
#	.association_class_name and :class_name must define
##############################################################################
@create[hOptions]
	$self.association_name[$hOptions.name]

	$self.association_class_name[$hOptions.association_class_name]
	$self.class_name[$hOptions.class_name]
	
	$self.inverse_of_name[$hOptions.inverse_of]

	$self.polymorphic($hOptions.polymorphic)
	
	^if(def $hOptions.through){
		$self.through[$hOptions.through]

		$self.association_proxy_name[$hOptions.association]
		^if(!def $self.association_proxy_name){
			$self.association_proxy_name[$self.association_name]
		}
	}{
		$self.through[]
		$self.association_proxy_name[]
	}

	$self.include[$hOptions.include]											^rem{ *** TODO: include *** }
	$self.join[$hOptions.join]													^rem{ *** TODO: join *** }
	$self.condition[$hOptions.condition]										^rem{ *** TODO: conditions *** }
	$self.order[$hOptions.order]												^rem{ *** TODO: order *** }
	
	$self.dependent[$hOptions.dependent]										^rem{ *** TODO: Void, Destroy, Delete, Nulled, DeleteAll ??? *** }

	$self.touch[$hOptions.touch]
	
	$self.before_save[$hOptions.before_save]									^rem{ *** TODO: переименовать в before_update & after_update *** }
	$self.after_save[$hOptions.after_save]
	
	$self.scope[$hOptions.scope]

#	^Framework:include_model[^string_transform[$association_class_name;classname_to_filename]]
#	^Framework:include_model[^string_transform[$class_name;classname_to_filename]]
#end @create[]



##############################################################################
#	Метод возвращает экземпляр класса для значения
##############################################################################
@implement[oInstance]
	$result[^_implement[]]
	$result.foreign_instance[$oInstance]
#end @implement[]



##############################################################################
@GET_association_mapper[]
	$result[$self.MAPPER_CLASS_OBJECT.[$self.association_class_name]]
	
	^if(!$result){
		$self.MAPPER_CLASS_OBJECT.[$self.association_class_name][^process{^$${self.association_class_name}:CLASS}]
		$result[$self.MAPPER_CLASS_OBJECT.[$self.association_class_name]]
	}
#end @GET_association_mapper[]



##############################################################################
@GET_mapper[]
	$result[$self.MAPPER_CLASS_OBJECT.[$self.class_name]]

	^if(!$result){
		$self.MAPPER_CLASS_OBJECT.[$self.class_name][^process{^$${self.class_name}:CLASS}]
		$result[$self.MAPPER_CLASS_OBJECT.[$self.class_name]]
	}
#end @GET_mapper[]



##############################################################################
#	Возвращает ActiveRelation для данной модели
##############################################################################
@GET_mapper_relation[]
^Framework:oLogger.trace[am.as.get_relation]{AssociationMeta "$self.association_name" from $self.association_mapper.class_name}{
	^if(def $self.scope){
		$scope[$self.mapper.[$self.scope]]
		^if(!^is[$scope;junction]){
			^throw[parser.runtime;$self.scope;No scope for $self.association_name from $self.association_mapper.class_name]
		}
		$result[^scope[]]
	}{
		$result[$self.mapper.model_relation]
	}
	^result.merge[
		$.include[$self.include]
		$.join[$self.join]
		$.condition[$self.condition]
		$.order[$self.order]
	]
}
#end @GET_mapper_relation[]
