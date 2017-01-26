##############################################################################
#	
##############################################################################

@CLASS
ActiveImage

@OPTIONS
locals
partial

@BASE
ActiveFile

@USE
active_image_info.p
active_image_actions.p



##############################################################################
@create[sAlias;oModel;oImageMeta]
	^if(!($oImageMeta is ActiveImageMeta)){
		^throw[parser.runtime;create;params must be ActiveImageMeta]
	}

	^BASE:create[$sAlias;$oModel;$oImageMeta]
	
	^rem{ *** image meta *** }
	$self._imeta[$self._meta.image]
	
	^rem{ *** хеш для подгруженных изображений *** }
	$self._images[^hash::create[]]
#end @create[]



##############################################################################
@GET_DEFAULT[name][result]
	^if($self._imeta.[$name]){
		^image[$name;$self._imeta.[$name]]
	}
#end @GET_DEFAULT[]



##############################################################################
@GET_file[]
	$name[file]

	^if(!^self._images.contains[$name]){
		$self._images.[$name][^_image_object[$self.original_path]]
	}

	$result[$self._images.[$name]]
#end @GET_file[]



##############################################################################
@html[hParams]
	$result[^self.file.html[$hParams]]
#end @html[]




##############################################################################
@GET_image_path[]
	^if(def $self._imeta.image_path){
		$result[$self.model.[$self._imeta.image_path]]
	}{
		$result[$self._image_path]
	}
#end @GET_image_path[]



##############################################################################
@_image_path[name;format]
	$result[^file:dirname[$self.original_path]/^file:justname[$self.original_path]_${name}.^if(def $format){$format}{^file:justext[$self.original_path]}]
#end @_image_path[]



##############################################################################
@image[name;meta][image]
	^rem{ *** проверяем наличие файла в открытых файлах *** }
	^if(!^self._images.contains[$name]){
		^rem{ *** путь до нового изображения *** }
		$path[^image_path[$name^if(def $meta.dynamic_name){_$self.model.[$meta.dynamic_name]};$meta.sFormat]]

		^rem{ *** генерируем изображение по параметрам *** }
		$self._images.[$name][^_image[$path;$meta]]
	}

	$result[$self._images.$name]
#end @image[]



##############################################################################
@_image[path;meta]
	^if(-f $self.original_path && !(-f $path)){
		$result[^_generate_image[$path;$meta]]
	}{
		$result[^_image_object[$path]]
	}
#end @_image[]



##############################################################################
@_image_object[path]
	$result[^ActiveImageInfo::create[$path]]
#end @_image_object[]



##############################################################################
@_generate_image[path;meta]
	^try{
		^if(def $meta.sFormat){
			^rem{ *** конвертируем изображение в новый формат для начала обработки *** }
			$file[^self._action_convert[$self.original_path;$path;$meta.sFormat]]

			^rem{ *** TODO: выкидывать ошибку только в DEBUG режиме *** }
			^if($file.status){
				^throw[active_image.generate.convert;$file.status;$file.stderr]
			}
		}{
			^rem{ *** копируем оригинальное изображения для начала обработки *** }
			^file:copy[$self.original_path;$path]
		}
		
		$result[^self._image_object[$path]]
		
		$steps(0)
		^meta.foreach[i;params]{
			^if($i eq "sFormat" || $i eq "dynamic_name"){^continue[]}
			^steps.inc[]
		}

		^rem{ *** пошаговое выполнение операций над файлом *** }
		^meta.foreach[i;step]{
			^if($i eq "sFormat" || $i eq "dynamic_name"){^continue[]}
			
			^if( !def $step.iQuality && $i != ($steps - 1)){
				$step.iQuality(100)												^rem{ *** для всех кроме последнего шага качество = 100% *** }
			}

			$file[^self.[_action_${step.action}][$result][$path;$step]]

			^rem{ *** TODO: выкидывать ошибку только в DEBUG режиме *** }
			^if($file.status && $oLogger.SEVERITY.DEBUG >= $oLogger.SEVERITY.[$oLogger.level]){
				^throw[active_image.generate.step;$file.status;$file.stderr]
			}
			
			$result[^self._image_object[$path]]
		}
	}{
		^rem{ *** в случае возникновения ошибки на любом шаге удаляем сгенерированный файл *** }
		^self._delete_file[$path]

		^if($exception.type eq "active_image.generate.convert"){
			$exception.handled(true)
		}
	}
#end @_generate_image[]



##############################################################################
@_delete[]
	^rem{ *** удаляем из хеша подгруженных изображений оригинал изображения *** }
	^self._images.delete[file]

	^rem{ *** удаляем файл *** }
	^BASE:_delete[]

	^self.delete_resizes[]
#end @_delete[]



##############################################################################
@delete_resizes[]
	^rem{ *** удаляем сгенерированные изображения *** }
	^self._imeta.foreach[name;meta]{
		^if(!($meta is hash)){^continue[]}
		^self.delete_image_file[$name^if(def $meta.dynamic_name){_$self.model.[$meta.dynamic_name]};$meta.sFormat]
	}

	$result[]
#end @delete_resizes[]



##############################################################################
@delete_image_file[name;format]
	$path[^image_path[$name;$format]]

	^rem{ *** удаляем из хеша подгруженных изображений *** }
	^self._images.delete[$name]

	^rem{ *** удаляем файл изображения *** }
	^self._delete_file[$path]

	$result[]
#end @delete_image_file[]
