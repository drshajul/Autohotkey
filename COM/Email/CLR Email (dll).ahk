CLR_StartDomain( mailDomain ) ;Isolate code to new AppDomain
asm := CLR_LoadLibrary("MyMail.dll" , mailDomain)
mail := CLR_CreateObject(asm, "iMail") ;Create object instance
attachs = %A_ScriptFullPath%|%A_ScriptDir%\Test.htm ;Pipe delimited list of attachment files
sent := mail.iSend("smtp.gmail.com"          ;smtp server
                  , 587                      ;port
                  , "username@gmail.com"     ;username
                  , "mypassword"		     ;password
                  , "username@gmail.com"     ;from address
                  , "recipient@gmail.com"    ;to address
                  , "Hi just testing"        ;message body
                  , "Hello"                  ;message subject
                  , attachs                  ;attachments
                  , True)                    ;ssl enabled
if not sent
  MsgBox, 48, Error!, Message sending failed!

CLR_StopDomain( mailDomain )
