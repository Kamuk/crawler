##############################################################################
#	
##############################################################################

@CLASS
ActiveImage

@OPTIONS
locals
partial



##############################################################################
@_action_info[path]
	^try{
		$result[^image::measure[$path]]
	}{
		^rem{ *** используем nconvert & etc для получения информации по форматам,
			      которые не поддерживает Parser
			*** }
		$result[^oImage.info[$path]]
		$result[
			$.src[$path]
			$.width[$result.iWidth]
			$.height[$result.iHeight]
			$.exif[$result]
		]
	}
#end @_action_info[]



##############################################################################
@_action_convert[original_path;path;format]
	$result[^oImage.convert[$original_path;$path;$format][$params]]
#end @_action_convert[]



##############################################################################
@_action_resize[image;path;params]
	^if(def $params.dynamic_width){
		$params.width[$self.model.[$params.dynamic_width]]
	}
	^if(def $params.dynamic_height){
		$params.height[$self.model.[$params.dynamic_height]]
	}

	$iWidth($image.width)
	$iHeight($image.height)

	^rem{*** если реальные размеры изображения совпадают - проверять min/max по размерам ресайза ***}
	^if($iWidth == $iHeight){
		$iWidth($params.width)
		$iHeight($params.height)
	}

	^switch[$params.sResizeBy]{
		^case[min]{
			^if($iWidth > $iHeight){
				$params.width[0]
			}{
				$params.height[0]
			}
		}

		^case[max]{
			^if($iWidth > $iHeight){
				$params.height[0]
			}{
				$params.width[0]
			}
		}
	}

	$result[^oImage.resize[$path;$path;$params.width;$params.height][$params]]
#end @_action_resize[]



##############################################################################
@_action_crop[image;path;params]		
	^switch[$params.position]{	
		^case[center]{
			$params.x(^math:floor($image.width / 2 - $params.width / 2))
			$params.y(^math:floor($image.height / 2 - $params.height / 2))
		}
		
		^case[top-center]{
			$params.x(^math:floor($image.width / 2 - $params.width / 2))
			$params.y(0)
		}
		
		^case[bottom]{
			$params.x(^math:floor($image.width / 2 - $params.width / 2))
			$params.y($image.height - $params.height)
		}
	}
	
	^if(def $params.dynamic_x){
		$params.x[$self.model.[$params.dynamic_x]]
	}
	^if(def $params.dynamic_y){
		$params.y[$self.model.[$params.dynamic_y]]
	}
	^if(def $params.dynamic_width){
		$params.width[$self.model.[$params.dynamic_width]]
	}
	^if(def $params.dynamic_height){
		$params.height[$self.model.[$params.dynamic_height]]
	}
	
	$result[^oImage.crop[$path;$path;$params.x;$params.y;$params.width;$params.height][$params]]
#end @_action_crop[]



##############################################################################
@_action_watermark[image;path;params]
	^if(^params.size_control.bool(false)){
		$watermark[^self._action_info[$params.image]]

		^if($image.width >= $watermark.width && $image.height >= $watermark.height){
			$result[^oImage.watermark[$path;$path;$params.image][$params]]
		}{
			$result[]
		}
	}{
		$result[^oImage.watermark[$path;$path;$params.image][$params]]
	}
#end @_action_watermark[]
