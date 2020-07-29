unit uhidpas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, hidapi, LMessages, LCLIntf, LCLMessageGlue;

const
  LM_HID_READ = LM_USER+100;

type

  TUSB=class;

  { THidReader }

  THidReader=class(TThread)
    public
      HID:TUSB;
      Data:Array[0..63] of Byte;

      constructor Create(Owner:TUSB); overload;
      procedure Execute; override;
  end;

  { TUSB }
  TOnData = procedure (Data:PByte) of object;

  TUSB=class
    private
      FHandle:THandle;
      FReader:THidReader;
      FOndata:TOnData;
      procedure WndProc(var TheMessage: TLMessage);
    public
      device:phid_device;
      Data:array[0..63] of Byte;

      constructor Create; reintroduce;
      destructor Destroy; override;

      function Write(buf:PByte):Boolean;
      function Read(buf:PByte):Boolean;
      function Open(vid,pid:Word):Boolean;

      property OnData:TOnData read FOnData write FOndata;
      property Handle:THandle read FHandle;
  end;

implementation

uses
  Windows;

{ THidReader }

constructor THidReader.Create(Owner: TUSB);
begin
  inherited Create(True);
  FreeOnTerminate:=True;
  HID:=Owner;
  Resume;
end;

procedure THidReader.Execute;
var
  ret,i:Integer;
  buf:array[0..64] of Byte;
begin
  while not Terminated do begin
    if Assigned(HID) and Assigned(HID.device) then begin
      buf[0]:=0;
      ret:=hid_read_timeout(HID.device,@buf[0],65,1);
      if ret>0 then begin
        for i:=1 to 64 do
          HID.Data[i-1]:=buf[i];
        SendMessage(HID.Handle,LM_HID_READ,0,0);
      end;
    end;
  end;
end;

{ TUSB }

procedure TUSB.WndProc(var TheMessage: TLMessage);
begin
  if TheMessage.msg=LM_HID_READ then begin
    if Assigned(FOnData) then
      FOndata(@Data[0]);
  end;
  TheMessage.Result:=DefWindowProc(FHandle,TheMessage.msg,
                                   TheMessage.wParam,
                                   TheMessage.lParam);
end;

constructor TUSB.Create;
begin
  FReader:=nil;
  FHandle:=AllocateHWnd(@WndProc);
  hid_init;
end;

destructor TUSB.Destroy;
begin
  FReader.Terminate;
  DeallocateHWnd(FHandle);
  hid_exit;
  inherited Destroy;
end;

function TUSB.Write(buf: PByte): Boolean;
var
  bf:array[0..64] of byte;
begin
  if device=nil then
    exit;
  system.Move(buf^,bf[1],64);
  Result:=hid_write(device,buf,65)>0;
end;

function TUSB.Read(buf: PByte): Boolean;
begin
  buf^:=0;
  Result:=hid_read_timeout(device,buf,65,1)>0
end;

function TUSB.Open(vid, pid: Word): Boolean;
begin
  Result:=False;
  device:=hid_open(vid,pid,nil);
  if device<>nil then begin
    //hid_set_nonblocking(device,True);
    FReader:=THidReader.Create(Self);
    Result:=True;
  end;
end;

end.

