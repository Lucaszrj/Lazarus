program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, datetimectrls, Unit1, Unit2, Unit3, Unit4
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TCadastroPrincipal, CadastroPrincipal);
  Application.CreateForm(TClienteCadastro, ClienteCadastro);
  Application.CreateForm(TIncluirCliente, IncluirCliente);
  Application.CreateForm(TAlterarCliente, AlterarCliente);
  Application.Run;
end.

