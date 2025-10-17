; 超星学习通助手 - Windows 安装程序脚本
; 使用 Inno Setup 6.0+ 编译

[Setup]
; 应用基本信息
AppName=超星学习通助手
AppVersion=1.0.0
AppPublisher=Chaoxing Helper Team
AppPublisherURL=https://github.com/Samueli924/chaoxing
DefaultDirName={autopf}\ChaoxingHelper
DefaultGroupName=超星学习通助手
OutputDir=build\windows\installer
OutputBaseFilename=ChaoxingHelper_Setup_v1.0.0
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\chaoxing_ft.exe

; 压缩和外观
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableWelcomePage=no

; 权限
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; 复制所有 Release 文件
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; 开始菜单快捷方式
Name: "{group}\超星学习通助手"; Filename: "{app}\chaoxing_ft.exe"
Name: "{group}\卸载超星学习通助手"; Filename: "{uninstallexe}"

; 桌面快捷方式（可选）
Name: "{autodesktop}\超星学习通助手"; Filename: "{app}\chaoxing_ft.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加选项:"; Flags: unchecked

[Run]
; 安装完成后选项
Filename: "{app}\chaoxing_ft.exe"; Description: "立即运行超星学习通助手"; Flags: nowait postinstall skipifsilent

[Code]
// 检查是否已安装
function InitializeSetup(): Boolean;
var
  OldVersion: String;
begin
  // 可以在这里添加版本检查逻辑
  Result := True;
end;
