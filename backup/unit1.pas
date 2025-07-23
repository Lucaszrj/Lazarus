unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  Unit2, Unit5;

type

  { TCadastroPrincipal }

  TCadastroPrincipal = class(TForm)
    Cliente: TButton;
    CadastroFornecedor: TButton;
    CadastroProduto: TButton;
    procedure CadastroProdutoClick(Sender: TObject);
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
    if Screen.Forms[i].ClassType = TClienteCadastro then
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

procedure TCadastroPrincipal.CadastroProdutoClick(Sender: TObject);
  var
  j: Integer;
  ProdutoForm: TProdutoCadastro;
begin
  {– Procura instância já aberta –}
  for j := 0 to Screen.FormCount - 1 do
    if Screen.Forms[j].ClassType  =     TProdutoCadastro then
    begin
      with TProdutoCadastro(Screen.Forms[j]) do
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
  ProdutoForm  := TProdutoCadastro.Create(Self);   { Self (FormPrincipal) será o Owner }

  ProdutoForm .Show;
end;


end.

