##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
@static:validate_with[sMethodName;hParam]
	^if(!($self.$sMethodName is junction)){
		^throw[parser.runtime;$sMethodName;Validator method not found]
	}
	
	^rem{ *** формируем параметры для валидатора *** }
	$param[^hash::create[$hParam]]
	$param.method[$sMethodName]
	
	^rem{ *** добавляем в массив валидаторов *** }
	^self.VALIDATORS.add[$param]
	
	$result[]
#end @validate_with[]



##############################################################################
@static:validate_on_create[sMethodName;hParam]
	$param[^hash::create[$hParam]]

	^self.validate_with[$sMethdoName][
		$param
		$.on[create]
	]
	
	$result[]
#end @validate_on_create[]



##############################################################################
@static:validate_on_update[sMethodName;hParam]
	$param[^hash::create[$hParam]]

	^self.validate_with[$sMethodName][
		$param
		$.on[update]
	]
	
	$result[]
#end @validate_on_update[]



##############################################################################
@static:validate_of[sMethodName;sAttribute;hParam]
	^rem{ *** формируем параметры для валидатора *** }
	$param[^hash::create[$hParam]]
	$param.attribute[$sAttribute]
	$param.method[$sMethodName]

	^rem{ *** добавляем в массив валидаторов *** }
	^self.VALIDATORS.add[$param]
	
	$result[]
#end @validate_of[]



##############################################################################
@static:validates_acceptance_of[sAttribute;hParam]
	^self.validate_of[_validates_acceptance_of;$sAttribute;$hParam]
#end @validates_acceptance_of[]



##############################################################################
@static:validates_associated[sAttribute;hParam]
	^self.validate_of[_validates_associated;$sAttribute;$hParam]
#end @validates_associated[]



##############################################################################
@static:validates_confirmation_of[sAttribute;hParam]
	^self.validate_of[_validates_confirmation_of;$sAttribute;$hParam]
#end @validates_confirmation_of[]



##############################################################################
@static:validates_exclusion_of[sAttribute;hParam]
	^self.validate_of[_validates_exclusion_of;$sAttribute;$hParam]
#end @validates_exclusion_of[]



##############################################################################
@static:validates_format_of[sAttribute;hParam]
	^self.validate_of[_validates_format_of;$sAttribute;$hParam]
#end @validates_format_of[]



##############################################################################
@static:validates_inclusion_of[sAttribute;hParam]
	^self.validate_of[_validates_inclusion_of;$sAttribute;$hParam]
#end @validates_inclusion_of[]



##############################################################################
@static:validates_length_of[sAttribute;hParam]
	^self.validate_of[_validates_length_of;$sAttribute;$hParam]
#end @validates_length_of[]



##############################################################################
@static:validates_numericality_of[sAttribute;hParam]
	^self.validate_of[_validates_numericality_of;$sAttribute;$hParam]
#end @validates_numericality_of[]



##############################################################################
@static:validates_presence_of[sAttribute;hParam]
	^self.validate_of[_validates_presence_of;$sAttribute;$hParam]
#end @validates_presence_of[]



##############################################################################
@static:validates_uniqueness_of[sAttribute;hParam]
	^self.validate_of[_validates_uniqueness_of;$sAttribute;$hParam]
#end @validates_uniqueness_of[]



##############################################################################
@static:validates_date_of[sAttribute;hParam]
	^self.validate_of[_validates_date_of;$sAttribute;$hParam]
#end @validates_date_of[]



##############################################################################
@static:validates_file_of[sAttribute;hParam]
	^self.validate_of[_validates_file_of;$sAttribute;$hParam]
#end @validates_file_of[]



##############################################################################
@static:validates_image_of[sAttribute;hParam]
	^self.validate_of[_validates_image_of;$sAttribute;$hParam]
#end @validates_image_of[]




##############################################################################
@_validates_numericality_of[hParam]
	$value[$self.attributes.[$hParam.attribute]]
	
	^rem{ *** TODO: integer only *** }
	
	^if(def $value && !^value.match[\A[+-]?\d+([.,]\d+)?\Z][i]){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute is not numericaly]
		}
		^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg]
	}
#end @_validates_numericality_of[]



##############################################################################
@_validates_presence_of[hParam]
	^if(def $self.FIELDS.[$hParam.attribute] || def $self.ACCESSORS.[$hParam.attribute]){
		$value[$self.attributes.[$hParam.attribute]]
		
		^if(!def $value){
			^if(!def $hParam.msg){
				$hParam.msg[$hParam.attribute empty]
			}
			^self.errors.append[${hParam.attribute}_empty;$hParam.attribute;$hParam.msg]
		}
	}(def $self.ASSOCIATIONS.[$hParam.attribute]){
		$value[$self.associations.[$hParam.attribute]]
		
		^if(!$value){
			^if(!def $hParam.msg){
				$hParam.msg[$hParam.attribute empty]
			}
			^self.errors.append[${hParam.attribute}_empty;$hParam.attribute;$hParam.msg]
		}
	}{
		^throw_inspect[Invalid argument ^inspect[$hParam]]
	}
#end @_validates_presence_of[]



##############################################################################
@_validates_uniqueness_of[hParam][scopes]
	$value[$self.attributes.[$hParam.attribute]]
	$value_was[$self.attributes_was.[$hParam.attribute]]
	
	$scopes[^table::create{alias	name}]

	^if(^hParam.contains[scope]){
		$scope_parts[^hParam.scope.split[,][lv][alias]]

		^scope_parts.menu{
			^scopes.append{^scope_parts.alias.trim[]	$self.FIELDS.[^scope_parts.alias.trim[]].name}
		}
	}
	
	^rem{ *** если изменилось значение уникального аттрибута или области его уникальности (scope) *** }
	$scopes_changed(false)
	^scopes.menu{
		$scopes_changed(!^self.FIELDS.[$scopes.alias].compare_value[$self.attributes.[$scopes.alias];$self.attributes_was.[$scopes.alias]])
		^if($scopes_changed){^break[]}
	}

	^if(def $value && (!^self.FIELDS.[$hParam.attribute].compare_value[$value;$value_was] || $scopes_changed) && ^self.CLASS.count[
		$.condition[^scopes.menu{`$self.table_name`.`$scopes.name` = ^DBField:sql-string[$self.attributes.[$scopes.alias]] AND} `$self.table_name`.`$self.FIELDS.[$hParam.attribute].name` = ^DBField:sql-string[$value] AND `$self.table_name`.`$primary_key` != "$self.id"]
	]){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute not unique]
		}
		^self.errors.append[${hParam.attribute}_exist;$hParam.attribute;$hParam.msg]
	}
#end @_validates_uniqueness_of[]



##############################################################################
@_validates_format_of[hParam]
	$value[$self.attributes.[$hParam.attribute]]

	$regexp[$hParam.with]
	^if(def $hParam.width){
		$regexp[$hParam.width]
	}
	
	^if(def $value && (!^value.match[$regexp][$hParam.modificator])){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute wrong format]
		}
		^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg;$value]
	}
#end @_validates_format_of[]



##############################################################################
@_validates_length_of[hParam]
	$value[$self.attributes.[$hParam.attribute]]
	$length[^value.length[]]
	
	^rem{ *** TODO: minimum, maximum & etc. *** }
	
	^if(def $value){
		^if(^hParam.contains[minimum] && $length < $hParam.minimum){
			^if(!def $hParam.msg){
				$hParam.msg[$hParam.attribute too small]
			}
			^self.errors.append[${hParam.attribute}_too_small;$hParam.attribute;$hParam.msg]
		}
		
		^if(^hParam.contains[maximum] && $length > $hParam.maximum){
			^if(!def $hParam.msg){
				$hParam.msg[$hParam.attribute too long]
			}
			^self.errors.append[${hParam.attribute}_too_long;$hParam.attribute;$hParam.msg]
		}
	}
#end @_validates_length_of[]



##############################################################################
@_validates_confirmation_of[hParam]
	$value[$self.attributes.[$hParam.attribute]]
	$value_was[$self.attributes_was.[$hParam.attribute]]
	$value_confirmation[$self.attributes.[${hParam.attribute}_confirmation]]
	
	^if(def $value && $value ne $value_was && $value ne $value_confirmation){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute not confirm]
		}
		^self.errors.append[${hParam.attribute}_confirmation_error;$hParam.attribute, ${hParam.attribute}_confirmation;$hParam.msg]
	}
#end @_validates_confirmation_of[]



##############################################################################
@_validates_date_of[hParam][value;image]
	$value[$self.attributes.[$hParam.attribute]]
	
	^if(def $value && !(^self.FIELDS.[$hParam.attribute].init[$value] is "date")){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute must be date]
		}
		^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg]
	}
#end @_validates_date_of[]



##############################################################################
@_validates_file_of[hParam][value;image]
	$value[$self.attributes.[$hParam.attribute]]
	
	^if(def $value && !($value is "file")){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute must be file]
		}
		^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg]
	}
#end @_validates_file_of[]



##############################################################################
@_validates_image_of[hParam][value;image]
	$value[$self.attributes.[$hParam.attribute]]
	
	^if(def $value){
		^if(!def $hParam.msg){
			$hParam.msg[$hParam.attribute must be jpg, gif or png]
		}

		^if($value is file){
			^try{
				$image[^image::measure[$value]]
			}{
				$exception.handled(true)
				^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg]

				^rem{ *** удаляем значение *** }
#				$self.attributes.[$hParam.attribute][]
			}
		}{
			^self.errors.append[${hParam.attribute}_wrong;$hParam.attribute;$hParam.msg]	
		}
	}
#end @_validates_image_of[]
