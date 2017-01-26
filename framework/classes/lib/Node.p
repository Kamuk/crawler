###########################################################################
# $Id: Node.p,v 1.12 2008-05-19 14:43:39 misha Exp $
###########################################################################


@CLASS
Node


@USE
Doc.p



###########################################################################
@auto[]
$sDummyRoot[dummy-root-tag]
#end @auto[]



###########################################################################
# print $xNode value as string (like ^xdoc.string[])
@toString[xNode;sRootTag][result;xDoc;_tmp]
^if($xNode){
	$xDoc[^xdoc::create[$sDummyRoot]]
	$_tmp[^xDoc.documentElement.appendChild[^xDoc.importNode[$xNode](1)]]

	$result[^Doc:toString[$xDoc]]
	$result[^result.match[^^<(^taint[regex][$sDummyRoot])><(^taint[regex][$xNode.nodeName])[^^>]*>(.*)</\2></\1>^$][]{$match.3}]
}
^if(def $sRootTag){
	$result[<$sRootTag>$result</$sRootTag>]
}
#end @toString[]



###########################################################################
# go through all nodes in $hNodeList and execute $jCode
@foreach[hNodeList;hNodeName;sNode;sAttr;jCode;sSeparator][result;i;xNode]
$result[^for[i](0;$hNodeList-1){$xNode[$hNodeList.$i]^if(^self._isRequestedNode[$xNode;$hNodeName]){$caller.$sNode[$xNode]^if(def $sAttr){$caller.$sAttr[^self.getAttributes[$xNode]]}$jCode}}[$sSeparator]]
#end @foreach[]



###########################################################################
# go through all children for $xParent and execute $jCode
@foreachChild[xParent;hNodeName;sNode;sAttr;jCode;sSeparator][result;xNode]
$xNode[$xParent.firstChild]
$result[^while($xNode){^if(^self._isRequestedNode[$xNode;$hNodeName]){$caller.$sNode[$xNode]^if(def $sAttr){$caller.$sAttr[^self.getAttributes[$xNode]]}$jCode}$xNode[$xNode.nextSibling]}[$sSeparator]]
#end @foreachChild[]



###########################################################################
# get children of $xParent as hash
@getChildren[xParent;hNodeName][result;xNode]
$result[^hash::create[]]
$xNode[$xParent.firstChild]
^while($xNode){^if(^self._isRequestedNode[$xNode;$hNodeName]){$result.[$xNode.nodeName][^self.toString[$xNode]]}$xNode[$xNode.nextSibling]}
#end @getChildren[]



###########################################################################
# return node attrubutes (or string with attributes) as hash
@getAttributes[uData][result;xAttr;hNodeAttr]
$result[^hash::create[]]
^if(def $uData){
	^if($uData is "xnode"){
		$hNodeAttr[$uData.attributes]
		^if($hNodeAttr){
			^hNodeAttr.foreach[;xAttr]{$result.[$xAttr.nodeName][^taint[$xAttr.nodeValue]]}
		}
	}{
		^if($uData is "string"){
			^if(^uData.pos[<] >= 0){
				^uData.match[<[-\w]+\s([^^>]+)/?>][]{$result[^self.getAttributes[$match.1]]}
			}{
				^uData.match[(\S+)\s*=\s*(["'])(.*?)\2][g]{$result.[$match.1][^taint[$match.3]]}
			}
		}
	}
}
#end @getAttributes[]



###########################################################################
# print hash with attributes as attr's string
@printAttributes[uData;hExclude][sName;sValue;result]
^if(def $uData){
	^if($uData is "hash"){
		^if($hExclude){
			$uData[^hash::create[$uData]]
			^uData.sub[$hExclude]
		}
		$result[^uData.foreach[sName;sValue]{ $sName="$sValue"}]
	}{
		^if($uData is "string" || $uData is "xnode"){
			$result[^self.printAttributes[^self.getAttributes[$uData];$hExclude]]
		}{
			$result[]
		}
	}
}{
	$result[]
}
#end @printAttributes[]



###########################################################################

@_isRequestedNode[xNode;hNodeName][result]
$result($xNode.nodeType == $xdoc:ELEMENT_NODE && (!def $hNodeName || def $hNodeName.[$xNode.nodeName]))
