##############################################################################
#	
##############################################################################

@CLASS
IndexerController

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

	$state(1)	^rem{*** Состояние страницы 0 - никаких действий не производилось, 1 - страница сохранена на компьютер, 2 - страница проиндексирована, 3 - страницу распарсили, достали характеристики товара ***}
	$filter_string[^filter_url[]]

	$pages[^Page:all[
			$.condition[state = '$state']
			$.limit(50)
		]]

	^while($pages){ 

		$pages[^Page:all[
			$.condition[state = '$state']
			$.limit(50)
		]]

		^pages.foreach[key;value]{
			$file[^get_html_file[^taint[as-is][$value.url]]]
			$url_hash[^parcing_url[$file]]
			^write_links_database[$url_hash;$filter_string]
		}

		^if($pages){
			$res(^Page:update_all[
					$.state(2)
				][
					$.condition[url IN (^foreach[$pages;value]{'$value.url'}[,])]
				])	
			}
		}

#Очистка от "мусора" память
		^Rusage:compact[]

#Рекомендованная задержка, чтобы не забанили на сайте=)
		^sleep(0.1)
	}

	$self.finish[Все ссылки с сайта получены!]

#end @aIndex[]
