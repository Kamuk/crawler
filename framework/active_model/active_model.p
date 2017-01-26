##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial
dynamic

@BASE
Model



##############################################################################
#	$_fields
#	$_primary_key - TODO: can be hash or false => id must be hash too or no id
#	$_table_name
##############################################################################


#^rem{ *** TODO: добавить хранение ссылок на все инициализированные ассоциации, для последующего обновления их при обновлении данной модели *** }



##############################################################################
@static:auto[]
^oLogger.trace[am.auto]{$self.CLASS_NAME - ^reflection:base_name[$self]}
	^BASE:auto[]
	
	^if($self.CLASS_NAME eq ActiveModel){
		$self.GLOBAL_CACHE_ENABLED(true)
	}
	^if(!^self._CACHE.contains[$self.table_name]){
		$self._CACHE.[$self.table_name][^hash::create[]]
	}

	^rem{ *** для ActiveModel не инициализировать переменные *** }
	^self._META.[$self.CLASS_NAME].add[
		$.CACHE_ENABLED(true)

#		^rem{ *** structure: $.[$class_name].[$model_id] *** }
		$.model_cache[$self._CACHE.[$self.table_name]]							^rem{ *** хеш для хранения кешированных объектов *** }
		$.fields[^hash::create[]]												^rem{ *** хеш для хранения аттрибутов модели *** }
		$.fields_accessor[^hash::create[]]										^rem{ *** хеш для хранение флагов обновления аттрибутов, которых нет в модели *** }
		$.nested_attributes_for[^hash::create[]]
		$.association[^hash::create[]]											^rem{ *** хеш для ассоциаций *** }
		$.validators[^array::create[]]											^rem{ *** массив для хранения валидаторов *** }
		$.attached_files_meta[^hash::create[]]									^rem{ *** хеш для хранения метаданных прикрепленных файлов *** }
		$.scopes[^hash::create[]]
		$.scopes_with[^array::create[]]
		$.inherited_from[]
	]
	
	^if($BASE:CLASS){
		$b[^reflection:base[$self]]
		^if($b.CLASS_NAME ne "Model" && $b.CLASS_NAME ne "ActiveModel"){
			^self._META.[$b.CLASS_NAME].child_classes.add[$self]
		}	
	}
}
#end @auto[]



##############################################################################
@GET_CHILD_CLASSES[]
	$result[^array::create[]]
	
	^result.add[$self.CLASS]
	^foreach[$self.META.child_classes;class]{
		^result.join[$class.CHILD_CLASSES]
	}
#end @GET_CHILD_CLASSES[]



##############################################################################
@GET_file_path[]
	$result[/off-line/^self.table_name.lower[]/${self.id}]
#end @GET_file_path[]



##############################################################################
@static:field[sAlias;hParams]
	^if($self.FIELDS.[$sAlias]){
		^throw[parser.runtime;field error;failed to initialize field $sAlias]
	}
	
^oLogger.trace[am.field]{$self.CLASS_NAME - initialize field $sAlias}{
	^rem{ *** добавляем данные о аттрибуте *** }
	^oLogger.trace[am.field.meta]{create field for $sAlias}{
		$self.FIELDS.[$sAlias][^DBField::create[
			^hash::create[$hParams]
			$.alias[$sAlias]
		]]
	}
	
	^rem{ *** getter method for attribute *** }
	$method_name[GET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.getter]{create getter for $sAlias}{
			^process[$self]{@${method_name}[]
				^if($sAlias eq "count"){
					^^if(^^reflection:dynamical[]){
						^$result[^$self.attributes.$sAlias]
					}{
						^$result[^$self.CLASS.model_relation.$sAlias]
					}
				}{
					^$result[^$self.attributes.$sAlias]
				}
			}
		}
	}

	^rem{ *** getter method for dirty attribute *** }
	$method_name[GET_${sAlias}_was]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.was]{create dirty getter for $sAlias}{
			^process[$self]{@${method_name}[]
				^$result[^$self.attributes_was.$sAlias]
			}
		}
	}
	
	^rem{ *** find method for attribute *** }
	$method_name[find_all_by_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.find_all]{create find_all method for $sAlias}{
			^process[$self]{@static:${method_name}[value^;hParam]
				^$result[^^self.CLASS.find_by_attributes[
					^$.${sAlias}[^$value]
				][^$hParam]]
			}
		}
	}
	
	^rem{ *** find method for attribute *** }
	$method_name[find_by_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.find_by]{create find method for $sAlias}{
			^process[$self]{@static:${method_name}[value^;uParam]
				^$criteria[^^AMCriteria::create[]]
				^^criteria.condition[`$self.table_name`.`$self.FIELDS.[$sAlias].name` = ^^self.FIELDS.[$sAlias].sql-string[^$value]]
				^^criteria.merge[^$uParam]

				^$result[^^self.CLASS.find_first[^$criteria]]
			}
		}
	}

	^rem{ *** setter method for attribute *** }
	$method_name[SET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.setter]{create setter for $sAlias}{
			^process[$self]{@${method_name}[value]
				^^self.update_attribute[$sAlias^;^$value]
				^$result[]
			}
		}
	}
	
	$result[]
}{
	$.Params[$hParams]
}
#end @field[]



##############################################################################
@static:field_accessor[sAlias]
	$self.ACCESSORS.[$sAlias](true)

	^rem{ *** getter method for attribute *** }
	$method_name[GET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.accessor.getter]{create getter for $sAlias}{
			^process[$self]{@${method_name}[]
				^$result[^$self.attributes.$sAlias]
			}
		}
	}
	
	^rem{ *** setter method for attribute *** }
	$method_name[SET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^oLogger.trace[am.field.accessor.setter]{create setter for $sAlias}{
			^process[$self]{@${method_name}[value]
				^^self.update_attribute[$sAlias^;^$value]
				^$result[]
			}
		}
	}

	$result[]
#end @field_accessor[]



##############################################################################
@static:has_attached_file[sAlias;hParams]
	^if($self.ATTACHED_FILES.[$sAlias]){
		^throw[parser.runtime;attache error;failed to initialize file $sAlias]
	}

	$self.ACCESSORS.[$sAlias](true)
	$self.ATTACHED_FILES.[$sAlias][^ActiveFileMeta::create[$hParams]]

	^rem{ *** getter method for file *** }
	$method_name[GET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^process[$self]{@${method_name}[]
			^$result[^$self.attached_files.$sAlias]
		}
	}

	^rem{ *** setter method for file *** }
	$method_name[SET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^process[$self]{@${method_name}[value]
			^$self.attributes.${sAlias}[^^self.attached_files.${sAlias}.update[^$value]]
			^$result[]
		}
	}

	$result[]
#end @has_attached_file[]



##############################################################################
@static:has_attached_image[sAlias;hParams]
	^if($self.ATTACHED_FILES.[$sAlias]){
		^throw[parser.runtime;attache error;failed to initialize file $sAlias]
	}

	$self.ACCESSORS.[$sAlias](true)
	$self.ATTACHED_FILES.[$sAlias][^ActiveImageMeta::create[$hParams]]
	
	^rem{ *** getter method for image *** }
	$method_name[GET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^process[$self]{@${method_name}[]
			^$result[^$self.attached_files.$sAlias]
		}
	}
	
	^rem{ *** setter method for image *** }
	$method_name[SET_${sAlias}]
	^if(!($self.$method_name is junction)){
		^process[$self]{@${method_name}[value]
			^$self.attributes.${sAlias}[^^self.attached_files.${sAlias}.update[^$value]]
			^$result[]
		}
	}

	$result[]
#end @has_attached_image[]



##############################################################################
@static:accepts_nested_attributes_for[sAssociation;hOptions]
	^if(!def $self.ASSOCIATIONS.[$sAssociation]){
		^throw[parser.runtime;attache error;no association for $sAssociation]
	}
	^if($self.NESTED_ATTRIBUTES_FOR.[$sAssociation]){
		^throw[parser.runtime;attache error;nested attributes alrady set for $sAssociation]
	}

	$self.NESTED_ATTRIBUTES_FOR.[$sAssociation][^hash::create[$hOptions]]
	$self.NESTED_ATTRIBUTES_FOR.[$sAssociation].association[$self.ASSOCIATIONS.[$sAssociation]]
#end @static:accepts_nested_attributes_for[]



##############################################################################
@static:is_model_in_cache[iId]
#	^oLogger.trace[am.is_model_in_cache]{$self.CLASS_NAME#$iId}
	$result($self.MODEL_CACHE.$iId)
#end @is_model_in_cache[]



##############################################################################
@static:get_model_from_cache[iId]
#	^oLogger.trace[am.get_model_from_cache]{$self.CLASS_NAME#$iId}
	$result[$self.MODEL_CACHE.$iId]
#end @get_model_from_cache[]



##############################################################################
@static:set_model_to_cache[iId;oModel]
#	^self.oLogger.trace[am.set_model_to_cache]{$self.CLASS_NAME#$iId}
	^if($self.CACHE_ENABLED){
		$self.MODEL_CACHE.[$iId][$oModel]
	}
#end @set_model_to_cache[]



##############################################################################
#	Метод чистит кеш модели
##############################################################################
@static:clear_model_cache[]
	^if($self.CLASS_NAME eq ActiveModel){
		^foreach[$self._META;meta]{^if($meta.model_cache){^meta.model_cache.delete[]}}					^rem{ *** для ActiveModel сбрасываем кеш по всем моделям рекурсивно *** }
	}{
		^self.META.model_cache.delete[]
	}
	
	^Rusage:compact[]
#end @clear_model_cache[]



##############################################################################
@static:_init[hData;bCacheEnabled]
^oLogger.trace[am.init]{Init $self.class_name}{
	^rem{ *** кеш отключается глобально или если в запросе присутствуют дополнительные поля, которых по-умолчанию нет в модели *** }
	$bCache(^bCacheEnabled.bool(true) && $self.CACHE_ENABLED)

	^rem{ *** TODO: Кешировать STI модели в базовый класс (т.к. единый набор ID) *** }
	
	^if($bCache && def $hData.[$self.primary_key] && ^is_model_in_cache[$hData.[$self.primary_key]]){
		$result[^get_model_from_cache[$hData.[$self.primary_key]]]				^rem{ *** модель из кеша *** }
	}{
		^if(def $self.FIELDS.type && def $hData.type){
			$result[^reflection:create[$hData.type;create;$hData]]
		}{
			$result[^BASE:_init[$hData]]
		}

		^if($self.CACHE_ENABLED && def $hData.[$self.primary_key] && !^is_model_in_cache[$hData.[$self.primary_key]]){
			^set_model_to_cache[$hData.[$self.primary_key];$result]				^rem{ *** если глобальный кеш включен - кешируем модель *** }
		}
	}
}
#end @_init[]



##############################################################################
@create[hData][hAttributesData]
^Environment:oLogger.trace[am.create;constructor]{
	^rem{ *** FIXME: clear this code *** }
	$hAttributesData[^hash::create[$hData]]
	^if(def $self.ASSOCIATIONS){
		^hAttributesData.sub[$self.ASSOCIATIONS]
	}

	^BASE:create[$hAttributesData]
	
	^if($self.is_new && def $self.FIELDS.type && ^reflection:base_name[$self] ne "ActiveModel"){
		$self.type[$self.CLASS_NAME]											^rem{ *** заполняем field "type" автоматически при создании *** }
	}
	
	^rem{ *** initialize all attributes from DB type *** }
	^if(!$is_new){
		^_init_attributes[$hAttributesData]
	}

	^_init_associations[$hData]
#	^_init_associations[^hData.intersection[$self.ASSOCIATIONS]]

	^_init_attached[$hData]
}
#end @create[]



##############################################################################
@_init_attributes[hData]
	^self.FIELDS.foreach[alias;field]{
		$self.attributes.[$alias][^field.init[$hData.[$alias]]]
		$self.attributes_was.[$alias][^field.init[$hData.[$alias]]]
	}
#end @_init_attributes[]



##############################################################################
@_init_associations[hData][locals]
	$self._associations_values[^hash::create[]]

	^if(def $self.ASSOCIATIONS){
		^self.ASSOCIATIONS.foreach[name;meta]{
			^rem{ *** create implementation for each association *** }
			$association[^self.ASSOCIATIONS.[$name].implement[$self]]
			
			^rem{ *** initialize association if $hData conatins same data *** }
			^rem{ *** FIXME: need check association.mapper.primary key because data can be "" and object was initialize as new *** }
			^if(def $hData && def $hData.[$name]){^association.init[$hData.[$name]]}

			^rem{ *** include association implementation as $name variable *** }
			$self.associations.[$name][$association]
		}
	}
#end @_init_associations[]



##############################################################################
@_init_attached[hData]
	$self._attached_files[^hash::create[]]

	^self.ATTACHED_FILES.foreach[alias;meta]{
		^if($meta.CLASS_NAME eq "ActiveImageMeta"){
			$self.attached_files.[$alias][^ActiveImage::create[$alias;$self;$meta]]
		}{
			$self.attached_files.[$alias][^ActiveFile::create[$alias;$self;$meta]]
		}
	}
#end @_init_attached[]



##############################################################################
#	Перекрывает метод обновления аттрибутов от Model, обновление происходит
#	только для объявленных полей (fields)
##############################################################################
@_update_attributes[hData;hDataFilter;bPrivateMode][field;nested_attributes;_data;association;value;val;object;new_object]
	$result(false)

	^hData.foreach[alias;value]{
		^if($hDataFilter.[$alias]){
			^continue[]
		}
		
		$field[$self.FIELDS.[$alias]]
		$nested_attributes[$self.NESTED_ATTRIBUTES_FOR.[$alias]]
		
		^if(def $field){
			^rem{ *** если данные для существующего аттрибута *** }
			
			^rem{ *** если аттрибут защищенный, а обновление не напрямую *** }
			^if(!$bPrivateMode && $field.is_protected){
				^continue[]
			}

			^rem{ *** TODO: throw exception if data not correspond to field system type *** }
			^if(!($value is $field.system_type)){
				^rem{ *** если пришедший тип данных не соответствует системному типу для аттрибута *** }
				^try{
					^rem{ *** пытаемся преобразовать пришедшие данные *** }
					$value[^field.init[$value]]
					$hData.[$alias][$value]
				}{
#					^throw[ErrorAttributeType;ErrorAttributeType;Wrong type of present data for attribute '$fields.attribute_name'. Must be '$fields.system_type' present '$hData.[$fields.attribute_name].CLASS_NAME'.]
					$exception.handled(true)
					$hData.[$alias][]
				}
			}
			
			^rem{ *** проверяем изменение аттрибута с первоначальными данными (с последнего сохранения) *** }
			^if(!^field.compare_value[$self.attributes_was.[$alias];$value]){
				$result($result || true)
				$self.attributes_dirty.[$alias](true)							^rem{ *** выставляем флаг что аттрибут "грязный" = изменен *** }
			}{
				^self.attributes_dirty.delete[$alias]
			}
			
			^rem{ *** FIXME: если не проверять тип, то ошибка может возникнуть только при сохранении
				           а это значит, что все вышестоящие методы сохранения будут выполнены *** }

			^rem{ *** not init/prepare data because format is Parser object *** }
			$self.attributes.[$alias][$value]
		}($nested_attributes){
			^if($nested_attributes.association is HasAndBelongsToManyAssociationMeta){
				$association[$self.associations.[$alias]]
				
				^rem{ *** TODO: сохранения для новой модели *** }

				^if(def $value){
					$objects[^association.mapper.find_by_ids[$value]]				^rem{ *** ищем имеющиеся модели по id *** }
					^association.update[$objects]
				}{
					^association.clear[]
				}
				
			}($nested_attributes.association is ManyAssociationMeta){
				$association[$self.associations.[$alias]]

				^foreach[$value;val]{
					^if(def $val.id){
						$object[^association.mapper.find_by_id($val.id)]		^rem{ *** ищем имеющуюся модель по id *** }
					}
					^if(!def $val.id || !$object){
						$object[^association.build[](false)]					^rem{ *** иначе создаем новую *** }
					}

					^if($nested_attributes.allow_destroy && $val._destroy){
						^object.mark_for_destruction[]							^rem{ *** если разрешено удаление и пришел флаг удаления - помечаем на удаление  *** }
					}

					^object.update[$val]										^rem{ *** обновляем модель данными *** }
					
					^if(!$object.is_marked_for_destruction && $object.is_new && $nested_attributes.reject_if is junction && ^nested_attributes.reject_if[$object]){^continue[]}

					^association.wait_save[$object]
					
					$object._go_save(true)										^rem{ *** устанавливаю флаг необходимости сохранения *** }
					
					^rem{ ***
						прямой вызов save не подойдет, т.к. модель может и удаляться,
						а по замыслу мы хотим это сделать только по save основной модели
					*** }
				}
			}($nested_attributes.association is OneAssociationMeta){
				$association[$self.associations.[$alias]]
				^if(def $value.id){
					$object[^association.mapper.find_by_id($value.id)]			^rem{ *** ищем имеющуюся модель по id *** }
				}{
					$object[$association.object]
				}
				^if(!$object){
					$object[^association.build[](false)]
				}

				^if($nested_attributes.allow_destroy && $value._destroy){
					^object.mark_for_destruction[]								^rem{ *** если разрешено удаление и пришел флаг удаления - помечаем на удаление  *** }
				}

				^object.update[$value]											^rem{ *** обновляем модель данными *** }

				^association.update[$object]

				^if(!$object.is_marked_for_destruction && $object.is_new && $nested_attributes.reject_if is junction && ^nested_attributes.reject_if[$object]){^continue[]}
				
				^rem{ ***
					TODO: сохранение текущей модели должно привести к сохранению и связанной
					Если связанная уже существовала - проблем нет, 
					а если мы ее создали, то ее нужно сохранить автоматически
				*** }
				
				^if($object.is_new){
					^throw_inspect[COLLISION]

					^association.wait_save[$self]
				}
			}{
				^throw_inspect[$nested_attributes]
			}
			
			$result($result || true)
			$self.attributes_dirty.[_nested_attributes](true)
		}{
			^rem{ *** если данные для несуществующего аттрибута - требуется наличие ассессора *** }
			
			^if($self.ACCESSORS.[$alias]){
				^rem{ *** FIX: сделать что-то с сеттерами ассоциаций и ассесоров *** }
				^if(!$bPrivateMode && $self.SET_$alias is junction && (!$self.ASSOCIATIONS || !^self.ASSOCIATIONS.contains[$alias])){
					^rem{ *** call setter *** }
					$self.[$alias][$value]
				}{
					$self.attributes.[$alias][$value]
				}
				
				^rem{ *** для аттрибутов не из полей модели всегда ставим флаг обновления *** }					
				$result($result || true)
				$self.attributes_dirty.[_accessor](true)
			}
		}
	}
#end @_update_attributes[]



##############################################################################
@_validate[]
	^if(def $self.FIELDS.type){
		^self._validates_presence_of[ $.attribute[type] ]						^rem{ *** автоматический валидатор на поле type *** }
	}
	
	^rem{ *** вызов валидаторов *** }
	^self.VALIDATORS.foreach[i;validator]{
		^rem{ *** пропускаем валидатор, если он не для текущего режима *** }
		^if(def $validator.on){
			^if((!$self.is_new && $validator.on eq "create") || ($self.is_new && $validator.on eq "update")){
				^continue[]
			}
		}

		$method_info[^reflection:method_info[$self.CLASS_NAME;$validator.method]]

		^if(def $method_info.0){
			^self.[$validator.method][$validator]
		}{
			^self.[$validator.method][]
		}
	}

	^rem{ *** валидация связанных моделей *** }
	^foreach[^hash::create[$self._listeners];model]{
		^if($model._go_save && !$model.is_marked_for_destruction && !$model.is_valid_native){
			^self.errors.join[$model.errors_native]
		}
	}
#end @_validate[]



##############################################################################
@before_save[]
	^BASE:before_save[]
	
	^self.attached_files.foreach[alias;file]{
		^rem{ *** сохраняем изменения в файлах *** }
		^self.update[^file.prepare_model_attributes[]][](true)
	}
#end @before_save[]



##############################################################################
@after_create[]
	^BASE:after_create[]
	
	^rem{ *** делаем копию для избежания взаимоблокировок *** }
	$associations[^hash::create[$self.associations]]
	
	^associations.foreach[name;association]{
		^rem{ *** обновляем зависимые ассоциации, если только что создали этот объект => они будут загруженны повторно *** }		
		^association.update_dependent_associations[]
	}
#end @after_create[]



##############################################################################
@after_save[]
	^BASE:after_save[]
	
	^rem{ *** делаем копию для избежания взаимоблокировок *** }
	$associations[^hash::create[$self.associations]]
	
	^associations.foreach[name;association]{
		^rem{ *** вызываем touch при необходимости *** }
		^oLogger.trace[am.touch]{touch_association "$name" [$self.CLASS_NAME]}{
			^if($association.is_touch){
				^association.touch_association[]
			}
		}
	}
	
	^self.attached_files.foreach[alias;file]{
		^rem{ *** сохраняем изменения в файлах *** }
		^file.save[]
	}
#end @after_save[]



##############################################################################
@before_destroy[]
	^BASE:before_destroy[]
	
	^rem{ *** делаем копию для избежания взаимоблокировок *** }
	$associations[^hash::create[$self.associations]]
	
	^associations.foreach[name;association]{
		^rem{ *** обновляем зависимые ассоциации, т.к. удалили => они будут загруженны повторно *** }		
		^association.update_dependent_associations[]
		^association.destroy_dependent[]
	}
	
	^self.attached_files.foreach[alias;file]{
		^rem{ *** удаляем файлы *** }
		^file.delete_file[]
	}
#end @before_destroy[]



##############################################################################
@after_destroy[]
	^BASE:after_destroy[]
	
	^rem{ *** делаем копию для избежания взаимоблокировок *** }
	$associations[^hash::create[$self.associations]]
	
	^associations.foreach[name;association]{
		^rem{ *** вызываем touch при необходимости *** }
		^oLogger.trace[am.touch]{touch_association "$name" [$self.CLASS_NAME]}{
			^if($association.is_touch){
				^association.touch_association[]
			}
		}
	}
#end @after_destroy[]



##############################################################################
#	Стандартный метод touch
#	Вызывается автоматически при обновлении зависящих ассоциаций 
##############################################################################
@touch[]
	$result[]
	
	^if(def $self.FIELDS.[dt_update]){
		$self.dt_update[^date::now[]]

		^if(!^self.save[]){
			^throw_inspect[^self.errors.array[]]
		}
	}
#end @touch[]



##############################################################################
#	Метод сбрасывает заивисмые ассоциации на перезагрузку
#	Вызывается автоматически при создании зависящих ассоциаций
##############################################################################
@update_dependent_associations[]
	$result[]

	^rem{ *** делаем копию для избежания взаимоблокировок *** }
	$associations[^hash::create[$self.associations]]
	
	^associations.foreach[name;association]{
		^rem{ *** сбрасываем флаг загруженности всех ассоциаций *** }
		$association._is_loaded(false)
	}
#end @update_dependent_associations[]
