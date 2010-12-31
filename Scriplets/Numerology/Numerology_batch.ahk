;; Uses chaldean numerology

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


a:= i:= j:= y:= q:= 1
b:= k:= r:= 2
c:= g:= l:= s:= 3
d:= m:= t:= 4
e:= h:= n:= x:= 5
u:= v:= w:= 6
o:= z:= 7
f:= p:= 8

ifnotexist, Numerology.csv
  fileappend, Name1 Name2 Name3..`,1s`,Quality`,1d`,Quality`,1+2s`,Quality`,1+2d`,Quality`,1+2+3s`,Quality`,1+2+3d`,Quality`n,Numerology.csv
Loop, Read, Numerology.txt, Numerology.csv
{
  if (Instr(A_LoopReadLine,";")=1 or A_LoopReadLine="")
    continue
  NameIn := A_LoopReadLine
  ;; - NameIn is a Name
  FCount=1
  FTotal=0
  Loop,parse,NameIn
  {
   if A_LoopField=%A_Space%
      {
      FTotal%FCount%=%FTotal%
      FTotal=0
      FCount++
  	  continue
      }
   tvar := %A_LoopField%
   FTotal += tvar
  }
  FTotal%FCount% = %FTotal%
  ShowVar%FCount%=%ShowVar%
  tTotal=0
  Loop,%FCount%
   {
    tTotal += FTotal%A_Index%
    tTotal%A_Index% := tTotal
    tTotalQ%A_Index% := Quality(tTotal)
    sTotal%A_Index% := C2S(tTotal) ;Function to convert Coumpound number to single number
    sTotalQ%A_Index% := Quality(sTotal%A_Index%)
   }
  fileappend, %NameIn%`,%sTotal1%`,%sTotalQ1%`,%tTotal1%`,%tTotalQ1%`,%sTotal2%`,%sTotalQ2%`,%tTotal2%`,%tTotalQ2%`,%sTotal3%`,%sTotalQ3%`,%tTotal3%`,%tTotalQ3%`n
  Loop,4        ;Correct upto four names eg "isha ann john maniparambil"
    tTotal%A_Index% :=  sTotal%A_Index%:=  tTotalQ%A_Index%:=  sTotalQ%A_Index%:=  FTotal%A_Index%:=
}
return

; ---- FUNCTION TO RETRIEVE QUALITY OF THE CORRESPONDING NUMBER
Quality(tvar)
{
loop
  {
  if tvar<52
    break
  tvar -= 9
  }
if tvar in 2,4,8,11,12,13,16,18,22,26,29,35,38,43,44,47
  return -2
else if tvar in 20,28,31,40,49
  return -1
else if tvar in 14,17,30,39,48,51
  return 0
else if tvar in 1,3,5,9,10,15,21,25,27,32,34,36,41,45,50
  return 1
else if tvar in 6,7,19,23,24,33,37,42,46
  return 2
}



; ---- FUNCTION TO RETRIEVE DATA OF THE CORRESPONDING NUMBER
NumberData(tvar)
{
loop
  {
  if tvar<52
    break
  tvar -= 9
  }

if tvar=1
ret=Sun*Creative`, individual`, inventive`, obstinate views`, determined`, ambitious`, rise in profession`, leader.`nFortunate days`: Sunday and Monday`nColors`: Gold`, Yellow`, Bronze`nStones`: Topaz`, Amber`, Yellow Diamond	
else if tvar=2
ret=Moon (Feminine attributes of Sun)*Though opposite`, good combination with No.1 and less so with No.7 people.`nGentle`, imaginative`, artistic`, romantic. More mental than physical plane. Gaurd against being restless`, unsettled`, lack of continuity`, lack of self-confidence`, oversensitive.`nDays`:Sunday`, Monday`, Friday`nColors`:Green`, cream and white. Avoid darks`nStones:Jade`, Pearls`, Moonstones.
else if tvar=3
ret=Jupiter*Harmonies with 6 and 9.`nAmbitious`, rise in world`, control and athourity`, order and discipline`, hate restraint. Rise to high positions`, concienttious`, responsible. Gaurd against being Dictatorial`, pride.`nDays`:Thursday`, Friday`, Tuesday.`nColors`:Mauve`, Violet`, Purple`, Blue`nStone`:Amethyst.
else if tvar=4
ret=Uranus*It is the most unfortunate number after number 8. It is a non materialistic number`, too. It is best suited for service. This number is very good for straight forward dealings. By any standards`, it is the best number for reliability. It is a number of dreaming`, too. It should be never considered for business purposes. 
else if tvar=5
ret=Mercury*This number is most intelligent`, very shrewd`, cunning and diplomatic and cannot be taken for granted at its face value. This is the most deceitful and opportunistic number one must be careful of. No other number has got as much flexibility and tact as this number has got in attracting people towards it. It can always be considered for business purposes.
else if tvar=6
ret=Venus*It is a number of beauty and attraction and no other number has got as much beauty as this number. This number has an inherent magnetic power in itself and stands second after number 5 in attracting people. This number has a taste for everything that is costly and palatable. 
else if tvar=7
ret=Neptune*This number has a penchant for everything that is new and foreign. It has a philosophical touch in everything it does. It is the most mysterious number and has business acumen also.
else if tvar=8
ret=Saturn*It is a number of either successes or failures and has no middle path. It is the most unfortunate number in the sense that it is never understood properly and always misunderstood. It has got a penchant for all low category things and is classified as a number of loneliness and melancholy.
else if tvar=9
ret=Mars*It is a number of domination, control, degeneration and destruction. It has a liking for accidents and quarrels and is never tired of fighting. It is the most authoritative number after number 1.
else if tvar=10
ret=Wheel of Forturne*Honour`, faith`, self-confidence`, of rise and fall. Name will be known for good or evil`, according to ones desires. Plans likely to be carried out.
else if tvar=11
ret=Clenched Hand/Lion Muzzled*Ominous Number. Warnings of Hidden dangers`, trial`, treachery`, great difficulties
else if tvar=12
ret=Sacrifice of the Victim*Suffering and anxiety of mind`, sacrificed for the plans of others.
else if tvar=13
ret=Skeleton/Death*Upheaval and destruction. Power`, if wrongly used will cause destruction of self. Warning of unknown or unexpected.
else if tvar=14
ret=Movement`, Combination of people or things`, Danger from natural forces.Fortunate for dealing in money but risk attached`, due to actions of others. Act with caution.
else if tvar=15
ret=Person associated will use every art/magic to carry out thier purpose. Eloquence`, Music and art and dramatic personality`, voluptous temperament`, personal magnetism. Fortunate for getting money`, gifts.
else if tvar=16
ret=Tower struck by lightening*Warning of strange fatality`, accidents`, defeat.
else if tvar=17
ret=Star of Magi*Superior in spirit to trials. Number of immortality`, name lives after him. Fortunate if not associated with single number 4 and 8.
else if tvar=18
ret=Materialism striving to destroy the spiritual side. Bitter quarrels`, war`, social upheavals`, danger from elements`, treachery`, deception.
else if tvar=19
ret=Prince of heaven*Fortunate and extremely favourable. The number promises happiness`, success`, esteem`, honour and promises success.
else if tvar=20
ret=The Awakening/The Judgement*New purpose`, plans`, ambitions. Not material number`, doubtful worldly success. Delays`, hindrances to plans.
else if tvar=21
ret=The Universe*Fortunate number`, denoting advancements`, honours`, elevation in life`, general success. Victory after a long fight.
else if tvar=22
ret=Good man blinded by folly of others*Illusion and delusion. Fools paradise. Dreamer who awakens only when surrounded by danger. False judgement by the influence of others.
else if tvar=23
ret=Royal Star of the Lion*Promise of success`, help from superiors and protection from those in high places.
else if (tvar=24 or tvar=33 or tvar=42)
ret=Fortunate Number. It promises the assistance/association of those of rank and position. Gain through love and opposite sex.
else if (tvar=25 or tvar=34)
ret=Strength gained through experience. Not exactly lucky`, as success is given by strife and trials in earlier life. Favourable when regards future.
else if (tvar=26 or tvar=35 or tvar=44)
ret=Gravest warnings*Foreshadows disaster brought about by association with others`, bad advice and partnerships.
else if (tvar=27 or tvar=36 or tvar=45)
ret=The Sceptre*Good number`, promise of athourity`, power and command. Reward from productive intellect and creative faculties.
else if tvar=28
ret=Not Fortunate*Great promise and possibilities`, taken away unless he provides for the future. Loss through trust in others`, opposition`, law and likely to begin lifes road again and again.
else if (tvar=29 or tvar=38 or tvar=47)
ret=Grave warning*Uncertainities`,treachery and deception`, trials`, tribulations`, unexpected dangers`, unreliable friends and grief and deception caused by opposite sex.
else if (tvar=30 or tvar=39 or tvar=48)
ret=Thoughtful deduction`, retrospection`, mental superiority. Likely to put all material things on one side`, so niether fortunate nor unfortunate. Powerful but indifferent.
else if (tvar=31 or tvar=40 or tvar=49)
ret=Thoughtful deduction`, retrospection`, mental superiority`, self-contained`, lonely. Likely to put all material things on one side`, so not fortunate by worldly standards.
else if (tvar=32 or tvar=41 or tvar=50)
ret=Magical number. Fortunate if person holds own judgement`, otherwise wrecked by stupidity of others. Fortunate for future events.
else if (tvar=37 or tvar=46)
ret=Good and fortunate friendships in love and opposite sex. Also good in partnerships. Fortunate for future events.
else if tvar=43
ret=Unfortunate number*Symbolised by sign of revolution`, upheaval and failure.
else if tvar=51
ret=Warrior*Promises sudden advancement in whatever one undertakes. Favourable for military life or leaders. Similarly, threatens enemies, danger and likely assasination.

return ret
}

; ---- Function to convert Coumpound number to single number
C2S(Nmbr)
{
  Loop									;Loop to convert compound number to single number
  {
   Length := StrLen(Nmbr)
   ret=0
   if Length>1
   {
     Loop, Parse, Nmbr
  		 ret := ret + A_LoopField
     Nmbr = %ret%
   }
   else
        break
  }
  return Nmbr
}

MainAbout:
Msgbox,,Numerology,Numerology v1.021`n(Based on Cheiro's Numerology)%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%`n`n`n(c) Shajul Georje, 2005.`ndr_shajul@yahoo.co.in


