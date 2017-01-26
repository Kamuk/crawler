##############################################################################
#	TODO: proxy all methods to CRITERIA after clone
##############################################################################

@CLASS
ActiveRelation

@OPTIONS
locals
partial



##############################################################################
@distinct[uValue]
	$result[^self.clone[]]
	^result.CRITERIA.distinct[$uValue]
#end @distinct[]



##############################################################################
@select[uAlias;sTable;sName]
	$result[^self.clone[]]
	^result.CRITERIA.column[$uAlias;$sTable;$sName]
#end @select[]



##############################################################################
@join_table[uName;uParam]
	$result[^self.clone[]]
	^result.CRITERIA.join_table[$uName;$uParam]
#end @join_table[]



##############################################################################
@join[uName;uParam]
	$result[^self.clone[]]
	^result.CRITERIA.join[$uName;$uParam]
#end @join[]



##############################################################################
@where[uCondition]
	$result[^self.clone[]]
	^result.CRITERIA.condition[$uCondition]
#end @method_where[]



##############################################################################
@grouping[sColumn;sType]
	$result[^self.clone[]]
	^result.CRITERIA.group[$sColumn;$sType]
#end @grouping[]



##############################################################################
@having[uCondition]
	$result[^self.clone[]]
	^result.CRITERIA.having[$uCondition]	
#end @having[]



##############################################################################
@sort[sColumn;sType]
	$result[^self.clone[]]
	^result.CRITERIA.order[$sColumn;$sType]
#end @sort[]



##############################################################################
@resort[sColumn;sType]
	$result[^self.clone[]]
	^result.CRITERIA.reorder[$sColumn;$sType]
#end @resort[]



##############################################################################
@include[uName;hParam]
	$result[^self.clone[]]
	^result.CRITERIA.include[$uName;$hParam]
#end @include[]



##############################################################################
@limit[iLimit]
	$result[^self.clone[]]
	^result.CRITERIA.limit($iLimit)
#end @limit[]



##############################################################################
@offset[iOffset]
	$result[^self.clone[]]
	^result.CRITERIA.offset($iOffset)
#end @offset[]



##############################################################################
@none[]
	$result[^self.clone[]]
	$result._none(true)
#end @none[]



##############################################################################
@find_each[sName;jCode;jSplitter][_var;start;resource;batch;key;val]
	$_var[$caller.[$sName]]
	
	$start(0)
	
	$resource[^self.all[
		$.order[$self.MAPPER.primary_key]
		$.limit(100)
	]]
	
	$batch[^resource.find[]]
	
	^while($batch){
		^batch.foreach[key;val]{$caller.[$sName][$val]${jCode}$start[$val.id]}{${jSplitter}}
		$batch[^resource.find[
			$.condition[$self.MAPPER.primary_key > $start]
		]]
	}

	$caller.[$sName][$_var]
#end @find_each[]
