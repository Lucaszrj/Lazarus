unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Unit2;

type

  { TProdutoCadastro }

  TProdutoCadastro = class(TClienteCadastro)
    procedure ConsultarClick(Sender: TObject);
  private

  public
       procedure ConsutarProdutoDaAPI;
  end;

var
  ProdutoCadastro: TProdutoCadastro;

implementation

{$R *.lfm}

{ TProdutoCadastro }

procedure TProdutoCadastro.ConsultarClick(Sender: TObject);
begin
  inherited;
  ConsutarProdutoDaAPI;

end;

procedure TProdutoCadastro.ConsutarProdutoDaAPI;
  var
  HTTP: TFPHTTPClient;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  i: Integer;
begin
  HTTP := TFPHTTPClient.Create(nil);
  try
    JSONData := GetJSON(HTTP.Get('http://localhost:8080/cliente'));
    JSONArray := TJSONArray(JSONData);

    // CONFIGURAR CAMPOS DO DATASET
    if MemDataset1.Active then
      MemDataset1.Close;

    MemDataset1.FieldDefs.Clear;
    MemDataset1.FieldDefs.Add('Ref.', ftInteger);
    MemDataset1.FieldDefs.Add('Nome', ftString, 255);
    MemDataset1.FieldDefs.Add('ID_Grupo', ftString, 20);
    MemDataset1.FieldDefs.Add('Preco', ftString, 10);
    MemDataset1.CreateTable;
    MemDataset1.Open;

    // PREENCHER COM DADOS DO JSON
    for i := 0 to JSONArray.Count - 1 do
    begin
      MemDataset1.Append;
      MemDataset1.FieldByName('Ref.').AsInteger        := JSONArray.Objects[i].Get('id', 0);
      MemDataset1.FieldByName('Nome').AsString       := JSONArray.Objects[i].Get('nome', '');
      MemDataset1.FieldByName('ID_Grupo').AsString       := JSONArray.Objects[i].Get('id_grupo', '');
      MemDataset1.FieldByName('Preco').AsString   := JSONArray.Objects[i].Get('preco', '');
      MemDataset1.Post;
    end;

  finally
    HTTP.Free;
    JSONData.Free;
  end;
end;

end.

