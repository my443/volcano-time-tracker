program volcano;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazdbexport, volcano_main, form2, TimeEntry, entrylist;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TNavigation, Navigation);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TTimeForm, TimeForm);
  Application.CreateForm(TEntries, Entries);
  Application.Run;
end.

