##############################################################################
#	
##############################################################################

@CLASS
Mailer

@OPTIONS
locals

@BASE
Environment



##############################################################################
@auto[]
	^rem{ *** перекрываем метод, чтобы не вызывался из Framework повторно *** }

	^if($self.CLASS_NAME eq "Mailer"){
		$self.oView[^View::create[$CONFIG.sViewPath/mailer/]]
	}{
		$self.default[^hash::create[]]
	}
#end @auto[]


##############################################################################
@GET_DEFAULT[sName][result]
	^if(^sName.pos[_]){
		^if(^self._vars.contains[$sName]){
			$self._vars.[$sName]
		}(^self._params.contains[$sName]){
			$self._params.[$sName]
		}{
			$self._context_mail.[$sName]
		}
	}
#end @GET_DEFAULT[]



##############################################################################
@GET_mailer_class_name[]
	$result[$self.CLASS_NAME]
#end @GET_mailer_class_name[]



##############################################################################
@GET_mailer_name[]
	$result[^_mailer_name[$self.mailer_class_name]]
#end @GET_mailer_name[]



##############################################################################
@GET_template[]
	$result[^if(!def $self.default._template){$self.mailer_name}{$self.default._template}]
#end @GET_template[]



##############################################################################
@SET_template[value]
	$self.default._template[$value]
#end @SET_template[]



##############################################################################
@_mailer_name[sMailerClassName]
	$result[^sMailerClassName.match[(Mail|Mailer)^$][i]{}]
	$result[^string_transform[$result;decode]]
#end @_mailer_name[]



##############################################################################
@send[hParams;hVariables]
	$self._context_mail[$caller.self]

	$self._params[^hash::create[$default]]
	^self._params.add[^hash::create[$hParams]]
	
	$self._vars[^hash::create[$hVariables]]

	^if(!def $self._params.text && $self.text_template.is_exist){
		$self._params.text[^render_text[]]
	}
	^if(!def $self._params.html && $self.html_template.is_exist){
		$self._params.html{^render_html[]}
	}
	
	^oLogger.debug{Send mail by $self.CLASS_NAME}
		
	$result[^mail:send[$self._params]]
#end @send[]



##############################################################################
@GET_text_template[]
	$result[^oView.pick_template[
		$.template[$self.template]
		$.format[text]
	]]
#end @GET_text_template[]



##############################################################################
@GET_html_template[]
	$result[^oView.pick_template[
		$.template[$self.template]
		$.format[html]
	]]
#end @GET_text_template[]



##############################################################################
@render_text[]
	$result[^self.text_template.render_template[]]
#end @render_text[]



##############################################################################
@render_html[]
	$result[^self.html_template.render_template[]]
#end @render_html[]