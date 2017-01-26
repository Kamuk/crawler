##############################################################################
#	
##############################################################################

@CLASS
Template

@OPTIONS
locals
partial



##############################################################################
#	.controller (only for controller)
#	.action (only for controller)
#	.status (only for controller)
#	.layout
#	.partial
#	.locals
#	.collection
#	.as
#	.object
#	.spacer_template
#	.template
#	.file
#	.use_full_path
#	.text
##############################################################################
@render[hParams;hLocals]
^oLogger.trace[render.template]{ }{
	^Rusage:compact[]

	^rem{ *** TODO: hParams - as string to template *** }
	^if(def $hParams && !($hParams is hash)){
		^throw[RenderError;RenderError;You called render with invalid options: ^inspect[$hParams]]
	}
	
	^if(!def $hParams.locals){
		$hParams.locals[^hash::create[$hParams]]
		^hParams.locals.sub[
			$.layout(true)
			$.partial(true)
			$.template(true)
			$.file(true)
			$.text(true)
			$.nothing(true)
			$.as(true)
			$.collection(true)
			$.spacer_template(true)
			$.object(true)
			$.cache(true)
			$.cache_key(true)
		]
	}
	
	^rem{ *** TODO: правильный url для кеширования *** }
	^if($hParams.cache && def $hParams.partial){
		$cache_key[$hParams.cache_key]
	
		^if(!def $cache_key){
			^if(def $hParams.object){
				$cache_key[$hParams.object.id]
				^if(def $hParams.locals){$cache_key[${cache_key}:^math:md5[^inspect[$hParams.locals]]]}
			}
		}
		$result[^self.oCacheStore.cache[/view/partial/${hParams.partial}^if(def $cache_key){-$cache_key}]($hParams.cache){^_render[^hash::create[$hParams]]}]
	}{
		$result[^_render[^hash::create[$hParams]]]
	}
}[
	$.Params[$hParams]
]
#end @render[]



##############################################################################
@expire_cache_partial[hParams]
	^if(def $hParams.partial){
		^if(def $hParams.object){
			$key[$hParams.object.id]
		}

		$path[$CONFIG:sCachePath/view/partial]
		$files[^file:list[$path;^^${hParams.partial}^if(def $key){-$key}]]

		^files.menu{
			^try{
				^file:delete[$path/$files.name]
			}{
				^if($exception.type eq "file.missing"){
					$exception.handled(true)
				}
			}
		}
	}
#end @expire_cache_partial[]



##############################################################################
@_render[hParams][context;layout_name;layout_template_path;layout_template_full_path;layout_template]
#	^if($oLogger){
#		^oLogger.info{	Call render with params: ^inspect[$hParams]}
#	}

	$context[$caller.caller.self]

	^if(def $hParams.layout){
		$layout_template[^self.view.pick_template[
			^if(def $hParams.partial){
				^if(^hParams.layout.pos[/] < 0){
					$.file[^file:dirname[$self.path]/_${hParams.layout}.$self.template_format]
				}{
					$.file[$view.path/^file:dirname[$hParams.layout]/_^file:basename[$hParams.layout].$self.template_format]
				}

			}{
				$.layout[$hParams.layout]
			}
		]]
		
		^if($oLogger){
			^oLogger.debug{	Rendering template within ^layout_template.path.match[^^$view.path/(.*?)\.$self.template_format^$][i]{$match.1}}
		}

		$layout_template.locals[$hParams.locals]
	}

	^switch(true){
		^case(def $hParams && ^hParams.contains[text]){
			$result[^render_for_text[$hParams.text]]
		}

		^case(def $hParams.file){
			$result[^render_for_file[
				$hParams
				$.use_full_path[^hParams.use_full_path.bool(false)]
			][$context]]
		}

		^case(def $hParams.template){
			$result[^render_for_file[$hParams;$context;$layout_template]]
		}

#		^case(def $hParams.action){
#			$result[^render_for_file[$hParams;$context;$layout_template]]
#		}

		^case(def $hParams.partial){
			^if(!($hParams.partial is string)){
				$hParams.object[$hParams.partial]
				$hParams.partial[^string_transform[$hParams.partial.CLASS_NAME;classname_to_filename]]
			}

			^if(^hParams.contains[collection]){
				$result[^render_partial_collection[$hParams;$context]]
			}{
				$result[^render_partial[$hParams;$context]]
			}
		}

		^case(def $hParams.nothing){
			$result[^render_for_text[]]
		}

		^case[DEFAULT]{
#			^throw[RenderError;RenderError;You called render with invalid options: ^inspect[$hParams]]
			$result[^self.render_template[$context]]
		}
	}

	^if($layout_template){
		$layout_template.content_for_layout[$result]
		$result[^layout_template.render_template[]]
	}
#end @_render[]



##############################################################################
@render_for_text[uText]
	$result[$uText]
#end @render_for_text[]



##############################################################################
@render_for_file[hParams;oContext;oLayoutTemplate][template;rusage]
^oLogger.trace[render.template.file]{Rendering for file}{
	$template[^self.view.pick_template[$hParams]]

	$template.locals[$hParams.locals]
	^if(^hParams.contains[object]){
		^template.assign_var[^if(def $hParams.as){$hParams.as}{^file:justname[$hParams.partial]};$hParams.object]
	}

	^if($oLayoutTemplate){
		$oLayoutTemplate.context[$template]
	}

	$result[^render_for_text{^template.render_template[$oContext]}]
}[
	$.Path[^self.path.match[^^$CONFIG.sRootPath][i]{}]
#	$.Params[$hParams]
]
#end @render_for_file[]



##############################################################################
#	patrional must be locate in folder with current template
@render_partial[hParams;oContext]
	^if(!def $self.PARTIAL_PATH.[$hParams.partial]){
		^if(^hParams.partial.pos[/] < 0){
			$path[^file:dirname[$self.path]/_${hParams.partial}]
		}{
			$path[$view.path/^file:dirname[$hParams.partial]/_^file:basename[$hParams.partial]]
		}
		
		$self.PARTIAL_PATH.[$hParams.partial][$path]
	}
	
	$hParams.file[${self.PARTIAL_PATH.[$hParams.partial]}.^if(def $hParams.format){p$hParams.format}{$self.template_format}]
	
	$result[^render_for_file[$hParams;$oContext]]
#end @render_partial[]



##############################################################################
@render_partial_collection[hParams;oContext][result;object]
^if($hParams.collection){
	$result[^render_for_text[^hParams.collection.foreach[key;object]{^render_partial[
		$.partial[$hParams.partial]
		$.object[$object]
		^if(def $hParams.as){
			$.as[$hParams.as]
		}
		$.locals[$hParams.locals]
		$.format[$hParams.format]
	][$oContext]}{
		^if(def $hParams.spacer){$hParams.spacer}
		^if(def $hParams.spacer_template){
			^render_partial[
				$.partial[$hParams.spacer_template]
				$.locals[$hParams.locals]
				$.format[$hParams.format]
			][$oContext]
		}
	}]]
}{
	$result[]
}
#end @render_partial_collection[]
