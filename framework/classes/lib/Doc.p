###########################################################################
# $Id: Doc.p,v 1.3 2007/11/26 09:14:22 misha Exp $
###########################################################################


@CLASS
Doc



###########################################################################
# print $xDoc as string without DOCTYPE and XML declaration
@toString[xDoc]
$result[^xDoc.string[
	$.omit-xml-declaration[yes]
	$.indent[no]
]]
$result[^result.trim[]]
$result[^result.match[<!DOCTYPE[^^>]+>\s*][i]{}]
#end @toString[]



###########################################################################
@create[sXML;hParam]
$result[^xdoc::create{<?xml version="1.0" encoding="^if(def $hParam && def $hParam.sCharset){$hParam.sCharset}{$request:charset}"?>
$sXML}]
#end @create[]
