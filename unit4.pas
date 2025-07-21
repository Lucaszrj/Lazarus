unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Unit3,
  fphttpclient, fpjson, jsonparser, DateUtils;

type

  { TAlterarCliente }

  TAlterarCliente = class(TIncluirCliente)
    BTAlterarCliente: TButton;
    procedure BTAlterarClienteClick(Sender: TObject);
  private
    procedure SalvaAlteracaoDeCliente;
  public
    ClienteID: Integer;

  end;

var
  AlterarCliente: TAlterarCliente;

implementation


{$R *.lfm}

{ TAlterarCliente }

procedure TAlterarCliente.SalvaAlteracaoDeCliente;
 var
  HTTP: TFPHTTPClient;
  JSONData: TJSONObject;
  URL: String;
  JSONStream: TStringStream;
  Response: TStringStream;
  StatusCode: Integer;
begin
  HTTP := TFPHTTPClient.Create(nil);
  JSONData := TJSONObject.Create;


  try
    // Monta JSON com os dados atualizados
    JSONData.Add('id', ClienteID);
    JSONData.Add('nome', EditNome.Text);
    JSONData.Add('sexo', RadioSexo.Items[RadioSexo.ItemIndex]);
    JSONData.Add('endereco', EditEndereco.Text);
    JSONData.Add('cidade', EditCidade.Text);
    JSONData.Add('cep', Cep.Text);
    JSONData.Add('ativo', CheckAtivo.Checked);
    JSONData.Add('dtNascimento', FormatDateTime('yyyy-mm-dd', DateTime.Date));


    URL := 'http://localhost:8080/cliente/' + IntToStr(ClienteID);
    //ShowMessage('URL: ' + URL);
    //ShowMessage('JSON Enviado: ' + JSONData.AsJSON);


    JSONStream := TStringStream.Create(JSONData.AsJSON, TEncoding.UTF8);
    Response := TStringStream.Create('', TEncoding.UTF8);

    try
      HTTP.AddHeader('Content-Type', 'application/json; charset=UTF-8');
      HTTP.AddHeader('User-Agent', 'PostmanRuntime/7.44.1');
      HTTP.AddHeader('Accept', '*/*');
      HTTP.AddHeader('Cache-Control', 'no-cache');
      HTTP.AddHeader('Accept-Encoding', 'gzip, deflate, br');
      HTTP.AddHeader('Connection', 'keep-alive');
      HTTP.AddHeader('Content-Length', IntToStr(Length(JSONData.AsJSON)));


      try
        // Tenta usar HTTPMethod em vez de Put diretamente
        HTTP.RequestBody := JSONStream;
        HTTP.HTTPMethod('PUT', URL, Response, []);
      except
        on E: Exception do
        begin
          ShowMessage('Erro na requisição PUT: ' + E.Message);
          Exit;
        end;
      end;

    StatusCode := HTTP.ResponseStatusCode;
    //ShowMessage('Status HTTP: ' + IntToStr(StatusCode) + sLineBreak + 'Resposta: ' + Response.DataString);

      if (StatusCode >= 200) and (StatusCode < 300) then
      begin
        ModalResult := mrOK;
        ShowMessage('Cliente alterado com sucesso!');
      end
      else
        ShowMessage('Erro ao alterar cliente: ' + Response.DataString);

    finally
      JSONStream.Free;
      Response.Free;
    end;

    ModalResult := mrOK;

  finally
    JSONData.Free;
    HTTP.Free;
  end;
end;

procedure TAlterarCliente.BTAlterarClienteClick(Sender: TObject);
begin
    SalvaAlteracaoDeCliente;
end;

end.

