#Set Deployment Vars
#/64bit to install Office 365 ProPlus 64-bit, otherwise it will default to 32-bit.
#/DisableUpdate TRUE, FALSE
#/Shared to install with Shared Computer Licensing for Remote Desktop Services.
#/Channel Microsoft Docs
#/Language default MatchOS MatchOS, ar-sa, bg-bg, zh-cn, zh-tw, hr-hr, cs-cz, da-dk, nl-nl, en-us, et-ee, fi-fi, fr-fr, de-de, el-gr, he-il, hi-in, hu-hu, id-id, it-it, ja-jp, kk-kz, ko-kr, lv-lv, lt-lt, ms-my, nb-no, pl-pl, pt-br, pt-pt, ro-ro, ru-ru, sr-latn-cs, sk-sk, sl-si, es-es, sv-se, th-th, tr-tr, uk-ua, vi-vn
#/Product default HomeBusinessRetail Supported PersonalRetail, ProPlusRetail, O365SmallBusPremRetail, O365BusinessRetail, O365ProPlusRetail, InfoPathRetail, SPDRetail, ProjectProRetail, VisioProRetail, LyncEntryRetail, LyncRetail, SkypeforBusiness, EntryRetail, SkypeforBusinessRetail, AccessRetail, Access2019Retail, Access2019Volume, Access2021Volume, ExcelRetail, Excel2019Retail, Excel2019Volume, Excel2021Volume, HomeBusinessRetail, HomeBusiness2019Retail, HomeStudentRetail, HomeStudent2019Retail, O365HomePremRetail, OneNoteRetail, OneNote2021Volume, OutlookRetail, Outlook2019Retail, Outlook2019Volume, Outlook2021Volume, Personal2019Retail, PowerPointRetail, PowerPoint2019Retail, PowerPoint2019Volume, PowerPoint2021Volume, ProfessionalRetail, Professional2019Retail, ProjectProXVolume, ProjectPro2019Retail, ProjectPro2019Volume, ProjectPro2021Volume, ProjectStdRetail, ProjectStdXVolume, ProjectStd2019Retail, ProjectStd2019Volume, ProjectStd2021Volume, ProPlus2019Volume, ProPlus2021Volume, ProPlusSPLA2021Volume, PublisherRetail, Publisher2019Retail, Publisher2019Volume, Publisher2021Volume, Standard2019Volume, Standard2021Volume, StandardSPLA2021Volume, VisioProXVolume, VisioPro2019Retail, VisioPro2019Volume, VisioPro2021Volume, VisioStdRetail, VisioStdXVolume, VisioStd2019Retail, VisioStd2019Volume, VisioStd2021Volume, WordRetail, Word2019Retail, Word2019Volume, Word2021Volume
#/Exclude Publisher, PowerPoint, OneDrive, Outlook, OneNote, Lync, Groove, Excel, Access, Word


$params1 = @(
    '/64bit'
    '/Product:ProPlus2019Volume'
    '/LicenseKey:B6KBT-DN948-TCMXK-JQH4R-3DC63'
)

$params2 = @(
    '/64bit'
    '/Product:ProjectPro2019Volume'
    '/LicenseKey:QWTK6-NH87R-3QKPV-HF2X3-2WHPC'
)



# Check if Chocolatey is installed
if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

  }

    choco install microsoft-office-deployment --params=$params1 -y --force
    choco install microsoft-office-deployment --params=$params2 -y --force

  