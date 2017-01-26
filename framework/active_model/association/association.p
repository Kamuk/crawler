##############################################################################
#	
##############################################################################

@CLASS
Association

@OPTIONS
partial

#@BASE
#Environment



##############################################################################
@auto[]
	^use[association_meta.p]
	^use[one_association_meta.p]
	^use[many_association_meta.p]
	^use[belongs_to_association_meta.p]
	^use[has_one_association_meta.p]
	^use[has_many_association_meta.p]
	^use[has_and_belongs_to_many_association_meta.p]
	^use[has_many_through_association_meta.p]

	^use[association_query_methods.p]
	^use[one_association.p]
	^use[many_association.p]
	^use[belongs_to_association.p]
	^use[has_one_association.p]
	^use[has_many_association.p]
	^use[has_and_belongs_to_many_association.p]
	^use[has_many_through_association.p]
#end @auto[]



##############################################################################
@_inspect[]
	$result[$self.CLASS_NAME ($self.mapper.CLASS_NAME)]
#end @_inspect[]



##############################################################################
@GET_DEFAULT[sName]
	^throw_inspect[NO $sName]
#end @GET_DEFAULT[]



##############################################################################
@GET_meta[]
	$result[$self._meta]
#end @GET_meta[]



##############################################################################
@GET_association_name[]
	$result[$self.meta.association_name]
#end @GET_association_name[]



##############################################################################
@GET_association_mapper[][result]
	$result[$self.meta.association_mapper]
#end @GET_association_mapper[]



##############################################################################
@GET_mapper[][result]
	$result[$self.meta.mapper]
#end @GET_mapper[]



##############################################################################
@GET_condition[]
	$result[$self.meta.condition]
#end @GET_condition[]



##############################################################################
@GET_dependent[]
	$result[$self.meta.dependent]
#end @GET_dependent[]



##############################################################################
@GET_include[]
	$result[$self.meta.include]
#end @GET_include[]



##############################################################################
@GET_join[]
	$result[$self.meta.join]
#end @GET_join[]



##############################################################################
@GET_order[]
	$result[$self.meta.order]
#end @GET_order[]



##############################################################################
@GET_touch_method_name[]
	$result[$self.meta.touch]
#end @GET_touch_method_name[]



##############################################################################
@GET_before_save_method_name[]
	$result[$self.meta.before_save]
#end @GET_before_save_method_name[]



##############################################################################
@GET_after_save_method_name[]
	$result[$self.meta.after_save]
#end @GET_after_save_method_name[]







##############################################################################
@GET[type]
	^switch[$type]{
		^case[def]{
			$result(true)
		}

		^case[bool]{
			$result($self.data)
		}
	
		^case[DEFAULT;hash]{
			$result[$self.data]
		}
	}
#end @GET[]



##############################################################################
@GET_is_loaded[]
	^throw_inspect[NO is_loaded]
#end @GET_is_loaded[]



##############################################################################
@GET_data[]
^Framework:oLogger.trace[am.as]{GET_data}{
	^if(!$self.is_loaded){
		^self.load[]
	}
	$result[$self._data]
}
#end @GET_data[]



##############################################################################
@GET_foreign_instance[][result]
	$self._foreign_instance
#end @GET_foreign_instance[]



##############################################################################
@SET_foreign_instance[oInstance]
	$self._foreign_instance[$oInstance]
#end @SET_foreign_instance[]



##############################################################################
@GET_RELATION[]
#	^if(!def $self._relation){
#		$self._relation[^self.__relation[]]
#	}
	
	$result[^self.__relation[]]
#end @GET_RELATION[]





##############################################################################
@create[oAssociationMeta]
	$self._meta[$oAssociationMeta]

	$self._is_loaded(false)
	$self._relation[]
	$self._data[]
	
	$self._foreign_instance[]
	
	$self._before_save_called(false)
	$self._after_save_called(false)

	$self._providers[^hash::create[]]
	$self._listeners[^hash::create[]]
#end @create[]                                                 



##############################################################################
@GET_is_touch[]
	$result((^self.touch_method_name.bool(false) && $self.touch_method_name) || def $self.touch_method_name)
#end @GET_is_touch[]



##############################################################################
@GET_touch_method[]
	$result[^if(^self.touch_method_name.bool(false)){touch}{$self.touch_method_name}]
#end @GET_touch_method[]



##############################################################################
@before_save[]
	^if(!$self._before_save_called && def $self.before_save_method_name){
		$self._before_save_called(true)
		
		^self.foreign_instance.[$self.before_save_method_name][]
		
		$self._before_save_called(false)
	}
#end @before_save[]



##############################################################################
@after_save[]
	^if(!$self._after_save_called && def $self.after_save_method_name){
		$self._after_save_called(true)
		
		^self.foreign_instance.[$self.after_save_method_name][]

		$self._after_save_called(false)
	}
#end @after_save[]



##############################################################################
@init[hData]
	$self._is_loaded(true)
	^self._init[$hData]
#end @init[]



##############################################################################
#	Метод вызывается при destroy родительского объекта
##############################################################################
@destroy_dependent[]
	^_destroy_dependent[]
	
	$result[]
#end @destroy_dependent[]



##############################################################################
@_destroy_dependent[]
	^switch[$self.dependent]{
		^case[void]{}
		^case[delete]{^_destroy_dependent_delete[]}
		^case[destroy]{^_destroy_dependent_destroy[]}
		^case[nulled]{^_destroy_dependent_nulled[]}
		^case[DEFAULT]{^_destroy_dependent_default[]}
	}
#end @_destroy_dependent[]



##############################################################################
@_destroy_dependent_default[]
	$result[]
#end @_destroy_dependent_default[]



##############################################################################
#	Предназначени для сброса ассоциаций у всех связанных моделей
#	Т.к. при оновлении данной модели (если данные о связи находятся в данной модели)
#	то в ассоциациях у других моделей останутся закешированными неправильные связи
#	Вызывается при сохранении текущей модели
##############################################################################
@update_dependent_associations[]
	^throw_inspect[NO METHOD]
#end @update_dependent_associations[]



##############################################################################
@wait_save[oObject]
	^self.add_provider[$oObject]												^rem{ *** добавляю в зависимости что жду его save *** }
	^oObject.add_listener[$self]
#end @wait_save[]



##############################################################################
@add_provider[oObject]
	$self._providers.[^reflection:uid[$oObject]][$oObject]
#end @add_provider[]



##############################################################################
@remove_provider[oObject]
	^self._providers.delete[^reflection:uid[$oObject]]
#end @remove_provider[]



##############################################################################
@add_listener[oObject]
	$self._listeners.[^reflection:uid[$oObject]][$oObject]
#end @add_listener[]



##############################################################################
@remove_listener[oObject]
	^self._listeners.delete[^reflection:uid[$oObject]]
#end @remove_listener[]



##############################################################################
@GET__go_save[]
	$result(true)
#end @GET__go_save[]



##############################################################################
@GET_is_marked_for_destruction[]
	$result(false)
#end @GET_is_marked_for_destruction[]



##############################################################################
@save_native[][model]
	^if(!$self._providers){
		^foreach[^hash::create[$self._listeners];model]{
			^model.remove_provider[$self]
			^self.remove_listener[$model]

			^if($model._go_save && !^model.save_native[]){
				^throw_inspect[^model.errors.array[]]
			}
		}
	}
	
	$result(true)
#end @save_native[]
