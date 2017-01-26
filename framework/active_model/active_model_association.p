##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
@GET_inherited_from[][result]
	$self.META.inherited_from
#end @GET_inherited_from[]



##############################################################################
@static:inherit_from[sName][class_name]
	^include_model[$sName]

	$class_name[^string_transform[$sName;filename_to_classname]]
	$self.META.inherited_from[$Framework:$class_name]
	
	$_primary_key[$inherited_from.primary_key]
#end @inherit_from[]



##############################################################################
#	Using caller.caller for get Class that call add_association firstly
##############################################################################
@static:_add_association[sType;sName;hParam][locals]
	$hParam[^hash::create[$hParam]]

	^if(!($self.ASSOCIATIONS.[$sName] is void)){
		^throw[parser.runtime;DublicateAssociation;Can't create two association with match name "$sName" for ${caller.caller.CLASS_NAME}.]
	}
	
	$hParam.name[$sName]
	$hParam.association_class_name[$self.CLASS_NAME]
	^if(!def $hParam.class_name){
		$hParam.class_name[^string_transform[$sName;filename_to_classname]]
	}
	
	^if(def $hParam.through){
		^switch[$sType]{
			^case[has_one]{
				$self.ASSOCIATIONS.[$sName][^HasOneThroughAssociationMeta::create[$hParam]]
			}
		
			^case[has_many]{
				$self.ASSOCIATIONS.[$sName][^HasManyThroughAssociationMeta::create[$hParam]]
			}
		
			^case[DEFAULT]{
				^throw[ErrorTypeAssociation;ErrorTypeAssociation;Uncknown type of through association '$sType']
			}
		}
	}{
		^switch[$sType]{
			^case[belongs_to]{
				$self.ASSOCIATIONS.[$sName][^BelongsToAssociationMeta::create[$hParam]]
			}

			^case[has_one]{
				$self.ASSOCIATIONS.[$sName][^HasOneAssociationMeta::create[$hParam]]
			}
		
			^case[has_many]{
				$self.ASSOCIATIONS.[$sName][^HasManyAssociationMeta::create[$hParam]]
			}
		
			^case[has_and_belongs_to_many]{
				$self.ASSOCIATIONS.[$sName][^HasAndBelongsToManyAssociationMeta::create[$hParam]]
			}
		
			^case[DEFAULT]{
				^throw[ErrorTypeAssociation;ErrorTypeAssociation;Uncknown type of association '$sType']
			}
		}
	}

	^rem{ *** compile getter for association in CLASS *** }
	$method_name[GET_${sName}]
	^if(!($self.$method_name is junction)){			
		^process[$self]{@main[][result]
			^$self.associations.[$sName]
		}[
			$.main[$method_name]
		]
	}
	
	^rem{ *** compile setter for association in CLASS *** }
	$method_name[SET_${sName}]
	^if(!($self.$method_name is junction)){
		^process[$self]{@main[value]
			^^self.associations.[$sName].update[^$value]
		}[
			$.main[$method_name]
		]
	}
#end @_add_association[]



##############################################################################
@static:belongs_to[sName;hParam][class_name]
	^_add_association[belongs_to;$sName;$hParam]
#end @belongs_to[]



##############################################################################
@static:has_one[sName;hParam]
	^_add_association[has_one;$sName;$hParam]
#end @has_one[]



##############################################################################
@static:has_many[sName;hParam]
	^_add_association[has_many;$sName;$hParam]
#end @has_many[]



##############################################################################
@static:has_and_belongs_to_many[sName;hParam]
	^_add_association[has_and_belongs_to_many;$sName;$hParam]
#end @has_and_belongs_to_many[]
