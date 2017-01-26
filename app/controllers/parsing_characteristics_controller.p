##############################################################################
#	
##############################################################################

@CLASS
ParsingCharacteristicsController

@OPTIONS
locals

@BASE
ApplicationController



#############################################################################
@create[]
	^BASE:create[]	

#end @create[]



#############################################################################
@get_goods_characteristics[goods_id;code_characteristics;characteristics]
																				^rem{*** Создание объекта модели ***}
	^if(def $characteristics){
		$good_characteristics[^WinestyleGoodsCharacteristics::create[]]
				^good_characteristics.update[
					$.goods_id[$goods_id]
					$.code_characteristics[$code_characteristics]
					^if($characteristics is string){
						$.characteristics[$characteristics]
					}{
						$.characteristics[^characteristics.sql-string[]]
					}					
				]	
		$result[$good_characteristics]
	}
	


##############################################################################
@aIndex[]
	
	$goods[^WinestyleGoods:all[
		$.condition[winestyle_goods_id NOT IN (SELECT goods_id FROM winestyle_goods_characteristics)]
		$.order[winestyle_goods_id ASC]
		$.limit(50)
	]]

	^while($goods){
		$goods_characteristics[^array::create[]]

		$goods[^WinestyleGoods:all[
			$.condition[winestyle_goods_id NOT IN (SELECT goods_id FROM winestyle_goods_characteristics)]
			$.order[winestyle_goods_id ASC]
			$.limit(50)
		]]

		^foreach[$goods;good]{
			^good.FIELDS.foreach[field;not_used]{
				^if(def $good.[$field]){
					^if(^field.match[taste(?!_)|suitable_for|style|composition|type_beer|type_barrels|supplements|aging_in_barrels|basis][gm]){
						$table_field[^good.[$field].match[(.*?),+][gs]]
						$table_field_part2[^good.[$field].match[.*,\s*(.*)^$][gs]]
						^if(def $table_field_part2){
							^table_field.append[ 
							   $.1[$table_field_part2.1] 
							]		
							^table_field.foreach[i;value]{
								^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$value.1]]		 
							} 	
						}{
							^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$good.[$field]]]
						}
					}(^field.match[grapes][gm]){
						^if(^good.[$field].match[,][gm]){
							$grapes_percent[^good.[$field].match[(.*?):\s*.*?,+\s*][gm]]
							$grapes_percent_part2[^good.[$field].match[.*,\s*(.*?):.*^$][gm]]
							^if($grapes_percent){
								^grapes_percent.append[ 
									$.1[$grapes_percent_part2.1] 
								]		
								^grapes_percent.foreach[i;value]{
									^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$value.1]]		 
								}
							}{	
								$table_grapes[^good.[$field].match[(.*?),+][gs]]
								$table_grapes_part2[^good.[$field].match[.*,\s*(.*)^$][gs]]
								^table_grapes.append[ 
									$.1[$table_grapes_part2.1] 
								]		
								^table_grapes.foreach[i;value]{
									^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$value.1]]		 
								} 
							}

						}{
							$grapes[^good.[$field].match[(.*?):.*][gm]]
							^if($grapes){
								^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$grapes.1]]	
							}{
								^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$good.[$field]]]
							}
						}
					}{
						^goods_characteristics.add[^get_goods_characteristics[$good.id;$field;$good.[$field]]]
					}
				}				
			}

		}
		
		^if($goods_characteristics){
			$res(^WinestyleGoodsCharacteristics:insert_all[$goods_characteristics])	
		}
	}

#end @aIndex[]