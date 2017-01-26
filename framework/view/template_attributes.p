##############################################################################
#	
##############################################################################

@CLASS
Template

@OPTIONS
locals
partial



##############################################################################
@GET[]
	$result(def $self.path)
#end @GET[]



##############################################################################
@GET_DEFAULT[sName][result]
	^if(^sName.pos[_] && $self._context_is_set){
		$self._context.[$sName]
	}
#end @GET_DEFAULT[]



##############################################################################
@GET_path[]
	$result[$self._path]
#end @GET_path[]



##############################################################################
@GET_is_exist[]
	$result(-f $self._path)
#end @GET_is_exist[]



##############################################################################
@GET_view[]
	$result[$self._view]
#end @GET_view[]



##############################################################################
@GET_template_format[]
	$result[$self._format]
#end @GET_template_format[]



##############################################################################
@SET_context[oContext]
	$self._context_is_set(true)
	$self._context[$oContext]
#end @SET_context[]



##############################################################################
@GET_context[][result]
	$self._context
#end @GET_context[]



##############################################################################
@SET_locals[hLocals]
	^assign_vars[$hLocals]
#end @SET_locals[]



##############################################################################
@GET_content_for_layout[][result]
	$self._content_for_layout
#end @GET_content_for_layout[]



##############################################################################
@SET_content_for_layout[uContent]
	$self._content_for_layout[$uContent]
#end @SET_content_for_layout[]



##############################################################################
@content[*args]
	$result[^args.foreach[k;v]{$v}[^;]]
#end @content[]



##############################################################################
@content_for[sName;*args]
	$result[]
	^if(!^is_set_content_for[$sName]){
		$self.content_for_$sName[^args.foreach[k;v]{$v}[^;]]
	}
#end @content_for[]



##############################################################################
@is_set_content_for[sName]
	$result(def $self.content_for_$sName)
#end @is_set_content_for[]



##############################################################################
@yield[sName][result]
	^if(def $sName){
		^self.content_for_$sName.trim[]
	}{
		^self.content_for_layout.trim[]
	}
#end @yield[]



##############################################################################
@assign_var[sName;uValue][result]
	$self.[^sName.trim[left;_]][$uValue]
#end @assign_var[]



##############################################################################
@assign_vars[hVars][result;varname;value]
	^if($hVars){
		$self._locals[$hVars]
		^hVars.foreach[varname;value]{^assign_var[$varname;$value]}
	}
#end @assign_vars[]



##############################################################################
@inherit_from[sPath]
	$self._inherit_template[^self._view.pick_template[
		$.layout[$sPath]
	]]
#end @inherit_from[]
