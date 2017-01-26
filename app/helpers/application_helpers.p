@filter_url[]
																				^rem{*** Хэш-фильтр для регулярки, отбираем нужные url ***}
	$filter_hash[^hash::create[]] 
	$filter_hash[
		$.1[products]
		$.2[wine]
		$.3[champagnes-and-sparkling]
		$.4[whisky]
		$.5[cognac]
		$.6[beer]
		$.7[liqueur]
		$.8[grappa]
		$.9[water]
		$.10[wine-set]
		$.11[sake]
		$.12[gifts]
		$.13[gift-pack]
		$.14[glass]
		$.15[accessory]
		$.16[cider]
		$.17[caviar]
		$.18[foie-gras]
		$.19[truffles]
		$.20[chocolate]
		$.21[spirit]
		$.22[rum]
	]

	^filter_hash.foreach[key;value]{ 
		$filter_hash.$key[^filter_hash.$key.match[($value)][gm]{http:\/\/winestyle.ru\/${match.1}.*|}]
	}
	^filter_hash.foreach[key;value]{ 
		$filter_string[${filter_string}${value}]
	}
	$filter_string[^filter_string.match[(.*)\|^$][gm]{${match.1}}]

#	Можно записать все это в одну строчку, но мне кажется, что хэш править удобнее $filter_string[http:\/\/winestyle.ru\/products.*|http:\/\/winestyle.ru\/wine.*|http:\/\/winestyle.ru\/champagnes-and-sparkling.*|http:\/\/winestyle.ru\/whisky.*|http:\/\/winestyle.ru\/cognac.*|http:\/\/winestyle.ru\/beer.*|http:\/\/winestyle.ru\/liqueur.*|http:\/\/winestyle.ru\/grappa.*|http:\/\/winestyle.ru\/water.*|http:\/\/winestyle.ru\/wine-set.*|http:\/\/winestyle.ru\/sake.*|http:\/\/winestyle.ru\/gifts.*|http:\/\/winestyle.ru\/gift-pack.*|http:\/\/winestyle.ru\/glass.*|http:\/\/winestyle.ru\/accessory.*|http:\/\/winestyle.ru\/cider.*|http:\/\/winestyle.ru\/caviar.*|http:\/\/winestyle.ru\/foie-gras.*|http:\/\/winestyle.ru\/truffles.*|http:\/\/winestyle.ru\/chocolate.*|http:\/\/winestyle.ru\/spirit.*|http:\/\/winestyle.ru\/rum.*]

	$result[$filter_string]

#end @filter_url[]



##############################################################################
@name_md5[url]
																				^rem{*** Преобразуем ссылку в md5 название файла ***}	
	$name[^math:md5[^taint[as-is][$url]]]
	$result[$name]

#end @name_md5[url]



##############################################################################
@get_html_file[url]
																				^rem{*** Выбираем файл с диска по url ***}
	$name[^name_md5[$url]] 
	$file[^file::load[text;../winestyle/${name}.html]]

	$result[$file]

#end @get_html_file[url]



##############################################################################
@parcing_url[file]
																				^rem{***Парсинг ссылок, Преобразование таблицы в хэш ***}
	$url_table[^file.text.match[href="(.*?)"][g]]
	
	$url_hash[^hash::create[]] 													^rem{*** Преобразование таблицы в хэш ***}	
	^url_table.foreach[i;value]{
		$url_table.1[^url_table.1.match[(^^\/\/.*)][gm]{http:$match.1}] 
		$url_table.1[^url_table.1.match[(^^\/[A-z]+.*)][gm]{http://winestyle.ru$match.1}] 
		$url_hash.[$url_table.1](true) 			 
	}

	$result[$url_hash]

#end @parcing_url[file]



##############################################################################
@write_links_database[url_hash;filter_string]
																				^rem{*** Запись ссылок со страницы в БД ***}
	$copy_url_hash[^hash::create[$url_hash]]
	^copy_url_hash.foreach[key;value]{
		^if(^key.match[$filter_string][gm]){
		}{
			^url_hash.delete[$key]
		}
	}

	$pages[^array::create[]]
	^url_hash.foreach[url;row]{
		$page[^Page::create[]]
		$page.url[$url]		
		^pages.add[$page]
	}
	^if($pages){
		$res(^Page:insert_all[$pages][
			$.url(true)
		])	
	}
	
#end @write_links_database[url_hash;filter_string]