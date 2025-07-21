unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Unit2;

type

  { TCadastroPrincipal }

  TCadastroPrincipal = class(TForm)
    Cliente: TButton;
    CadastroFornecedor: TButton;
    CadastroProduto: TButton;
    procedure ClienteClick(Sender: TObject);
  private

  public

  end;

var
  CadastroPrincipal: TCadastroPrincipal;

implementation

{$R *.lfm}

{ TCadastroPrincipal }

//testegit
//teste

procedure TCadastroPrincipal.ClienteClick(Sender: TObject);
  var
  i: Integer;
  ClienteForm: TClienteCadastro;
begin
  {– Procura instância já aberta –}
  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i] is TClienteCadastro then
    begin
      with TClienteCadastro(Screen.Forms[i]) do
      begin
        { Se estiver minimizado, restaura }
        if WindowState = wsMinimized then
          WindowState := wsNormal;

        Show;        { garante que está visível }
        BringToFront;
        Activate;    { foca sem disparar exceção }
      end;
      Exit;          { Já existia → sai }
    end;

  {– Caso não exista, cria –}
  ClienteForm  := TClienteCadastro.Create(Self);   { Self (FormPrincipal) será o Owner }

  ClienteForm .Show;
end;

end.

