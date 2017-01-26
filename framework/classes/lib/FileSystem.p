###########################################################################
# $Id: FileSystem.p,v 1.6 2007/08/15 12:34:57 misha Exp $
###########################################################################


@CLASS
FileSystem



###########################################################################
@auto[]
$hNameDefault[
	$.b[bytes]
	$.kb[KB]
	$.mb[MB]
]
$sSpaceDefault[&nbsp^;]
$sFormatDefault[%.1f]
#end @auto[]



###########################################################################
# return size for specified file or file with specified filename
@getFileSize[uFile][result;fFile]
$result[]
^if(def $uFile){
	^if($uFile is "file"){
		$result($uFile.size)
	}{
		^if($uFile is "string" && -f $uFile){
			$fFile[^file::stat[$uFile]]
			$result($fFile.size)
		}
	}
}
#end @getFileSize[]



###########################################################################
# print string with file size. $.hName with bytes/KB/MB texts $.sDecimalDivider and $.sFormat can be specified
@printFileSize[iSize;hParam][result;hName;sSpace;sFormat]
^if(def $iSize){
	$hName[^if(def $hParam && def $hParam.hName){$hParam.hName}{$hNameDefault}]
	$sSpace[^if(def $hParam && def $hParam.sSpace){$hParam.sSpace}{$sSpaceDefault}]
	$sFormat[^if(def $hParam && def $hParam.sFormat){$hParam.sFormat}{$sFormatDefault}]
	^if($iSize < 1024){
		$result[${iSize}${sSpace}$hName.b]
	}{
		^if($iSize < 1048576){
			$result[^eval($iSize/1024)[$sFormat]${sSpace}$hName.kb]
		}{
			$result[^eval($iSize/1048576)[$sFormat]${sSpace}$hName.mb]
		}
	}
	$result[^result.match[\.0+(?=\s)][]{}]
	^if(def $hParam && def $hParam.sDecimalDivider){
		$result[^result.match[\.][]{$hParam.sDecimalDivider}]
	}
}{
	$result[]
}
#end @printFileSize[]



###########################################################################
# copy file
@fileCopy[sFileFrom;sFileTo][fFile]
^if(def $sFileFrom && def $sFileTo && $sFileFrom ne $sFileTo && -f $sFileFrom){
	^try{
		^file:copy[$sFileFrom;$sFileTo]
	}{
		^rem{ *** for parser without ^file:copy[] *** }
		$exception.handled(1)
		$fFile[^file::load[binary;$sFileFrom]]
		^fFile.save[binary;$sFileTo]
	}
}
$result[]
#end @fileCopy[]



###########################################################################
# with $.bRecursive(true) all subdirs will be copyed
@dirCopy[sDirFrom;sDirTo;hParam][tFile;sSourceName]
^if(def $sDirFrom && def $sDirTo && $sDirFrom ne $sDirTo && -d $sDirFrom){
	$tFile[^file:list[$sDirFrom]]
	^tFile.menu{
		$sSourceName[$sDirFrom/$tFile.name]
		^if(def $hParam && ($hParam.bRecursive || $hParam.is_recursive) && -d $sSourceName){
			^self.dirCopy[$sSourceName;$sDirTo/$tFile.name;$hParam]
		}{
			^if(-f $sSourceName){
				^self.fileCopy[$sSourceName;$sDirTo/$tFile.name]
			}
		}
	}
}
$result[]
#end @dirCopy[]



###########################################################################
# with $.bRecursive(true) all subdirs will be deleted
@dirDelete[sDir;hParam][tFile;sSourceName]
^if(def $sDir && -d $sDir){
	$tFile[^file:list[$sDir]]
	^tFile.menu{
		$sSourceName[$sDir/$tFile.name]
		^if(def $hParam && ($hParam.bRecursive || $hParam.is_recursive) && -d $sSourceName){
			^self.dirDelete[$sSourceName;$hParam]
		}{
			^if(-f $sSourceName){
				^try{
					^file:delete[$sSourceName]
				}{
					$exception.handled(1)
				}
			}
		}
	}
}
$result[]
#end @dirDelete[]
