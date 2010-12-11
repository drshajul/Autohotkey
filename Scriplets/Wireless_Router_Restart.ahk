#noenv 
html     := "" 
URL      := "http://admin:admin@192.168.10.1/goform/formSetReboot" 
POSTData := "restart=Restart&webpage=lan.asp"

length := httpQuery(html,URL,POSTdata) 
varSetCapacity(html,-1)
IfExist, delme.htm
   FileDelete, delme.htm
FileAppend, % html, delme.htm


