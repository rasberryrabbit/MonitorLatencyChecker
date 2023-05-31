unit MonitorTiming_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Spin, OpenGLContext, GL, LazSerial, UniqueInstance, LazSynaSer,
  UExceptionLogger;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ButtonChk: TButton;
    ButtonRF: TButton;
    CBCOMList: TComboBox;
    ExceptionLogger1: TExceptionLogger;
    Label1: TLabel;
    LazSerial1: TLazSerial;
    Memo1: TMemo;
    OpenGLControl1: TOpenGLControl;
    SpinEditPS: TSpinEdit;
    TimerUSB: TTimer;
    UniqueInstance1: TUniqueInstance;
    procedure Button1Click(Sender: TObject);
    procedure ButtonCalClick(Sender: TObject);
    procedure ButtonRFClick(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonChkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
      const Value: string);
    procedure OpenGLControl1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure TimerUSBTimer(Sender: TObject);
  public
    bComEnable: Boolean;
    bCheck: Boolean;
    bDeviceChange: Boolean;

    procedure GetSerialPort;
    procedure GetSystemComPort;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  Windows;

var
  bBlack: Boolean = True;
  flt: longword = 0;
  tlt: longword = 0;
  OldWndProc:WNDPROC;


{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Clear;
  flt:=0;
  tlt:=0;
  if bComEnable then
    LazSerial1.WriteData('PS'+char(SpinEditPS.Value));
  Mouse.CursorPos:=ClientToScreen(Classes.Point(OpenGLControl1.Left+5,OpenGLControl1.Top+5));
end;

procedure TForm1.ButtonCalClick(Sender: TObject);
begin
  if bComEnable then begin
    bBlack:=False;
    OpenGLControl1.Paint;

    LazSerial1.WriteData('CA0');
  end;
end;

procedure TForm1.ButtonRFClick(Sender: TObject);
begin
  GetSerialPort;
end;

procedure TForm1.ButtonOpenClick(Sender: TObject);
begin

end;

procedure TForm1.ButtonChkClick(Sender: TObject);
begin
  bCheck:=False;
  ButtonChk.Font.Color:=clActiveCaption;
  if bComEnable then
    LazSerial1.WriteData('NNN');
end;

//device change
function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam): LRESULT; stdcall;
begin
  if uMsg = WM_DEVICECHANGE then begin
    Form1.bDeviceChange:=True;
    Form1.TimerUSB.Enabled:=True;
  end;
  Result := CallWindowProc(OldWndProc, Ahwnd, uMsg, WParam, LParam);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.OnException:=@ExceptionLogger1.HandleException;
  bDeviceChange:=False;
  OldWndProc := Windows.WNDPROC(SetWindowLongPtr(Self.Handle, GWL_WNDPROC, PtrInt(@WndCallback)));
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
  TimerUSB.Enabled:=True;
end;

procedure TForm1.LazSerial1RxData(Sender: TObject);
var
  s, si: string;
  lt: LongWord;
begin
  if not bComEnable then
    exit;
  s:=LazSerial1.ReadData;
  lt:=PLongWord(@s[2])^;
  si:=s[1]+IntToStr(lt);
  if Length(s)>1 then begin
    case s[1] of
    'O': if not bCheck then
           bCheck:=True;
    'T': if tlt<>0 then begin
           tlt:=(tlt+lt) div 2;
         end else
           tlt:=lt;
    'F': if flt<>0 then begin
           flt:=(flt+lt) div 2;
         end else
           flt:=lt;
    'C': si:=s;
    end;
  end;
  label1.Caption:=Format('W->B %2.3f ms, B->W %2.3f ms',[tlt/1000,flt/1000]);
  Memo1.Lines.Add(si);
end;

procedure TForm1.LazSerial1Status(Sender: TObject; Reason: THookSerialReason;
  const Value: string);
begin
  case Reason of
  HR_Connect: bComEnable:=True;
  HR_SerialClose: bComEnable:=False;
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

procedure TForm1.TimerUSBTimer(Sender: TObject);
begin
  TimerUSB.Enabled:=False;
  GetSerialPort;
end;

procedure TForm1.GetSystemComPort;
begin
  CBCOMList.Items.Clear;
  CBCOMList.Items.Delimiter:=',';
  CBCOMList.Items.DelimitedText:=GetSerialPortNames;
  CBCOMList.ItemIndex:=CBCOMList.Items.Count-1;
end;

procedure TForm1.GetSerialPort;
var
  i, j: Integer;
begin
  bDeviceChange:=False;
  GetSystemComPort;
  Cursor:=crHourGlass;
  for i:=0 to CBCOMList.Items.Count-1 do begin
    LazSerial1.Close;
    Sleep(50);
    LazSerial1.Device:=CBCOMList.Items[i];
    try
      LazSerial1.Open;
      // send dummy
      bCheck:=False;
      LazSerial1.WriteData('NNN');
      // wait response
      j:=0;
      while j<20 do begin
        Application.ProcessMessages;
        Sleep(10);
        Inc(j);
        if bCheck or bDeviceChange then
          break;
      end;
      // valid connect
      if bCheck then begin
        CBCOMList.ItemIndex:=i;
        break;
      end;
      if bDeviceChange then
          break;
    except
      on e:exception do begin
        bComEnable:=False;
        LazSerial1.Close;
        Memo1.Lines.Add(e.Message);
      end;
    end;
  end;
  if bDeviceChange then
      LazSerial1.Close;
  Cursor:=crDefault;
end;

end.

