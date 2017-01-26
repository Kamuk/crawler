##############################################################################
#	Перекрываем dispatche для Framework, который будем использовать для работы с миграцией
#	Разбирает параметры коммендной строки, содержит главные методы миграции
##############################################################################

@CLASS
Framework

@OPTIONS
locals
partial



##############################################################################
@console_text_line[text;length]
	$result[$text^for[i](0;^length.int($self.LINE_COLS) - ^text.length[]){ }]
#end @console_text_line[]



##############################################################################
@init_versions[]	
	$migrations[^oSql.table{
		SELECT
			`migration_id`,
			`version`,
			`up`,
			`migrate`
		FROM
			`db_version`
	}]

	$self._versions[^migrations.hash{$migrations.version}]
#end @init_versions[]



##############################################################################
@init_files[]
	$self._files[^hash::create[]]

	$files[^file:list[$CONFIG:sMigrationPath;\.p^$]]
	^if(!$files){
		$CONFIG:sMigrationPath[$CONFIG:sRootPath/script/migration]
		$files[^file:list[$CONFIG:sRootPath/script/migration;\.p^$]]
	}
	^files.sort{$files.name}[asc]
	
	^MAIN:CLASS_PATH.append{$CONFIG:sMigrationPath}
	
	^files.menu{
		$class_name[^files.name.left(^files.name.length[] - 2)]
		
		$self._files.[$class_name][
			$.class_name[$class_name]
			$.name[$files.name]
			$.src[$CONFIG:sMigrationPath/$files.name]
		]
	}
#end @init_files[]



##############################################################################
@dispatche[sRequest]
	$self.LINE_COLS(92)

	^use_application[]
	^Controller:include_helpers[*]

	^use[$CONFIG:sFrameworkPath/migration/migration.p]

	^self.init_files[]

	^try{
		^self.init_versions[]
	}{
		^try{
		^if($exception.type eq "sql.execute"){
			$exception.handled(true)

			^self.oSql.void{
					CREATE TABLE `db_version` (
						`migration_id` int(10) NOT NULL AUTO_INCREMENT,
						`version` varchar(250) NOT NULL,
						`up` tinyint(1) UNSIGNED NOT NULL DEFAULT "0",
						`migrate` tinyint(1) UNSIGNED NOT NULL DEFAULT "0",
						PRIMARY KEY (`migration_id`),
						UNIQUE `version` (`version`)
					) ENGINE=InnoDB DEFAULT CHARSET=utf8
			}

				^self.init_versions[]
		}
		}{
			^if($exception.type eq "sql.execute"){
				$exception.handled(true)
				
				^self.oSql.void{
					ALTER TABLE
						`db_version`
					ADD COLUMN
						`up` tinyint(1) UNSIGNED NOT NULL DEFAULT "0",
					ADD COLUMN
						`migrate` tinyint(1) UNSIGNED NOT NULL DEFAULT "0"
	}

				^self.oSql.void{
					UPDATE
						`db_version`
					SET
						`up` = 1,
						`migrate` = 1
				}

				^self.init_versions[]
			}
		}
	}

	^oSql.void{SET AUTOCOMMIT = 0}

	^switch[^request:argv.1.lower[]]{
		^case[up]{
        	^self.oSql.transaction_start[]
			^migrate_up[$request:argv.2]
        	^self.oSql.transaction_commit[]
		}
		^case[down]{
        	^self.oSql.transaction_start[]
			^migrate_down[$request:argv.2]
        	^self.oSql.transaction_commit[]
		}
		^case[redo]{
			^self.oSql.transaction_start[]
			^migrate_redo[$request:argv.2]
			^self.oSql.transaction_commit[]
		}
		^case[migrate]{
        	^self.oSql.transaction_start[]
        	^migrate_up[$request:argv.2](true)
        	^self.oSql.transaction_commit[]
		}
		^case[DEFAULT]{
			^throw[direction.null;Migration;No direction for migration specified]
		}
	}
	
	$result[]
#end @dispatche[]



##############################################################################
@migrate_up[version;bMigreate]
	^rem{ *** Если есть версия, но её нет среди файлов - отмена *** }
	^if(def $version && !$self._files.[$version]){
		^throw[version.not_found;Migration;Specified version not found ($version)]
	}

	^rem{ *** собираем файлы миграций *** }
	$instances[^array::create[]]
	^foreach[$self._files;file]{
		$class_name[$file.class_name]
		$v[$self._versions.[$class_name]]

		^rem{ *** создаем запись о миграции *** }
		^if(!$v){
			^self.oSql.void{
				INSERT INTO
					`db_version` (`version`)
				VALUES
					('$class_name')
			}
			^self.oSql.transaction_commit[]
			^self.oSql.transaction_start[]
		}

		^rem{ *** если миграция еще не применялась никогда *** }
		^if(!$v || !$v.up || !$v.migrate || ($bMigreate && $v.version eq $version)){
			^use[$file.src]
			$migration[^reflection:create[$class_name;create]]

			^rem{ *** сохраняем все проделанные миграции, что бы потом вызывать migrate методы у них в точно таком же порядке *** }
			^instances.add[$migration]
		}
	}
			
	^rem{ *** вызываем методы up для выбранных миграций *** }
	^foreach[$instances;instance]{
		$v[$self._versions.[$instance.CLASS_NAME]]

		^if($v.up){^continue[]}													^rem{ *** если обновление данных для этой версии уже применялась *** }

		$console:line[^console_text_line[$instance.CLASS_NAME]($self.LINE_COLS - 4)^[UP^]]
		^instance.up[]
		^self.oSql.void{UPDATE `db_version` SET `up` = 1 WHERE `version` = "$instance.CLASS_NAME"}	^rem{ *** обновляем информацию о миграции данных *** }
		
		^self.oSql.transaction_commit[]
		^self.oSql.transaction_start[]

		^if($instance.CLASS_NAME eq $version){ ^break[] }						^rem{ *** если поднимаем до этой версии - остановиться *** }
	}{
		^Rusage:compact[]
	}

	^rem{ *** вызываем методы migrate от проделанных миграций *** }
	^foreach[$instances;instance]{
		$v[$self._versions.[$instance.CLASS_NAME]]
		
		^if($v.migrate && !($bMigreate && $v.version eq $version)){^continue[]}											^rem{ *** если миграция для этой версии уже применялась *** }

		$console:line[^console_text_line[$instance.CLASS_NAME]($self.LINE_COLS - 9)^[MIGRATE^]]
		^instance.migrate[]
		^self.oSql.void{UPDATE `db_version` SET `migrate` = 1 WHERE `version` = "$instance.CLASS_NAME"}	^rem{ *** обновляем информацию о миграции данных *** }
		
		^self.oSql.transaction_commit[]
		^self.oSql.transaction_start[]

		^if($instance.CLASS_NAME eq $version){ ^break[] }						^rem{ *** если поднимаем до этой версии - остановиться *** }
	}{
		^Rusage:compact[]
	}
#end @migrate_up[]



##############################################################################
@migrate_down[version]
	^if(!def $version){
		^throw[version.not_found;Migration;Specified version not found]
	}

	$file[$self._files.[$version]]

	^if(def $file && $self._versions.[$version] && $self._versions.[$version].up){
		$class_name[$file.class_name]
		$console:line[^console_text_line[$class_name]($self.LINE_COLS - 6)^[DOWN^]]

		^use[$file.src]
		$migration[^reflection:create[$class_name;create]]

		^migration.down[]

		^rem{ *** удалить инфу об этой миграции из базы и из хэша (тк это может быть часть redo) *** }
		^self.oSql.void{
			DELETE
			FROM
				`db_version`
			WHERE
				`version` = "$class_name"
		}

		^self._versions.delete[$class_name]
	}
#end @migrate_down[]



##############################################################################
@migrate_redo[version]
	^if(!def $version){
		$console:line[Error: Migration version not specified]
	}

	^rem{ *** оставить только 1 файл с миграцией в списке файлов и подсунуть на migrate_down, migrate_up *** }
	$self._files[^self._files.intersection[
		$.[$version](true)
	]]

	^if(def $self._files){
		^migrate_down[$version]
		^migrate_up[$version]
	}
#end @migrate_redo[]
