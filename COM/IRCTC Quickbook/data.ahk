#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

javascript: document.all.userName.value = 'shajul'; void 0   
javascript: document.all.password.value = 'one4all'; void 0   
javascript: document.all.button.click()  ;click login

tvar := document.location
RegExMatch(tvar,"BV_SessionID.+$",sID)
StringReplace,sID,sID,&,&amp`;
qlocation := "https://www.irctc.co.in/cgi-bin/bv60.dll/irctc/booking/quickBook.do?LinkValue=1&amp;QuickNav=true&amp;submitClicks=1&amp;voucher=43&amp;" . sID

javascript: document.location(qlocation)