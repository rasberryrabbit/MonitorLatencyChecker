unit uForm_face;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  OpenGLContext, GL;

type

  { TFormFace }

  TFormFace = class(TForm)
    OpenGLControl1: TOpenGLControl;
    procedure FormCreate(Sender: TObject);
    procedure OpenGLControl1Paint(Sender: TObject);
  private
  public
    glface: GLclampf;
    procedure PaintBlack;
    procedure PaintWhite;
  end;

var
  FormFace: TFormFace;

implementation

{$R *.lfm}

{ TFormFace }

procedure TFormFace.FormCreate(Sender: TObject);
begin

end;

procedure TFormFace.OpenGLControl1Paint(Sender: TObject);
begin
end;

procedure TFormFace.PaintBlack;
begin

end;

procedure TFormFace.PaintWhite;
begin

end;

end.

