##############################################################################
# :anchor — specifies the anchor name to be appended to the path. For example, url_for :controller => ‘posts’, :action => ‘show’, :id => 10, :anchor => ‘comments’ will produce "/posts/show/10#comments".
# :only_path — if true, returns the relative URL (omitting the protocol, host name, and port) (false by default)
# :trailing_slash — if true, adds a trailing slash, as in "/archive/2005/". Note that this is currently not recommended since it breaks caching.
# :host — overrides the default (current) host if provided.
# :protocol — overrides the default (current) protocol if provided.
# :port — optionally specify the port to connect to.
# :user — Inline HTTP authentication (only plucked out if :password is also present).
# :password — Inline HTTP authentication (only plucked out if :user is also present).
# :skip_relative_url_root — if true, the url is not constructed using the relative_url_root of the request so the path will include the web server relative installation directory.
##############################################################################
@url_for[uParams]
	^switch[$uParams.CLASS_NAME]{
		^case[string]{
			^if($uParams eq ":back"){
				^rem{ *** TODO: if $env:HTTP_REFERER eq $sRequest or if $env:HTTP_REFERER from other site *** }
				$result[^taint[as-is][$env:HTTP_REFERER]]
			}{
				$result[^uParams.trim[]]
			}
		}
		^case[hash]{
			$result[^oMap.path_for[$uParams;$self.params]]
		}
		^case[DEFAULT]{
			^throw[ParamError;ParamError;Unknown param #1 for method url_for, must be string or hash]
		}
	}
#end @url_for[]



##############################################################################
@named_url_for[sName;hParams]
	$result[^oMap.named_path_for[$sName;$hParams;$self.params]]
#end @named_url_for[]



##############################################################################
@is_current_page[uOptions;hOptions][locals]
	$result(false)
	
	^if($uOptions is string){
		$hOptions[^hash::create[$hOptions]]

		^if($uOptions eq "/"){
			$result(!def $sRequest)
		}{
			^hOptions.add[^oMap.named_route[$uOptions;$self.params]]
			$result[^is_current_page[$hOptions]]
		}
	}{
		$hOptions[^hash::create[$uOptions]]
		$result(^compare_value_include[$hOptions;$self.params])
	}
#end @is_current_page[]



##############################################################################
#	Сравнивает 2 переменных на включение значений u1 в u2 для хешей или равенства для строк
#	возвращает: true - если равны и false если отличаются
##############################################################################
@compare_value_include[u1;u2][locals]
	$result(true)

	^if($u1.CLASS_NAME ne $u2.CLASS_NAME){
		$result(false)
	}{
		^switch[$u1.CLASS_NAME]{
			^case[hash;array]{
				$result($u1 <= $u2)	^rem{ *** проверяем на количество значений *** }
				
				^if($result){
					^u1.foreach[k;v]{
						^if(!^compare_value_include[$v;$u2.$k]){
							$result(false)
							^break[]
						}
					}
				}
			}
			^case[string][DEFAULT]{
				$result($u1 eq $u2)
			}
		}
	}
#end @compare_values[]



##############################################################################
#	TODO: throw if named_link not found
@named_link_to[sName;sAncor;hParams;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.href[^named_url_for[$sName;$hParams]]
	]]
	^if(def $hOptions.confirm){
		$hOptions.onclick[if (confirm ('$hOptions.confirm')) { ^if(def $hOptions.onclick){$hOptions.onclick}{return true^;} } else { return false^; }]
		^hOptions.delete[confirm]
	}

	$result[^content_tag[a;$sAncor;$hOptions]]
#end @named_link_to[]



##############################################################################
@link_to[sAncor;hParams;hOptions]
	$hOptions[^hash::create[$hOptions]]
	^if(!def $hOptions.href){
		$hOptions.href[^url_for[$hParams]]
	}
	^if(def $hOptions.confirm){
		$hOptions.onclick[if (confirm ('$hOptions.confirm')) { ^if(def $hOptions.onclick){$hOptions.onclick}{return true^;} } else { return false^; }]
		^hOptions.delete[confirm]
	}

	$result[^content_tag[a;$sAncor;$hOptions]]
#end @link_to[]



##############################################################################
@link_to_if[bCondition;sAncor;hParams;hOptions]
	^if(^bCondition.bool(true)){
		$result[^link_to[$sAncor;$hParams;$hOptions]]
	}{
		$result[$sAncor]
	}
#end @link_to_if[]



##############################################################################
@link_to_unless_current[sAncor;hParams;hOptions]
	$result[^link_to_if(!^is_current_page[$hParams])[$sAncor;$hParams;$hOptions]]
#end @link_to_unless_current[]



##############################################################################
@mail_to[sEmail;sAncor;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.href[mailto:$sEmail]
	]]

	$result[^content_tag[a;$sAncor;$hOptions]]
#end @mail_to[]



##############################################################################
@button_to[sText;hParams;hOptions]
	$hOptions[^hash::create[$hOptions]]
	$hOptions[^hOptions.union[
		$.onclick[window.location = '^url_for[$hParams]']
	]]
	^if(def $hOptions.confirm){
		$hOptions.onclick[if (confirm ('$hOptions.confirm')) { $hOptions.onclick return true^; } else { return false^; }]
		^hOptions.delete[confirm]
	}
	
	$result[^content_tag[button;^content_tag[span;$sText];$hOptions]]
#end @button_to[]
