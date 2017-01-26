##############################################################################
#
##############################################################################

@CLASS
HasManyThroughAssociation

@OPTIONS
partial

@BASE
ManyAssociation



##############################################################################
@GET_through[]
	$result[$self.meta.through]
#end @GET_through[]



##############################################################################
@GET_primary_key[]
	$result[$self.meta.primary_key]
#end @GET_primary_key[]



##############################################################################
@GET_foreign_key[]
	$result[$self.meta.foreign_key]
#end @GET_foreign_key[]



##############################################################################
@create[oAssociationMeta]
	^BASE:create[$oAssociationMeta]
#end @create[]






##############################################################################
@GET_is_loaded[]
	$result($self._is_loaded)
#end @GET_is_loaded[]



##############################################################################
@GET_foreign_key_present[]
	^rem{ *** !$self.foreign_instance.is_new или $self.foreign_instance.[$self.primary_key] ??? *** }
	$result(def $self.foreign_instance.[$self.primary_key])
#end @GET_foreign_key_present[]



##############################################################################
@load[]
^Framework:oLogger.trace[am.as]{^inspect[$self]: load}{
	^if($self.foreign_instance && $self.foreign_key_present){
		^self._load[]
	}{
		^self.init[^array::create[]]
	}
}
#end @load[]



##############################################################################
@__relation[]
	$result[$self.meta.mapper_relation]
	^result.merge[
		$.condition[`^if(def $self.meta.proxy_association.through){$self.meta.proxy_association.through}{$self.through}`.`$self.foreign_key` = "$self.foreign_instance.[$self.primary_key]"]
	]
#end @__relation[]



##############################################################################
@_load[][condition]
	^self.init[$self.RELATION]
#end @_load[]



##############################################################################
@update_dependent_associations[]
	^rem{ *** не трубет обновления, т.к. связь у той модели *** }
#end @update_dependent_associations[]
