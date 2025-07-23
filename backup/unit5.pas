unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TIncluirProduto }

  TIncluirProduto = class(TForm)
    ButtonCancelar: TButton;
    ButtonSalvar: TButton;
    EditRef: TEdit;
    EditNome: TEdit;
    EditGrupo: TEdit;
    EditValor: TEdit;
    Grupo: TLabel;
    Valor: TLabel;
    Nome: TLabel;
    Ref: TLabel;
    procedure EditRefChange(Sender: TObject);
    procedure RefClick(Sender: TObject);
  private

  public

  end;

var
  IncluirProduto: TIncluirProduto;

implementation

{$R *.lfm}

{ TIncluirProduto }

end.

