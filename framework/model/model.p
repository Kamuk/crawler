##############################################################################
#	
##############################################################################

@CLASS
Model

@OPTIONS
locals
partial
dynamic

@BASE
Environment



##############################################################################
@static:auto[]
^oLogger.trace{m.auto}{$self.CLASS_NAME - Model}{
	
	^if($self.CLASS_NAME eq "Model"){
		$self._META[^hash::create[]]											^rem{ *** глобальный хеш для метаданных с описанием моделей *** }
			
		$self._CACHE[^hash::create[]]											^rem{ *** глобавльный хеш для кеширования *** }
	}
	
	^self.META.add[
		$.class_name[^self.CLASS_NAME.match[Mapper^$][i]{}]
		$.model_name[^string_transform[$self.CLASS_NAME;classname_to_filename]]
		
		$.child_classes[^array::create[]]										^rem{ *** массив для родительских классов *** }
	]
}
#end @auto[]



##############################################################################
@static:GET_META[]
	^if(!$self._META.[$self.CLASS_NAME]){
		$self._META.[$self.CLASS_NAME][^hash::create[]]
	}
		
	$result[$self._META.[$self.CLASS_NAME]]
#end @GET_META[]



##############################################################################
@create[hData]
^Environment:oLogger.trace[m.create;constructor]{
	$self._created(true)
	$self._changed(true)
	$self._validated(false)
	
	$self._marked_for_destruction(false)
	
	$self._id[]
	$self._version(1)															^rem{ *** локальная версия объекта *** }
	
	$self._in_update(0)
	$self._go_save(false)
	$self._in_save(false)														^rem{ *** обозначает стадию before_save *** }	
	$self._in_after_save(false)													^rem{ *** обозначает стадию after_save *** }

	$self._errors[^ModelErrors::create[]]

	$self._data_was[^hash::create[]]
	$self._data_dirty[^hash::create[]]											^rem{ *** массив измененных полей *** }

	$self.attributes[$hData]
	$self.attributes_was[]

	^rem{ *** TODO: calculate no_primary_key when create model *** }
	^if($self.attributes && ^primary_key.bool(true)){
		$self.id[$self.attributes.[$primary_key]]
	}
	
	^rem{ *** FIXME: if primary_key = false that always not_new *** }
	^if(def $self.id){
		$self._created(false)
		$self._changed(false)
		$self._validated(true)
		
		$self.attributes_was[$hData]
	}
	
	$self._providers[^hash::create[]]
	$self._listeners[^hash::create[]]
	
	^self.after_initialize[]
}
#end @create[]



##############################################################################
@clone[]
	^rem{ *** TODO: clone object instance *** }
#end @clone[]



##############################################################################
@update[hData;hDataFilter;bPrivateMode]
	$result[]
	
	^if($self._in_after_save){
		^self._version.inc[]													^rem{ *** если вызываем обновление из after_* то attributes_was должны быть уже от следуюшей версии  *** }
	}
	
	^rem{ *** update может быть вызван рекурсивно поэтому нужно считать кол-во вызовов *** }
	^self._in_update.inc[]

	$hData[^hash::create[$hData]]
	$hDataFilter[^hash::create[$hDataFilter]]
	^hData.sub[$hDataFilter]
	
	^rem{ *** только для 1-ого вызова инициализируем выделение аттрибутов *** }
	^rem{ *** старые значения сохраняются до окончания вызова save *** }
#	^if($self._in_update == 1 && !$self.is_changed || $self.attributes_was is void){
#		$self.attributes_was[$attributes]
#	}
	
	^before_update_attributes[]

	$r(^self._update_attributes[$hData;$hDataFilter;$bPrivateMode])
	
	^after_update_attributes[]
	
	^if(^r.bool(true)){
#		$self._changed(true)
		$self._validated(false)
	}
	^if(!$self.is_changed){
		$self._validated(true)													^rem{ *** если изменения привели к возврату - все валидно *** }
	}
	
	^self._in_update.dec[]
	
	^if($self._in_after_save){
		^self._version.dec[]
	}
#end @update[]



##############################################################################
#	Метод обновляет аттрибуты у модели
#	Возвращает true, если хотябы одно поле изменилось
##############################################################################
@_update_attributes[hData;hDataFilter]
	$self.attributes[$self.attributes]
	^self.attributes.add[$hData]

	$result(true)
#end @_update_attributes[]



##############################################################################
@update_attributes[hData;hDataFilter]
	^self.update[$hData;$hDataFilter]
	$result(^save[])
#end @update_attributes[]



##############################################################################
@update_attribute[sName;uValue]
	$result[]
	^self.update[
		$.[$sName][$uValue]
	][](true)
#end @update_attribute[]



##############################################################################
@validate[]
	$result[]

	^if($self.is_changed && !$self.is_validated){
		^self._errors.clear[]
		^self.before_validate[]
		^self._validate[]
		^self.after_validate[]
	}

	$self._validated(true)
#end @validate[]



##############################################################################
#	Сохранение изменений
@save[][_is_new;model]
	$result(false)
		
	^rem{ *** если уже в фазе сохранения - повторно не вызываем *** }
	^if(!$self._in_save){
		^if($self._in_after_save){
			^self._version.inc[]												^rem{ *** поднимаем версию для использования в validate текущих attributes_was *** }
		}

		$is_valid($self.is_valid)												^rem{ *** проводим валидацию модели *** }
		
		^if($self._in_after_save){
			^self._version.dec[]
		}

		^if($self.is_marked_for_destruction){
			$result(^self.destroy[])											^rem{ *** удаляем если помечен на удаление *** }
		}($is_valid){
			^if(!$self._providers){
				^if($self.is_changed){
					$self._in_save(true)
					
					$_is_new($self.is_new)
					
					^if($self._in_after_save){
						$_in_after_save(true)
						$self._in_after_save(false)

						^self._version.inc[]
					}{
						$_in_after_save(false)
					}

					^self.before_save[]
					^if($_is_new){
						^self.before_create[]
						^self._create[]
					}{
						^self.before_update[]
						^self._update[]
					}

					$self._created(false)
					$self._changed(false)
				
					$self._data_dirty[^hash::create[]]
				
					^rem{ *** фаза сохранения заканчивается после записи в БД,
						      если будет вызван повторный save - он внесет изменения в БД *** }
					^if(!$self._in_after_save){
						$self._in_save(false)
					}
					$self._in_after_save(true)
					
					$self._data_was.[^eval($self._version + 1)][^hash::create[$self.attributes]]	^rem{ *** инициируем attributes_was для новой версии *** }

					^if($_is_new){
						^self.after_create[]
					}{
						^self.after_update[]
					}
					^self.after_save[]

					^if($_in_after_save){
						^self._version.dec[]
					}{
						^self._version.inc[]
						$self._in_after_save(false)
					}
				}
				
				^foreach[^hash::create[$self._listeners];model]{
					^model.remove_provider[$self]
					^self.remove_listener[$model]

					^if($model._go_save && !^model.save_native[]){
						^throw_inspect[^model.errors.array[]]
					}
				}
				
				^if(!$_in_after_save){
					$self._go_save(false)
				}
			}{
				$self._go_save(true)
			}

			$result(true)
		}
	}{
		$result(true)
	}
#end @save[]



##############################################################################
#	Метод для "проксирующего" сохранения
##############################################################################
@GET_save_native[]
	$result[$self.save]
#end @GET_save_native[]



##############################################################################
#	Удаление из БД
##############################################################################
@delete[]
	$result(true)
	
	^if(!$self.is_new){
		^self.before_delete[]
		^self._delete[]
		^self.after_delete[]
		
		^rem{ *** TODO: заблокировать объект для изменений *** }
	}
#end @delete[]



##############################################################################
#	Пометка модели для удаления при сохранении
##############################################################################
@mark_for_destruction[]
	$self._marked_for_destruction(true)
#end @mark_for_destruction[]



##############################################################################
#	Удаление из БД и связанные объекты
##############################################################################
@destroy[]
	$result(true)
	
	^if(!$self.is_new){
		^self.before_destroy[]
		^self._destroy[]
		^self._delete[]
		^self.after_destroy[]

		^rem{ *** TODO: заблокировать объект для изменений *** }
	}
#end @destroy[]



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
@wait_save[oObject]
	^self.add_provider[$oObject]												^rem{ *** добавляю в зависимости что жду его save *** }
	^oObject.add_listener[$self]
#end @wait_save[]

