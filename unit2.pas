unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, fphttpclient, fpjson, jsonparser, DB, memds,DateUtils,
  Unit3, opensslsockets, LCLType, Unit4;

type

  { TClienteCadastro }

  TClienteCadastro = class(TForm)
    Alterar: TButton;
    FecharCliente: TButton;
    Deletar: TButton;
    EditBusca: TEdit;
    Incluir: TButton;
    Consultar: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    MemDataset1: TMemDataset;
    MemDataset1Ativo: TBooleanField;
    MemDataset1Cep: TStringField;
    MemDataset1Cidade: TStringField;
    MemDataset1Endereco: TStringField;
    MemDataset1Nascimento: TStringField;
    MemDataset1Nome: TStringField;
    MemDataset1Ref: TLongintField;
    MemDataset1Sexo: TStringField;
    procedure AlterarClick(Sender: TObject);
    procedure ConsultarClick(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DeletarClick(Sender: TObject);
    procedure EditBuscaChange(Sender: TObject);
    procedure EditBuscaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FecharClienteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure IncluirClick(Sender: TObject);
    procedure MemDataset1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    procedure ExcluirCLienteDaAPI;
  public
    procedure CarregarClientesDaAPI;
  end;

var
  ClienteCadastro: TClienteCadastro;

implementation

uses unit1;

{$R *.lfm}

{ TClienteCadastro }

var
  FiltroTexto: String;

procedure TClienteCadastro.FormCreate(Sender: TObject);
begin
    MemDataset1.OnFilterRecord := @MemDataset1FilterRecord;
end;

Procedure TClienteCadastro.ExcluirCLienteDaAPI;
var
  ID: Integer;
  Nome: String;
  HTTP: TFPHTTPClient;
  URL: String;
begin

  // Verifica se há registro selecionado
  if not DataSource1.DataSet.Active or DataSource1.DataSet.IsEmpty then
  begin
    ShowMessage('Nenhum cliente selecionado.');
    Exit;
  end;


  ID      := DataSource1.DataSet.FieldByName('Ref.').AsInteger;
  Nome    := DataSource1.DataSet.FieldByName('Nome').AsString;

  // Confirmação
  if MessageDlg('Deseja realmente excluir o cliente Ref: ' + IntToStr(ID) + '-' +Nome + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    Exit;


  HTTP := TFPHTTPClient.Create(nil);
  try
    URL := 'http://localhost:8080/cliente/' + IntToStr(ID);
    HTTP.Delete(URL);
    ShowMessage('Cliente excluído com sucesso!');
  except
    on E: Exception do
      ShowMessage('Erro ao excluir cliente: ' + E.Message);
  end;
  HTTP.Free;


  CarregarClientesDaAPI;
end;
procedure TClienteCadastro.IncluirClick(Sender: TObject);
var
i: Integer;
IncluirClienteForm: TIncluirCliente;
begin
{– Procura instância já aberta –}
for i := 0 to Screen.FormCount - 1 do
  if Screen.Forms[i] is TIncluirCliente then
  begin
    with TIncluirCliente(Screen.Forms[i]) do
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
IncluirClienteForm  := TIncluirCliente.Create(Self);   { Self (FormPrincipal) será o Owner }

IncluirClienteForm .Show;
end;

procedure TClienteCadastro.MemDataset1FilterRecord(DataSet: TDataSet;  var Accept: Boolean);
var
   NomeCampo: String;
   RefCampo: Integer;
begin
     if FiltroTexto = '' then
     begin
       Accept := True;
       Exit;
     end;

     NomeCampo := UpperCase(DataSet.FieldByName('nome').AsString);
     RefCampo  := DataSet.FieldByName('ref.').AsInteger;

     Accept := (Pos(UpperCase(FiltroTexto), NomeCampo) > 0) or
               (Pos(UpperCase(FiltroTexto), IntToStr(RefCampo)) > 0);
end;

procedure TClienteCadastro.ConsultarClick(Sender: TObject);
begin
      CarregarClientesDaAPI;
end;

procedure TClienteCadastro.AlterarClick(Sender: TObject);

begin
  if not MemDataset1.Active or MemDataset1.IsEmpty then
  begin
    ShowMessage('Nenhum cliente selecionado!');
    Exit;
  end;

  // Cria a tela de edição
  with TAlterarCliente.Create(Self) do
  begin
    // Passa os dados do cliente selecionado
    EditNome.Text      := MemDataset1.FieldByName('Nome').AsString;

    if MemDataset1.FieldByName('Sexo').AsString = 'Masculino' then
  RadioSexo.ItemIndex := 0
else if MemDataset1.FieldByName('Sexo').AsString = 'Feminino' then
  RadioSexo.ItemIndex := 1
else
  RadioSexo.ItemIndex := -1; // Nenhum selecionado

    EditEndereco.Text  := MemDataset1.FieldByName('Endereco').AsString;
    EditCidade.Text    := MemDataset1.FieldByName('Cidade').AsString;
    Cep.Text           := MemDataset1.FieldByName('Cep').AsString;
    CheckAtivo.Checked := MemDataset1.FieldByName('Ativo').AsBoolean;

    // Parse da data
    try
      DateTime.Date := StrToDate(MemDataset1.FieldByName('Nascimento').AsString);
    except
      DateTime.Date := Now;
    end;

    // Armazena o ID do cliente que será alterado (em uma variável pública)
    ClienteID := MemDataset1.FieldByName('Ref.').AsInteger;

    ShowModal;  // Mostra a tela para edição

    Free;
  end;
end;

procedure TClienteCadastro.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_DELETE then
  begin
    ExcluirCLienteDaAPI;
    Key := 0;
  end;
end;




procedure TClienteCadastro.DeletarClick(Sender: TObject);
begin
  ExcluirCLienteDaAPI;
end;






procedure TClienteCadastro.CarregarClientesDaAPI;
var
  HTTP: TFPHTTPClient;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  i: Integer;
  dtNascimentoStr: String;
  dtNascimento: TDateTime;
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
    MemDataset1.FieldDefs.Add('Sexo', ftString, 20);
    MemDataset1.FieldDefs.Add('Nascimento', ftString, 90);
    MemDataset1.FieldDefs.Add('Endereco', ftString, 255);
    MemDataset1.FieldDefs.Add('Cidade', ftString, 255);
    MemDataset1.FieldDefs.Add('Ativo', ftBoolean);
    MemDataset1.FieldDefs.Add('Cep', ftString, 20);
    MemDataset1.CreateTable;
    MemDataset1.Open;

    // PREENCHER COM DADOS DO JSON
    for i := 0 to JSONArray.Count - 1 do
    begin
      MemDataset1.Append;
      MemDataset1.FieldByName('Ref.').AsInteger        := JSONArray.Objects[i].Get('id', 0);
      MemDataset1.FieldByName('Nome').AsString       := JSONArray.Objects[i].Get('nome', '');
      MemDataset1.FieldByName('Sexo').AsString       := JSONArray.Objects[i].Get('sexo', '');
      dtNascimentoStr := JSONArray.Objects[i].Get('dtNascimento', '');
      if TryISO8601ToDate(dtNascimentoStr, dtNascimento) then
        MemDataset1.FieldByName('Nascimento').AsString := FormatDateTime('dd/mm/yyyy', dtNascimento)
      else
        MemDataset1.FieldByName('Nascimento').AsString := '';
      MemDataset1.FieldByName('Endereco').AsString   := JSONArray.Objects[i].Get('endereco', '');
      MemDataset1.FieldByName('Cidade').AsString     := JSONArray.Objects[i].Get('cidade', '');
      MemDataset1.FieldByName('Ativo').AsBoolean     := JSONArray.Objects[i].Get('ativo', False);
      MemDataset1.FieldByName('Cep').AsString        := JSONArray.Objects[i].Get('cep', '');
      MemDataset1.Post;
    end;

  finally
    HTTP.Free;
    JSONData.Free;
  end;
end;


procedure TClienteCadastro.EditBuscaChange(Sender: TObject);
begin
  FiltroTexto := Trim(EditBusca.Text);
  MemDataset1.Filtered := False;
  MemDataset1.Filtered := True;
end;

procedure TClienteCadastro.EditBuscaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    CarregarClientesDaAPI;
    Key := 0;
  end;
end;

procedure TClienteCadastro.FecharClienteClick(Sender: TObject);
begin
  Close;
  CadastroPrincipal.Show;
end;

procedure TClienteCadastro.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
      MemDataset1.Close;     // fecha o dataset
end;


end.

