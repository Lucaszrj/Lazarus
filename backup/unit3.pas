unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  EditBtn, DateTimePicker, fphttpclient, LCLType, MaskEdit,
  opensslsockets, fpjson, jsonparser;

type

  { TIncluirCliente }

  TIncluirCliente = class(TForm)
    BtIncluir: TButton;
    BClose: TButton;
    CheckAtivo: TCheckBox;
    Cep: TEditButton;
    DateTime: TDateTimePicker;
    EditCidade: TEdit;
    EditEndereco: TEdit;
    EditNome: TEdit;
    Label1: TLabel;
    LabelEndereco: TLabel;
    LabelCep: TLabel;
    LabelCidade: TLabel;
    LabelNome: TLabel;
    MemoCep: TMemo;
    RadioSexo: TRadioGroup;
    procedure BCloseClick(Sender: TObject);
    procedure BtIncluirClick(Sender: TObject);
    procedure CepButtonClick(Sender: TObject);
    procedure CepKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CepKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);


  private
  public
     procedure LimparCampos;
     procedure BuscarCep;
  end;

var
  IncluirCliente: TIncluirCliente;

implementation

{$R *.lfm}

{ TIncluirCliente }





procedure TIncluirCliente.BtIncluirClick(Sender: TObject);
var
  HTTP: TFPHTTPClient;
  JsonBody: TJSONObject;
  RequestStream, ResponseStream: TStringStream;
begin
// Verificação do campo obrigatório CEP
if Trim(Cep.Text) = '' then
begin
  ShowMessage('O campo CEP está vazio. Preencha antes de continuar!');
  Cep.SetFocus;
  Exit;
end;
//Nome
if Trim(EditNome.Text) = '' then
begin
  ShowMessage('O campo Nome está vazio. Preencha antes de continuar!');
  EditNome.SetFocus;
  Exit;
end;
//endereco
if Trim(EditEndereco.Text) = '' then
begin
  ShowMessage('O campo Endereço está vazio. Preencha antes de continuar!');
  EditEndereco.SetFocus;
  Exit;
end;
//dt
if DateTime.Date = EncodeDate(1900, 1, 1) then
begin
  ShowMessage('Por favor, selecione a data de nascimento.');
  DateTime.SetFocus;
  Exit;
end;
//EditCidade
if Trim(EditCidade.Text) = '' then
begin
  ShowMessage('O campo Cidade está vazio. Preencha antes de continuar!');
  EditCidade.SetFocus;
  Exit;
end;


// Descobre qual sexo foi selecionado
if RadioSexo.ItemIndex = -1 then
begin
  ShowMessage('Por favor, selecione o sexo.');
  RadioSexo.SetFocus;
  Exit;
end;

// Cria o JSON com os dados
JsonBody := TJSONObject.Create;
try
  JsonBody.Add('nome', EditNome.Text);
  JsonBody.Add('dtNascimento', FormatDateTime('yyyy-mm-dd', DateTime.Date));
  JsonBody.Add('sexo', RadioSexo.Items[RadioSexo.ItemIndex]);
  JsonBody.Add('endereco', EditEndereco.Text);
  JsonBody.Add('cidade', EditCidade.Text);
  JsonBody.Add('ativo', CheckAtivo.Checked);
  JsonBody.Add('cep', Cep.Text);

  // Envia para API
  RequestStream := TStringStream.Create(JsonBody.AsJSON);
  ResponseStream := TStringStream.Create('');
  HTTP := TFPHTTPClient.Create(nil);
  try
    HTTP.AddHeader('Content-Type', 'application/json');
    HTTP.RequestBody := RequestStream;
    HTTP.Post('http://localhost:8080/cliente', TStringStream.Create(JsonBody.AsJSON));

    //ShowMessage('Resposta da API:' + sLineBreak + ResponseText);
    //ShowMessage('Cliente incluído com sucesso!' + sLineBreak + ResponseText);
  finally
    HTTP.Free;
    RequestStream.Free;
    ResponseStream.Free;
  end;
finally
  JsonBody.Free;
end;

   //LimparCampos;
   if MessageDlg('Cliente incluído com sucesso!' + sLineBreak + 'Deseja incluir outro cliente?',
              mtConfirmation, [mbYes, mbNo], 0) = mrYes then
begin
  LimparCampos;      // limpa os campos para nova inclusão
  EditNome.SetFocus; // foca no primeiro campo
end
else
begin
  LimparCampos;
  Close;             // fecha a tela
end;

end;

procedure TIncluirCliente.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TIncluirCliente.LimparCampos;
begin
  IncluirCliente.EditNome.Clear;
  IncluirCliente.EditEndereco.Clear;
  IncluirCliente.EditCidade.Clear;
  IncluirCliente.Cep.Clear;
  IncluirCliente.DateTime.Date := Date;
  IncluirCliente.RadioSexo.ItemIndex := -1;
  IncluirCliente.CheckAtivo.Checked := True;
end;

procedure TIncluirCliente.CepButtonClick(Sender: TObject);
begin
       BuscarCep
end;


procedure TIncluirCliente.CepKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    BuscarCep;
    Key := 0;
  end
  else if Key = VK_TAB then
  begin
    BuscarCep;
    // Não zera o Key: TAB ainda funciona normalmente
  end;
end;

procedure TIncluirCliente.CepKeyPress(Sender: TObject; var Key: char);
begin
  // Só permite números e backspace
  if not (Key in ['0'..'9', #8]) then
    begin
      Key := #0;
      Exit;
    end;

  // Aplica a máscara "#####-###" automaticamente
  if (Length(Cep.Text) = 5) and (Key <> #8) then
  begin
    Cep.Text := Cep.Text + '-';
    Cep.SelStart := Length(Cep.Text); // Move o cursor pro final

  end;

  // Impede digitação após 9 caracteres (sem contar backspace)
  //if (Length(Cep.Text) >= 9) and (Key <> #8) then
   // Key := #0;
end;



procedure TIncluirCliente.FormCreate(Sender: TObject);
begin
DateTimePicker1.Date := Date;  // Ajuste o nome do componente aqui
RadioSexo.ItemIndex := 0;
CheckAtivo.Checked := True;
end;



procedure TIncluirCliente.BuscarCep;
var
     client: TFPHTTPClient;
     response: TStringStream;
     jsonData: TJSONData;
     cepedit: String;
begin

     cepedit := Trim(Cep.Text);

     //Validação básica
     if (cepedit = '') or (Length(cepedit) <> 9) then
     begin
        ShowMessage('Digite um CEP válido (apenas 9 números).');
        Exit;
     end;

     client := TFPHTTPClient.Create(nil);
     response := TStringStream.Create('');

try
      client.AddHeader('User-Agent', 'Mozilla/5.0');  // ReceitaWS exige um user-agent
      client.SimpleGet('http://viacep.com.br/ws/' + cepedit + '/json/',response);

       // Mostrar JSON no Memo
       MemoCep.Lines.Text := response.DataString;

       // Parse do JSON
       jsonData := GetJSON(response.DataString);
       // Preenchendo os TEdit com os dados do JSON
       EditEndereco.Text := jsonData.FindPath('logradouro').AsString;
       //EditBairro.Text     := jsonData.FindPath('bairro').AsString;
       EditCidade.Text     := jsonData.FindPath('localidade').AsString;
       //EditUF.Text         := jsonData.FindPath('uf').AsString;
       Cep.Text        := jsonData.FindPath('cep').AsString;


       // Preencher os campos do dataset com os dados do JSON
       //MemDataset1.FieldByName('Cep').AsString        := cep;
       //MemDataset1.FieldByName('Endereco').AsString   := jsonData.FindPath('logradouro').AsString;
       //MemDataset1.FieldByName('cidade').AsString     := jsonData.FindPath('localidade').AsString;
       //MemDataset1.FieldByName('uf').AsString         := jsonData.FindPath('uf').AsString;
       //MemDataset1.Post;

       jsonData.Free;

     except
       on E: Exception do
         ShowMessage('Erro: ' + E.Message);
     end;
     response.Free;
     client.Free;



end;




end.

