

;MSDN Ref: http://msdn.microsoft.com/en-us/library/aa752084(v=vs.85).aspx
;AHK Ref: http://www.autohotkey.com/forum/viewtopic.php?t=51020

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

pwb := ComObjCreate( "InternetExplorer.Application" ) ; Create an IE object
pwb.Visible := True ; Make the IE object visible
pwb.Navigate( "www.irctc.co.in" )
While, pwb.ReadyState <> 4
; While, pwb.Busy
   Continue
pwb.document.all.userName.value := "shajul"
pwb.document.all.password.value := "one4all"
pwb.document.all.button.click()  ;click login
While, pwb.Busy
   Continue
sLocation := pwb.LocationURL
RegExMatch(sLocation,"BV_SessionID.+$",sID)
qlocation := "https://www.irctc.co.in/cgi-bin/bv60.dll/irctc/booking/quickBook.do?LinkValue=1&amp;QuickNav=true&amp;submitClicks=1&amp;voucher=43&amp;" . sID
StringReplace,qlocation,qlocation,&amp`;,&,All

pwb.Navigate(qlocation)
While, pwb.Busy
   Continue
pwb.document.all.stationFrom.value := "ktym"   
pwb.document.all.stationTo.value := "sbc"   
pwb.document.all.classCode.selectedIndex := 4   
/*
1 - 1A
2 - FC (First Class)
3 - 2A
4 - 3A
5 - CC (Chair Car)
6 - SL
7 - 2S (Second Sitting)
8 - 3E (3AC Economy)
*/
pwb.document.all.trainNo.value := 12258
pwb.document.all.boardPoint.value := "ers"  
pwb.document.all.quota[2].checked := true
pwb.Navigate("javascript: return setQuota('CK');")


;Passenger data filling
pwb.document.BookTicketForm.hidModFlag.value := "true" ;From function modify()
; passenger name length is 16 chars only - IMPORTANT
pwb.document.all["passengers[0].passengerName"].value := "Shajul George"
pwb.document.all["passengers[0].passengerAge"].value := 31
pwb.document.all["passengers[0].passengerSex"].selectedIndex := 1  ;1-Male 2-Female
pwb.document.all["passengers[0].berthPreffer"].selectedIndex := 1  ;1-Lower 2-Middle 3-Upper 4-SU 5-SL
;passengers[0].seniorCitizen  ; checkbox -disabled in tatkal

pwb.document.all["childPassengers[0].childPassengerName"].value := "Leo S John"
pwb.document.all["childPassengers[0].childPassengerAge"].selectedIndex := 2  ;1-<1 2-1 3-2 4-3 5-4
pwb.document.all["childPassengers[0].childPassengerSex"].selectedIndex := 1  ;1-Male 2-Female

pwb.Navigate("javascript:showCal();$('JDate').select();showCalendarControl($('JDate'),'1');")
While, pwb.Busy
   Continue
pwb.Navigate("javascript:setCalendarControlDate(2011,2,12);")
While, pwb.Busy
   Continue

;Payment data
pwb.document.BookTicketForm.gatewayID.selectedIndex := 4
pwb.Navigate("javascript:GetSerCahrge(document.BookTicketForm.gatewayID.value);")
While, pwb.Busy
   Continue
/*
Gateway 2(Operated By ICICI)
Gateway 1(Operated By Citibank)
HDFC Bank
ICICI Bank
IDBI Bank
CITI Debit
Oriental Bank Of Commerce
ITZ Cash Card
axis
State Bank Of India
Punjab National Bank
American Express Bank Gateway
ABN Amro Bank
Corporation Bank
Federal Bank
CITI Bank EMI
Syndicate Bank
Union Bank
IciciEmi
IndusInd Bank
I Cash Card
Andhra Bank
Karnataka Bank
SBI Debit Card
Rajasthan Bank
Bank Of India
SBIAssociate
Indian Bank
Canara Bank
Bank Of Baroda
HDFC Bank Payment Gateway
oxicash
AXIS PG
*/


MsgBox, Pls Check all data - especially Date-Boarding point
;pwb.document.all.Submit.click()