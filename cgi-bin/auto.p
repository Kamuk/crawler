@conf[filespec][confdir;charsetsdir;sqldriversdir]

$confdir[^file:dirname[$filespec]]
$charsetsdir[$confdir/charsets]
$sqldriversdir[$confdir/lib]

$CHARSETS[
#	$.cp866[$charsetsdir/cp866.cfg]
	$.koi8-r[$charsetsdir/koi8-r.cfg]
#	$.koi8-u[$charsetsdir/koi8-u.cfg]
#	$.windows-1250[$charsetsdir/windows-1250.cfg]
	$.windows-1251[$charsetsdir/windows-1251.cfg]
#	$.windows-1254[$charsetsdir/windows-1254.cfg]
#	$.windows-1257[$charsetsdir/windows-1257.cfg]
#	$.x-mac-cyrillic[$charsetsdir/x-mac-cyrillic.cfg]
]

#change your client libraries paths to those on your system
$SQL[
	$.drivers[^table::create{protocol	driver	client
mysql	$sqldriversdir/parser3mysql.dll	$sqldriversdir/libmySQL.dll
sqlite	$sqldriversdir/parser3sqlite.dll	$sqldriversdir/sqlite3.dll
#pgsql	$sqldriversdir/parser3pgsql.dll	$sqldriversdir/libpq.dll
#odbc	$sqldriversdir/parser3odbc.dll
#oracle	$sqldriversdir/parser3oracle.dll	c:\Oracle\Ora81\BIN\oci.dll?PATH+=^;C:\Oracle\Ora81\bin
}]
]

#for ^file::load[name;user-name] mime-type autodetection
$MIME-TYPES[^table::create{ext	mime-type
7z	application/x-7z-compressed
au	audio/basic
avi	video/x-msvideo
css	text/css
cvs	text/csv
doc	application/msword
docx	application/vnd.openxmlformats-officedocument.wordprocessingml.document
dtd	application/xml-dtd
gif	image/gif
gz	application/x-gzip
htm	text/html
html	text/html
ico	image/x-icon
jpeg	image/jpeg
jpg	image/jpeg
js	application/javascript
json	application/json
log	text/plain
mid	audio/midi
midi	audio/midi
mov	video/quicktime
mp3	audio/mpeg
mpg	video/mpeg
mpeg	video/mpeg
mts	application/metastream
pdf	application/pdf
png	image/png
ppt	application/powerpoint
ra	audio/x-realaudio
ram	audio/x-pn-realaudio
rar	application/x-rar-compressed
rdf	application/rdf+xml
rpm	audio/x-pn-realaudio-plugin
rss	application/rss+xml
rtf	application/rtf
svg	image/svg+xml
swf	application/x-shockwave-flash
tar	application/x-tar
tgz	application/x-gzip
tif	image/tiff
txt	text/plain
wav	audio/x-wav
xls	application/vnd.ms-excel
xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
xml	text/xml
xsl	text/xml
zip	application/zip
}]

$LIMITS[
	$.post_max_size(10*0x400*0x400)
]	

$MAIL[
	$.SMTP[smtp.domain.ru]
]


@fatal_error[title;subtitle;body]
$response:status(500)
$response:content-type[
	$.value[text/html]
	$.charset[$response:charset]
]
<html>
<head><title>$title</title></head>
<body>
<h1>^if(def $subtitle){$subtitle;$title}</h1>
$body
#for [x] MSIE friendly
^for[i](0;512/8){<!-- -->}
</body>
</html>


@unhandled_exception_debug[exception;stack]
^fatal_error[Unhandled Exception^if(def $exception.type){ ($exception.type)};$exception.source;
<pre>^untaint[html]{$exception.comment}</pre>
^if(def $exception.file){
^untaint[html]{<tt>$exception.file^(${exception.lineno}:$exception.colno^)</tt>}
}
^if($stack){
	<hr/>
	<table>
	^stack.menu{
		<tr><td>$stack.name</td><td><tt>$stack.file^(${stack.lineno}:$stack.colno^)</tt></td></tr>
	}
	</table>
}
]


@unhandled_exception_release[exception;stack]
^fatal_error[Unhandled Exception;;

<p>The server encountered an unhandled exception 
and was unable to complete your request.</p>
<p>Please contact the server administrator, $env:SERVER_ADMIN
and inform them of the time the error occurred, 
and anything you might have done that may have caused the error.</p>
<p>More information about this error may be available in the Parser error log
or in debug version of unhandled_exception.</p>

]


@is_developer[]
#change mask to your ip address
$result(def $env:REMOTE_ADDR && ^env:REMOTE_ADDR.match[^^127\.0\.0\.1^$])


@unhandled_exception[exception;stack]
#developer? use debug version to see problem details
^if(^is_developer[]){
	^unhandled_exception_debug[$exception;$stack]
}{
	^if($exception.type eq "file.missing"){
		$response:status(404)
	}{
		^unhandled_exception_release[$exception;$stack]
	}
}


@auto[]
#source/client charsets
$request:charset[UTF-8]
$response:charset[UTF-8]

$response:content-type[
	$.value[text/html]
	$.charset[$response:charset]
]

#$SQL.connect-string[mysql://user:password@host/db]
#$SQL.connect-string[pgsql://user:password@host/db]
#$SQL.connect-string[oracle://user:password@service?NLS_LANG=RUSSIAN_AMERICA.CL8MSWIN1251&NLS_DATE_FORMAT=YYYY-MM-DD HH24:MI:SS&ClientCharset=windows-1251]
#$SQL.connect-string[odbc://DSN=datasource^;UID=user^;PWD=password]
#$SQL.connect-string[sqlite://db]

