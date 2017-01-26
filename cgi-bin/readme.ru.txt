Apache Win32, CGI:
-----------------
Создайте в корневом каталоге вашего сервера файл .htaccess 
и добавьте в него следующие команды:

# назначение обработчиком .html страниц:
AddHandler parsed-html html
Action parsed-html /cgi-bin/parser3.exe


# запрет на доступ к .cfg и .p файлам:
<Files ~ "\.(p|cfg)$">
Order allow,deny
Deny from all
</Files>

Также добавьте еще одну команду:

CharsetDisable On

Если добавление этой команды привело к ошибке, значит ваш веб-сервер 
не нуждается в этой дополнительной настройке.

По-умолчанию, в установке Apache возможность использования .htaccess отключена.

Internet Information Server 4–5 (Win32):
---------------------------------------

Запустите Management Console, нажмите правую кнопку мыши на названии 
вашего веб-сервера и выберите "Properties".

Перейдите на вкладку «Home directory» и в разделе «Application settings» 
нажмите на кнопку «Configuration...». В появившемся окне нажмите на кнопку «Add».

В поле «Executable» задайте полный путь к CGI-скрипту parser3.exe 
В поле «Extension» укажите «.html».
Включите опцию «Check that file exists».
Нажмите на кнопку «OK».

Parser также можно установить на IIS 2 и на Personal Web Server, 
назначив обработчиком файлов *.html CGI-скрипт parser3.exe.

Также рекомендуем ознакомиться с документом по безопасности IIS:
http://support.microsoft.com/support/kb/articles/Q260/0/69.ASP