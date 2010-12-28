/*++

    Ken Reneris

Module Name:

    Exif.cpp

Abstract:
    
    Classes for handling Exif/IFD image info
    www.reneris.com/tools

    Exif parsing information found at:
        http://www.ba.wakwak.com/~tsuruzoh/Computer/Digicams/exif-e.html
    
Revision History:

    06-May-2001    Ken Reneris

--*/

#include "stdafx.h"
#include "SImageUtil.h"
#include "Image.h"

//
//
//

EXIF_TAG_VALUES ResUnit[] = {
    1,  "no-unit",
    2,  "inch",
    3,  "cm",
    0,  NULL
};

EXIF_TAG_VALUES FPResUnit[] = {
    1,  "inch",     
    2,  "inch",     // should be meter, but broke on some cameras?
    3,  "centimeter",
    4,  "milimemeter",
    5,  "micrometer",
    0,  NULL
};

EXIF_TAG_VALUES ExpProg[] = {
    1,  "manual",
    2,  "program",
    3,  "aperture priority",
    4,  "shutter priority",
    5,  "slow",
    6,  "action",
    7,  "portiat",
    8,  "landscape",
    0,  NULL
};

EXIF_TAG_VALUES BpsCompress[] = {
    1,  "basic",
    2,  "normal",
    3,  "fine",
    4,  "fine",
    0,  NULL
}; 

EXIF_TAG_VALUES MeterMode[] = {
    0,  "unknown",
    1,  "average",
    2,  "center weighted",
    3,  "spot",
    4,  "multi-spot",
    5,  "multi-segment",
    6,  "spot AF area",
    0,  NULL
}; 

EXIF_TAG_VALUES LightSource[] = {
    0,  "unknown/cloudy",
    1,  "daylight",
    2,  "fluorescent",
    3,  "tungsten",
    10, "flash",
    17, "standard light A",
    18, "standard light B",
    19, "standard light C",
    20, "D55",
    21, "D65",
    22, "D75",
    0,  NULL
}; 

EXIF_TAG_VALUES FlashUsed[] = {
    // This is a bit encoded field
    0,      "no",
    1,      "yes",
    5,      "yes, but no return detect",
    7,      "yes, return detected",

    // Bit 8 means camera has a build in flash
    8+0,  "no",
    8+1,  "yes",
    8+5,  "yes, but no return detect",
    8+7,  "yes, return detected",

    0,  NULL
}; 


EXIF_TAG_VALUES ColorSpace[] = {
    1,  "sRGB",
    65535, "uncalibrated",
    0,  NULL
}; 


EXIF_TAG_VALUES SenseMethod[] = {
    2, "1 chip color area",
    0,  NULL
}; 


EXIF_TAG_VALUES FileSource[] = {
    3, "digital still camera",
    0,  NULL
}; 


EXIF_TAG_VALUES SceneType[] = {
    1, "directly photographed",
    0,  NULL
}; 

EXIF_TAG_VALUES OlyJpegQ[] = {
    1, "SQ",
    2, "HQ",
    3, "SHQ",
    0,  NULL
}; 

EXIF_TAG_VALUES OlyMacro[] = {
    0, "normal",
    1, "macro",
    0,  NULL
}; 

EXIF_TAG_VALUES OlySharp[] = {
    0, "normal",
    1, "hard",
    2, "soft",
    0,  NULL
}; 

EXIF_TAG_VALUES OlyFlash[] = {
    0, "on",
    1, "red-eye",
    2, "fill",
    2, "off",
    0,  NULL
}; 

EXIF_TAG_VALUES CanMacro[] = {
    1, "macro",
    2, "off",
    0,  NULL
};

EXIF_TAG_VALUES CanFlashMode[] = {
    0,  "off",
    1,  "auto",
    2,  "on",
    3,  "red-eye",
    4,  "slow",
    5,  "auto + red-eye",
    6,  "on + red-eye",
    16, "external",
    0,  NULL
};

EXIF_TAG_VALUES CanFocusMode[] = {
    0,  "one-shot",
    1,  "AI servo",
    2,  "AI Focus",
    3,  "Manual",
    4,  "Single",
    5,  "Continuous",
    6,  "Manual",
    0,  NULL
};

EXIF_TAG_VALUES CanShootMode[] = {
    0,  "Full auto",
    1,  "Manual",
    2,  "Landscape",
    3,  "Fast shutter",
    4,  "Slow shutter",
    5,  "Night",
    6,  "B & W",
    7,  "Sepia",
    8,  "Portrait",
    9,  "Sports",
    10, "Macro",
    11, "Pan Focus",
    0,  NULL
};

EXIF_TAG_VALUES CanLNH[] = {
    0xFFFF, "low",
    0,      "normal",
    1,      "high",
    0,  NULL
};

EXIF_TAG_VALUES CanWhiteBal[] = {
    0,  "auto",
    1,  "sunny",
    2,  "cloudy",
    3,  "tungsten",
    4,  "flourescent",
    5,  "flash",
    6,  "custom",
    0,  NULL
};

EXIF_TAG_VALUES CanAFPoint[] = {
    0x3000, "MF",
    0x3001, "auto selected",
    0x3002, "right",
    0x3003, "center",
    0x3004, "left",
    0,  NULL
};




// Units
EXIF_TAG_VALUES UnitsSec[] = { VALUE_UNIT, "s" };
EXIF_TAG_VALUES UnitsM[] =   { VALUE_UNIT, "m" };
EXIF_TAG_VALUES UnitsMM[] =  { VALUE_UNIT, "mm" };
EXIF_TAG_VALUES UnitsX[] =   { VALUE_UNIT, "x" };

EXIF_TAG_VALUES LowerStr[]   = { VALUE_LOWER_STR, NULL };

EXIF_TAGS   MainTags[] = {          // Prefix Main
    0x010E, "Desc",         NULL,       "Image Description",
    0x010F, "Make",         NULL,       "Camera Make",
    0x0110, "Model",        NULL,       "Camera Model",
    0x0112, "Ori",          NULL,       "Orientation",
    0x011A, "XRes",         NULL,       "X Resolution",
    0x011B, "YRes",         NULL,       "Y Resolution",
    0x0128, "ResUnit",      ResUnit,    "Resolution Unit",
    0x0131, "Software",     NULL,       "Camera Software",
    0x0132, "ModTime",      NULL,       "Last Modification",
    0x013E, "WPoint",       NULL,       "White Point",
    0x013F, "PrimChr",      NULL,       "Primary Chromaticities",
    0x0211, "YCbCrCoef",    NULL,       "YCbCrCoefficients",
    0x0213, "YCbCrPos",     NULL,       "YCbCrPositioning",
    0x0214, "RefBW",        NULL,       "Reference Black/White point",
    0x8298, "Copy",         NULL,       "Copyright",
    0x8769, "ExifOffset",   NULL,       "Sub IFD Offset",

    // Windows XP tags
    0x9C9B, "Title",        NULL,       "Image Title",
    0x9C9C, "Comments",     NULL,       "Image Comments",
    0x9C9D, "Author",       NULL,       "Image Author",
    0x9C9E, "Keywords",     NULL,       "Image Keywords",
    0x9C9F, "Subject",      NULL,       "Image Subject",

    0, NULL, NULL, NULL
}; 


EXIF_TAGS   SubTags[] = {        // Prefix Sub
    0x829A, "s",            UnitsSec,   "Exposure Time",
    0x829D, "f",            NULL,       "F-Stop",
    0x8822, "prog",         ExpProg,    "Program",
    0x8827, "iso",          NULL,       "Equivalent ISO speed",
    0x9000, "ExifVer",      NULL,       "Exif Version",
    0x9003, "OrigTime",     NULL,       "Original Time",
    0x9004, "DigTime",      NULL,       "Digitized Time",
    0x9101, "CompConfig",   NULL,       "Components Configuration",
    0x9102, "bpp",          BpsCompress,"Average compression ratio",
    0x9201, "sa",           NULL,       "Shutter Speed APEX",
    0x9202, "aa",           NULL,       "Aperture APEX",
    0x9203, "ba",           NULL,       "Brightness APEX",
    0x9204, "eba",          NULL,       "Exposure Bias APEX",
    0x9205, "maa",          NULL,       "Maximum Aperture APEX",
    0x9206, "dist",         UnitsM,     "Subject Distance",
    0x9207, "meter",        MeterMode,  "Metering Mode",
    0x9208, "ls",           LightSource,"Light Source",
    0x9209, "flash",        FlashUsed,  "Flash Used",
    0x920a, "focal",        UnitsMM,    "Focal Length",
    0x927c, "Maker",        NULL,       "Maker Note",
    0x9286, "User",         NULL,       "User Comment",
    0x9290, "sTime",        NULL,       "Subsecond Time",
    0x9291, "sOrigTime",    NULL,       "Subsecond Original Time",
    0x9292, "sDigTime",     NULL,       "Subsecond Digitized Time",
    0xA000, "flashpix",     NULL,       "Flash Pix Version",
    0xA001, "ColorSpace",   ColorSpace, "Color Space",
    0xA002, "Width",        NULL,       "Image Width",
    0xA003, "Height",       NULL,       "Image Height",
    0xA004, "SndFile",      NULL,       "Sound File",
    0xA005, "ExitIntOff",   NULL,       "Exif Interoperability Offset",
    0xA20E, "FPXRes",       NULL,       "Focal Plan X Resolution",
    0xA20F, "FPYRes",       NULL,       "Focal Plan Y Resolution",
    0xA210, "FPResUnit",    FPResUnit,  "Focal Plan Unit",
    0xA215, "ExpIndex",     NULL,       "Exposure Index",
    0xA217, "SenseMethod",  SenseMethod,"Sensing Method",
    0xA300, "FileSource",   FileSource, "File Source",
    0xA301, "SceneType",    SceneType,  "Scene Type",
    0xA302, "CFAPat",       NULL,       "CFA Pattern",
    0, NULL, NULL, NULL
};

EXIF_TAGS   NikonTags[] = {         // Prefix is Nikon
    0x0002, "ISO",          NULL,       "Nikon ISO Setting",
    0x0003, "Color",        LowerStr,   "Nikon Color Mode",
    0x0004, "Quality",      LowerStr,   "Nikon Quality",
    0x0005, "WhiteBal",     LowerStr,   "Nikon White Balance",
    0x0006, "Sharp",        LowerStr,   "Nikon Image Sharpening",
    0x0007, "Focus",        LowerStr,   "Nikon Focus Mode",
    0x0008, "Flash",        LowerStr,   "Nikon Flash",
    0x0009, "FlashMode",    LowerStr,   "Nikon Flash Mode",
    0x000F, "ISOSel",       LowerStr,   "Nikon ISO Selection",
    0x0080, "ImgAdjust",    LowerStr,   "Nikon Image Adjustment",
    0x0082, "Adapter",      LowerStr,   "Nikon Adapter Setting",
    0x0084, "Lens",         LowerStr,   "Nikon Lens",
    0x0085, "ManFocus",     UnitsM,     "Nikon Manual Focus Distance",
    0x0086, "DigZoom",      UnitsX,     "Nikon Digital Zoom",
    0x0088, "AFPos",        NULL,       "Nikon Auto Focus Position",
    //0x0090, "FlashType?",   LowerStr,   "Nikon Flash Type",
    0, NULL, NULL, NULL
};


EXIF_TAGS   OlympusTags[] = {       // Prefix is Oly
    0x0200, "SpcMode",      NULL,       "Olympus Special Mode",
    0x0201, "Quality",      OlyJpegQ,   "Olympus JPG Quality",
    0x0202, "Macro",        OlyMacro,   "Olympus Macro",
    0x0204, "DigZoom",      UnitsX,     "Olympus Digital Zoom",
    0x0207, "Software",     NULL,       "Olympus Software",
    0x0209, "CameraID",     NULL,       "Olympus Camera ID",

    // E-10 fields (from dougho@niceties.com)
    0x1004, "Flash",        OlyFlash,   "Olympus Flash Mode",
    0x100F, "Sharp",        OlySharp,   "Olympus Sharpness Mode",
    0x102a, "SharpScale",   NULL,       "Olympus Sharpness",
    
    0, NULL, NULL, NULL
};

EXIF_TAGS   CanonTags[] = {         // Prefix is Canon
    0x0001, "Set1",         NULL,       "Canon Settings 1",
    0x0004, "Set2",         NULL,       "Canon Settings 2",
    0x0006, "ImageType",    NULL,       "Canon Image Type",
    0x0007, "Software",     NULL,       "Canon Firmware Version",
    0x0008, "ImageNo",      NULL,       "Canon Image Number",
    0x0009, "Owner",        NULL,       "Canon Owner Name",
    0x000C, "SerialNo",     NULL,       "Canon Serial Number",
    0x000F, "CustomFnc",    NULL,       "Canon Custom Functions",
    0, NULL, NULL, NULL
};


EXIF_TAGS   CanonSet1[] = {         
    1,      "Macro",        CanMacro,       "Canon Macro Mode",
    4,      "Flash",        CanFlashMode,   "Canon Flash Mode",
    7,      "Focus",        CanFocusMode,   "Canon Focus Mode",
    11,     "Shoot",        CanShootMode,   "Canon Easy Shooting Mode",
    13,     "Contrast",     CanLNH,         "Canon Contrast Setting",
    14,     "Saturation",   CanLNH,         "Canon Saturation Setting",
    15,     "Sharpness",    CanLNH,         "Canon Sharpness Setting",
    19,     "AFPoint",      CanAFPoint,     "Canon AutoFocus Point",
    20,     "ExpMode",      NULL,           "Canon Exposure Mode",
    29,     "FlashDet",     NULL,           "Canon Flash Details",
    32,     "FocusMode",    NULL,           "Canon Focus Mode",
    0, NULL, NULL, NULL
};

EXIF_TAGS   CanonSet2[] = {         
    7,      "WhiteBal",     CanWhiteBal,    "Canon White Balance",
    15,     "FlashBias",    NULL,           "Canon Flash Bias", // signed * 0.03125 = ev
    19,     "SubjectDist",  NULL,           "Canon Subject Distance (0.01m or 0.001m)",
    0, NULL, NULL, NULL
};






//
// Format types
//

VOID Swiz16(UCHAR *);
VOID Swiz32(UCHAR *);
VOID SwizR64(UCHAR *);


EXIF_FORMAT rgExifFormat[] = {
    1,  NULL,   CExifTag::RenUndef,  // 0. undefined
    1,  NULL,   CExifTag::RenUDef,   // 1. unsigned byte
    1,  NULL,   CExifTag::RenStr,    // 2. ascii string
    2,  Swiz16, CExifTag::RenUDef,   // 3. unsigned short
    4,  Swiz32, CExifTag::RenUDef,   // 4. unsigned long
    8,  SwizR64,CExifTag::RenURat,   // 5. unsigned rational
    1,  NULL,   CExifTag::RenDef,    // 6. signed byte
    1,  NULL,   CExifTag::RenUndef,  // 7. undefined
    2,  Swiz16, CExifTag::RenDef,    // 8. signed short
    4,  Swiz32, CExifTag::RenDef,    // 9. signed long
    8,  SwizR64,CExifTag::RenRat,    // 10. signed rational
    4,  NULL,   CExifTag::RenUndef,  // 11. signed float (not used)
    8,  NULL,   CExifTag::RenUndef,  // 12. signed double (not used)

    // Our internal types
    1,  NULL,   CExifTag::RenUniStr  // 13. unicode string
} ;


UINT32 rgMask[] = { 0, 0x000000FF, 0x0000FFFF, 0x00FFFFFF, 0xFFFFFF };
CString NullCString;

/////////////////////////////////////////////////////////////////////////////
// 

VOID Swiz16(UCHAR *Buffer)
{
    UCHAR       l0;

    l0 = Buffer[0];
    Buffer[0] = Buffer[1];
    Buffer[1] = l0;
}

VOID Swiz32(UCHAR *Buffer)
{
    UCHAR       l0, l1, l2;

    l0 = Buffer[0];
    l1 = Buffer[1];
    l2 = Buffer[2];

    Buffer[0] = Buffer[3];
    Buffer[1] = l2;
    Buffer[2] = l1;
    Buffer[3] = l0;
}

VOID SwizR64(UCHAR *Buffer)
// Rationals are 2 32bit values in a row
{
    Swiz32(Buffer);
    Swiz32(Buffer + 4);
}



/////////////////////////////////////////////////////////////////////////////
// 

CExif::CExif()
{
    m_Fp = NULL;
    m_Image = NULL;
    m_Endian = FALSE;
    m_IdfOffset = 0;
    m_FocalConvert = 0;
}


CExif::~CExif()
{
    Close();
}


VOID CExif::Initialize(CImage *Parent, FILE *fp)
{
    EXIF_HEADER         Hdr;
    UINT16              Len;
    UINTN               SubPos;
    CExifTag            *Tag;
    CString             Str;

    m_Lock.Acquire();

    //
    // If we've already initialized, then do nothing
    //

    if (m_Image || !fp) {
        goto Done;
    }

    //
    // Remember our info
    //

    m_Image = Parent;
    m_Fp = fp;
    m_IdfOffset = 0;

    // Read in the EXIF file header
    SetPos(0);
    fread(&Hdr, sizeof(Hdr), 1, m_Fp);

    // Some files have a Jfif header in front of the Exif header.  If this is a JFIF header,
    // skip it and check the next header
    if (Hdr.SOI == 0xD8FF && Hdr.App1 == 0xE0FF && memcmp(Hdr.Exif, "JFIF", 4) == 0) {
        Swiz16((PUCHAR) &Hdr.Size);
        m_IdfOffset = Hdr.Size + 2;

        SetPos(0);
        fread(&Hdr, sizeof(Hdr), 1, m_Fp);
        Hdr.SOI = 0xD8FF;
    }

    // verify this is an Exif file
    if (Hdr.SOI != 0xD8FF || Hdr.App1 != 0xE1FF || memcmp(Hdr.Exif, "Exif\0\0", 6) != 0) {
        goto Done;
    }

    // Determine the endian type
    if (Hdr.Type == 'II') {
        m_Endian = FALSE;

    } else if (Hdr.Type == 'MM') {
        m_Endian = TRUE;

    } else {

        // Unknown type
        goto Done;
    }

    // Check for valid len
    SetPos(sizeof(Hdr));
    Len = GetU16();
    if (Len != 0x2a) {
        goto Done;
    }

    //
    // Looks good - crack the main Exif directory
    //

    m_IdfOffset = m_IdfOffset + 0xC;
    GetU32();       // junk
    ReadIFD(MainTags, "Main.");

    //
    // Crack the sub-Exif directory
    //

    Tag = GetTag("Main.ExifOffset");
    if (Tag) {
        SetPos(Tag->m_UInt);
        ReadIFD(SubTags, "Sub.");
    }

    // 
    // Crack camera specific information
    //

    GetTag("Main.Make", Str);
    Tag = GetTag("Sub.Maker");
    Str.MakeLower();

    if (Str.Find("nikon") >= 0 && Tag) {
        SetPos(Tag->m_Pos);
        SubPos = 0;

        if (memcmp(Tag->m_Buffer, "Nikon", 5) == 0) {
            SetPos(Tag->m_Pos + 18);
            // The ascii string offsets in this block are all adjusted
            SubPos = Tag->m_Pos + 10;
        }

        ReadIFD(NikonTags, "Nikon.", SubPos);
        GetTag("Main.Model", Str);
        if (Str == "E990" || Str == "E880") {
            m_FocalConvert = 0.209;
        }
        if (Str.Find("D1X") >= 0) {
            m_FocalConvert = 1 / 1.5;
        }

    } else if (Str.Find("olympus") >= 0 && Tag) {
        SetPos(Tag->m_Pos + 8);
        ReadIFD(OlympusTags, "Oly.");

        GetTag("Main.Model", Str);
        if (Str == "E-10") {
            m_FocalConvert = 0.2571;
        }

    } else if (Str.Find("canon") >= 0 && Tag) {
        SetPos(Tag->m_Pos);
        ReadIFD(CanonTags, "Canon.");
        ExpandBinaryTag("Canon.Set1", CanonSet1, EXIF_TYPE_UINT16);
        ExpandBinaryTag("Canon.Set2", CanonSet2, EXIF_TYPE_UINT16);
    }

    //
    // OK, we've cracked everything we know about.  Now we will
    // build our default tags
    //

    BuildDefaultTags();

Done:
    m_Lock.Release();
}


VOID CExif::Close()
{
    CExifTag        *Tag;

    m_Lock.Acquire();

    // 
    // Free any tags we may have allocated
    //

    while (Tag = m_AllTags.RemoveHead()) {
        delete Tag;
    }
    m_Tags.RemoveAll();

    //
    // Re-Initialize values
    //

    m_Fp = NULL;
    m_Image = NULL;
    m_Endian = FALSE;
    m_IdfOffset = 0;
    m_FocalConvert = 0;

    m_Lock.Release();
}



VOID CExif::BuildDefaultTags()
{
    CString         Str, Str1, Str2, Model;
    CExifTag        *Tag;
    FLOATN          w, d1, d2;
    UCHAR           c;

    //
    // Once all the other tags are read in, we create a common set
    // of tags built up from the others.  This allows the callers to
    // read the common stuff without needing to worry about the camera
    // specific fields, but if they want they can read those as well.
    //
    //  Make        - Camera Make
    //  Model       - Camera Model
    //  Software    - Camera Software
    //  Date        - Original Photo date/time
    //  Res         - X x Y size of original
    //  Flash       - Flash used & setting
    //  Focal       - Focal length
    //  s           - Exposure time
    //  f           - Aperture f/
    //  ISO         - ISO Equiv
    //  WhiteBal    - WhiteBalance
    //  Meter       - Metering mode
    //  ExpProg     - Exposure program
    //  ExpBias     - Exposure Bias
    //  Focus       - Focus
    //  qual        - Compression quality
    //  Lens        - Info on the lens
    //  ImageAdj    - Image adjustment
    //  Sharpness   - Sharpness setting
    //  
    //  Title       - User supplied title string
    //  Comments    - User supplied comments string
    //  Author      - User supplied author string
    //  Keywords    - User supplied keywords
    //  Subject     - User supplied subject
    //

    Model = TagStr("Main.Model");

    // Many tags are just copies.. so make them
    CopyTag("Main.Make",        "Make");
    CopyTag("Main.Model",       "Model");
    CopyTag("Sub.Meter",        "Meter");
    CopyTag("Sub.Prog",         "ExpProg");
    CopyTag("Main.Title",       "Title");
    CopyTag("Main.Comments",    "Comments");
    CopyTag("Main.Author",      "Author");
    CopyTag("Main.Keywords",    "Keywords");
    CopyTag("Main.Subject",     "Subject");

    // For Date use the last found of these time fields
    CopyTag("Sub.ModTime",      "Date");
    CopyTag("Sub.OrigTime",     "Date");
    CopyTag("Sub.DigTime",      "Date");
    
    CopyTag("Main.Software",    "Software");
    CopyTag("Canon.Software",   "Software");
    AddTag ("Software",         "Oly.Software");

    // Get the width & height for Res
    Str.Format("%s x %s", TagStr("Sub.Width"), TagStr("Sub.Height"));
    SetTag("Res", Str);

    // Set the flash mode - append the camera specific setting if the flash fired
    GetTag("Sub.Flash", Str);
    SetTag("Flash", Str);
    if (Str.Find("yes") >= 0) {
        AddTag("Flash", "Nikon.Flash");
        AddTag("Flash", "Canon.Flash");
        AddTag("Flash", "Oly.Flash");
    }

    // The D1x doesn't set Sub.Flash
    if (Model.Find("D1X") >= 0) {
        AddTag("Flash", "Nikon.Flash");
        AddTag("Flash", "Nikon.FlashMode");
    }

    // CCD width
    GetTag("Sub.Width", w);
    GetTag("Sub.FPXRes", d1);
    Tag = GetTag("Sub.FPResUnit");
    d2 = 0;
    if (Tag) {
        switch(Tag->m_UInt) {
        case 1:     d2 = 25.4;      break;      // inch
        case 2:     d2 = 25.4;      break;      // inch
        case 3:     d2 = 10;        break;      // centimeter    
        case 4:     d2 = 1;         break;      // milimeter
        case 5:     d2 = 0.001;     break;      // micrometer
        }
    }
    if (w && d1 && d2) {
        d1 = w * d2 / d1;
        Str.Format("%4.2fmm", d1);
        SetTag("CCDWidth", Str);

        // Set conversion 
        if (!m_FocalConvert) {
            m_FocalConvert = d1 / 35;
        }
    }

    // Focal length
    Tag = GetTag("Sub.Focal");
    if (Tag) {
        Str.Format("%4.1fmm", Tag->m_Float);
        if (m_FocalConvert > 0) {
            Str.Format("%4.1fmm  (35mm equivalent: %dmm)", 
                Tag->m_Float,
                (UINTN) (Tag->m_Float / m_FocalConvert + 0.5)
                );
        }
        SetTag("Focal", Str);
    }

    // shutter speed
    Tag = GetTag("Sub.s");
    if (Tag) {
        Str.Format("%6.3fs", Tag->m_Float);
        if (Tag->m_Float <= 0.5) {
            Str.Format("%6.3fs (1/%d)", Tag->m_Float, (UINTN) (1/Tag->m_Float + 0.5));
        }
        SetTag("s", Str);
    }

    // aperture
    Tag = GetTag("Sub.f");
    if (Tag) {
        Str.Format("f/%3.1f", Tag->m_Float);
        SetTag("f", Str);
    }

    // ISO
    CopyTag("Sub.ISO", "ISO");
    if (!GetTag("ISO")) {                   // ISO set?
        Tag = GetTag("Nikon.ISO");          // No, get the Nikon.ISO setting
        if (Tag) {      
            Str.Format("%d", Tag->m_Int);   // Move the last Int from this tag
            SetTag("ISO", Str);             // to the ISO info
        }
    }

    // Exposure Bias
    GetTag("Sub.eba", d1);
    if (d1 != 0) {
        c = '+';
        if (d1 < 0) {
            d1 = -d1;
            c = '-';
        }

        Str.Format("%c%3.2f", c, d1);
        SetTag("ExpBias", Str);
    }

    // White balance
    CopyTag("Sub.ls", "WhiteBal");
    CopyTag("Nikon.WhiteBal", "WhiteBal");

    //
    // Focus
    //

    AddTag("Focus", "Nikon.Focus");
    AddTag("Focus", "Oly.Macro", "normal");

    Str1.Empty();
    Tag = GetTag("Sub.Dist", d1);
    
    // Kodak is expressing -1 as an unsigned in the numerator. So check for it.
    if (Tag && Tag->m_Num == 0xFFFFFFFF) {
        d1 = -1;
    }

    Tag = GetTag("Nikon.ManFocus");
    if (Tag && Tag->m_Num != 0) {
        d1 = Tag->m_Float;
        // Nikon expresses INF as 1/0
        if (Tag->m_Num == 1 && Tag->m_Den == 0) {
            d1 = -1;
        }
    }

    if (d1 > 0) {
        Str1.Format("%5.2fm", d1);
    } else if (d1 < 0) {
        Str1 = "Infinite";
    }
    AddStr("Focus", Str1);

    //
    // Compression Quality
    //

    CopyTag("Sub.bpp", "Qual");
    CopyTag("Nikon.Quality", "Qual");
    CopyTag("Oly.Quality", "Qual");

    // Lens, ImageAdj, Sharpness
    Tag = GetTag("Nikon.Lens");
    if (Tag) {
        FLOATN      Low, High;
        CString     Focal, Aperture;

        Low = Tag->GetFloat(0);
        High = Tag->GetFloat(1);
        FormatRange(Low, High, Focal);

        Low = Tag->GetFloat(2);
        High = Tag->GetFloat(3);
        FormatRange(Low, High, Aperture);

        Str.Format("%smm f/%s", Focal, Aperture);
        SetTag("Lens", Str);
    }

    AddTag("Lens", "Nikon.Adapter",  "off");

    // ImageAdj, Sharpness
    AddTag("ImageAdj", "Nikon.ImgAdjust", "auto");

    AddTag("Sharpness","Nikon.Sharp",     "auto");
    AddTag("Sharpness","Oly.Sharp",       "normal");
}



CExifTag *CExif::GetTag(LPCSTR TagName)
{
    CExifTag    *Tag;
    BOOLEAN     f;
    CString     Str;

    Str = TagName;
    Str.MakeLower();

    f = m_Tags.Lookup(Str, Tag);
    return f ? Tag : NULL;
}

CExifTag *CExif::GetTag(LPCSTR TagName, CString &Value)
{
    CExifTag    *Tag;

    Value.Empty();
    Tag = GetTag(TagName);
    if (Tag) {
        Value = Tag->m_Value;
    }
    return Tag;
}


CExifTag *CExif::GetTag(LPCSTR TagName, FLOATN &Value)
{
    CExifTag    *Tag;

    Value = 0;
    Tag = GetTag(TagName);
    if (Tag) {
        Value = Tag->m_Float;
    }
    return Tag;
}


CString &CExif::TagStr(LPCSTR TagName)
{
    CExifTag    *Tag;

    Tag = GetTag(TagName);
    return Tag ? Tag->m_Value : NullCString;
}


VOID CExif::CopyTag(LPCSTR Src, LPCSTR Dst)
// N.B. this only copies the string value of the tag
{
    CExifTag    *Tag;
    
    Tag = GetTag(Src);
    if (Tag) {
        SetTag(Dst, Tag->m_Value);
    }
}


VOID CExif::SetTag(LPCSTR Dst, LPCSTR Value)
{
    CExifTag    *Tag;
    
    Tag = GetTag(Dst);
    if (!Tag) {
        Tag = new CExifTag(this, 0, 2, 0);

        // Add to our list of tags
        Tag->m_ShortName = Dst;
        Tag->m_Lookup = Tag->m_ShortName;
        Tag->m_Lookup.MakeLower();

        m_AllTags.InsertTail(&Tag->m_Link);
        m_Tags.SetAt(Tag->m_Lookup, Tag);
    }

    Tag->m_Fmt = &rgExifFormat[2];
    Tag->m_Value = Value;
}

VOID CExif::AddTag(LPCSTR DstTag, LPCSTR SrcTag, LPCSTR Skip, LPCSTR Sep)
// Add SrcTag to DstTag if SrcTag is present and is not Skip
// Put the string Sep between the tags
{
    CString     Str;

    GetTag(SrcTag, Str);
    AddStr(DstTag, Str, Skip, Sep);
}

VOID CExif::AddStr(LPCSTR DstTag, CString &SrcStr, LPCSTR Skip, LPCSTR Sep)
{
    CString     Str, Str2;

    Str = SrcStr;
    Str.MakeLower();
    if (SrcStr.GetLength() == 0 || Str == "" || (Skip && Str == Skip)) {
        return ;
    }

    
    GetTag(DstTag, Str2);
    if (!Sep) {
        Sep = " / ";
    }
    if (Str2.GetLength() == 0) {
        Sep = "";
    }

    Str.Format("%s%s%s", Str2, Sep, SrcStr);
    SetTag(DstTag, Str);
}


VOID CExif::FormatRange(FLOATN Low, FLOATN High, CString &Str)
{
    CString     LStr, HStr;

    LStr.Format("%4.1f", Low);
    LStr.TrimRight("0");
    LStr.TrimRight(".");
    LStr.TrimLeft(" ");

    HStr.Format("%4.1f", High);
    HStr.TrimRight("0");
    HStr.TrimRight(".");
    HStr.TrimLeft(" ");

    Str = LStr;
    if (LStr != HStr) {
        Str.Format("%s-%s", LStr, HStr);
    }
}


VOID CExif::ReadIFD(EXIF_TAGS *Tags, LPCSTR Prefix, UINTN IfdIndent)
{
    UINTN       NoDir, DirPos, Index;
    UINTN       TagNo, Format, NoComp, Offset;
    CExifTag    *Tag;

    NoDir = GetU16();
    DirPos = GetPos();

    while (NoDir) {

        //
        // Allocate a new tag 
        //

        SetPos(DirPos);
        TagNo  = GetU16();
        Format = GetU16();
        NoComp = GetU32();

        //
        // Handle special cases where format is not supplied with the tag
        //
        
        switch(TagNo) {
        case 0x9C9B:
        case 0x9C9C:
        case 0x9C9D:
        case 0x9C9E:
        case 0x9C9F:
            Format = 13;        // unicode string
            break;
        }

        Tag = new CExifTag(this, TagNo, Format, NoComp);

        //
        // Create the tag's shortname (and initialize it's m_Tag)
        //

        Tag->m_ShortName.Format("%s%04x", Prefix, Tag->m_TagNo);
        for(Index=0; Tags[Index].ShortName; Index++) {
            if (Tags[Index].Tag == Tag->m_TagNo) {
                Tag->m_Tag = &Tags[Index];
                Tag->m_ShortName.Format("%s%s", Prefix, (LPCSTR) Tag->m_Tag->ShortName);
                break;
            }
        }

        //
        // Read the tag's data into its buffer
        //

        // If the data size is larger then 4, then we have a pointer to it
        if (Tag->m_Size > 4) {
            Offset = GetU32() + IfdIndent;
            SetPos(Offset);
        }

        Tag->m_Pos = GetPos();
        Read(Tag->m_Buffer, Tag->m_Size);

        //
        // If we are the wrong endian, then swizzle the data buffer
        //

        if (m_Endian) {
            Tag->Swizzle();
        }

        //
        // Print the value into a string
        //

        Tag->Render();

        //
        // Add this tag to the database
        //
        Tag->m_Lookup = Tag->m_ShortName;
        Tag->m_Lookup.MakeLower();

        m_AllTags.InsertTail(&Tag->m_Link);
        m_Tags.SetAt(Tag->m_Lookup, Tag);

        //
        // Next DirEntry
        //

        NoDir = NoDir - 1;
        DirPos = DirPos + 12;
    }
}


VOID CExif::ExpandBinaryTag(LPCSTR Src, EXIF_TAGS *Tags, UINTN Type)
{
    UINTN       ElmSize, ElmFormat;
    CExifTag    *SrcTag, *Tag;
    CString     Prefix;
    UINTN       Index;
    INTN        Pos;    

    SrcTag = GetTag(Src);
    if (!SrcTag || SrcTag->m_Fmt != &rgExifFormat[Type]) {
        return ;
    }

    // Prefix is the original prefix
    Prefix = Src;
    Pos = Prefix.Find(".");
    if (Pos >= 0) {
        Prefix = Prefix.Left(Pos+1);
    }

    // Tag should be items of all one size.  For now we are assuming they
    // are type 3 (unsigned short)

    ElmSize = rgExifFormat[Type].Size;
    ElmFormat = Type; 

    for (Index=0; Tags[Index].ShortName && Tags[Index].Tag < SrcTag->m_NoComp; Index++) {
        
        //
        // Allocate a tag for this item
        //

        Tag = new CExifTag(this, Tags[Index].Tag, ElmFormat, 1);
        Tag->m_Tag = &Tags[Index];
        Tag->m_ShortName.Format("%s%s", Prefix, Tag->m_Tag->ShortName);
        memcpy (Tag->m_Buffer, SrcTag->m_Buffer + Tag->m_TagNo * ElmSize, ElmSize);

        //
        // If we are the wrong endian, then swizzle the data buffer
        //

        if (m_Endian) {
            Tag->Swizzle();
        }

        //
        // Print the value into a string
        //

        Tag->Render();

        //
        // Add this tag to the database
        //
        Tag->m_Lookup = Tag->m_ShortName;
        Tag->m_Lookup.MakeLower();

        m_AllTags.InsertTail(&Tag->m_Link);
        m_Tags.SetAt(Tag->m_Lookup, Tag);
    }
}


VOID CExif::DumpAll()
{
    CExifTag        *Tag;
    CString         Str, Prefix;
    BOOLEAN         TableOpen;
    INTN            Pos;

    TableOpen = FALSE;
    for(Tag=m_AllTags.Next(); Tag; Tag=Tag->m_Link.Next()) {

        Pos = Tag->m_ShortName.Find(".");
        Str = Tag->m_ShortName.Left(Pos+1);
        if (Str != Prefix) {
            Prefix = Str;

            if (TableOpen) {
                OutRaw("</table><br>");
            }

            OutRaw("<table border=1>");
            OutRaw("<tr bgcolor='#C0C0C0'><td>ShortName</td><td>Description</td><td>Value</td></tr>");
            TableOpen = TRUE;
        }

        OutRaw("<tr><td>");
        Out(Tag->m_ShortName);

        OutRaw("</td><td>");
        if (Tag->m_Tag) {
            Out(Tag->m_Tag->Desc);
        } else {
            OutRaw("&nbsp;");
        }

        OutRaw("</td><td>");

        // DEBUG - include the format value
        // Str.Format("(%d): ", Tag->m_Format);
        // OutRaw(Str);
        // DEBUG

        if (Tag->m_Value.GetLength()) {
            Out(Tag->m_Value);
        } else {
            OutRaw("&nbsp;");
        }

        OutRaw("</td></tr>");
    }

    if (TableOpen) {
        OutRaw("</table>");
    }
}

// IO function
VOID CExif::SetPos(UINTN Pos)
{
    Pos += m_IdfOffset;
    fseek(m_Fp, Pos, SEEK_SET);
}


UINTN CExif::GetPos()
{
    return ftell(m_Fp) - m_IdfOffset;
}


VOID CExif::Read(VOID *Buffer, UINTN Size)
{
    UINTN       i;

    i = fread(Buffer, Size, 1, m_Fp);
    if (i != 1) {
        throw new CImageException("Exif read data error");
    }
}


UINT16 CExif::GetU16()
{
    UINT16      u16;

    Read(&u16, sizeof(u16));
    if (m_Endian) {
        Swiz16((PUCHAR) &u16);
    }

    return u16;
}


UINT32 CExif::GetU32()
{
    UINT32      u32;

    Read(&u32, sizeof(u32));
    if (m_Endian) {
        Swiz32((PUCHAR) &u32);
    }

    return u32;
}


VOID CExif::Out(LPCSTR Str)
{
    m_Image->OutputEncodeString(Str);
}

VOID CExif::OutRaw(LPCSTR Str)
{
    m_Image->OutputRawString(Str);
}



/////////////////////////////////////////////////////////////////////////////
//

CExifTag::CExifTag(CExif *Parent, UINTN TagNo, UINTN Format, UINTN NoComp)
{
    m_Link.Initialize(FIELD_OFFSET(CExifTag, m_Link));
    m_Tag = NULL;
    m_Fmt = NULL;
    m_Buffer = NULL;
    m_TagNo = 0;
    m_Format = 0;
    m_Size = 0;
    m_NoComp = 0;
    m_Num = 0;
    m_Den = 1;
    m_Int = 0;
    m_UInt = 0;
    m_Float = 0;

    //
    //m_Exif = Parent;
    m_TagNo = TagNo;
    m_Format = Format;
    m_NoComp = NoComp;
    if (Format < 1 || Format > 13) {
        throw new CImageException("Tag format field not understood");
    }

    // Allocate a buffer for this tags data
    m_Fmt = &rgExifFormat[Format];
    m_Size = m_Fmt->Size * m_NoComp;
    if (m_Size > 64*1024 || m_NoComp > 64*1024) { 
        throw new CImageException("NoComp field not understood");
    }

    if (m_Size) {
        m_Buffer = (UCHAR *) malloc(m_Size);

        if (!m_Buffer) {
            throw new CImageException("Out of memory");
        }
    }
}


CExifTag::~CExifTag()
{
    if (m_Buffer) {
        free(m_Buffer);
        m_Buffer = NULL;
    }

}


VOID CExifTag::Swizzle()
// Data needs swizzled
{
    UINTN       Index;
    PUCHAR      Buffer;

    if (m_Fmt->Swizzle) {
        Buffer = m_Buffer;
        for (Index=0; Index < m_NoComp; Index++) {
            m_Fmt->Swizzle(Buffer);
            Buffer = Buffer + m_Fmt->Size;
        }
    }
}

VOID CExifTag::Render()
{
    UINTN               Index, Count;
    UCHAR               *Buffer;
    

    m_Value.Empty();
    Buffer = m_Buffer;
    Index = 0;
    Count = 0;

    for (; ;) {
        Index += (this->*m_Fmt->Render)(Buffer);
        if (Index >= m_NoComp) {
            break;
        }

        Count += 1;
        if (Count >= 16) {
            m_Value += " ...";
            break;
        }

        // Add a space between the array of values
        m_Value += " ";
    }

    // Normalize the value into different formats
    if (m_Den != 0) {
        m_Float = (FLOAT) m_Num / (FLOAT) m_Den;
        m_Int = (INT64) (m_Float + 0.5);
        m_UInt = (UINTN) m_Int;
    }

    // See if there is any translation
    if (m_Tag && m_Tag->Trans) {
        EXIF_TAG_VALUES     *Trans;

        Trans = m_Tag->Trans;
        if (Trans[0].Value == VALUE_UNIT) {

            // Translator supplies units of value
            m_Value += " ";
            m_Value += Trans[0].Desc;

        } else if (Trans[0].Value == VALUE_LOWER_STR) {

            m_Value.MakeLower();

        } else {

            // Lookup value's verbose name and use that
            for (Index=0; Trans[Index].Desc; Index++) {
                if (Trans[Index].Value == m_UInt) {
                    m_Value = Trans[Index].Desc;
                    break;
                }
            }

        }
    }

    // Trim trailing spaces from output
    m_Value.TrimRight(' ');
}


FLOATN CExifTag::GetFloat(UINTN Index)
{
    Value(Index);
    return m_Float;
}

VOID CExifTag::Value(UINTN Index)
{
    UINTN               Count;
    UCHAR               *Buffer;
    CString             HoldValue;
    
    HoldValue = m_Value;
    m_Num = 0;
    m_Den = 0;
    m_Int = 0;
    m_UInt = 0;
    m_Float = 0;

    // If Index is in range, let's get it
    if (Index <= m_NoComp) {

        // Render each element and stop at the one we want
        Count = 0;
        Buffer = m_Buffer;
        while (Count <= Index) {
            m_Value = "";
            Count += (this->*m_Fmt->Render)(Buffer);
        }
    }

    // Normalize the value into different formats
    if (m_Den != 0) {
        m_Float = (FLOAT) m_Num / (FLOAT) m_Den;
        m_Int = (INT64) (m_Float + 0.5);
        m_UInt = (UINTN) m_Int;
    }

    // restore original string
    m_Value = HoldValue;
}


//
// Render functions
//

UINTN CExifTag::RenUDef(PUCHAR &Buffer)
// Default unsigned number of m_Fmt->Size
{
    UINT32      Accum, Size;
    CString     Str;

    // Pull the value from the stream
    Size = m_Fmt->Size;
    memcpy (&Accum, Buffer, Size);
    Accum = Accum & rgMask[Size];

    // Append this value to the output
    Str.Format("%u", Accum);
    m_Value += Str;

    // Remember last value
    m_Num = Accum;

    // Done - we handled 1 value of this type
    Buffer += Size;
    return 1;
}


UINTN CExifTag::RenDef(PUCHAR &Buffer)
// Default signed number of m_Fmt->Size
{
    UINT32      Size, Mask;
    INT32       Accum;
    CString     Str;

    // Pull the value from the stream
    Size = m_Fmt->Size;
    Mask = rgMask[Size];
    memcpy (&Accum, Buffer, Size);
    Accum = Accum & Mask;

    // If the sign bit is set, sign extend the value
    if (Accum & (1 << (Size * 8 - 1))) {
        Accum = Accum | (-1L ^ Mask);
    }

    // Append this value to the output
    Str.Format("%d", Accum);
    m_Value += Str;
    m_Num = Accum; 

    // Done - we handled 1 value of this type
    Buffer += Size;
    return 1;
}


UINTN CExifTag::RenRat(PUCHAR &Buffer)
// Signed Rational
{
    INT32       Num, Den;
    CString     Str;

    memcpy (&Num, Buffer, 4);
    memcpy (&Den, Buffer+4, 4);

    // Append this value to the output
    Str.Format("%d/%d", Num, Den);
    m_Value += Str;
    m_Num = Num;
    m_Den = Den;

    // Done - we handle 1 value of this type
    Buffer += 8;
    return 1;
}

UINTN CExifTag::RenURat(PUCHAR &Buffer)
// Unsigned Rational
{
    UINT32      Num, Den;
    CString     Str;

    memcpy (&Num, Buffer, 4);
    memcpy (&Den, Buffer+4, 4);

    // Append this value to the output
    Str.Format("%u/%u", Num, Den);
    m_Value += Str;
    m_Num = Num;
    m_Den = Den;

    // Done - we handle 1 value of this type
    Buffer += 8;
    return 1;
}

UINTN CExifTag::RenStr(PUCHAR &Buffer)
{
    UINTN       Index;
    UCHAR       c;
    CString     Str;

    Index = 0;
    while (*Buffer && Index < m_Size) {
        c = *Buffer;
        if (c >= ' ' && c <= 127) {
            m_Value += c;
        } else {
            switch (c) {
            case '\n':  Str = "\\n";  break;
            case '\r':  Str = "\\r";  break;
            case '\t':  Str = "\\t";  break;
            case '\b':  Str = "\\b";  break;
            default:
                Str.Format("\\0x%02x", c);
            }
            m_Value += Str;
        }

        // Next char
        Buffer += 1;
        Index += 1;
    }

    // Done - we handled the whole value
    return m_NoComp;
}

UINTN CExifTag::RenUniStr(PUCHAR &Buffer)
{
    UINTN       Index;
    UINT16      c;
    CString     Str;

    Index = 0;
    while (*Buffer && Index < m_Size) {
        c = Buffer[0] | (Buffer[1] << 8);

        if (c >= ' ' && c <= 127) {
            m_Value += c;
        } else {
            switch (c) {
            case '\n':  Str = "\\n";  break;
            case '\r':  Str = "\\r";  break;
            case '\t':  Str = "\\t";  break;
            case '\b':  Str = "\\b";  break;
            default:
                Str.Format("\\0x%02x", c);
            }
            m_Value += Str;
        }

        // Next char
        Buffer += 2;
        Index += 1;
    }

    // Done - we handled the whole value
    return m_NoComp;
}


UINTN CExifTag::RenUndef(PUCHAR &Buffer)
{
    BOOLEAN     AscStr;
    UINTN       Index, Size;
    UCHAR       c;
    CString     Str;

    AscStr = TRUE;
    for(Index=0; Index < m_Size; Index++) {
        c = Buffer[Index];
        if ((c < ' '|| c > 127) && c != 0 && c != '\n' && c != '\r' && c != '\t' && c != '\b') {
            AscStr = FALSE;
            break;
        }
    }

    if (AscStr) {
        return RenStr(Buffer);
    }
    
    // Dump the leading bytes
    Size = m_Size;
    if (Size > 16) {
        Size = 16;
    }

    m_Value += "{ ";
    for(Index=0; Index < Size; Index++) {
        Str.Format("%02x ", Buffer[Index]);
        m_Value += Str;
    }

    if (Size != m_Size) {
        m_Value += "... ";
    }

    m_Value += "}";

    // Take the last byte as our default value
    m_Num = Buffer[m_Size-1];

    // Done - we handled the whole value
    return m_NoComp;
}
    