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

txt := DisplayNode(mainNode, indent=0)
FileAppend, %txt%, toc.txt

DisplayNode(node, indent=0)
{
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
     text .= spaces(indent) . "<a href=""" . LinkURL . """>" . LinkText . "</a>`n"
     }
   else
     {
     if (node[nIndex].childNodes[0].childNodes[0].getAttribute("name") = "Name")
       LinkText := node[nIndex].childNodes[0].childNodes[0].getAttribute("value")
     text .= spaces(indent) . "<a href=""#"">" . LinkText . "</a>`n"
     text .= DisplayNode(node[nIndex].childNodes[1].childNodes, indent+2)
     }
   }
   return text
}

spaces(n)
{
   Loop, %n%
      t .= " "
   return t
}