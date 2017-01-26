##############################################################################
@html[*args]
	$result[^args.foreach[k;v]{$v}[^;]]
#end @html[]



##############################################################################
@n2br[sText]
	$result[^sText.match[\n][gi]{<br/>^#0A}]
#end @n2br[]



##############################################################################
@n2li[sText]
	$result[<li>^sText.match[\n][gi]{</li>^#0A<li>}</li>]
#end @n2li[]



##############################################################################
@small_typograf[sText]
	$result[^sText.match[(?<![\wа-я\-])(\d+|ООО|ЗАО|это|в|и|под|или|для|на|как|с|к|их|по|от|ее|де)(?:\s)][gi]{${match.1}&nbsp^;}]
#end @small_typograf[]



##############################################################################
@markup[sText]
	$result[$sText]

	$result[^result.match[http://([\w_\-%\./]+)][gi]{^link_to[$match.1][http://${match.1}]}]
	$result[^result.match[~~(.+?)~~][gi]{<del>$match.1</del>}]
	$result[^result.match[\*(.+?)\*][gi]{<em>$match.1</em>}]
	$result[^result.match[\*\*(.+?)\*\*][gi]{<strong>$match.1</strong>}]
	$result[^result.match[```(.+?)```][gi]{<pre>$match.1</pre>}]
	
	$result[^result.match[^^([#]{1,6})(.*+)^$][mgi]{<h^match.1.length[]>${match.2}</h^match.1.length[]>}]
	$result[^result.match[^^([*-])(.*+)^$][mgi]{<li>${match.2}</li>}]
#end @markup[]



##############################################################################
#	Автообрамление url
##############################################################################
@matchHrefs[text;attr]
	$result[^if(def $text){^text.match[(?<![="])((?:https?://|ftp://|mailto:)(?:[:\w~%{}./?=&@,#-]+))(?<![.:,])(?!(?:"<|[^^<]*>))][gi]{<a href="$match.1"^if(def $attr){ $attr}>$match.1</a>}}]
#end @matchHrefs[]



##############################################################################
@console_text_line[text;length]
	$result[$text^for[i](0;^length.int($self.LINE_COLS) - ^text.length[]){ }]
#end @console_text_line[]



#############################################################################
@string_transform[sString;sType;sSplitter][result;sSplitter]
	^if(!def $sSplitter){
		$sSplitter[_]
	}

	^switch[$sType]{
		^case[path_to_string]{
			$sString[^sString.trim[both;/]]
			^sString.match[/][g]{$sSplitter}
		}
		^case[classname_to_filename;decode]{
#			$sString[^sString.match[^^([A-Z]+)][]{^match.1.lower[]}]
			$prev_length(0)
			^sString.match[([A-Z0-9])([a-z]*)][g]{^if($prev_length > 1){$sSplitter}^match.1.lower[]^match.2.lower[]$prev_length(^match.1.length[] + ^match.2.length[])}
		}
		^case[filename_to_classname;encode;DEFAULT]{
			^sString.match[(?:^^|$sSplitter)(\w)(.*?)][g]{^match.1.upper[]^match.2.lower[]}
		}
	}
#end @string_transform[]



##############################################################################
@split_string_to_params[sString;sColumnName]
	$result[^sString.match[\s][gi]{}]
	$result[^result.split[,;;$sColumnName]]
#end @split_string_to_params[]
