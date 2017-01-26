##############################################################################

@CLASS
Model

@OPTIONS
locals
partial


##############################################################################
@_inspect[]
	$result[$self.CLASS_NAME]
#end @_inspect[]



##############################################################################
@GET[type]
	^switch[$type]{
		^case[def]{
			$result(true)
		}

		^case[bool]{
			$result($self.attributes)
		}

		^case[DEFAULT;hash]{
			$result[$self.attributes]
		}
	}
#end @GET[]



##############################################################################
	^rem{ *** FIXME: maybe need add "&& def $self.attributes" *** }
##############################################################################
@GET_DEFAULT[sName][result]
	^if(^sName.pos[_] && $self.attributes){
		^if(^sName.match[_was^$][i]){
			$self.attributes_was.[^sName.left(^sName.length[] - 4)]
		}{
			$self.attributes.[$sName]
		}
	}
#end @GET_DEFAULT[]






##############################################################################
@GET_id[]
	$result[$self._id]
#end @GET_id[]



##############################################################################
@SET_id[iId]
	$self.attributes.[$primary_key][$iId]
	$self._id[$iId]
#end @SET_id[]



##############################################################################
@GET_attributes[]
	$result[$self._data]
#end @GET_attributes[]



##############################################################################
@SET_attributes[hAttr]
	$self._data[^hash::create[$hAttr]]
#end @SET_attributes[]



##############################################################################
@GET_attributes_was[]
	$result[$self._data_was.[$self._version]]
#end @GET_attributes_was[]



##############################################################################
@SET_attributes_was[hAttr]
	$self._data_was.[$self._version][^hash::create[$hAttr]]
#end @SET_attributes_was[]



##############################################################################
@GET_attributes_dirty[]
	$result[$self._data_dirty]
#end @GET_attributes_dirty[]






##############################################################################
@GET_errors[]
	$result[$self._errors]
#end @GET_errors[]



##############################################################################
@GET_is_new[]
	$result($self._created)
#end @GET_is_new[]



##############################################################################
@GET_is_changed[]
	$result($self._created || $self._changed || $self.attributes_dirty)
#end @GET_changed[]



##############################################################################
@SET_is_changed[value]
	$self._changed($self._changed || $value)
	$result[]
#end @SET_is_changed[]



##############################################################################
@GET_is_validated[]
	$result($self._validated)
#end @GET_is_validated[]



##############################################################################
@GET_is_marked_for_destruction[]
	$result($self._marked_for_destruction)
#end @GET_is_marked_for_destruction[]



##############################################################################
@GET_is_valid[]
	^if(!$self.is_validated){
		^validate[]
	}

	$result(!$self.errors)
#end @GET_is_valid[]



##############################################################################
@GET_is_valid_native[]
	$result[$self.is_valid]
#end @GET_is_valid_native[]



##############################################################################
@GET_errors_native[]
	$result[$self.errors]
#end @GET_errors_native[]
