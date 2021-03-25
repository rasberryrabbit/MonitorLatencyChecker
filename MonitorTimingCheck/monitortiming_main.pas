unit MonitorTiming_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Spin, OpenGLContext, GL, LazSerial, UniqueInstance;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ButtonChk: TButton;
    ButtonRF: TButton;
    ButtonOpen: TButton;
    CBCOMList: TComboBox;
    LazSerial1: TLazSerial;
    Memo1: TMemo;
    OpenGLControl1: TOpenGLControl;
    SpinEditPS: TSpinEdit;
    UniqueInstance1: TUniqueInstance;
    procedure Button1Click(Sender: TObject);
    procedure ButtonRFClick(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonChkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure OpenGLControl1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControl1Paint(Sender: TObject);
  public
    bComEnable: Boolean;
    bCheck: Boolean;

    procedure GetSystemComPort;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  LazSynaSer;

var
  bBlack: Boolean = True;


{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if bComEnable then
    LazSerial1.WriteData('PS'+char(SpinEditPS.Value));
  Mouse.CursorPos:=ClientToScreen(Point(OpenGLControl1.Left+5,OpenGLControl1.Top+5));
end;

procedure TForm1.ButtonRFClick(Sender: TObject);
begin
  GetSystemComPort;
end;

procedure TForm1.ButtonOpenClick(Sender: TObject);
begin
  if bComEnable then begin
    bComEnable:=False;
    LazSerial1.Close;
  end;

  LazSerial1.Device:=CBCOMList.Text;
  try
    LazSerial1.Open;
    bComEnable:=True;
  except
    on e:exception do
      ShowMessage(e.Message);
  end;
end;

procedure TForm1.ButtonChkClick(Sender: TObject);
begin
  bCheck:=False;
  ButtonChk.Font.Color:=clActiveCaption;
  if bComEnable then
    LazSerial1.WriteData('NNN');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key=$7a then begin
    bBlack:=not bBlack;
    OpenGLControl1.Paint;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  //OpenGLControl1.RealizeBounds;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  GetSystemComPort;
end;

procedure TForm1.LazSerial1RxData(Sender: TObject);
var
  s, si: string;
begin
  s:=LazSerial1.ReadData;
  si:=s[1]+IntToStr(PLongWord(@s[2])^);
  Memo1.Lines.Add(si);
  if (not bCheck) and (Length(s)>1) and (s[1]='O') then begin
    bCheck:=True;
  end;
end;

procedure TForm1.OpenGLControl1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TForm1.OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bBlack:=not bBlack;
  OpenGLControl1.Paint;
end;

procedure TForm1.OpenGLControl1Paint(Sender: TObject);
begin
  if bBlack then
    glClearColor(0.0, 0.0, 0.0, 1.0)
    else
      glClearColor(1.0, 1.0, 1.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  OpenGLControl1.SwapBuffers;
end;

procedure TForm1.GetSystemComPort;
begin
  CBCOMList.Items.Clear;
  CBCOMList.Items.Delimiter:=',';
  CBCOMList.Items.DelimitedText:=GetSerialPortNames;
  CBCOMList.ItemIndex:=CBCOMList.Items.Count-1;
end;

end.

