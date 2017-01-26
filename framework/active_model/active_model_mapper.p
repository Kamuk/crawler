##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
#	Loading tAssociations objects and include to each object from aObject array
#	метод вызывается статически
##############################################################################
@static:_load_association[aObjects;hIncludes][locals]
^self.oLogger.trace[am._load_association]{$self.CLASS_NAME}{
	^if($aObjects && $hIncludes){
		^hIncludes.foreach[name;params]{
			$association[$self.ASSOCIATIONS.[$name]]				^rem{ *** FIX: throw exception if association not found *** }
			^if(!def $association){
				^throw[parser.runtime;$name;no assosiation]
			}
			^association.find_by_association[$aObjects;$params]
			
			^Rusage:compact[]
		}
	}
}
#end @_load_association[]



##############################################################################
@_create[]
	^oSql.void{
		INSERT
		INTO
			`$self.table_name` ($self.primary_key^self.FIELDS.foreach[alias;field]{, `$field.name`})
		VALUES
			(^if(def $self.id){$self.id}{DEFAULT}^self.FIELDS.foreach[alias;field]{, ^field.value[$self.attributes.[$alias]]})
	}
	
	^if(!$self.id){
		$self.id(^oSql.lastInsertId[$table_name])
	}
	
	^rem{ *** add to cache *** }
	^self.CLASS.set_model_to_cache[$self.id;$self]
#end @_create[]



##############################################################################
#	TODO: доделать метод!!!
#	Передача необходимых аттрибутов
#	Передача значений
#	Проверка значений ?
#	Автоматические поля с сохранением в БД?
##############################################################################
@static:_insert_all[aModels;hDataDuplicate]
	^rem{ *** TODO: получить id моделей *** }
	^oSql.void{
		INSERT
		INTO
			`$self.table_name` ($self.primary_key^self.FIELDS.foreach[alias;field]{, `$field.name`})
		VALUES
			^foreach[$aModels;model]{(^if(def $model.id){$model.id}{DEFAULT}^self.FIELDS.foreach[alias;field]{, ^field.value[$model.attributes.[$alias]]})}[, ]
		^if($hDataDuplicate){
			ON DUPLICATE KEY UPDATE
			^self.FIELDS.foreach[alias;field]{^if(^hDataDuplicate.contains[$alias] || ^hDataDuplicate.contains[_$alias]){
				`$field.name` = ^if(^hDataDuplicate.contains[_$alias]){$hDataDuplicate.[_$alias]}{VALUES(`$field.name`)}
			}}[, ]
		}
	}
#end @_insert_all[]



##############################################################################
@static:_update_all[hData;hParam;oModel][locals]
	$_condition[^SqlCondition::create[]]
	^_condition.add[$hParam.condition]
	
	^if(def $oModel){
		^rem{ *** если сохранение модели *** }
		$data[^hash::create[]]
		
		^rem{ *** формируем массив с обновляемыми данными *** }
		^oModel.FIELDS.foreach[alias;field]{
			^if((^hData.contains[$alias] && $oModel.attributes_dirty.[$alias]) || ^hData.contains[_$alias]){
				$data.[$field.name][^if(^hData.contains[_$alias]){$hData.[_$alias]}{^field.value[$hData.[$alias]]}]
			}
		}
		
		^if($data){
			^rem{ *** обновляем модель *** }
			^oSql.void{
				UPDATE $hParam.query_modifier
					`$self.table_name` ^if(def $hParam.alias){AS `$hParam.alias`}
				SET
					^data.foreach[attr;value]{`$attr` = $value}[, ]

				^if($_condition){
					WHERE $_condition.to_string
				}
			}
		}
	}{
		^rem{ *** если метод обновления всех *** }
		^oSql.void{
			UPDATE $hParam.query_modifier
				`$self.table_name` ^if(def $hParam.alias){AS `$hParam.alias`}
			SET
				^self.FIELDS.foreach[alias;field]{^if(^hData.contains[$alias] || ^hData.contains[_$alias]){
					`$field.name` = ^if(^hData.contains[_$alias]){$hData.[_$alias]}{^field.value[$hData.[$alias]]}
				}}[, ]

			^if($_condition){
				WHERE $_condition.to_string
			}
		}
	}
#end @_update_all[]



##############################################################################
@static:_delete_all[hParam;bModelUpdate][locals]
	$_condition[^SqlCondition::create[]]
	^_condition.add[$hParam.condition]

	^oSql.void{
		DELETE
		FROM
			`$self.table_name`

		^if($_condition){
			WHERE $_condition.to_string
		}
		^if(def $hParam.order){
			ORDER BY $hParam.order
		}
		^if(def $hParam.limit){
			LIMIT $hParam.limit	
		}
	}
#end @delete_all[]



##############################################################################
@_destroy[]

#end @_destroy[]
