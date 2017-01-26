##############################################################################
#	Перекрываем dispatche для Framework, который будем использовать для работы с БД
#	- backup {ENV}
#	- restore {ENV} {filename}
#	- clone	{ENV} {ENV}
##############################################################################

@CLASS
Framework

@OPTIONS
locals
partial



##############################################################################
@dispatche[sCommand]
	$self.sDumpPath[../dumps]
	$self.DB[^_parseYML[${CONFIG:sConfigPath}/database.yml]]

	^switch[$sCommand]{
		^case[backup]{
			$r[^backup[$request:argv.2]]
			$result[Database backup to $r]
		}
		
		^case[restore]{
			$r[^restore[$request:argv.2;$request:argv.3]]
			$result[Database was restored]
		}
		
		^case[clone]{
			$r[^clone[$request:argv.2;$request:argv.3]]
			$result[Database was clone]
		}
		
		^case[DEFAULT]{
			^throw_inspect[Uncknown command]
		}
	}
	
	$console:line[$result]
	
	$result[]
#end @dispatche[]



##############################################################################
@backup[sEnv]
	^if(!def $sEnv){
		$sEnv[$self.ENV]
	}
	$db[$self.DB.[$sEnv]]

	$now[^date::now[]]
	
	$result[${sEnv}-^now.sql-string[date]-^now.hour.format[%02d]^now.minute.format[%02d].sql]

	^if(!(-d ${self.sDumpPath})){
		$keepfile[^file::create[text;.gitkeep][]]
		^keepfile.save[text;${self.sDumpPath}/.gitkeep]
	}

	$f[^file::exec[binary;${CONFIG:sScriptPath}/mysqldump][
		$.CGI_FILENAME[${self.sDumpPath}/$result]
	][-u${db.username};-p${db.password};^if(def $db.host){-h${db.host}};--no-autocommit;--single-transaction;$db.database]]

	^if($f.status){
		^throw_inspect[$f.status;$f.stderr]
	}
#end @backup[]



##############################################################################
@restore[sEnv;sFile]
	^if(!def $sFile){
		$sFile[$sEnv]
		$sEnv[]
	}
	^if(!def $sEnv){
		$sEnv[$self.ENV]
	}
	$db[$self.DB.[$sEnv]]
	
	^if(!def $sFile){
		^throw[parser.runtime;restore;No souch file for restore]
	}
	
	$result[]

	$f[^file::exec[binary;${CONFIG:sScriptPath}/mysql][
		$.CGI_FILENAME[${self.sDumpPath}/${sFile}]
	][-u${db.username};-p${db.password};^if(def $db.host){-h${db.host}};$db.database]]

	^if($f.status){
		^throw_inspect[$f.status;$f.stderr]
	}
#end @restore[]



##############################################################################
@clone[sEnvSrc;sEnvDst]
	^if(!def $sEnvSrc || !def $self.DB.[$sEnvSrc]){
		^throw[parser.runtime;clone;No source env "$sEnvSrc"]
	}
	^if(!def $sEnvDst || !def $self.DB.[$sEnvDst]){
		^throw[parser.runtime;clone;No destination env "$sEnvDst"]
	}
	^if($sEnvSrc eq $sEnvDst){
		^throw[parser.runtime;clone;Source and Destination equal "$sEnvSrc"]
	}
	
	$filename[^backup[$sEnvSrc]]
	^restore[$sEnvDst;$filename]
#end @clone[]
