
CLR_LoadLibrary(sLibrary, pAppDomain=0)
{
    if !(pApp := pAppDomain ? pAppDomain : CLR_GetDefaultDomain())
        return 0
    if p_App := COM_QueryInterface(pApp,"{05F696DC-2B29-3663-AD8B-C4389CF2A713}")
    {
        psLib := COM_SysAllocString(sLibrary)

        ; Attempt to load by full name (incl. Version, Culture & PublicKeyToken) first.
        hr:=DllCall(NumGet(NumGet(p_App+0)+176),"uint",p_App,"uint",psLib,"uint*",pAsm)

        if (hr!=0 or !pAsm)
        {
            ; Get typeof(Assembly) for calling static methods. (p_App->GetType()->Assembly->GetType())
            DllCall(NumGet(NumGet(p_App+0)+40),"uint",p_App,"uint*",p_Type)
           ,DllCall(NumGet(NumGet(p_Type+0)+80),"uint",p_Type,"uint*",p_Asm)
           , COM_Release(p_Type)
           ,DllCall(NumGet(NumGet(p_Asm+0)+40),"uint",p_Asm,"uint*",p_Type)
           , COM_Release(p_Asm)
            
            ; Initialize VARIANTs & SAFEARRAY(VARIANT) for method args.
           ,VarSetCapacity(vArg,16,0), NumPut(8,vArg), NumPut(psLib,vArg,8)
           ,VarSetCapacity(vRet,16,0)
           ,VarSetCapacity(rArgs,24,0), NumPut(1,NumPut(&vArg,NumPut(16,NumPut(1,rArgs))+4))
            
            ; Attempt to load from file.  Does not use IfExist since LoadFrom probably doesn't use A_WorkingDir (exclusively or at all).
           ,hr:=DllCall(NumGet(NumGet(p_Type+0)+228),"uint",p_Type
                ,"uint",pws:=COM_SysAllocString("LoadFrom"),"int",0x118
                ,"uint",0,"int64",1,"int64",0,"uint",&rArgs,"uint",&vRet)
           ,COM_SysFreeString(pws)
            
            if (hr!=0 or !NumGet(vRet,8))  ; Attempt to load using partial name.
                hr:=DllCall(NumGet(NumGet(p_Type+0)+228),"uint",p_Type
                    ,"uint",pws:=COM_SysAllocString("LoadWithPartialName")
                    ,"int",0x118,"uint",0,"int64",1,"int64",0,"uint",&rArgs,"uint",&vRet)
                ,COM_SysFreeString(pws)
            
            ; If successful, vRet should be of type VT_DISPATCH.
            pAsm := hr ? 0 : NumGet(vRet,8)
            
            COM_Release(p_Type)
        }
        COM_SysFreeString(psLib)
        COM_Release(p_App)
    }
    if (pAppDomain != pApp)
        COM_Release(pApp)
    return pAsm ? COM_Enwrap(pAsm) : ""
}

CLR_CreateObject(Assembly, TypeName, prm0="vT_NoNe", prm1="vT_NoNe", prm2="vT_NoNe", prm3="vT_NoNe", prm4="vT_NoNe", prm5="vT_NoNe", prm6="vT_NoNe", prm7="vT_NoNe", prm8="vT_NoNe", prm9="vT_NoNe")
{
    if (prm0=="vT_NoNe")
        return COM_Invoke(Assembly, "CreateInstance", TypeName)
    
    ; Code based heavily on COM_L.ahk by Sean:
    VarSetCapacity(varg,160), nParams:=10
    static sParams:="0123456789"
	Loop, Parse, sParams
	if (prm%A_LoopField%=="vT_NoNe")
	{
	 	nParams:=A_Index-1
		Break
	}
	Else If	prm%A_LoopField% is integer
		NumPut(SubStr(prm%A_LoopField%,1,1)="+" ? 9 : prm%A_LoopField%=="-0" ? (prm%A_LoopField%:=0x80020004)*0+10 : 3, NumPut(prm%A_LoopField%,varg,168-16*A_Index,"int64"), -16)
	Else If	IsObject(prm%A_LoopField%)
		typ:=prm%A_LoopField%["typ_"], prm:=prm%A_LoopField%["prm_"]
        , NumPut(typ==8 ? CLR_BSTR(prm%A_LoopField%,prm) : prm, NumPut(typ,varg,160-16*A_Index), 4, "int64")
	Else NumPut(CLR_BSTR(prm%A_LoopField%,prm%A_LoopField%), NumPut(8,varg,160-16*A_Index), 4)
    
    VarSetCapacity(aArgs,24,0), NumPut(&varg+160-16*nParams,NumPut(16,NumPut(1,aArgs,0,"Ushort")+2)+4), NumPut(nParams,aArgs,16)
    static ArrayEmpty, saE
    ArrayEmpty ? "" : VarSetCapacity(saE,24,0), NumPut(16,NumPut(0x120001,saE)), ArrayEmpty := COM_Parameter(0x200C,&saE)
    return COM_Invoke(Assembly, "CreateInstance_3", TypeName, 0, 0, "+0", COM_Parameter(0x200C,&aArgs), "+0", ArrayEmpty)
}

CLR_CompileC#(Code, References, pAppDomain=0, FileName="", CompilerOptions="")
{
    return CLR_CompileAssembly(Code, References, "System", "Microsoft.CSharp.CSharpCodeProvider", pAppDomain, FileName, CompilerOptions)
}

CLR_CompileVB(Code, References, pAppDomain=0, FileName="", CompilerOptions="")
{
    return CLR_CompileAssembly(Code, References, "System", "Microsoft.VisualBasic.VBCodeProvider", pAppDomain, FileName, CompilerOptions)
}

CLR_StartDomain(ByRef pAppDomain, BaseDirectory="")
{
    RtHst:=CLR_Start(), pAppDomain:=0
    if (BaseDirectory!="")    ; AppDomainSetup.ApplicationBase = BaseDirectory;
        DllCall(NumGet(NumGet(RtHst+0)+72),"uint",RtHst,"uint*",puSetup)
        ,pSetup := COM_QueryInterface(puSetup, "{27FFF232-A7A8-40DD-8D4A-734AD59FCD41}")
        ,DllCall(NumGet(NumGet(pSetup+0)+16),"uint",pSetup,"uint",CLR_BSTR(ws,BaseDirectory))
        ,COM_Release(pSetup)
    else
        puSetup := 0
    hr:=DllCall(NumGet(NumGet(RtHst+0)+68),"uint",RtHst ,"uint*",0,"uint",puSetup,"uint",0,"uint*",pAppDomain)
    if puSetup
        COM_Release(puSetup)
    return hr
}

CLR_StopDomain(pAppDomain)
{
    RtHst:=CLR_Start()
    return DllCall(NumGet(NumGet(RtHst+0)+80),"uint",RtHst,"uint",pAppDomain)
}

;
; INTERNAL FUNCTIONS
;

; Note: Absence of error-checking before invoking RtHst should be OK
; as NumGet will detect it, return "" and cause DllCall to safely fail.

CLR_Start() ; returns ICorRuntimeHost*
{
    static RtHst
    return RtHst ? RtHst : (RtHst:=COM_CreateObject("CLRMetaData.CorRuntimeHost","{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"), DllCall(NumGet(NumGet(RtHst+0)+40),"uint",RtHst))
}

CLR_GetDefaultDomain() ; returns IUnknown*
{
    static pApp
    if pApp=
        RtHst:=CLR_Start(), DllCall(NumGet(NumGet(RtHst+0)+52),"uint",RtHst,"uint*",pApp)
    return pApp
}

CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, pAppDomain=0, FileName="", CompilerOptions="")
{
    if !(pApp := pAppDomain ? pAppDomain : CLR_GetDefaultDomain())
        return 0
    
    if asmProvider := CLR_LoadLibrary(ProviderAssembly, pApp)
        asmSystem := ProviderAssembly="System" ? asmProvider : CLR_LoadLibrary("System",pApp)
    if (pAppDomain != pApp)
        COM_Release(pApp) ; Clean up unmanaged reference.
    if !asmProvider
        return 0
    
    if !(codeProvider := asmProvider.CreateInstance(ProviderType))
    || !(codeCompiler := codeProvider.CreateCompiler())
        return 0

    ; Create array of strings (references) -> SAFEARRAY.
    StringSplit, Refs, References, |, %A_Space%%A_Tab%
    VarSetCapacity(aRefs,24+4*Refs0,0), NumPut(Refs0,aRefs,16)
    NumPut(&aRefs+24,NumPut(4,NumPut(1,aRefs,0,"Ushort")+2)+4)
    Loop, %Refs0%
        NumPut(CLR_BSTR(Refs%A_Index%,Refs%A_Index%), aRefs, 20+4*A_Index)
    ; Create CompilerParameters object.
    compilerParms := CLR_CreateObject(asmSystem
        , "System.CodeDom.Compiler.CompilerParameters", COM_Parameter(0x2008, &aRefs))
    
    ; Set parameters for compiler.
    if FileName !=
        compilerParms.OutputAssembly := FileName
    compilerParms.GenerateInMemory := FileName=""
    if SubStr(FileName,-3)=".exe"
        compilerParms.GenerateExecutable := true
    if CompilerOptions
        compilerParms.CompilerOptions := CompilerOptions
    compilerParms.IncludeDebugInformation := true
    
    ; Compile!
    compilerRes := codeCompiler.CompileAssemblyFromSource(compilerParms, Code)
    
    if error_count := (errors := compilerRes.Errors).Count
    {
        Loop % error_count
        {
            error := errors.Item[A_Index-1]
            error_text .= (error.IsWarning ? "Warning " : "Error ")
                . error.ErrorNumber " on line " error.Line
                . ": " error.ErrorText "`n`n"
        }
        MsgBox, 16, Compilation Failed, %error_text%
        return 0
    }
    ; Success.
    return compilerRes[FileName="" ? "CompiledAssembly" : "PathToAssembly"]
}

CLR_BSTR(ByRef wString, sString)  ; In place of COM_SysString (COM_U) and COM_Unicode4Ansi (COM_L), more convenient than COM_SysAllocString/COM_SysFreeString.
{
    if A_IsUnicode {
        VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
        Return DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
    } else {
        VarSetCapacity(wString,3+2*nLen:=1+StrLen(sString))
        Return NumPut(DllCall("kernel32\MultiByteToWideChar","Uint",0,"Uint",0,"Uint",&sString,"int",nLen,"Uint",&wString+4,"int",nLen,"Uint")*2-2,wString)
    }
}
