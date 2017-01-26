##############################################################################
#
##############################################################################

@CLASS
Migration

@OPTIONS
locals

@USE
environment.p
config.p

@BASE
Environment



##############################################################################
#:constructor
@create[]

#end of @create



##############################################################################
#	Заглушка для метода up
##############################################################################
@up[]
	
#end @up[]



##############################################################################
#	Заглушка для метода down
##############################################################################
@down[]
	
#end @down[]



##############################################################################
#	Заглушка для метода migrate
##############################################################################
@migrate[]
	
#end @migrate[]




##############################################################################
#:param type type string
#:param hOptions type hash
#:result string
@_type[type;hOptions][result]
^switch[^type.upper[]]{
	^case[TINYINT]{
		$result[TINYINT ^if(def	$hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[SMALLINT]{
		$result[SMALLINT ^if(def $hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[MEDIUMINT]{
		$result[MEDIUMINT ^if(def $hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[INT]{
		$result[INT ^if(def $hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[INTEGER]{
		$result[INTEGER ^if(def $hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[BIGINT]{
		$result[BIGINT ^if(def $hOptions.length){($hOptions.length)}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[REAL]{
		$result[REAL ^if(def $hOptions.length){($hOptions.length ^if(def $hOptions.decimals){,$hOptions.decimals})}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[DOUBLE]{
		$result[DOUBLE ^if(def $hOptions.length){($hOptions.length ^if(def $hOptions.decimals){,$hOptions.decimals})}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[FLOAT]{
		$result[FLOAT ^if(def $hOptions.length){($hOptions.length ^if(def $hOptions.decimals){,$hOptions.decimals})}
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[DECIMAL]{
		$result[DECIMAL ($hOptions.length,$hOptions.decimals)
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[NUMERIC]{
		$result[NUMERIC ($hOptions.length,$hOptions.decimals)
						^if(def $hOptions.unsigned){UNSIGNED}
						^if(def $hOptions.zerofill){ZEROFILL}
		]
	}
	^case[CHAR]{
		$result[CHAR ($hOptions.length)
						^if(def $hOptions.binary){BINARY}
		]
	}
	^case[VARCHAR;STRING]{
		$result[VARCHAR (^if(def $hOptions.length){$hOptions.length}{255})
						^if(def $hOptions.binary){BINARY}
		]
	}

	^case[DATE]{ $result[DATE] }
	^case[TIME]{ $result[TIME] }
	^case[TIMESTAMP]{ $result[TIMESTAMP] }
	^case[DATETIME]{ $result[DATETIME] }
	^case[TINYBLOB]{ $result[TINYBLOB] }
	^case[BLOB]{ $result[BLOB] }
	^case[MEDIUMBLOB]{ $result[MEDIUMBLOB] }
	^case[LONGBLOB]{ $result[LONGBLOB] }
	^case[TINYTEXT]{ $result[TINYTEXT] }
	^case[TEXT]{ $result[TEXT] }
	^case[MEDIUMTEXT]{ $result[MEDIUMTEXT] }
	^case[LONGTEXT]{ $result[LONGTEXT] }

	^case[ENUM]{ $result[ENUM ($hOptions.enum)] }
	^case[SET]{ $result[SET ($hOptions.enum)] }

#	Framework types
	^case[BOOL]{ $result[TINYINT(1) UNSIGNED] }


	^case[DEFAULT]{ ^throw[type.wrong;Migration;Bad type decaration] }
}
##end of @_type



##############################################################################
#:param options type hash
#:result string
@_table_options[options][result]
$result[
	^if(def $options.engine){ ENGINE = $options.engine }{ ENGINE = InnoDB }
	^if(def $options.auto_increment ){ AUTO_INCREMENT  = $options.auto_increment }
	^if(def $options.avg_row_length){ AVG_ROW_LENGTH = $options.avg_row_length }
	^if(def $options.checkshum){ CHECKSUM = $options.checksum }
	^if(def $options.comment){ COMMENT = "$options.comment" }
	^if(def $options.max_rows){ MAX_ROWS = $options.max_rows }
	^if(def $options.min_rows){ MIN_ROWS = $options.min_rows }
	^if(def $options.pack_keys){ PACK_KEYS = $options.pack_keys }
	^if(def $options.password){ PASSWORD = "$options.password" }
	^if(def $options.delay_key_write){ DELAY_KEY_WRITE = $options.delay_key_write }
	^if(def $options.row_format){ ROW_FORMAT = $options.row_format }
	^if(def $options.raid_type && def $options.raid_chunks && def $options.raid_chunksize){
		RAID_TYPE = $options.raid_type RAID_CHUNKS = $options.raid_chunks RAID_CHUNKSIZE = $options.raid_chunksize
	}
	^if(def $options.union){ UNION = ($options.union) }
	^if(def $options.insert_method){ INSERT_METHOD = $options.insert_method }
	^if(def $options.data_directoy){ DATA DIRECTORY = "$options.data_directoy" }
	^if(def $options.index_directory){ INDEX DIRECTORY = "$options.index_directory" }
]
##end of @_table_options



##############################################################################
#:param select type hash
#:result string
@_select_statement[select][result]
$result[
	^if(def $select.ignore){
		IGNORE
	}(def $select.replace){
		REPLASE
	}
#TODO: do we need SELECT here?
	$select.query
]
##end of @_select_statement



##############################################################################
#:param name type string
#:param DBType type string
#:param hOptions type hash
#:result string
@add_column[name;DBType;hOptions][result]
$result[
	^if($self.not_first_element){,}{$self.not_first_element(true)}
	^if($self.is_alter_table){ ADD }
	`$name` ^_type[$DBType;$hOptions]
	^if(def $hOptions.null){
		^if($hOptions.null){
			NULL
		}{
			NOT NULL
		}
	}
	^if(def $hOptions.default){ DEFAULT $hOptions.default }
	^if(def $hOptions.auto_increment){ AUTO_INCREMENT }
#	TODO: Reference definition

	^if($self.is_alter_table){
		^if(def $hOptions.first){
			FIRST
		}(def $hOptions.after){
			AFTER `$hOptions.after`
		}
	}

	^if(def $hOptions.primary_key){ PRIMARY KEY }
	^if(def $hOptions.index){ ^add_index[$name] }
	^if(def $hOptions.unique){ ^add_unique[$name] }
	^if(def $hOptions.key){ ^add_key[$name] }
	^if(def $hOptions.fulltext){ ^add_fulltext[$name] }
]
##end of @column


##############################################################################
# @primary_key, @key, @index, @unique, @fulltext
##############################################################################
#:param index_name type string
#:param index_col_name type string
#:result string
@add_index[index_col_name;index_name][result]
	$result[
	^if($self.not_first_element){,}{$self.not_first_element(true)}
	^if($self.is_alter_table){ ADD }
		INDEX
		^if(def $index_name){$index_name}
		($index_col_name)
	]
##end of @index



##############################################################################
#:param index_name type string
#:param index_col_name type string
#:result string
@primary_key[index_col_name;index_name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		^if($self.is_alter_table){ ADD }
		PRIMARY KEY ($index_col_name)
	]
##end of @primary_key



##############################################################################
#:param index_name type string
#:param index_col_name type string
#:result string
@add_unique[index_col_name;index_name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		^if($self.is_alter_table){ ADD }
		UNIQUE
		^if(def $index_name){$index_name}
		($index_col_name)
	]
##end of @unique



##############################################################################
#:param index_name type string
#:param index_col_name type string
#:result string
@add_key[index_col_name;index_name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		^if($self.is_alter_table){ ADD }
		KEY
		^if(def $index_name){$index_name}
		($index_col_name)
	]
##end of @key



##############################################################################
#:param index_name type string
#:param index_col_name type string
#:result string
@add_fulltext[index_col_name;index_name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		^if($self.is_alter_table){ ADD }
		FULLTEXT
		^if(def $index_name){$index_name}
		($index_col_name)
	]
##end of @fulltext



##############################################################################
#:param name type string
#:result string
@drop_column[name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		DROP COLUMN `$name`
	]
##end of @drop_column



##############################################################################
#:param name type string
#:result string
@drop_primary_key[][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		DROP PRIMARY KEY
	]
##end of @drop_primary_key



##############################################################################
#:param name type string
#:result string
@drop_index[name][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		DROP INDEX `$name`
	]
##end of @drop_index



##############################################################################
#	TODO: множественное переименование таблиц вне alter table: "RENAME TABLE x1 TO x2, y1 to y2, ..."
#	TODO: переименование с переносом в другую базу "RENAME TABLE db1.tbl1 TO db2.tbl2"
##############################################################################
#:param old_name type string
#:param new_name type string
#:result string
@rename_table[old_name;new_name][result]
	^if($self.is_alter_table){
		$new_name[$old_name]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
			RENAME TO `$new_name`
		]
	}{
		$result[
			^self.oSql.void{
				RENAME TABLE `$old_name` TO `$new_name
			}
    ]
	}
##end of @rename_table



##############################################################################
#:param name type string
#:param hOptions type hash
#:result string
@alter_column[name;hOptions][result]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		ALTER COLUMN `$name`
		^if(def $hOptions.default){
			SET DEFAULT $hOptions.default
		}{
			DROP DEFAULT
		}
	]
##end of @alter_column



##############################################################################
#:param oldname type string
#:param name type string
#:param DBType type string
#:param hOptions type hash
#:result string
@change_column[oldname;name;DBType;hOptions][result]
	^if(!def $name){$name[$oldname]}
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		CHANGE COLUMN `$oldname`
		`$name` ^_type[$DBType;$hOptions]
		^if(def $hOptions.null){
			^if($hOptions.null){
				NULL
			}{
				NOT NULL
			}
		}
		^if(def $hOptions.default){ DEFAULT $hOptions.default }
		^if(def $hOptions.auto_increment){ AUTO_INCREMENT }
#		TODO: Reference definition

		^if(def $hOptions.first){
			FIRST
		}(def $hOptions.after){
			AFTER `$hOptions.after`
		}

		^if(def $hOptions.primary_key){ PRIMARY KEY }
		^if(def $hOptions.index){ ^add_index[$name] }
		^if(def $hOptions.unique){ ^add_unique[$name] }
		^if(def $hOptions.key){ ^add_key[$name] }
		^if(def $hOptions.fulltext){ ^add_fulltext[$name] }
	]
##end of @column



##############################################################################
#:param old_name type string
#:param new_name type string
#:result string
@rename_column[old_name;new_name][result]
	^if(!def $self.show_create){
		$self.show_create[^hash::create[]]
	}
	^if(!def $self.show_create.[$self.table_name]){
		$show_create_table[^self.oSql.table{
			SHOW CREATE TABLE `$self.table_name`
		}]
		$self.show_create.[$self.table_name][$show_create_table.[Create Table]]
	}
	$match_table[^self.show_create.[$self.table_name].match[\s*`$old_name`(.+),][U]]
	$result[
		^if($self.not_first_element){,}{$self.not_first_element(true)}
		CHANGE COLUMN `$old_name` `$new_name` ^taint[as-is][$match_table.1]
	]
#end of @rename_column



##############################################################################
#:param tbl_name  type string
#:param create_definition type junction
#:param table_options type hash
#:param select_statement type hash
#:param hOptions type hash
@create_table[tbl_name;create_definition;hOptions]
	$self.not_first_element(false)
	$self.is_alter_table(false)
	^self.oSql.void{
		CREATE
		^if(def $hOptions.temporary){ TEMPORARY }
		TABLE
		IF NOT EXISTS
#		^if(def $hOptions.if_not_exists){ IF NOT EXISTS }
		`$tbl_name`
		(
		^if(!^hOptions.no_auto_primary_key.bool(false)){
			`${tbl_name}_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY
			$self.not_first_element(true)
		}
		$create_definition)
		^_table_options[$hOptions]
		^_select_statement[$hOptions]
	}
	$self.not_first_element(false)
##end of @create_table



##############################################################################
#:param tbl_name type string
#:param alter_spec type Junction
#:param table_options type hash
#:param hOptions type hash
@alter_table[tbl_name;alter_spec;hOptions]
	$self.not_first_element(false)
	$self.is_alter_table(true)
	$self.table_name[$tbl_name]
	^self.oSql.void{
		ALTER
		^if(def $hOptions.ignore){ IGNORE }
		TABLE
		`$tbl_name`
		$alter_spec
		^if($self.not_first_element){,}
		^_table_options[$hOptions]
	}
	$self.is_alter_table(false)
	$self.not_first_element(false)
##end of @alter_table



##############################################################################
#:param names type hash
#:result string
@drop_table[*names]
	^self.oSql.void{
		DROP TABLE
		IF EXISTS
		^names.foreach[key;tbl_name]{
			`$tbl_name`
		}[,]
	}
#end of @drop_table
