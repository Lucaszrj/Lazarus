unit Unit7;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Unit2,
  StdCtrls, DBGrids, fphttpclient, fpjson, jsonparser, DB, memds, DateUtils,
  opensslsockets, LCLType, DBCtrls;

type

  { TProdutoCadastro }

  TProdutoCadastro = class(TForm)
    Alterar: TButton;
    Consultar: TButton;
    DataSourcegrupo: TDataSource;
    DataSourceProduto: TDataSource;
    DBGrid1: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    Deletar: TButton;
    EditBusca: TEdit;
    FecharCliente: TButton;
    Incluir: TButton;
    MemDatasetgrupo: TMemDataset;
    MemDatasetgrupoid: TLongintField;
    MemDatasetgruponome: TStringField;
    MemDatasetProduto: TMemDataset;
    MemDatasetProdutoID_Grupo: TLongintField;
    MemDatasetProdutoNome: TStringField;
    MemDatasetProdutoPreco: TStringField;
    MemDatasetProdutoRef: TLongintField;
    procedure ConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
        procedure ConsultarProdutoDaAPI;
        procedure ConsultarGrupoDaAPI;
  end;

var
  ProdutoCadastro: TProdutoCadastro;

implementation

{$R *.lfm}


{ TProdutoCadastro }

procedure TProdutoCadastro.ConsultarClick(Sender: TObject);
begin
  consultarGrupoDaAPI;
  ConsultarProdutoDaAPI;

end;




procedure TProdutoCadastro.FormCreate(Sender: TObject);
begin
  with MemDatasetgrupo.FieldDefs do
  begin
    Clear;
    Add('id', ftInteger);
    Add('nome', ftString, 100); // 100 é o tamanho do campo
  end;

  MemDataSetGrupo.CreateTable;
    // MemDatasetgrupo.Open;     // 1º: Abre o dataset do grupo (para popular o Lookup)
 //    MemDataSetProduto.Open;   // 2º: Depois abre o dataset principal (produto)

end;



procedure TProdutoCadastro.ConsultarProdutoDaAPI;
  var
  HTTP: TFPHTTPClient;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  i: Integer;
begin
  HTTP := TFPHTTPClient.Create(nil);
  try
    JSONData := GetJSON(HTTP.Get('http://localhost:8080/produto'));
    JSONArray := TJSONArray(JSONData);

    // CONFIGURAR CAMPOS DO DATASET
    if MemDatasetProduto.Active then
      MemDatasetProduto.Close;

    MemDatasetProduto.FieldDefs.Clear;
    MemDatasetProduto.FieldDefs.Add('Ref', ftInteger);
    MemDatasetProduto.FieldDefs.Add('Nome', ftString, 255);
    MemDatasetProduto.FieldDefs.Add('ID_Grupo', ftInteger);
    MemDatasetProduto.FieldDefs.Add('Preco', ftFloat);
    MemDatasetProduto.CreateTable;
    MemDatasetProduto.Open;

    // PREENCHER COM DADOS DO JSON
    for i := 0 to JSONArray.Count - 1 do
    begin
      MemDatasetProduto.Append;
      MemDatasetProduto.FieldByName('Ref').AsInteger        := JSONArray.Objects[i].Get('id', 0);
      MemDatasetProduto.FieldByName('Nome').AsString       := JSONArray.Objects[i].Get('nome', '');
      MemDatasetProduto.FieldByName('ID_Grupo').AsInteger       := JSONArray.Objects[i].Get('id_grupo', 0);
      MemDatasetProduto.FieldByName('Preco').AsFloat   := JSONArray.Objects[i].Get('preco', 0.0);
      MemDatasetProduto.Post;
    end;

  finally
    HTTP.Free;
    JSONData.Free;
  end;
end;

procedure TProdutoCadastro.ConsultarGrupoDaAPI;
  var
    HTTP: TFPHTTPClient;
    JSONData: TJSONData;
    JSONArray: TJSONArray;
    i: Integer;
begin
  HTTP := TFPHTTPClient.Create(nil);
   try
     JSONData := GetJSON(HTTP.Get('http://localhost:8080/grupo'));
     JSONArray := TJSONArray(JSONData);

     // CONFIGURAR CAMPOS DO DATASET
     if MemDatasetgrupo.Active then
       MemDatasetgrupo.Close;

     MemDatasetgrupo.FieldDefs.Clear;
     MemDatasetgrupo.FieldDefs.Add('id', ftInteger);
     MemDatasetgrupo.FieldDefs.Add('nome', ftString, 80);
     MemDatasetgrupo.CreateTable;
     MemDatasetgrupo.Open;

     // PREENCHER COM DADOS DO JSON
     for i := 0 to JSONArray.Count - 1 do
     begin
       MemDatasetgrupo.Append;
       MemDatasetgrupo.FieldByName('id').AsInteger        := JSONArray.Objects[i].Get('id', 0);
       MemDatasetgrupo.FieldByName('nome').AsString       := JSONArray.Objects[i].Get('nome', '');
       MemDatasetgrupo.Post;
     end;

   finally
     HTTP.Free;
     JSONData.Free;
   end;
 end;

end.

