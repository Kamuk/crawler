##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
partial



##############################################################################
@GET_performed[]
  $result($self.performed_render || $self.performed_redirect)
#end @GET_performed[]



##############################################################################
@GET_controller_class_name[]
	$result[$self.CLASS_NAME]
#end @GET_controller_class_name[]



##############################################################################
@GET_controller_name[]
	$result[^_controller_name[$controller_class_name]]
#end @GET_controller_name[]



##############################################################################
@GET_action_name[]
	$result[$self._action]
#end @GET_action_name[]



##############################################################################
@SET_action_name[sAction]
	$self._action[$sAction]
#end @SET_action_name[]



##############################################################################
@GET_action_method_name[]
	$result[^_action_method_name[$action_name]]
#end @GET_action_method_name[]



##############################################################################
@GET_params[]
	$result[$self._params]
#end @GET_params[]



##############################################################################
@SET_params[hParams]
	^self._params.add[$hParams]
#end @SET_params[]



##############################################################################
@GET_forms[]
	$result[$self._forms]
#end @GET_forms[]



##############################################################################
@SET_forms[hForm]
	$self._forms[$hForm]
#end @SET_forms[]



##############################################################################
@GET_filtred_params[]
	$result[^_filter_parameters[$params]]
#end @GET_filtred_params[]



##############################################################################
@GET_parameter_filter[]
	$result[$self._params_filter]
#end @GET_parameter_filter[]



##############################################################################
@SET_parameter_filter[sFilter]
	$self._params_filter[$sFilter]
#end @SET_parameter_filter[]



##############################################################################
@GET_template_format[]
	^if(^params.contains[format]){
		$result[$params.format]
	}{
		$result[$DEFAULT_RENDER_FORMAT]
	}
#end @GET_template_format[]



##############################################################################
@SET_template_format[sFormat]
	$params.format[$sFormat]
#end @SET_template_format[]



##############################################################################
@GET_template[]
	$result[^oView.pick_template[
		$.template[$template_name]
	]]
#end @GET_template[]



##############################################################################
@GET_is_layout_set[]
	$result[$self._layout_set]
#end @GET_is_layout_set[]



##############################################################################
@GET_layout[]
	$result[$self._layout]
#end @GET_layout[]



##############################################################################
@SET_layout[uLayout]
	^switch[$uLayout.CLASS_NAME]{
		^case[string]{
			$self._layout[$uLayout]
			$self._layout_set(true)
		}

		^case[bool;DEFAULT]{
			^if(^uLayout.bool(true)){
				$self._layout[$self.controller_name]
			}{
				$self._layout[]
			}
			$self._layout_set(false)
		}
	}
#end @SET_layout[]



##############################################################################
@GET_template_name[]
	$result[^_template_name[]]
#end @GET_template_name[]



##############################################################################
@GET_is_not_found_availible[][_action]
	$_action[$self.action_name]

	$self.action_name[not_found]
	$result($self.aNotFound is junction || $self.template.is_exist)
	
	$self.action_name[$_action]
#end @GET_is_not_found_availible[]