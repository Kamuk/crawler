##############################################################################
#
##############################################################################

@CLASS
Controller

@OPTIONS
partial



##############################################################################
#	.controller
#	.action
#	.layout
#	.status
#	.template
#	.file
#	.use_full_path
#	.text
##############################################################################
@render[hParams;hLocals][rusage]
^oLogger.info[render][Call render]{
	$self._cur_phase(2)														^rem{ *** set phase as "render" = 2 *** }

	^Rusage:measure[rusage]{
		$caller.result[^_render[^hash::create[$hParams]]]
	}

	$self._stat.render[$rusage]
}[
	$.Params[$hParams]
]

#	^throw[fw.interupt.render;Render]											^rem{ *** выкидываем exception для остановки обработки, в последствии обрабатывается framework *** }
#end @render[]



##############################################################################
@_render[hParams][layout_template;template]
	^if($self.performed){
		^throw[DoubleRenderError;DoubleRenderError;Can only render or redirect once per action]
	}
	^if(def $hParams && !($hParams is hash)){
		^throw[RenderError;RenderError;You called render with invalid options: ^inspect[$hParams]]
	}

	^if(def $hParams.location){
		^Lib:location[^url_for[$hParams.location]]
	}

	^rem{ *** determine current layout *** }
	^if(def $hParams.layout){
		^if($hParams.layout is bool){
			^if($hParams.layout){
				^rem{ *** default layout *** }
				$layout_template[^oView.pick_template[
					$.layout[$controller_name]
				]]

#				^if(!$layout_template.is_exist){
#					$layout_template[]
#				}
			}{
				^rem{ *** no layout *** }
#				$hParams.layout[]
			}
		}{
#			$hParams.layout[$hParams.layout]
			$layout_template[^oView.pick_template[
				$.layout[$hParams.layout]
			]]
		}
	}{
		^rem{ *** use layout that set in controller on .template or .action present *** }
		^if((!def $hParams || def $hParams.template || def $hParams.action) && def $self.layout){
			$layout_template[^oView.pick_template[
				$.layout[$self.layout]
			]]

			^if(!$self.is_layout_set && !$layout_template.is_exist){
				$layout_template[]
			}
		}
	}

	^switch(true){
		^case(def $hParams && ^hParams.contains[text]){
			$result[^render_for_text[$hParams.text;$hParams.status]]
		}

		^case(def $hParams.file){
			$template[^oView.pick_template[
				$.file[$hParams.file]
			]]
			^log_render_template[$template;$hParams]{
				$result[^render_for_text[^template.render_template[];$hParams.status]]
			}
		}

		^case(def $hParams.template){
			$template[^oView.pick_template[
				$.template[$hParams.template]
			]]
			^log_render_template[$template;$hParams]{
				$result[^render_for_text[^template.render_template[];$hParams.status]]
			}
		}

		^case(def $hParams.action){
			$template[^oView.pick_template[
				$.template[^_template_name[$hParams.action;$hParams.controller]]
			]]
			^log_render_template[$template;$hParams]{
				$result[^render_for_text[^template.render_template[];$hParams.status]]
			}
		}

		^rem{ *** TODO: необходима ли возможность вызова partial из контроллера? *** }
		^rem{ *** Т.к. возможна передача параметров вида object, as, collection и т.п.,
		          что не логично в данном случае. *** }
		^rem{ *** И создание шаблона для вызова шаблонного render не правильно *** }
#		^case(def $hParams.partial){
#			^rem{ *** TODO: partial with spec name *** }
#			$template[^oView.pick_template[
#				$.template[^_template_name[$hParams.partial;$hParams.controller]]
#			]]
#			$result[^render_for_text[^template.render[$hParams];$hParams.status]]
#		}

		^case(def $hParams.nothing){
			$result[^render_for_text[;$hParams.status]]
		}

		^case[DEFAULT]{
#			$template[^oView.pick_template[
#				$.template[$template_name]
#			]]
			$template[$self.template]
			^log_render_template[$template;$hParams]{
				$result[^render_for_text[^template.render_template[];$hParams.status]]
			}
		}
	}

	^if($layout_template){
		^oLogger.info[render]{Rendering within ^layout_template.path.match[^^$oView.path/(.*?)\.p$oView.format^$][i]{$match.1}}{
			$layout_template.content_for_layout[$result]
			$result[^layout_template.render_template[$template]]
		}
	}

	^if(^MAIN:MIME-TYPES.locate[ext;$template_format]){
		$response:content-type.value[$MAIN:MIME-TYPES.mime-type]
	}
#end @_render[]



##############################################################################
@log_render_template[oTemplate;hParams;jCode]
	^oLogger.info[render]{Rendering ^oTemplate.path.match[^^$oView.path/(.*?)\.p$oView.format^$][i]{$match.1}^if($hParams.status){ ($hParams.status)}}{		
		$result[$jCode]
	}{
		$.Params[$hParams]
		$.File[^oTemplate.path.match[^^$CONFIG:sRootPath][i]{}]
	}
#end @log_render_template[]



##############################################################################
@render_for_text[uText;iStatus]
	$self.performed_render(true)

	^if(^iStatus.int(0) || !def $response:status){
		$response:status[^interpret_status(^iStatus.int($DEFAULT_RENDER_STATUS_CODE))]
	}
#	^Lib:status(^iStatus.int($DEFAULT_RENDER_STATUS_CODE))

  $result[$uText]
#end @render_for_text[]



##############################################################################
@interpret_status[iStatus]
	^if(^STATUS_CODES.contains[$iStatus]){
		$result[$iStatus $STATUS_CODES.[$iStatus]]
	}{
		^throw[parser.runtime;$iStatus;uncknown response status]
	}
#end @interpret_status[]
