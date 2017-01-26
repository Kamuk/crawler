##############################################################################
#	
##############################################################################

@CLASS
ActiveFile

@OPTIONS
locals

@BASE
Environment

@USE
active_file_info.p



##############################################################################
@create[sAlias;oModel;oFileMeta]
	^if(!($oFileMeta is ActiveFileMeta)){
		^throw[parser.runtime;create;params must be ActiveFileMeta]
	}
	
	^rem{ *** file meta *** }
	$self._alias[$sAlias]
	^if(def $oFileMeta.field){
		$self._field[$oFileMeta.field]
	}{
		$self._field[$sAlias]
	}
	^if(def $oFileMeta.file_name){
		$self._file_name[$oFileMeta.file_name]
	}
	$self._model[$oModel]
	$self._meta[$oFileMeta]

	$self._mark_delete(false)

	^rem{ *** сохраняем старое значение для удаления *** }
	$self._delete_file_name[$self.model.[${self.field}_file_name]]
	
	$self._file_is_loaded(false)
	$self._file[]
	$self.new_file[]
#end @create[]



##############################################################################
@GET[]
	$result($self.file)
#end @GET[]



##############################################################################
@GET_name[]
	$result[$self.model.[${self.field}_file_name]]
#end @GET_name[]



##############################################################################
@GET_ico[]
	$file_icons[
		$.GIF[GIF]
		$.JPG[JPG]
		$.JPEG[JPEG]
		$.PNG[PNG]
		$.PSD[PSD]
		$.ZIP[ZIP]
		$.TAR[TAR]
		$.GZ[TGZ]
		$.TGZ[TGZ]
		$.TXT[TXT]
		$.HTML[HTML]
		$.SWF[SWF]
		$.PDF[PDF]
		$.DOC[DOC]
		$.DOCX[DOC]
		$.XLS[XLS]
		$.XLSX[XLS]
		$.PPT[PPT]
		$.PPTX[PPT]
		$._default[Generic]
	]
	
	$ext[^file:justext[$self.path]]
	$result[$file_icons.[^ext.upper[]]]
#end @GET_ico[]



##############################################################################
@GET_alias[]
	$result[$self._alias]
#end @GET_alias[]



##############################################################################
@GET_field[]
	$result[$self._field]
#end @GET_field[]



##############################################################################
@GET_model[]
	$result[$self._model]
#end @GET_model[]



##############################################################################
@GET_path[]
	$result[$self.original_path]
#end @GET_path[]



##############################################################################
@GET_original_path[]
	$result[$self.model.file_path/${self.file_name}.^file:justext[$self.name]]
#end @GET_original_path[]



##############################################################################
@GET_file_name[]
	^if(def $self._file_name){
		$result[$self.model.[$self._file_name]]
	}{
		$result[$self._field]
	}
#end @GET_file_name[]



##############################################################################
@GET_file[]
	^if(!$self._file_is_loaded){
		$self._file_is_loaded(true)
		
		$self._file[^ActiveFileInfo::create[$self.original_path][$self.model.[${self.field}_file_name]]]
	}
	
	$result[$self._file]
#end @GET_file[]



##############################################################################
#	Возвращает размер файла
##############################################################################
@GET_size[]
	$result[$self.file.size]
#end @GET_size[]



##############################################################################
#	Метод сохраняет файл для последующей обработки и выставляет необходимые флаги
#	Возвращает значение, которое попадет в аттрибут $alias модели
##############################################################################
@update[value][file]
	^if($value is file){
		$file[$value]
	}($value is ActiveFile){
		$file[$value.file.file]
	}($value is ActiveFileInfo){
		$file[$value.file]
	}

	^if($value is hash){
		^if($value.file is file){
			$file[$value.file]
		}
		
		^if($value.$alias is file){
			$file[$value.$alias]
		}($value.$alias is ActiveFile){
			$file[$value.[$alias].file.file]
		}($value.$alias is ActiveFileInfo){
			$file[$value.[$alias].file]
		}

		^rem{ *** mark to delete image *** }
		^if($self._meta.is_deletable && $value.delete){
			$self._mark_delete(true)
		}
	}
	
	$result[]
		
	^if(def $file){
		$self.new_file[$file]
		
		^rem{ *** устанавливаем значение аттрибута у модели для валидации *** }
		$result[$file]
	}
#end @update[]



##############################################################################
#	Метод обновляет аттрибуты модели в соответствии с новым значением
#	Возвращает хеш атрибут = значения для обновления модели
##############################################################################
@prepare_model_attributes[]
	$result[^hash::create[]]

	^if($self._mark_delete){
		$result.[${self.field}_file_name][]
	}

	^if(def $self.new_file){
		$result.[${self.field}_file_name][$self.new_file.name]
	}
#end @prepare_model_attributes[]



##############################################################################
#	Метод производит сохранение файла и/или удаление старого
##############################################################################
@save[]
	^if(def $self.new_file || $self._mark_delete){
		^self.delete_file[]
	}

	^if(def $self.new_file){
		^rem{ *** сохраняем новый файл *** }
		^self.new_file.save[binary;$self.path]

		$self.new_file[]
	}
	
	$result[]
#end @save[]



##############################################################################
#	Метод удаляет файлы с жесткого диска
##############################################################################
@delete_file[][file_name]
	^rem{ *** запоминаем текущее имя файла *** }
	$file_name[$self.model.[${self.field}_file_name]]

	^rem{ *** выставляем старое имя файла *** }
	$self.model.[${self.field}_file_name][$self._delete_file_name]

	^rem{ *** удаляем файл *** }
	^self._delete[]
	
	^rem{ *** восстанавливаем значение *** }
	$self.model.[${self.field}_file_name][$file_name]
	
	$result[]
#end @delete_file[]



##############################################################################
@_delete[]
	^self._delete_file[$self.path]
#end @_delete[]



##############################################################################
@_delete_file[path]
	^try{
		^file:delete[$path]
	}{
		^if($exception.type eq "file.missing"){
			$exception.handled(true)
		}
	}
#end @_delete_file[]
