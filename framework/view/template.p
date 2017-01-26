##############################################################################
#	
##############################################################################

@CLASS
Template

@OPTIONS
locals
partial

#@BASE
#Environment



##############################################################################
#@auto[]
#	$self.PARTIAL_PATH[^hash::create[]]
#end @auto[]



##############################################################################
@create[sPath;oView]
	^if(!def $sPath){
		^throw[TemplateError;TemplateCreateError;You try to create Template with invalid options: ^inspect[$sPath]]
	}
	
	$self.PARTIAL_PATH[^hash::create[]]
	
	$self._path[$sPath]
	$self._view[$oView]
	$self._format[^file:justext[$sPath]]

#	$self._method_name[^math:md5[$_path]]
#	$self.s_method_name[^string_transform[$_path;path_to_string]]
	$self._method_name[$_path]
	
	$self._inherit_template[]
		
	$self._context_is_set(false)
	$self._context[$self]
#	$_source[]
#	$_locals[^hash::create[$hLocals]]
	$self._locals[^hash::create[]]
#end @create[]



##############################################################################
@render_template[oContext]
^Environment:oLogger.trace[render.template]{$self._method_name}{
	^if(!$self._context_is_set){
		$self.context[^if(def $oContext){$oContext}{$caller.self}]
	}

	^compile[]

	$result[^self.$_method_name[]]
	
	^if(def $self._inherit_template){
		$self._inherit_template.content_for_layout[$result]
		$result[^self._inherit_template.render_template[$self]]
	}
}[
	$.File[$self._path]
]
#end @render_template[]



##############################################################################
@compile[][_file;_source]
	^if(!($CLASS.$_method_name is junction)){
		^Environment:oLogger.trace[render.template.compile]{$self._method_name}{
			$_file[^file::load[text;$self._path]]
			$_source[$_file.text]

			^process[$CLASS]{^untaint[as-is]{$_source}}[
				$.main[$_method_name]
				$.file[$_path]
			]
		}[
			$.File[$self._path]
		]
	}
#end @compile[]
