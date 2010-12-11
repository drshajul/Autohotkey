#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
play;887
pause;888
play/pause;889
stop;890
Frame Forward;891
Frame Backward;892
Increase Rate;895
Decrease rate;894
Audio Delay +10ms;905
Audio Delay -10ms;906
Jump Forward Small;900
Jump Backward Small;899
Jump Forward Medium;902
Jump Backward Medium;901
Jump Forward Large;904
Jump Backward Large;903
Jump Forward Keyframe;898
Jump Backward Keyframe;897
Next;921
Previous;920
Next Playlist Item;919
Previous Playlist Item;918
Toggle Caption & Menu;817
Toggle Seeker;818
Toggle Controls;819
Toggle Information;820
Toggle Statistics;821
Toggle Status;822
Toggle SubResync Bar;823
Toggle Playlist;824
Toggle Capture Bar;825
View Minimal;827
View Compact;828
View Normal;829
Fullscreen;830
Fullscreen (no res change);831
zoom 50%;832
zoom 100%;833
zoom 200%;834
Always on Top;884
Volume Up;907
Volume Down;908
Volume Mute;909
DVD Title Menu;922
DVD Root Menu;923
DVD Menu Activate(Enter);932
DVD Menu Left;928
DVD Menu Right;929
DVD Menu Up;930
DVD Menu Down;931
DVD Menu Back;933
Filters Menu;950
Player Menu (long);949
Player Menu (short);948
Boss Button;943
DVD Menu Leave;934
DVD Chapter Menu;927
DVD Angle Menu;926
DVD Audio Menu;925
Subs On/Off;955
Previous Subtitle;954
Next Subtitle;953
Previous Audio;952
Next Audio;951
Next Subtitle DVD;964
Previous Audio DVD;963
Next Audio DVD;962
Previous Angle DVD;961
Next Angle DVD;960
Previous Subtitle .OGM;959
Next Subtitle .OGM;958
Previous Audio .OGM;957
Next Audio .OGM;956
Reload Subtitles;973
Subtitles On/Off DVD;966
Previous Subtitle DVD;965
DVD Menu Subtitle;924
Options;886
Exit;816 
*/

var TBM_GETPOS = 0x400;
var MPC_COM = 0x111;
var MPC_VOLUP = 907;
var MPC_VOLDW = 908;
var MPC_MUTE = 909;
var MPC_PLAYPAUSE = 889;
var MPC_STOP = 890;
var MPC_JPBCKMED = 901;
var MPC_JPFORMED = 902;
var MPC_JPBCKLAR = 903;
var MPC_JPFORLAR = 904;
var MPC_RESET = 861;
var MPC_INC_SIZE = 862;
var MPC_INC_WIDTH = 864;
var MPC_INC_HEIGHT = 866;
var MPC_DEC_SIZE = 863;
var MPC_DEC_WIDTH = 865;
var MPC_DEC_HEIGHT = 867;
var MPC_FULL_SCR = 830;
Return

^+#F3::
ControlMPC(MPC_JPFORMED)
return
;; 			SendMessage( mpcwh, MPC_COM, MPC_JPFORMED, 0 );

ControlMPC(COMMAND) {
global MPC_COM
SendMessage, %MPC_COM%, %COMMAND%, 0, , ahk_class MediaPlayerClassicW
If Errorlevel = FAIL
  Return Errorlevel
Else
  Return := ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel
}