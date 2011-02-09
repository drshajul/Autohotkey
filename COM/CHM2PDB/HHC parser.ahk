/*           ,---,                                          ,--,    
           ,--.' |                                        ,--.'|    
           |  |  :                      .--.         ,--, |  | :    
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '    
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |    
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |    
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :    
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__  
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'| 
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ; 
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /  
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
                      `--`---'     \   \  /                         
                                    `--`-'  
------------------------------------------------------------------
Function:
Requires: 
URL: 
------------------------------------------------------------------
*/

#NoEnv
SetWorkingDir %A_ScriptDir%
FileRead, html, toc.hhc

; write the Google Source to an HTMLfile
doc := ComObjCreate("HTMLfile")
doc.write(html)

ul := doc.getElementsByTagName("UL")
mainNode := ul[0].childNodes
txt =
(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
<title>Index</title>
</head>
<body>
)
txt .= DisplayNode(mainNode, indent=0)
txt .= "</body>`n</html>"
FileAppend, %txt%, toc.htm

DisplayNode(node, indent=0)
{
   text .= "<ul>`n"
   Loop, % node.length
   {
   nIndex := A_Index-1
    ; MsgBox % node[nIndex].InnerHTML   ;LI inner
   if not node[nIndex].getElementsByTagName("UL").length
     {
     if (node[nIndex].childNodes[0].childNodes[0].getAttribute("name") = "Name")
       LinkText := node[nIndex].childNodes[0].childNodes[0].getAttribute("value")
     if (node[nIndex].childNodes[0].childNodes[1].getAttribute("name") = "Local")
       LinkURL := node[nIndex].childNodes[0].childNodes[1].getAttribute("value")
     text .= spaces(indent) . "<li><a href=""" . LinkURL . """>" . LinkText . "</a></li>`n"
     }
   else
     {
     if (node[nIndex].childNodes[0].childNodes[0].getAttribute("name") = "Name")
       LinkText := node[nIndex].childNodes[0].childNodes[0].getAttribute("value")
     text .= spaces(indent) . "<li><a href=""#"">" . LinkText . "</a></a></li>`n"
     text .= DisplayNode(node[nIndex].childNodes[1].childNodes, indent+2)
     }
   }
   text .= "</ul>`n"
   return text
}

spaces(n)
{
   Loop, %n%
      t .= " "
   return t
}