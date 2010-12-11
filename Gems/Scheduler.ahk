; -- On Windows Vista, some scripts might require administrator privileges to function properly 
;   (such as a script that interacts with a process or window that is run as administrator). 
RunAsAdmin:
params := ""
if 0>0
{
	Loop, %0%  ; For each parameter:
	{
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		params .= A_Space . param
	}
}
If A_IsCompiled
{
	if not A_IsAdmin
	{
	   DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
	   ExitApp
	}
}
Else
{
	if not A_IsAdmin
	{
	   DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
	   ExitApp
	}
}
   version = 0.03
   #Persistent
   #SingleInstance Force
   SetBatchLines -1       ; maximum speed for loops
   SendMode Input        ; Recommended for new scripts due to its superior speed and reliability.
   #NoEnv
   #MaxThreadsPerHotkey 1   ;required to enable correction on accidental press of several hotkeys (only last pressed hotkey will be fired)
   DetectHiddenWindows ON
   SetWorkingDir %A_ScriptDir%   ; -- makes sure the script looks for the icons and such in the right place
   
   GoSub vars
   GoSub list_txt
   GoSub function_menu
   GoSub ini_read
   gosub function_parse_timers
   chosen_action := last_action
   GoSub GUI_start
return

vars:
   program_closeMain   =   ahk-timer.ahk
   ini_file   =   ahk-timer.ini
   timer_free   =   0
return

ini_read:
   IniRead , last_action, %ini_file%, General, last_action, 11   ; -- 11 is last action in the list: "no action"
   IniRead , warning, %ini_file%, General, warning, 0
   IniRead , program, %ini_file%, General, program, 0
   IniRead , allow_cancel, %ini_file%, General, allow_cancel, 1
   IniRead , program_close, %ini_file%, General, program_close, 0
   IniRead , warning_message, %ini_file%, General, warning_message, %A_Space%
   IniRead , path_program, %ini_file%, General, path_program, %A_Space%
   IniRead , run_program_path, %ini_file%, General, run_program_path, %A_Space%
   IniRead , when, %ini_file%, General, when, 1
   IniRead , Timers, %ini_file%, General, Timers, %A_Space%
return

function_parse_timers:
   Outputdebug (%A_LineNumber%) function_parse_timers start (timer_free : %timer_free%)
   gosub command_timers_off
   StringReplace Timers , Timers , `,%A_Space%`,,, All
   StringReplace Timers , Timers , %A_Space%`, ,, All
   StringReplace Timers , Timers , `,`, , `,, All
   timer_free = 0
   if Timers <>
   {
      loop , parse, Timers , `,
      {
         if A_LoopField <>
         {
            current_timer := A_Index
            timer_%A_Index% := A_LoopField
            ScheduledTime := A_LoopField
            gosub function_start_timers
            timer_free += 1
         }
      }
   }
   Outputdebug (%A_LineNumber%) function_parse_timers finish (timer_free : %timer_free%)
return

function_get_timer_total:
   timer_free = 0
   if Timers <>
   {
      loop , parse, Timers , `,
      {
         if A_LoopField <>
         {
            current_timer := A_Index
            timer_%A_Index% := A_LoopField
            timer_free += 1
         }
      }
   }
   timer_total := timer_free
   GUIControl , 10: , gui_timer , &Timers (%timer_total%)
   outputdebug function_get_timer_total > &Timers (%timer_total%)
return

function_start_timers:
   ; IniRead , ScheduledTime, %ini_file%, %ScheduledTime%, ScheduledTime, %A_Space% ; -- no need, already set
   IniRead , chosen_action, %ini_file%, %ScheduledTime%, Action, %A_Space%
   IniRead , warning, %ini_file%, %ScheduledTime%, warning, %A_Space%
   IniRead , warning_message, %ini_file%, %ScheduledTime%, warning_message, %A_Space%
   IniRead , program, %ini_file%, %ScheduledTime%, program, %A_Space%
   IniRead , path_program, %ini_file%, %ScheduledTime%, path_program, %A_Space%
   IniRead , WorkingDir, %ini_file%, %ScheduledTime%, WorkingDir, %A_Space%
   gosub command_start_timers
   Outputdebug (%A_LineNumber%) timer_%A_Index% : %ScheduledTime% - %chosen_action% - %warning_message% - %path_program%
return

GUI_start:
   SetTitleMatchMode 3   ; -- 3 to make the titlematchmode EXACT
   ifWinExist AHK-Scheduler
   {
      GUI 10:Show
      return
   }
   gosub function_get_timer_total ; -- counts amount of timers
   GUI 10:Add, GroupBox, y8 w205 h45 section, Action
   stringreplace , last_action_2 , chosen_action , action ,   ; -- needed to get rid of the "action" part in the variable
   GUI 10:Add, DropDownList, gcaction_2 vaction_2 xs+10 ys+18 w185 r11 choose%last_action_2% altsubmit, %text_action1%|%text_action2%|%text_action3%|%text_action4%|%text_action5%|%text_action6%|%text_action7%|%text_action8%|%text_action9%|%text_action10%|%text_action11%

   GUI 10:Add, GroupBox, xs ys+50 w205 h113 section, Options
   GUI 10:Add, Checkbox, gcwarning vwarning xs+10 ys+18 w115 h18 section, &Warning message
   GUI 10:Add, Checkbox, gcprogram vprogram xs wp hp, &Run Program
   GUI 10:Add, Checkbox, disabled gcprogram_close vprogram_close xs wp hp , Close Program
   GUI 10:Add, Checkbox, gcallow_cancel vallow_cancel xs wp hp , Allow cancel
   GUI 10:Add, Button, disabled gbmessage vbmessage xs+120 ys-2 w70 h20, Message...
   GUI 10:Add, Button, disabled gbprogram vbprogram xs+120 ys+24 wp hp , Program...
   GUI 10:Add, Button, disabled gbprogram_close vbprogram_close xs+120 ys+48 wp hp , Program...
   
   if warning = 1
   {
      GUIControl , 10: , warning , 1
      GUIControl , 10:enable , bmessage
   }
   if program = 1
   {
      GUIControl , 10: , program , 1
      GUIControl , 10:enable , bprogram
   }
   if allow_cancel = 1
      GUIControl , 10: , allow_cancel , 1
   if program_close = 1
   {
      GUIControl , 10: , program_close , 1
      GUIControl , 10:enable , bprogram_close
   }
   
   GUI 10:Add, GroupBox, xs-10 ys+96 w205 h115 section, When
   GUI 10:Add, Radio, gcwhen vwhen xs+10 ys+18 w115 h18 section checked, &Immediate
   GUI 10:Add, Radio, gcwhen xs wp hp section, &Scheduled
   GUI 10:Add, Radio, gcwhen xs wp hp , &Countdown
   GUI 10:Add, Radio, disabled gcwhen xs wp hp , &After a process stops
   GUI 10:Add, Button, disabled gbschedule vbschedule xs+120 ys-2 w70 h20, Schedule...
   GUI 10:Add, Button, disabled gbtimer vbtimer xs+120 ys+24 wp hp , Timer...
   GUI 10:Add, Button, disabled gbprocess vbprocess xs+120 ys+48 wp hp , Process...

   gosub cwhen   ; -- this selects the radio button and activates the right button

   GUI 10:Add, Button, disabled ggui_timers vgui_timer xs-10 w95 section, &Timers (%timer_total%)
   GUI 10:Add, Button, ys wp Default, &OK

   if timer_total > 0
      GUIControl ,10:enable, gui_timer
   
   GUI 10:Show,, AHK-Scheduler
Return

caction_2:
   GUI 10:Submit, nohide
   chosen_action = action%action_2%
   IniWrite , %chosen_action%, %ini_file%, General, last_action
return

gui_timers:
   GUI_timers_exist = 1
   gosub command_hide
   GUI 20:Add, Text, x10 y10 Section, Scheduled at
   GUI 20:Add, Text, xs110 ys , Actions
   GUI 20:Add, Text, xs310 ys , Message
   GUI 20:Add, Text, xs415 ys , Program
   GUI 20:Add, Text, xs520 ys , Repeat?
   
   gosub gui_filltimers
   
   GUI 20:Add, Button, gcancel_timer vcancel_all_timers xs section, &Cancel all timers
   GUI 20:Add, Button, g20guiclose ys w62 Default, &Close
   GUI 20:Show, , AHK-Scheduler : Timerlist
return
20guiclose:
   GUI 20:destroy
   GUI_timers_exist = 0
   gosub command_restore
return
gui_filltimers:
   timer_number = 0
   IniRead , Timers, %ini_file%, General, Timers, %A_Space%
   Sort Timers, U ND,
   if Timers <>
   {
      loop , parse, Timers , `,
      {
         if A_LoopField <>
         {
            timer_number += 1
            ScheduledTime := A_LoopField
            
            IniRead , timer_action, %ini_file%, %ScheduledTime%, Action, %A_Space%
            gosub command_get_msgaction
            IniRead , allow_cancel, %ini_file%, %ScheduledTime%, allow_cancel, %A_Space%
            IniRead , warning, %ini_file%, %ScheduledTime%, warning, %A_Space%
            IniRead , timer_message, %ini_file%, %ScheduledTime%, warning_message, %A_Space%
            IniRead , program, %ini_file%, %ScheduledTime%, program, %A_Space%
            IniRead , path_program, %ini_file%, %ScheduledTime%, path_program, %A_Space%
            IniRead , WorkingDir, %ini_file%, %ScheduledTime%, WorkingDir, %A_Space%
            outputdebug %number% %ScheduledTime% %timer_action% %timer_message%
            FormatTime , timer_time, %A_LoopField%, yyyy-MM-dd HH:mm
            GUI 20:Add, Text, xs section, %timer_time%
            GUI 20:Add, Text, xs110 w90 ys, %timer_action%         
            if timer_message <>
            {
               if timer_action = action11
                  msg_action = Pop up         
               else
                  msg_action = %msg_action% / Pop up
               GUI 20:Add, Text, xs310 w100 ys r1, %timer_message%
            }
            if program <> 0
            {
               splitpath , path_program , path_prog
               GUI 20:Add, Text, xs415 w100 ys r1, %path_prog%
               msg_action = %msg_action% / run program
            }
            if program_close <> 0
            {
               splitpath , path_program_close , path_prog
               GUI 20:Add, Text, xs415 w100 ys r1, %path_prog%
               msg_action = %msg_action% / close program
            }
            else
               GUI 20:Add, Text, xs415 w100 ys, -
            GUI 20:Add, Text, xs110 w180 ys, %msg_action%         
            if repeat <> 0
            {
               GUI 20:Add, Text, xs520 ys w90 , *placeholder*
            }
            GUI 20:Add, Button, ys-5 gcancel_timer v%ScheduledTime%, Cancel timer
            if allow_cancel = 0
               GUIControl 20:disable, %ScheduledTime%
         }
         if timer_number = 0
            GUI 20:Add, Text, xs section, - empty -
      }
   }
   GUIControl 20:Show,timerlist,   
return

cancel_timer:
   if A_GuiControl = cancel_all_timers
   {
      MsgBox , 4, , You are about to cancel all timers.`nAre you sure?
         IfMsgBox No
            return
         else
            IniWrite , %A_Space%, %ini_file%, General, Timers   ; -- empties the timers-list in the ini-file, effectively deleting all timers
   }
   else
   {
      MsgBox , 4, , You are about to cancel a timer.`nAre you sure?
         IfMsgBox No
            return
         else
         {
            stringreplace , Timers , Timers, %A_GuiControl%`,   ; -- prunes the selected timer from the timers list
            IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
            IniDelete , %ini_file%, %A_GuiControl%            ; -- deletes the section of the one timer
         }
   }
   GUI 20:destroy
   gosub gui_timers
return
; -- enters the right actions in the timers menu
command_get_msgaction:
   msg_action :=
   if timer_action = action1
      msg_action = %text_action1%
   if timer_action = action2
      msg_action = %text_action2%
   if timer_action = action3
      msg_action = %text_action3%
   if timer_action = action4
      msg_action = %text_action4%
   if timer_action = action5
      msg_action = %text_action5%
   if timer_action = action6
      msg_action = %text_action6%
   if timer_action = action7
      msg_action = %text_action7%
   if timer_action = action8
      msg_action = %text_action8%
   if timer_action = action9
      msg_action = %text_action9%
   if timer_action = action10
      msg_action = %text_action10%
   if timer_action = action11
      msg_action = %text_action11%
return
; -- saves last selected action in the ini-file
caction:
   GUI 10:Submit, nohide
   chosen_action := A_GuiControl
   IniWrite , %chosen_action%, %ini_file%, General, last_action
return

list_txt:
   text_action1 =   Log off
   text_action2 =   Reboot
   text_action3 =   Shutdown
   text_action4 =   Power off
   text_action5 =   Standby
   text_action6 =   Hibernate
   text_action7 =   Lock Windows
   text_action8 =   Turn off monitor
   text_action9 =   Turn on monitor
   text_action10 =   Screensaver
   text_action11 =   No Action
return

command_action:
   Outputdebug (%A_LineNumber%) command_action start
   if chosen_action = action1
      Shutdown 0
   if chosen_action = action2
      Shutdown 2
   if chosen_action = action3
      Shutdown 1
   if chosen_action = action4
      Shutdown 8
   if chosen_action = action5
      DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
   if chosen_action = action6
      DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
   if chosen_action = action7
      Send #l
   if chosen_action = action8
      SendMessage , 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
   if chosen_action = action9
      SendMessage , 0x112, 0xF170, -1,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
   if chosen_action = action10
      SendMessage , 0x112, 0xF140, 0,, Program Manager  ; 0x112 is WM_SYSCOMMAND, and 0xF140 is SC_SCREENSAVE.
   if program = 1
   {
      if WorkingDir =
         SplitPath , path_program , , WorkingDir
      run %path_program%, %WorkingDir%
   }
   if when <> 1      ; -- when = 1 = immediate, then a popup would make no sense
   {
      if warning = 1
      {
         msgbox Alert! %warning_message%
      }
   }
return

command_hide:
   GUI 10:destroy
return
command_restore:
   gosub GUI_start
return

bschedule:
   ;GUI 2:+owner ;+sysmenu
   gosub command_hide
   SetTimer , timer_update_time , 1000
   
   GUI 2:Add, GroupBox, w170 h110 section, Scheduler
   GUI 2:Add, Text, xs+10 ys+21 w60 h20 section, Start Time:
   GUI 2:Add, DateTime, ys-2 w80 vStartTime 1, HH:mm ;time
   GUI 2:Add, Text, xs w60 hp section, Start Date:
   GUI 2:Add, DateTime, ys-2 w80 vStartDate , yyyy-MM-dd
   GUI 2:Add, Text, xs w80 hp section, Current Time:
   GUI 2:Add, Text, xs+72 ys w70 left vcurrent_time, %A_Hour%:%A_Min%:%A_Sec%
   GUI 2:Add, Text, xs ys+15 w70 hp section, Current Date:
   GUI 2:Add, Text, xs+72 w70 ys left vcurrent_date, %A_YYYY%-%A_MM%-%A_DD%

   GUI 2:Add, GroupBox, x10 h46 w170 section , Repeat
   GUI 2:Add, Text, xs+10 ys+21 w30 h20, Every
   GUI 2:Add, Edit, xs+45 ys+19 w45 hp limit3 vrepeat_amount disabled,
   GUI 2:Add, UpDown
   GUI 2:Add, ComboBox, xs+95 ys+19 w65 choose1 vrepeat_count disabled, minute|hour|day|week|month|year
   ;GUI 2:Add, Text, xs+10 ys+21 w30 h20, Until
   ;GUI 2:Add, DateTime, ys-2 w80 vEndDate , yyyy-MM-dd
   
   GUI 2:Add, GroupBox, x10 h46 w170 section, Waarschuwingsbericht
   GUI 2:Add, Checkbox, xs+10 ys+21 w15 gdwarning vwarning h18 section,
   GUI 2:Add, Edit, disabled xs+25 ys-2 w125 h20 vwarning_message , %warning_message%
   if warning = 1
   {
      GUIControl , 2: , warning , 1
      GUIControl , 2:enable , warning_message
   }

   GUI 2:Add, Button, gschedule_cancel xm w78 section, &Cancel
   GUI 2:Add, Button, gschedule_ok ys wp Default, &OK
   GUI 2:Show,, AHK-Scheduler : Scheduler
return
schedule_ok:
   GUI 2:Submit, nohide
   Stringmid, YYYY   ,StartDate,1,4   ;Year
   Stringmid, MM   ,StartDate,5,2   ;Month
   Stringmid, DD   ,StartDate,7,2   ;Day
   Stringmid, Hour   ,StartTime,9,2   ;hour
   Stringmid, Min   ,StartTime,11,2 ;minute
   ScheduledTime   =   %YYYY%%MM%%DD%%Hour%%Min%00
   SetTimer , timer_update_time , Off
   if warning = 1
      IniWrite , %warning_message%, %ini_file%, General, warning_message
schedule_cancel:
   GUI 2:destroy
   gosub command_restore
return
dwarning:
   GUI submit, nohide
   if warning = 1
   {
      GUIControl , 2:enable , warning_message
      GUIControl , 2:focus , warning_message
      GUIControl , 3:enable , warning_message
      GUIControl , 3:focus , warning_message
      IniWrite , 1, %ini_file%, General, warning
   }
   else
   {
      GUIControl , 2:disable , warning_message
      GUIControl , 3:disable , warning_message
      IniWrite , 0, %ini_file%, General, warning
   }
return

timer_update_time:
   GUIControl , 2: , current_time, %A_Hour%:%A_Min%:%A_Sec%
   GUIControl , 2: , current_date, %A_YYYY%-%A_MM%-%A_DD%
return

btimer:
   ;GUI 3:+owner ;+sysmenu
   gosub command_hide

   GUI 3:Add, GroupBox, w170 h125 section, Timer
   GUI 3:Add, Text, xs+10 ys+21 w60 h20 section, Countdown:
   GUI 3:Add, Edit, ys-2 w80 gtimed_update vtimer_amount 1 right,
   GUI 3:Add, UpDown
   GUI 3:Add, Radio, xs vtimer_selection gtimed_update yp+21 w55 hp Checked, &minutes
   GUI 3:Add, Radio, xp yp+21 gtimed_update wp hp, &days
   GUI 3:Add, Radio, xs+70 yp-21 gtimed_update wp hp, &hours
   GUI 3:Add, Radio, xp yp+21 gtimed_update wp hp, &weeks

   GUI 3:Add, Text, xs w80 hp section, Timed Time:
   GUI 3:Add, Text, xs+72 ys w70 left vtimed_time, %A_Hour%:%A_Min%
   GUI 3:Add, Text, xs ys+15 w70 hp section, Timed Date:
   GUI 3:Add, Text, xs+72 w70 ys left vtimed_date, %A_YYYY%-%A_MM%-%A_DD%

   GUI 3:Add, GroupBox, x10 h46 w170 section, Repeat
   GUI 3:Add, Text, xs+10 ys+21 w30 h20, Every
   GUI 3:Add, Edit, xs+45 ys+19 w45 hp limit3 vrepeat_amount disabled,
   GUI 3:Add, UpDown
   GUI 3:Add, ComboBox, xs+95 ys+19 w65 choose1 vrepeat_count disabled, minute|hour|day|week|month|year
   
   GUI 3:Add, GroupBox, x10 h46 w170 section, Waarschuwingsbericht
   GUI 3:Add, Checkbox, xs+10 ys+21 w15 gdwarning vwarning h18 section,
   GUI 3:Add, Edit, disabled xs+25 ys-2 w125 h20 vwarning_message , %warning_message%
   if warning = 1
   {
      GUIControl , 3: , warning , 1
      GUIControl , 3:enable , warning_message
   }
   
   GUI 3:Add, Button, gtimer_cancel x10 w80 section, &Cancel
   GUI 3:Add, Button, gtimer_ok ys wp Default, &OK
   GUI 3:Show,, AHK-Scheduler : Timer
return
timed_update:
   GUI 3:Submit, nohide

   timed_date = %A_Now%
   
   if timer_selection = 1   ; - minutes
      timed_date += timer_amount, Minutes
   if timer_selection = 2   ; - days
      timed_date += timer_amount, Days
   if timer_selection = 3   ; - hours
      timed_date += timer_amount, Hours
   if timer_selection = 4    ; - weeks
   {
      timer_amount := timer_amount * 7
      timed_date += timer_amount, Days
   }
   Stringmid, timed_YYYY   ,timed_date,1,4   ;Year
   Stringmid, timed_MM      ,timed_date,5,2   ;Month
   Stringmid, timed_DD      ,timed_date,7,2   ;Day
   Stringmid, timed_hour   ,timed_date,9,2   ;hour
   Stringmid, timed_min   ,timed_date,11,2 ;minute
   
   GUIControl , 3: , timed_time, %timed_Hour%:%timed_Min%
   GUIControl , 3: , timed_date, %timed_YYYY%-%timed_MM%-%timed_DD%
   
   ScheduledTime   =   %timed_YYYY%%timed_MM%%timed_DD%%timed_hour%%timed_min%00
   Outputdebug (%A_LineNumber%) Counter:  ScheduledTime   =   %ScheduledTime%
return
timer_ok:
   gosub timed_update
timer_cancel:
   GUI 3:destroy
   gosub command_restore
return

bprocess:
   ;GUI 4:+owner ;+sysmenu
   gosub command_hide
   GUI 4:Add, Text, w70 section, Process:
   GUI 4:Add, Edit, ys w105 vselected_process ,
   GUI 4:Add, Button, ys-1 w50 gcommand_showprocesses, ...
   GUI 4:Add, Button, gprocess_cancel xm w78 section, &Cancel
   GUI 4:Add, Button, gprocess_ok ys wp Default, &OK
   GUI 4:Show,, AHK-Scheduler : Process
return
process_ok:
   GUI 4:Submit, nohide
process_cancel:
   GUI 4:destroy
   gosub command_restore
return

bmessage:
   ;GUI 5:+owner ;+sysmenu
   gosub command_hide
   GUI 5:Add, Edit, w170 h170 vwarning_message , %warning_message%
   GUI 5:Add, Button, gmessage_cancel xm w78 section, &Cancel
   GUI 5:Add, Button, gmessage_ok ys wp Default, &OK
   GUI 5:Show,, AHK-Scheduler : Warning Message
return
message_ok:
   GUI 5:Submit, nohide
   IniWrite , %warning_message%, %ini_file%, General, warning_message
message_cancel:
   GUI 5:destroy
   gosub command_restore
return

bprogram:
   ;GUI 6:+owner ;+sysmenu
   gosub command_hide
   GUI 6:Add, Text, w70 section, Program to run:
   GUI 6:Add, Edit, ys w105 vrun_program , %path_program%
   GUI 6:Add, Button, ys-1 w50 gprogram_browse, Browse
   GUI 6:Add, Text, xs 70 section, Start from:
   GUI 6:Add, Edit, ys w105 vrun_program_path , %WorkingDir%
   GUI 6:Add, Button, ys-1 w50 gprogram_browse_workingdir, Browse
   GUI 6:Add, Button, gprogram_cancel xm w78 section, &Cancel
   GUI 6:Add, Button, gprogram_ok ys wp Default, &OK
   GUI 6:Show,, AHK-Scheduler : Program
return
program_browse:
   FileSelectFile , path_program , 3, C:, ,
   SplitPath , path_program , , WorkingDir
   WorkingDir = %WorkingDir%\
   GUIControl , 6:,run_program, %path_program%
   GUIControl , 6:,run_program_path, %WorkingDir%
return
program_browse_workingdir:
   FileSelectFolder , WorkingDir , %program_path%, ,
   GUIControl , 6:,run_program_path, %WorkingDir%
return
program_ok:
   GUI 6:Submit, nohide
   IniWrite , %path_program%, %ini_file%, General, path_program
   IniWrite , %WorkingDir%, %ini_file%, General, run_program_path
program_cancel:
   GUI 6:destroy
   gosub command_restore
return

bprogram_close:
   ;GUI 16:+owner ;+sysmenu
   gosub command_hide
   GUI 16:Add, Text, w70 section, Program to close:
   GUI 16:Add, Edit, ys w105 vrun_program_close , %path_program_close%
   GUI 16:Add, Button, ys-1 w50 gprogram_close_browse, Browse
   GUI 16:Add, Text, xs 70 section, Start from:
   GUI 16:Add, Edit, ys w105 vrun_program_close_path , %WorkingDir%
   GUI 16:Add, Button, ys-1 w50 gprogram_close_browse_workingdir, Browse
   GUI 16:Add, Button, gprogram_close_cancel xm w78 section, &Cancel
   GUI 16:Add, Button, gprogram_close_ok ys wp Default, &OK
   GUI 16:Show,, AHK-Scheduler : program_close
return
program_close_browse:
   FileSelectFile , path_program_close , 3, C:, ,
   SplitPath , path_program_close , , WorkingDir
   WorkingDir = %WorkingDir%\
   GUIControl , 16:,run_program_close, %path_program_close%
   GUIControl , 16:,run_program_close_path, %WorkingDir%
return
program_close_browse_workingdir:
   FileSelectFolder , WorkingDir , %program_close_path%, ,
   GUIControl , 16:,run_program_close_path, %WorkingDir%
return
program_close_ok:
   GUI 16:Submit, nohide
   IniWrite , %path_program_close%, %ini_file%, General, path_program_close
   IniWrite , %WorkingDir%, %ini_file%, General, run_program_close_path
program_close_cancel:
   GUI 16:destroy
   gosub command_restore
return

cwarning:
   GUI submit, nohide
   if warning = 1
   {
      GUIControl , enable , bmessage
      GUIControl , +default, bmessage
      GUIControl , focus , bmessage
      IniWrite , 1, %ini_file%, General, warning
   }
   else
   {
      GUIControl , disable , bmessage
      IniWrite , 0, %ini_file%, General, warning
   }
return
cprogram:
   GUI submit, nohide
   if program = 1
   {
      GUIControl , enable , bprogram
      GUIControl , +default, bprogram
      GUIControl , focus , bprogram
      IniWrite , 1, %ini_file%, General, program
   }
   else
   {
      GUIControl , disable , bprogram
      IniWrite , 0, %ini_file%, General, program
   }
return
cprogram_close:
   GUI submit, nohide
   if program_close = 1
   {
      GUIControl , enable , bprogram_close
      GUIControl , +default, bprogram_close
      GUIControl , focus , bprogram_close
      IniWrite , 1, %ini_file%, General, program_close
   }
   else
   {
      GUIControl , disable , bprogram_close
      IniWrite , 0, %ini_file%, General, program_close
   }
return
callow_cancel:
   GUI submit, nohide
   if allow_cancel = 1
      IniWrite , 1, %ini_file%, General, allow_cancel
   else
      IniWrite , 0, %ini_file%, General, allow_cancel
return
cwhen:
   GUI submit, nohide
   if when = 2
   {
      scheduler = 1
      GUIControl ,10:enable , bschedule
      GUIControl ,10:+default, bschedule
      GUIControl ,10:focus , bschedule
      GUIControl ,10: , &Scheduled , 1
   }
   else
   {
      GUIControl ,10:disable , bschedule
      scheduler = 0
   }
   if when = 3
   {
      timer = 1
      GUIControl ,10:enable , btimer
      GUIControl ,10:+default, btimer
      GUIControl ,10:focus , btimer
      GUIControl ,10: , &Countdown , 1
   }
   else
   {
      GUIControl ,10:disable , btimer
      timer = 0
   }
   if when = 4
   {
      process = 1
      GUIControl ,10:enable , bprocess
      GUIControl ,10:+default, bprocess
      GUIControl ,10:focus , bprocess
      GUIControl ,10: , &After a process stops , 1
   }
   else
   {
      GUIControl ,10:disable , bprocess
      process = 0
   }
   IniWrite , %when%, %ini_file%, General, when
return

function_menu:
   IfExist , %A_WorkingDir%\ahk-scheduler.ico
      Menu , Tray, Icon, %A_WorkingDir%\ahk-scheduler.ico
   Menu , Tray, NoStandard
   Menu , Tray, Tip , AHK-Scheduler
   Menu , Tray, Add , Open AHK-Scheduler %version%, GUI_start
   Menu , Tray, Default, Open AHK-Scheduler %version%

   Menu , Tray, Add,
   Menu , Tray, Add, Reload, command_reload
   Menu , Tray, Add, Exit, command_exit
return

command_exit:
   exitapp
return

command_reload:
   Reload
return

ButtonQuit:
GuiClose:
ButtonHide:
   GUI Destroy
   return
   
10ButtonOK:
   GUI submit, nohide
   Action :=
   if chosen_action =
      chosen_action = action11
   if program_close = 1
   {
      msgbox program_close = 1
   }
   if program   =   0   ; -- needed to circumvent an error about run function needing arguments
   {
      path_program = placeholder
      WorkingDir   = placeholder
   }
   if when = 1      ; -- when = immediate
   {
      gosub command_action
   }
   else
   {
      if timer_free > 10
      {
         MsgBox, 4,, All 10 timer-slots are taken, please cancel any timers before making a new one.
         return
      }
      if warning = 0
      {
         if program = 0
         {
            if chosen_action = action11
            {
               MsgBox, 4,, No action, warning or program has been set to run when this timer runs out. `n`nDo you still want to continue?
               IfMsgBox No
                  return
               else
                  gosub function_delayed_action
            }
         }
      }
      else
         gosub function_delayed_action
   }
   GUI Destroy   
return

program_closeMain:
return

function_delayed_action:
   Outputdebug (%A_LineNumber%) function_delayed_action start
   Timers = %ScheduledTime%,%Timers%
   gosub ini_write_timer
   Outputdebug (%A_LineNumber%) function_delayed_action : Timers: %Timers%
   gosub command_delayed_action
return

ini_write_timer:
   Outputdebug (%A_LineNumber%) ini_write_timer start ( ScheduledTime : %ScheduledTime% )
   Sort Timers, U ND,
   IniWrite , %Timers%, %ini_file%, General, Timers   ; -- appends the timer time to the list of timers
   IniWrite , %ScheduledTime%, %ini_file%, %ScheduledTime%, ScheduledTime
   IniWrite , %chosen_action%, %ini_file%, %ScheduledTime%, Action
   IniWrite , %warning%, %ini_file%, %ScheduledTime%, warning
   IniWrite , %warning_message%, %ini_file%, %ScheduledTime%, warning_message
   IniWrite , %program%, %ini_file%, %ScheduledTime%, program
   IniWrite , %path_program%, %ini_file%, %ScheduledTime%, path_program
   IniWrite , %WorkingDir%, %ini_file%, %ScheduledTime%, WorkingDir
   IniWrite , %allow_cancel%, %ini_file%, %ScheduledTime%, allow_cancel
   GoSub ini_read
   gosub function_parse_timers
return

command_start_timers:
   Outputdebug (%A_LineNumber%) command_start_timers start
command_delayed_action:
   Outputdebug (%A_LineNumber%) command_delayed_action start
   if ( current_timer = 1 )
   {
      deadline_1    = %ScheduledTime%
      action_1   = %warning_message%
      settimer , command_timer_1, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_1 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%)
   }
   if ( current_timer = 2 )
   {
      deadline_2 = %ScheduledTime%
      action_2   = %warning_message%
      settimer , command_timer_2, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_2 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( current_timer = 3 )
   {
      deadline_3 = %ScheduledTime%
      action_3   = %warning_message%
      settimer , command_timer_3, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_3 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( current_timer = 4 )
   {
      deadline_4 = %ScheduledTime%
      settimer , command_timer_4, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_4 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( current_timer = 5 )
   {
      deadline_5 = %ScheduledTime%
      settimer , command_timer_5, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_5 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( current_timer = 6 )
   {
      deadline_6 = %ScheduledTime%
      settimer , command_timer_6, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_6 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( timer_free = 7 ) OR ( current_timer = 7 )
   {
      deadline_7 = %ScheduledTime%
      settimer , command_timer_7, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_7 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( timer_free = 8 ) OR ( current_timer = 8 )
   {
      deadline_8 = %ScheduledTime%
      settimer , command_timer_8, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_8 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( timer_free = 9 ) OR ( current_timer = 9 )
   {
      deadline_9 = %ScheduledTime%
      settimer , command_timer_9, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_9 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if ( timer_free = 10 ) OR ( current_timer = 10 )
   {
      deadline_10 = %ScheduledTime%
      settimer , command_timer_10, 1000
      Outputdebug (%A_LineNumber%) command_delayed_action command_timer_10 : started (%ScheduledTime% - %chosen_action% - %warning% - %warning_message% - %program% - %path_program% - %WorkingDir%))
   }
   if timer_free > 10
      MsgBox , All 10 timer-slots are taken, please cancel any timers before making a new one.
return

; -- this command is invoked when a timer runs out, it re-calculates the available timers
command_restart:
   gosub function_get_timer_total   ; -- to update the timer-count on the main GUI
   if GUI_timers_exist = 1      ; -- to update the timer-list, if that is open
   {
      gosub 20guiclose
      gosub gui_timers
   }
return
; -- this command makes and runs a batch file to restart tckr, to prevent the memleak and re-sort the timers
command_restart2:
   Outputdebug (%A_LineNumber%) command_restart start
   ifexist tckr_restart.bat
      filedelete tckr_restart.bat
   FileAppend , %A_ScriptName%, tckr_restart.bat
   ifexist tckr_restart.bat
      run tckr_restart.bat , , Min
   else
      gosub command_restart
   exitapp
return

command_timers_off:
   Outputdebug (%A_LineNumber%) command_timers_off start : turning all timers off
   settimer , command_timer_1, off
   settimer , command_timer_2, off
   settimer , command_timer_3, off
   settimer , command_timer_4, off
   settimer , command_timer_5, off
   settimer , command_timer_6, off
   settimer , command_timer_7, off
   settimer , command_timer_8, off
   settimer , command_timer_9, off
   settimer , command_timer_10, off
return
   
; -- number each timer, using Func%A_Index%() to start each ?
command_getinfo:
   IniRead , chosen_action, %ini_file%, %deadline%, Action, %A_Space%
   IniRead , warning, %ini_file%, %deadline%, warning, %A_Space%
   IniRead , warning_message, %ini_file%, %deadline%, warning_message, %A_Space%
   IniRead , program, %ini_file%, %deadline%, program, %A_Space%
   IniRead , path_program, %ini_file%, %deadline%, path_program, %A_Space%
   IniRead , WorkingDir, %ini_file%, %deadline%, WorkingDir, %A_Space%
return

command_timer_1:
   if deadline_1 > %A_Now%
   {
      ;Outputdebug (%A_LineNumber%) command_timer_1 %deadline_1% > %A_Now% : %action_1%
      return
   }
   else
   {
      Outputdebug (%A_LineNumber%) command_timer_1 %deadline_1% <= %A_Now% : %action_1%
      deadline := deadline_1
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_1%`,
      IniDelete , %ini_file%, %deadline_1%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_1, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_2:
   if deadline_2 > %A_Now%
   {
      ;Outputdebug (%A_LineNumber%) command_timer_2 %deadline_2% > %A_Now% : %action_2%
      return
   }
   else
   {
      Outputdebug (%A_LineNumber%) command_timer_2 %deadline_2% <= %A_Now% : %action_2%
      deadline := deadline_2
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_2%`,
      IniDelete , %ini_file%, %deadline_2%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_2, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_3:
   if deadline_3 > %A_Now%
   {
      ;Outputdebug (%A_LineNumber%) command_timer_3 %deadline_3% > %A_Now% : %action_3%
      return
   }
   else
   {
      Outputdebug (%A_LineNumber%) command_timer_3 %deadline_3% <= %A_Now% : %action_3%
      deadline := deadline_3
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_3%`,
      IniDelete , %ini_file%, %deadline_3%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_3, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_4:
   if deadline_4 > %A_Now%
      return
   else
   {
      deadline := deadline_4
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_4%`,
      IniDelete , %ini_file%, %deadline_4%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_4, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_5:
   ;Outputdebug (%A_LineNumber%) command_timer_5 %deadline_5%
   if deadline_5 > %A_Now%
      return
   else
   {
      deadline := deadline_5
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_5%`,
      IniDelete , %ini_file%, %deadline_5%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_5, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_6:
   if deadline_6 > %A_Now%
      return
   else
   {
      deadline := deadline_6
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_6%`,
      IniDelete , %ini_file%, %deadline_6%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_6, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_7:
   if deadline_7 > %A_Now%
      return
   else
   {
      deadline := deadline_7
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_7%`,
      IniDelete , %ini_file%, %deadline_7%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_7, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_8:
   if deadline_8 > %A_Now%
      return
   else
   {
      deadline := deadline_8
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_8%`,
      IniDelete , %ini_file%, %deadline_8%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_8, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_9:
   if deadline_9 > %A_Now%
      return
   else
   {
      deadline := deadline_9
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_9%`,
      IniDelete , %ini_file%, %deadline_9%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_9, off
      timer_free -=1
      gosub command_restart
   }
return

command_timer_10:
   if deadline_10 > %A_Now%
      return
   else
   {
      deadline := deadline_10
      gosub command_getinfo
      gosub command_action
      stringreplace , Timers , Timers, %deadline_10%`,
      IniDelete , %ini_file%, %deadline_10%
      IniWrite , %Timers%, %ini_file%, General, Timers   ; -- prunes the list of timers
      settimer , command_timer_10, off
      timer_free -=1
      gosub command_restart
   }
return

command_getprocesses:
   d = `n ; string separator
   s := 4096 ; size of buffers and arrays (4 KB)

   Process, Exist ; sets ErrorLevel to the PID of this running script
   ; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
   h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
   ; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
   DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
   VarSetCapacity(ti, 16, 0) ; structure of privileges
   NumPut(1, ti, 0) ; one entry in the privileges array...
   ; Retrieves the locally unique identifier of the debug privilege:
   DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
   NumPut(luid, ti, 4, "int64")
   NumPut(2, ti, 12) ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
   ; Update the privileges of this process with the new access token:
   DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
   DllCall("CloseHandle", "UInt", h) ; close this process handle to save memory

   hModule := DllCall("LoadLibrary", "Str", "Psapi.dll") ; increase performance by preloading the libaray
   s := VarSetCapacity(a, s) ; an array that receives the list of process identifiers:
   c := 0 ; counter for process identifiers
   DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
   Loop, % r // 4 ; parse array for identifiers as DWORDs (32 bits):
   {
      id := NumGet(a, A_Index * 4)
      ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
      h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
      VarSetCapacity(n, s, 0) ; a buffer that receives the base name of the module:
      e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "UInt", s)
      DllCall("CloseHandle", "UInt", h) ; close process handle to save memory
      if (n && e) ; if image is not null add to list:
      {
         proc := n
         if proclist =
            proclist = %proc%,%ID%
         else
            proclist = %proclist%`n%proc%,%ID%
      }
   }
   DllCall("FreeLibrary", "UInt", hModule) ; unload the library to free memory
   Sort, proclist, C ; uncomment this line to sort the list alphabetically
   Loop , Parse, proclist, `n
   {
      Loop , Parse, A_LoopField, `,
      {
         if A_Index = 1
            proc := A_LoopField
         if A_Index = 2
            id := A_LoopField
      }
      LV_Add("",proc,id)
   }
   LV_ModifyCol()
return

command_showprocesses:
   GUI Add, ListView, r20 w700 vMyListView gMyProcesses, Process|PID
   GUIControl -Redraw, MyListView
   gosub command_getprocesses
   GUIControl , +Redraw, MyListView
   GUIControl Show,MyListView,
   GUI Show, Autosize NoActivate
return

MyProcesses:
   if A_GuiEvent = DoubleClick
   {
      LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
      msgbox You have selected process: %A_EventInfo% : "%RowText%"
   }
return