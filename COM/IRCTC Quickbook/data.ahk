#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

javascript: document.all.userName.value = 'shajul'; void 0   
javascript: document.all.password.value = 'one4all'; void 0   
javascript: document.all.button.click()  ;click login

RegExMatch(document.location,"BV_SessionID.+$",sID)
StringReplace,sID,sID,&,&amp`;
qlocation := "https://www.irctc.co.in/cgi-bin/bv60.dll/irctc/booking/quickBook.do?LinkValue=1&amp;QuickNav=true&amp;submitClicks=1&amp;voucher=43&amp;" . sID

javascript: document.location(qlocation)
javascript: document.all.stationFrom.value = 'ktym'; void 0   
javascript: document.all.stationTo.value = 'shajul'; void 0   
javascript: document.all.classCode.selectedIndex = 4; void 0   
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
javascript: document.all.trainNo.value = 12258; void 0
javascript: document.all.boardPoint.value = 'ers'; void 0  
javascript: document.all.quota[2].checked = true; void 0
javascript: return setQuota('CK');


;Passenger data filling
javascript: document.BookTicketForm.hidModFlag.value="true"; void 0 ;From function modify()
; passenger name length is 16 chars only - IMPORTANT
javascript: document.all['passengers[0].passengerName'].value = 'Shajul George'; void 0
javascript: document.all['passengers[0].passengerAge'].value = 31; void 0
javascript: document.all['passengers[0].passengerSex'].selectedIndex = 1; void 0  ;1-Male 2-Female
javascript: document.all['passengers[0].berthPreffer'].selectedIndex = 1; void 0  ;1-Lower 2-Middle 3-Upper 4-SU 5-SL
;passengers[0].seniorCitizen  ; checkbox -disabled in tatkal

javascript: document.all['childPassengers[0].childPassengerName'].value = 'Leo S John'; void 0
javascript: document.all['childPassengers[0].childPassengerAge'].selectedIndex = 2; void 0  ;1-<1 2-1 3-2 4-3 5-4
javascript: document.all['childPassengers[0].childPassengerSex'].selectedIndex = 1; void 0  ;1-Male 2-Female

javascript:showCal();$('JDate').select();showCalendarControl($('JDate'),'1');
javascript:setCalendarControlDate(2011,2,12);

;Payment data
javascript: document.BookTicketForm.gatewayID.selectedIndex = 15; void 0
javascript: GetSerCahrge(document.BookTicketForm.gatewayID.value);
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
javascript: document.all.Submit.click()