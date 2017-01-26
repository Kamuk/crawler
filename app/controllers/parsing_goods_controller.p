##############################################################################
#	
##############################################################################

@CLASS
ParsingGoodsController

@OPTIONS
locals

@BASE
ApplicationController



#############################################################################
@create[]
	^BASE:create[]	

#end @create[]
	


##############################################################################
@aIndex[]

	$state(2)	^rem{*** Состояние страницы 0 - никаких действий не производилось, 1 - страница сохранена на компьютер, 2 - страница проиндексирована, 3 - страницу распарсили, достали характеристики товара ***}
	$pages[^Page:all[
			$.condition[state = '$state']
			$.limit(50)
	]]

	^while($pages){ 

		$pages[^Page:all[
			$.condition[state = '$state']
			$.limit(50)
		]]

		$goods_array[^array::create[]]

		^pages.foreach[page_key;page_value]{
			^if(^page_value.url.match[.*(products).*][xm]){
# 				$file[^get_html_file[^taint[as-is][$page_value.url]]] 
				$file[^get_html_file[^taint[as-is][http://winestyle.ru/products/Paderborner-Pilsener-in-can.html]]]
				$table_article[^file.text.match[<span class="bg-text" title="Артикул">(.*?)<\/span>][gm]]
				$article[$table_article.1]

		 		$table_name[^file.text.match[<h1 itemprop="name" class="main-title">(.*?)<\/h1>][gm]]
		 		$name[$table_name.1] 

		 		$table_types[^name.match[^^([А-я\s]*)][gm]]
		 		$types[$table_types.1] 

		 		$table_geo[^file.text.match[<span.*?>Регион.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>.*?<a.+?>(.+?)<\/a>.*?<a.+?>(.+?)<\/a>][gm]]
		 		^if(def $table_geo){
		 			$country[$table_geo.1]
		 			$region[$table_geo.2]
		 			$subregion[$table_geo.3]
		 		}{
		 			$table_geo[^file.text.match[<span.*?>Регион.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>.*?<a.+?>(.+?)<\/a>][gm]]
		 			^if(def $table_geo){
			 			$country[$table_geo.1]
			 			$region[$table_geo.2]
		 			}{
		 				$table_geo[^file.text.match[<span.*?>Регион.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
		 				$country[$table_geo.1]
		 			}
		 		}

		 		$table_price[^file.text.match[(<meta itemprop="priceCurrency" content="RUB"\/><\/span>|<span class="mobile-name mobile-only">Цена<\/span>)\s*<span class='price'>(.*?)<span>][gm]]
		  		$price[^table_price.2.match[(\d*)\s*(\d*)\s*(\d*)][gm]{${match.1}${match.2}${match.3}}]

		  		$table_price_old[^file.text.match[(<meta itemprop="priceCurrency" content="RUB"\/><\/span>|<span class="mobile-name mobile-only">Цена<\/span>)\s*<span class='price'>.*?<span>.*\s*<span class='price-old'.*>(.*?)<span>][gm]]
		  		$price_old[^table_price_old.2.match[(\d*)\s*(\d*)\s*(\d*)][gm]{${match.1}${match.2}${match.3}}]

		  		$table_rating[^file.text.match[<meta itemprop="reviewCount".*>\s*<span class="text">(.*)<\/span>][gm]]
		  		$rating[$table_rating.1]

		  		$table_wine[^file.text.match[<span.*?>Вино[^^град].*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>.*?<a.+?>(.+?)<\/a>][gm]]
		 			^if(def $table_wine){
		 			
		 				$color[^table_wine.1.match[Красное|Белое|Розовое|красное|белое|розовое][gm]]
		 				^if(def $color){
		 					$color_wine[$table_wine.1]
						}{
							$kind_wine[$table_wine.1]
						}

		 				$type_wine[$table_wine.2]
		 			}{
		 				$table_wine[^file.text.match[<span.*?>Вино[^^град].*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
		 				$kind_wine[$table_wine.1]
		 			}

		 		$table_factory[^file.text.match[<span.*?>Производитель.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
				^if(def $table_factory){
					$factory[$table_factory.1]
				}{
					$table_factory[^file.text.match[<span.*?>Производитель.*?<\/span>\s*(.+?)\s*<\/li>][gm]]
					$factory[$table_factory.1]
				}
				
		 		$table_brand[^file.text.match[<span.*?>Бренд.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
				^if(def $table_brand){
					$brand[$table_brand.1]
				}{
					$table_brand[^file.text.match[<span.*?>Бренд.*?<\/span>\s*(.+?)\s*<\/li>][gm]]
					$brand[$table_brand.1]
				}

				$table_volume[^file.text.match[<span class=("|')val("|')>(.*)?<\/span>][gm]]
				$volume[$table_volume.3]

				$table_excert[^file.text.match[<span.*?>Выдержка.*?<\/span>\s*(.+?)\s*<\/li>][gm]]
				^if(def $table_excert){
					$excert[$table_excert.1]	
				}{
					$table_excert[^file.text.match[<span>Выдержка:<\/span>.*?<\/span>\s*(.*?)<\/li>][gs]]
					$excert[$table_excert.1]
				}

				$table_class[^file.text.match[<span.*?>Класс коньяка.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
				^if(def $table_class){
					$class[$table_class.1]
				}{
					$table_class[^file.text.match[<span.*?>Класс коньяка.*?<\/span>\s*(.+?)\s*<\/li>][gm]]			
					^if(def $table_class){
						$class[$table_class.1]
					}{
						$table_class[^file.text.match[<span>Класс:<\/span>.*?<\/span>\s*(.*?)<\/li>][gs]]
						$class[$table_class.1]
					}
				}
				
				$table_fortress[^file.text.match[<span.*?>Крепость.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gm]]
				^if(def $table_fortress){
					$fortress[$table_fortress.1]
				}{
					$table_fortress[^file.text.match[<span.*?>Крепость.*?<\/span>\s*(.+?)\s*<\/li>][gm]]
					$fortress[$table_fortress.1]
				}
				

				$table_taste_description[^file.text.match[<span.*?>Вкус<\/span>\s*<p.*?>\s*(.*?)\s*<\/p>][gm]]
				$taste_description[$table_taste_description.1]

				$table_color[^file.text.match[<span.*?>Цвет<\/span>\s*<p.*?>\s*(.*?)\s*<\/p>][gm]]
				$color[$table_color.1]

				$table_gastronomy[^file.text.match[<span.*?>Гастрономические сочетания<\/span>\s*<p.*?>\s*(.*?)\s*<\/p>][gm]]
				$gastronomy[$table_gastronomy.1]

				$table_fragrance[^file.text.match[<span.*?>Аромат<\/span>\s*<p.*?>\s*(.*?)\s*<\/p>][gm]]
				$fragrance[$table_fragrance.1]

				$table_taste[^file.text.match[<span.*?>Вкус<\/span>\s*<ul.*?>(.*?)<\/ul>][gm]]
				$table_taste[^table_taste.1.match[<a.*?>(.*?)<\/a>][gm]]
				$hash_taste[^hash::create[]] 
				^table_taste.foreach[i;value]{
					$hash_taste.$i[$value.1] 			 
				}
				^hash_taste.foreach[key;value]{
					^if(def $taste){
						$taste[${taste}, ${value}]
					}{
						$taste[${value}]
					}			
				}

				$table_suitable_for[^file.text.match[<span.*?>Подходит к<\/span>\s*<ul.*?>(.*?)<\/ul>][gm]]
				$table_suitable_for[^table_suitable_for.1.match[<a.*?>(.*?)<\/a>][gm]]
				$hash_suitable_for[^hash::create[]] 
				^table_suitable_for.foreach[i;value]{
					$hash_suitable_for.$i[$value.1] 			 
				}
				^hash_suitable_for.foreach[key;value]{
					^if(def $suitable_for){
						$suitable_for[${suitable_for}, ${value}]
					}{
						$suitable_for[${value}]
					}			
				}
				
				$table_facts[^file.text.match[Интересные факты<\/h4>\s*<div.*?>(?!<div)\s*(.*?)(?=<div.*?>)][gs]]
				$table_facts[^table_facts.1.match[<\/div>.*?<\/div>.*][gs]{}]
				$table_facts[^table_facts.match[(<\/div>|<span class="blt   ">|<b class="bs-fs-bold">|<\/b>|<strong>|<\/strong>|<span class="blt ">|<p>|<p style="text-align: right^;">|<\/p>|<span class="blt  ">|<span mce_name="strong" mce_style="font-weight: bold^;" style="font-weight: bold^;" class="Apple-style-span" mce_fixed="1">|<span class="blt">|<br>|<br \/>|<\/em>|<em>|&deg^;|&nbsp^;|&quot^;|<span>|<\/span>|&mdash^;)][g]{}]
				$facts[$table_facts]

				$table_about_factory[^file.text.match[О производителе<\/h4>\s*<div.*?>(?!<div)\s*(.*?)(?=<div.*?>)][gs]]
				$table_about_factory[^table_about_factory.1.match[<\/div>.*?<\/div>.*][gs]{}]
				$table_about_factory[^table_about_factory.match[(<\/div>|<span class="blt   ">|<b class="bs-fs-bold">|<\/b>|<strong>|<\/strong>|<span class="blt ">|<span mce_name="strong" mce_style="font-weight: bold^;" style="font-weight: bold^;" class="Apple-style-span" mce_fixed="1">|<p>|<p style="text-align: right^;">|<\/p>|<span class="blt  ">|<span class="blt">|<br>|<br \/>|<\/em>|<em>|&deg^;|&nbsp^;|&quot^;|<span>|<\/span>|&mdash^;)][g]{}]
				$about_factory[$table_about_factory]

				$table_year[^file.text.match[<span.*?>(Год|Винтаж).*?<\/span>\s*(.+?)\s*<\/li>][gm]]
				^if(def $table_year){
					$year[$table_year.2]
				}{
					$table_year[^name.match[[^^\d]([\d]{4})(?!(\sмл|\d))][gs]]
					$year[$table_year.1]
				}

				$table_stock[^file.text.match[<(div class="title condition|span class="stock").*?>(.*?)<][gm]]
				$stock[$table_stock.2]

				$table_grapes[^file.text.match[<span.*?>Виноград.*?<\/span>\s*<div.*?>(.*?)<\/div>][gs]]
				^if(def $table_grapes){

					$table_sort_grapes[^table_grapes.1.match[<a.*?>(.*?)<\/a>][gm]]
					$table_percent_grapes[^table_grapes.1.match[<\/a>(.*?)(<a.*?>|^$)][gm]]
					$hash_grapes[^hash::create[]] 
					$hash_percent_grapes[^hash::create[]] 
					^table_sort_grapes.foreach[i;value]{
						$hash_grapes.$i[$value.1] 			 
					}
					^table_percent_grapes.foreach[i;value]{
						$hash_percent_grapes.$i[$value.1] 			 
					}
					^hash_grapes.foreach[key;value]{
						^if(def $grapes){
							$grapes[${grapes} ${value}${hash_percent_grapes.$key}]
						}{
							$grapes[${value}${hash_percent_grapes.$key}]
						}			
					}	
				}{
					$table_grapes[^file.text.match[<span>Сорт винограда:<\/span>.*?<\/span>\s*(.*?)<\/li>][gs]]
					$grapes[$table_grapes.1]
					$table_grapes[^grapes.match[(.*?),+][gs]]
					$table_grapes_part2[^grapes.match[.*,(.*)^$][gs]]
					^if(def $table_grapes_part2){
						^table_grapes.append[ 
						   $.1[$table_grapes_part2.1] 
						]
						$hash_grapes[^hash::create[]] 
						^table_grapes.foreach[i;value]{
							$hash_grapes.$i[$value.1] 			 
						} 	
					}		
				}
				
				$table_type_of_packaging[^file.text.match[<span>Тип ёмкости:<\/span>.*?<a.*?>(.*?)<\/a>][gs]]
				$type_of_packaging[$table_type_of_packaging.1]

				$table_color_depth[^file.text.match[<span>Глубина цвета:<\/span>.*?<a.*?>(.*?)<\/a>][gs]]
				$color_depth[$table_color_depth.1]

				$table_opacity[^file.text.match[<span>Тело\/Насыщенность:<\/span>.*?<a.*?>(.*?)<\/a>][gs]]
				$opacity[$table_opacity.1]

				$table_temperature[^file.text.match[<span>Температура сервировки:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$temperature[$table_temperature.1]

				$table_site_factory[^file.text.match[<span>Сайт производителя:<\/span>.*?<a.*?>(.*?)<\/a>][gs]]
				$site_factory[$table_site_factory.1]

				$table_site_brand[^file.text.match[<span>Сайт бренда:<\/span>.*?<a.*?>(.*?)<\/a>][gs]]
				$site_brand[$table_site_brand.1]

				$table_style[^file.text.match[<span.*?>Стиль.*?<\/span>\s*<div.*?>\s*(.*?)\s*<\/div>][gm]]
				$table_style[^table_style.1.match[<a.*?>(.*?)<\/a>][gs]]
				$hash_style[^hash::create[]] 
				^table_style.foreach[i;value]{
					$hash_style.$i[$value.1] 			 
				}
				^hash_style.foreach[key;value]{
					^if(def $style){
						$style[${style}, ${value}]
					}{
						$style[${value}]
					}			
				}

				$table_composition[^file.text.match[<span>Состав:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$composition[$table_composition.1]
				$table_composition[^composition.match[(.*?),+][gs]]
				$table_composition_part2[^composition.match[.*,\s*(.*)^$][gs]]
				^if(def $table_composition_part2){
					^table_composition.append[ 
					   $.1[$table_composition_part2.1] 
					]		
					$hash_composition[^hash::create[]] 
					^table_composition.foreach[i;value]{
						$hash_composition.$i[$value.1] 			 
					} 	
				}		

				$table_type_beer[^file.text.match[<span.*?>Пиво.*?<\/span>\s*<div.*?>\s*(.*?)\s*<\/div>][gm]]
				$table_type_beer[^table_type_beer.1.match[<a.*?>(.*?)<\/a>][gs]]
				$hash_type_beer[^hash::create[]] 
				^table_type_beer.foreach[i;value]{
					$hash_type_beer.$i[$value.1] 			 
				}
				^hash_type_beer.foreach[key;value]{
					^if(def $type_beer){
						$type_beer[${type_beer}, ${value}]
					}{
						$type_beer[${value}]
					}			
				}

				$table_type_curing[^file.text.match[<span>Тип термообработки:<\/span>.*?<\/span>\s*<a.*?>(.*?)<\/a>\s*<\/li>][gs]]
				$type_curing[$table_type_curing.1]

				$table_filtration[^file.text.match[<span.*?>Фильтрация.*?<\/span>\s*<div class="links">\s*<a.*?>\s*(.+?)\s*<\/a>][gm]]
				$filtration[$table_filtration.1]

				$table_type_barrels[^file.text.match[<span>Тип бочки:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$type_barrels[$table_type_barrels.1]
				$table_type_barrels[^type_barrels.match[(.*?),+][gs]]
				$table_type_barrels_part2[^type_barrels.match[.*,(.*)^$][gs]]
				^if(def $table_type_barrels_part2){
					^table_type_barrels.append[ 
					   $.1[$table_type_barrels_part2.1] 
					]		
					$hash_type_barrels[^hash::create[]] 
					^table_type_barrels.foreach[i;value]{
						$hash_type_barrels.$i[$value.1] 			 
					} 	
				}	

				$table_supplements[^file.text.match[<span>Добавки:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$table_supplements[^table_supplements.1.match[<a.*?>(.*?)<\/a>][gs]]
				$hash_supplements[^hash::create[]] 
				^table_supplements.foreach[i;value]{
					$hash_supplements.$i[$value.1] 			 
				}
				^hash_supplements.foreach[key;value]{
					^if(def $supplements){
						$supplements[${supplements}, ${value}]
					}{
						$supplements[${value}]
					}			
				}

				$table_density[^file.text.match[<span>Плотность:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$density[$table_density.1]

				$table_technology_maturation[^file.text.match[<span>Технология созревания:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$technology_maturation[$table_technology_maturation.1]

				$table_type_fermentation[^file.text.match[<span.*?>Тип ферментации.*?<\/span>\s*<div.*?>\s*<a.+?>(.+?)<\/a>][gs]]
				$type_fermentation[$table_type_fermentation.1]

				$table_hop_content[^file.text.match[<span>Содержание хмеля:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$hop_content[$table_hop_content.1]

				$table_pack_items[^file.text.match[<span>В коробке:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$pack_items[$table_pack_items.1]

				$table_aging_in_barrels[^file.text.match[<span.*?>Выдержка в бочках.*?<\/span>\s*<div.*?>\s*(.*?)\s*<\/div>][gs]]
				$table_aging_in_barrels[^table_aging_in_barrels.1.match[<a.*?>(.*?)<\/a>][gs]]
				$hash_aging_in_barrels[^hash::create[]] 
				^table_aging_in_barrels.foreach[i;value]{
					$hash_aging_in_barrels.$i[$value.1] 			 
				}
				^hash_aging_in_barrels.foreach[key;value]{
					^if(def $aging_in_barrels){
						$aging_in_barrels[${aging_in_barrels}, ${value}]
					}{
						$aging_in_barrels[${value}]
					}			
				}

				$table_views_beverage[^file.text.match[<span>Тип:<\/span>.*?<\/span>\s*<a.*?>(.*?)<\/a>][gs]]
				$views_beverage[$table_views_beverage.1]

				$table_basis[^file.text.match[<span>Основа:<\/span>.*?<\/span>\s*(.*?)\s*<\/li>][gs]]
				$table_basis[^table_basis.1.match[<a.*?>(.*?)<\/a>][gs]]
				$hash_basis[^hash::create[]] 
				^table_basis.foreach[i;value]{
					$hash_basis.$i[$value.1] 			 
				}
				^hash_basis.foreach[key;value]{
					^if(def $basis){
						$basis[${basis}, ${value}]
					}{
						$basis[${value}]
					}			
				}

				$good[^WinestyleGoods::create[]]
				^good.update[
					$.article[$article]
					$.name[$name]
					$.types[$types]
					$.region[$region]
					$.subregion[$subregion]
					$.country[$country]
					$.price[$price]
					$.rating[$rating]
					$.color_wine[$color_wine]
					$.type_wine[$type_wine]
					$.kind_wine[$kind_wine]
					$.brand[$brand]
					$.volume[$volume]
					$.excert[$excert]
					$.class[$class]
					$.fortress[$fortress]
					$.taste_description[$taste_description]
					$.color[$color]
					$.gastronomy[$gastronomy]
					$.fragrance[$fragrance]
					$.taste[$taste]
					$.suitable_for[$suitable_for]
					$.facts[$facts]
					$.about_factory[$about_factory]
					$.factory[$factory]
					$.price_old[$price_old]
					$.year[$year]
					$.stock[$stock]
					$.grapes[$grapes]
					$.type_of_packaging[$type_of_packaging]
					$.color_depth[$color_depth]
					$.opacity[$opacity]
					$.temperature[$temperature]
					$.site_factory[$site_factory]
					$.site_brand[$site_brand]
					$.style[$style]
					$.composition[$composition]
					$.type_beer[$type_beer]
					$.type_curing[$type_curing]
					$.filtration[$filtration]
					$.type_barrels[$type_barrels]
					$.supplements[$supplements]
					$.density[$density]
					$.technology_maturation[$technology_maturation]
					$.type_fermentation[$type_fermentation]
					$.hop_content[$hop_content]
					$.pack_items[$pack_items]
					$.aging_in_barrels[$aging_in_barrels]
					$.views_beverage[$views_beverage]
					$.basis[$basis]
				]
			^goods_array.add[$good]

			}{} 

			$article[]
			$name[]
			$type[]
			$region[]
			$subregion[]
			$country[]
			$price[]
			$rating[]
			$price_old[]
			$color_wine[]
			$type_wine[]
			$kind_wine[]
			$brand[]
			$factory[]
			$volume[]
			$excert[]
			$class[]
			$fortress[]
			$taste_description[]
			$color[]
			$gastronomy[]
			$fragrance[]
			$taste[]
			$suitable_for[]
			$facts[]
			$about_factory[]
			$year[]
			$stock[]
			$grapes[]
			$type_of_packaging[]
			$color_depth[]
			$opacity[]
			$temperature[]
			$site_factory[]
			$site_brand[]
			$style[]
			$composition[]
			$type_beer[]
			$type_curing[]
			$filtration[]
			$type_barrels[]
			$supplements[]
			$density[]
			$technology_maturation[]
			$type_fermentation[]
			$hop_content[]
			$pack_items[]
			$aging_in_barrels[]
			$views_beverage[]
			$basis[]
		}

		^if($goods_array){
			$res(^WinestyleGoods:insert_all[$goods_array][
				$.name(true)
			])	
		}

		^if($pages){
			$res(^Page:update_all[
					$.state(3)
				][
					$.condition[url IN (^foreach[$pages;value]{'$value.url'}[,])]
				])	
		}
	#Очистка от "мусора" память
		^Rusage:compact[]
	}


#end @aIndex[]
