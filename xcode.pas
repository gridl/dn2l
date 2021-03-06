unit XCode;

interface

uses
  Defines, Objects2, Streams, UKeyMap
  ;

type

  PXCoder = ^TXCoder;
  {`2 ����� � ��४���஢���� � ��ᬮ��, dbf � �.�.}
  TXCoder = object(TObject)
    XLatCP: TXLatCP;
    KeyMap: TKeyMap;
      {` KeyMap=kmXlat ��� ����஢��, ����㦥���� �� xlt-䠩��`}
    MaxCodeTagLen: Byte;
      {` ���ᨬ��쭠� ����� CodeTag. �� ����� 8.`}
    CodeTag: Str8;
      {` ������祭�� ����஢�� ��� ������樨 � ࠬ��.
      �� ��� �।��।��񭭮� ����஢�� ��� ��� 䠩�� ����㦥����
      xlt-⠡���� ��� ��� `}
    constructor Init(AMaxCodeTagLen: Byte);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure UseToAscii;
      {` ����ந�� ��� �� kmXlat �� �᭮����� XLatCP[ToAscii]`}
    procedure UseKeyMap;
      {` ����ந�� ��� �� ⥪���� KeyMap (kmAscii ��� �����)`}
    procedure LoadXlatTable;
    procedure NextXLat;
      {` ��४��祭�� �� ���� �।��।����� ����஢�� `}
    procedure FromHistory(fKeyMap: TKeyMap;
      fToAscii: TXLat; fCodeTag: Str8);
    procedure ToHistory(var fKeyMap: TKeyMap;
      var fToAscii: TXLat; var fCodeTag: Str8);
    end;
    {`}

implementation
uses
  Advance, Advance1, Lfnvp, DNStdDlg, DnApp, Commands, DnIni
  ;

constructor TXCoder.Init;
  begin
  inherited Init;
  KeyMap := kmAscii;
  UseKeyMap;
  if (AMaxCodeTagLen > 8) then
    AMaxCodeTagLen := 8;
  MaxCodeTagLen := AMaxCodeTagLen;
  end;

procedure TXCoder.Store;
  begin
  S.Write(KeyMap, SizeOf(KeyMap));
  S.Write(MaxCodeTagLen, SizeOf(MaxCodeTagLen));
  S.Write(CodeTag, SizeOf(CodeTag));
  if KeyMap = kmXlat then
    S.Write(XLatCP[ToAscii], SizeOf(TXLat));
  end;

constructor TXCoder.Load;
  var
    FName: PString;
  begin
  S.Read(KeyMap, SizeOf(KeyMap));
  S.Read(MaxCodeTagLen, SizeOf(MaxCodeTagLen));
  S.Read(CodeTag, SizeOf(CodeTag));
  if KeyMap <> kmXlat then
    UseKeyMap
  else
    begin
    S.Read(XLatCP[ToAscii], SizeOf(TXLat));
    UseToAscii;
    end;
  end;

procedure TXCoder.UseToAscii;
  begin
  KeyMap := kmXlat;
  AcceptToAscii(XLatCP);
  end;

procedure TXCoder.UseKeyMap;
  begin
  XLatCP := KeyMapDescr[KeyMap].XLatCP^;
  CodeTag := KeyMapDescr[KeyMap].Tag;
  end;

procedure TXCoder.LoadXlatTable; {JO}
  var
    FN: String;
    More: Boolean;
    None: Boolean;
    Dr: String;
    Nm: String;
    Xt: String;
  label
    SkipMenu;
  begin
  More := True;
  None := KeyMap = kmXlat;
   if SkipXLatMenu then
     goto SkipMenu;
  FN := GetFileNameMenu(SourceDir+'XLT\', '*.XLT', FN, True, More, None);
  if None then
    begin
    UseKeyMap;
    Exit;
    end;
  if More then
SkipMenu:
    FN := GetFileNameDialog(SourceDir+'XLT\*.XLT',
        GetString(dlSelectXLT),
        GetString(dlOpenFileName),
        fdOKButton+fdHelpButton,
        hsOpenXLT);
  if BuildCodeTable(FN, XLatCP) then
    begin
    lFSplit(FN, Dr, Nm, Xt);
    CodeTag := Cut(Nm, MaxCodeTagLen);
    KeyMap := kmXlat;
    end;
  end { LoadXlatTable }; {JO}

procedure TXCoder.NextXLat;
  begin
  KeyMap := RollKeyMap[KeyMap];
  UseKeyMap;
  end;

procedure TXCoder.FromHistory(fKeyMap: TKeyMap;
      fToAscii: TXLat; fCodeTag: Str8);
  begin
  KeyMap := fKeyMap;
  CodeTag := fCodeTag;
  XLatCP[ToAscii] := fToAscii;
  if KeyMap = kmXlat then
    UseToAscii
  else
    UseKeyMap;
  end;

procedure TXCoder.ToHistory(var fKeyMap: TKeyMap;
      var fToAscii: TXLat; var fCodeTag: Str8);
  begin
  fKeyMap := KeyMap;
  fCodeTag := CodeTag;
  fToAscii := XLatCP[ToAscii];
  end;

end.
