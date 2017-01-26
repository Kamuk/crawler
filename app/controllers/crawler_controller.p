##############################################################################
#	
##############################################################################

@CLASS
CrawlerController

@OPTIONS
locals

@BASE
ApplicationController



#############################################################################
@create[]
	^BASE:create[]	

#end @create[]



#############################################################################
^rem{*** Получение html-файла ***}
@save_html_file[url]
	^try{
		$self.file[^curl:load[ 
			$.ssl_verifypeer(0)
			$.ssl_verifyhost(0)
			$.url[$url] 
			$.timeout(60) 
			$.failonerror(1)
		]] 
	}{
		 $exception.handled(true)
		 	$page[^Page:all[
				$.condition[url = '$url']
			]]
			$new_status_page[^page.update_attributes[
				$.status[$exception.comment]
			]]
	}

	$name[^name_md5[$url]] 
	^file.save[text;../winestyle/${name}.html]

#end @save_html_file[url]



##############################################################################
@aIndex[]
# 	$filter_string[^filter_url[]]

# 	^if(def $params.Send){
# 		^save_html_file[^taint[as-is][$params.url]]

# 		$file[^get_html_file[^taint[as-is][$params.url]]]
# 		$url_hash[^parcing_url[$file]]
# 		^write_links_database[$url_hash;$filter_string]

# 		^redirect_to[
# 			$.controller[crawler]
# 			$.action[crawler]
# 		]
# 	}

^save_html_file[http://winestyle.ru/products/Paderborner-Pilsener-in-can.html]
^redirect_to[
				$.controller[parsing_goods]
				$.action[index]
			]

#end @aIndex[]



##############################################################################
@aCrawler[]

	$state(0)	^rem{*** Состояние страницы 0 - никаких действий не производилось, 1 - страница сохранена на компьютер, 2 - страница проиндексирована, 3 - страницу распарсили, достали характеристики товара ***}

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
				^save_html_file[^taint[as-is][$value.url]]
		}

		^if($pages){
			$res(^Page:update_all[
					$.state(1)
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

	$self.finish[Все файлы с сайта получены!]

#end @aCrawler[]
