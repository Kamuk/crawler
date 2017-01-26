##############################################################################
#	
##############################################################################

@CLASS
View

@OPTIONS
locals
partial

@USE
template.p
template_attributes.p
template_render.p



##############################################################################
@auto[]
	$self.DEFAULT_RENDER_FORMAT[html]
#end @auto[]



##############################################################################
@GET_path[]
	$result[$self._path]
#end @GET_path[]



##############################################################################
@GET_format[]
	$result[$self._format]
#end @GET_format[]



##############################################################################
@SET_format[sFormat]
	^if(def $sFormat){
		$self._format[$sFormat]
	}
#end @SET_format[]



##############################################################################
@create[sPath;sFormat]
	^if(!def $sPath){
		^throw[ViewError;ViewCreateError;You try to create View with invalid options: ^inspect[$sPath]]
	}
	
	$self._path[^sPath.trim[end;/]]
	
	^if(def $sFormat){
		$self._format[$sFormat]
	}{
		$self._format[$DEFAULT_RENDER_FORMAT]
	}
#end @create[]



##############################################################################
#	.file
#	.template
#	.layout
#	.partial (.controller)
#	.action (.controller)
#	.use_full_path = true || false
@find_base_path_for[hParams][use_full_path;file_name]
	$use_full_path(^hParams.use_full_path.bool(!def $hParams.file))

	^switch(true){
		^case(def $hParams.file){
			$result[$hParams.file]
		}

		^case(def $hParams.template){
			$result[$hParams.template]
			$result[^result.trim[left;/]]
		}

		^case(def $hParams.layout){
			$result[$hParams.layout]
			^if(^result.pos[/] < 0){
				$result[layouts/$result]
			}
			$result[^result.trim[left;/]]
		}

#		^case(def $hParams.partial){
#			$result[$hParams.partial]
#			^if(^result.pos[/] < 0){
#				$result[^if(def $hParams.controller){$hParams.controller}{$controller_name}/$result]
#			}
#			$result[^result.trim[left;/]]
#			^if(^file:dirname[$result] eq "."){
#				$result[_$result]
#			}{
#				$result[^file:dirname[$result]/_^file:basename[$result]]
#			}
#		}

#		^case(def $hParams.action){
#			$result[$hParams.action]
#			$result[^if(def $hParams.controller){$hParams.controller}{$controller_name}/^result.trim[left;/]]
#		}
		
		^case[DEFAULT]{
			^throw[ViewError;ViewTemplatePathError;You try to find Template with invalid options: ^inspect[$hParams]]
		}
	}

	^if($use_full_path){
		$result[$self._path/$result]

#		^if(!def ^file:justext[$result]){
		^if(!^result.match[/?\w+\.\w+^$][i]){
			$result[${result}.p^if(def $hParams.format){$hParams.format}{$self.format}]
		}
	}
#end @find_base_path_for[]



##############################################################################
@pick_template[hParams][file_path]
	$file_path[^find_base_path_for[$hParams]]
	$result[^Template::create[$file_path;$self]]
#end @pick_template[]
