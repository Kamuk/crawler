###########################################################################
# $Id: LibCompFull.p,v 1.1 2007/01/15 15:31:32 misha Exp $
# very old stuff for backward compatibility
# the best way switch from those methods asap and don't @USE this file anymore
###########################################################################


@USE
LibComp.p



@default[var;dflt][v]
# works like ^default[] from parser2
# don't forget to use correct brakets: ^default{$val;$dflt}
$v[$var]
$result[^if(def $v){$v}{$dflt}]



@ifdef[var;def;undef][v]
# works like ^ifdef[] from parser2
# don't forget to use correct brakets: ^ifdef{$var;$def;$undef}
$v[$var]
$result[^if(def $v){$def}{$undef}]



@is_flag[data]
$result(^if(^data.int(0)){1}{0})



@max[inhash][tmp;max;key;value]
# return maximum hash value
$tmp[^inhash._keys[]]
$max[$tmp.key]
^inhash.foreach[key;value]{^if($value > $max){$max[$value]}}
$result[$max]



@trim_old[sText;sChar][tbl]
# cut trailing and leading chars $sChar (whitespaces by default) for string $sText
# old version for parser 3.1.1 and below
^if(def $sText){
	^if(!def $sChar){$sChar[\s]}
	$sText[^sText.match[^^$sChar*][]{}]
	$tbl[^sText.match[^^(.*[^^$sChar])$sChar*^$]]
	$result[$tbl.1]
}{
	$result[]
}



@load[param1;param2][named;file;f]
# works like ^load[] from parser2
# much better just use ^table::load[filename] 
^if(def $param2){
	$file[$param2]
	$named[$param1]
}{
	$file[$param1]
	$named[]
}
$f[^file:find[$file]]
^if(def $f){
	^if(def $named){
		$result[^table::load[$f]]
	}{
		$result[^table::load[nameless;$f]]
	}
}{
	$result[^table::create[nameless]{}]
}



@remove[in;pos;cnt;where][first;last]
# remove $cnt lines from table $in starting from line $pos
# in $where you can specify your own conditions (ex: ^remove[$tbl;2;1]{^if($tbl.a eq a4){1}{0}} )
# much better just use ^table.select(conditions)
^if(def $in){
	$first(^pos.int(0))
	$last($first+^cnt.int(1))
	$result[^in.select(((^in.line[]<$first) || (^in.line[]>=$last+$count)) && !$where)]
}{
	$result[$in]
}



@getFileExt[sFileName]
# return extention for specified file
# was usable long time ago because of absent of ^file:justext[] 
$result[^file:justext[$sFileName]]



@macro_use[sFileName]
# works like ^macro_use[] from parser2
# can be usable only if $CLASS_PATH declared as string but not as table
^if($MAIN:CLASS_PATH is "string" && def $sFileName){
	$result[^include[$MAIN:CLASS_PATH/$sFileName]]
}{
	$result[]
}
