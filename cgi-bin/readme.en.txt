Apache Win32 (CGI):
------------------

Put file parser3.exe to cgi-bin folder of your web-site.

Create in root folder of your site file .htaccess and add these commands to it: 

# assign parser as .html pages handler:
AddHandler parsed-html html
Action parsed-html /cgi-bin/parser3.exe

# disable access to .cfg and .p files:
<Files ~ "\.(p|cfg)$">
Order allow,deny
Deny from all
</Files>

Note: default Apache server configration does not allow to use .htaccess files.


Internet Information Server 4–5 (Win32):
---------------------------------------

Place Parser's module executables (parser3isapi.dll in current version) into an arbitrary directory.
If you use version with XML support, unpack XML libraries into directory specified in environment variable PATH 
(for example C:\WinNT).

Having placed files to needed locations, you need to declare Parser as .html files handler:

1.	Run Management Console, right-click icon with your web server and choose Properties;  
	
2.	Go to Application settings and under Home directory click on the Configuration button;  
	
3.	Click Add;  
	
4.	In the Executable box, type full path to parser3.exe;  
	
5.	In the Extension box, type .html;  
	
6.	Check Check that file exists box;  
	
7.	Click OK.  

We recommend you to read document on IIS security:
http://support.microsoft.com/support/kb/articles/Q260/0/69.ASP
