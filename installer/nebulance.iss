; Instalador do NEBULANCE: As Sementes do Colapso (Windows 64 bits). Gera installer/Output/NEBULANCE_Setup.exe.
; Compilar:  ISCC.exe installer\nebulance.iss   (precisa de build\NEBULANCE.exe, exportado pelo Godot).
#define AppName "NEBULANCE"
#define AppVersion "0.5.1"

[Setup]
AppId={{6E2B7C1A-4D5F-4E0B-9A31-7B8C2F9D1E54}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Maycon
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayName={#AppName}: As Sementes do Colapso
UninstallDisplayIcon={app}\NEBULANCE.exe
OutputDir=Output
OutputBaseFilename=NEBULANCE_Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern
DisableProgramGroupPage=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\NEBULANCE.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\NEBULANCE.exe"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\NEBULANCE.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\NEBULANCE.exe"; Description: "Jogar {#AppName} agora"; Flags: nowait postinstall skipifsilent
