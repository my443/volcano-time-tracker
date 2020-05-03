unit volcano_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, fpXMLXSDExport, FileUtil,
  fpdataexporter, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls,
  DbCtrls, ExtCtrls, Menus, IniPropStorage, ComCtrls, EditBtn, Form2, TimeEntry,
  entrylist, fpDBExport, LCLType;

type

  { TNavigation }

  TNavigation = class(TForm)
    Button1: TButton;
    InactiveCheck: TCheckBox;
    FilterDate: TDateEdit;
    DBGrid2: TDBGrid;
    ExportButton: TButton;
    MenuItem5: TMenuItem;
    NewFile: TMenuItem;
    OpenDialog1: TOpenDialog;
    NewFileSave: TSaveDialog;
    PageControl1: TPageControl;
    Panel2: TPanel;
    SaveExport: TSaveDialog;
    SQLQuery2: TSQLQuery;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TodayTab: TTabSheet;
    volcano_ini: TIniPropStorage;
    TimeEntries: TButton;
    TimeEntry: TButton;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    NewProject: TButton;
    Edit: TButton;
    Delete: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    ProjectsDatabase: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    XMLXSDExporter1: TXMLXSDExporter;
    procedure Button1Click(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure DBGrid2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DBGrid2KeyPress(Sender: TObject; var Key: char);

    procedure DeleteClick(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
    procedure FilterDateChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure InactiveCheckChange(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure NewFileClick(Sender: TObject);
    procedure NewProjectClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OpenDialog1Close(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ProjectsDatabaseAfterConnect(Sender: TObject);
    procedure deleteItem(Sender: TObject);
    procedure ResizeColumns(Sender: TObject);
    procedure EditRecord(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject);
    procedure TodayTabEnter(Sender: TObject);
    procedure TimeEntriesClick(Sender: TObject);
    procedure TimeEntryClick(Sender: TObject);
    procedure TodayTabExit(Sender: TObject);
    procedure TodayTabShow(Sender: TObject);
    procedure XMLXSDExporter1ExportRow(Sender: TObject; var AllowExport: Boolean
      );
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  Navigation: TNavigation;

const
  // Sets a line-break character that can be used in dialogue boxes, etc.
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF}
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};
implementation

{$R *.lfm}

{ TNavigation }



procedure TNavigation.FormCreate(Sender: TObject);
var d : TDate;
begin
  ShortDateFormat := 'mm/dd/yy';                          // Resets the date format for the application.
                                                           // Has been deprecated - should use:  DefaultFormatSettings instead.


  volcano_ini.restore;
  while ProjectsDatabase.DatabaseName = '' do
  Begin
    case QuestionDlg ('No database found','I cannot find your database.  What do you want to do?',mtCustom,[20,'Make a new database', 21, 'Open a database',22,'Quit'],'') of
       20: NewFileClick(Navigation);
       21: MenuItem2Click(Navigation);
       22: ShowMessage('Quit');
     end;
       //OpenDialog1.Execute;
       volcano_ini.Save;
       volcano_ini.restore;
  end;

  FilterDate.DateFormatChanged;
  FilterDate.Date := Now;


  StatusBar1.Panels[0].Text := ProjectsDatabase.DatabaseName;
  Button1Click(Button1);
  if (Form1 = nil) then Application.CreateForm(TForm1, Form1);         // Initialize Form1
  if (TimeForm = nil) then Application.CreateForm(TTimeForm, TimeForm);// Initialize TimeForm
  if (Entries = nil) then Application.CreateForm(TEntries, Entries);   // Initialize TimeForm
end;

procedure TNavigation.OpenDialog1Close(Sender: TObject);
var tempdbname : string;
begin

  //if OpenDialog1.Filename <> '' then
  //Begin
  //  SQLQuery1.close;
  //  ProjectsDatabase.Connected:= False;
  //  SQLTransaction1.Active:= False;
  //  ProjectsDatabase.DatabaseName := OpenDialog1.Filename;
  //  StatusBar1.SimpleText := ProjectsDatabase.DatabaseName;
  //  volcano_ini.Save;
  //end
  //Else
  //    volcano_ini.restore;
  //
  //Button1Click(Button1);

end;

procedure TNavigation.PageControl1Change(Sender: TObject);
begin

end;

procedure TNavigation.ProjectsDatabaseAfterConnect(Sender: TObject);
begin

end;

procedure TNavigation.Button1Click(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := ProjectsDatabase.DatabaseName;          // Not efficient, but catches all updates.
  if not InactiveCheck.Checked then
  Begin
       SQLQuery1.SQL.Text := 'Select Proj_PK as ID, cast(Proj_Name as TEXT) as PROJECT, cast(Proj_StartDate as TEXT) as START, CAST(Proj_EndDate AS TEXT) as END, Proj_Active as ACTIVE FROM projects where Proj_Active = 1';
  End
  else
  Begin
      SQLQuery1.SQL.Text := 'Select Proj_PK as ID, cast(Proj_Name as TEXT) as PROJECT, cast(Proj_StartDate as TEXT) as START, CAST(Proj_EndDate AS TEXT) as END, Proj_Active as ACTIVE FROM projects';
  End;

  ProjectsDatabase.Connected:= True;
  SQLTransaction1.Active:= True;
  SQLTransaction1.Commit;
  //DBGrid1.Columns[0].Visible:=false;                        Project Name
  SQLQuery1.Open;
  //ResizeColumns(Navigation);

end;

procedure TNavigation.DBGrid1CellClick(Column: TColumn);
var LastID : Integer;
begin
    //LastID := DataSet.FieldByName('ID').AsInteger;
    //LastID := 43;
    //SQLQuery1.Locate('ID', LastID, []);
    //ShowMessage(IntToStr(DBGrid1.SelectedIndex)) ; // Column number
    //DBGrid1.DataSource1.SQLQuery1.RecNo; // Row Number
end;

procedure TNavigation.DBGrid1ColumnSized(Sender: TObject);
begin
  //ResizeColumns(Navigation);
end;

procedure TNavigation.DBGrid2DblClick(Sender: TObject);
var LastID : integer;
begin
  LastID := SQLQuery1.FieldByName('Time_PK').AsInteger;         // Save the last row number

   TimeForm.Newtime := False;
   TimeForm.ProjectID   := SQLQuery1.Fields[0].AsInteger;                     // Give the TimeForm the Project ID
   TimeForm.ProjectName := SQLQuery1.Fields[2].AsString;                 //Pass the Projectname to the timeform
   TimeForm.ActivateForm:= True;                        // Tell the form it is the first-time activation

   if SQLQuery1.Fields[0].AsString <> '' then
   begin
     TimeForm.RecordID := SQLQuery1.Fields[1].AsInteger; // Tell the TimeForm the time entry record selected.
     TimeForm.ShowModal;
     SQLQUERY1.REFRESH;
   end;
   TodayTabShow(Navigation);                                // So that the sum of hours recalculates.
   SQLQuery1.Locate('Time_PK', LastID, []);                     // Go back to the last row number
end;

procedure TNavigation.DBGrid2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (KEY = VK_RETURN) OR (KEY = VK_SPACE) then
  Begin

       DBGrid2DblClick(Navigation);

  end;
end;

procedure TNavigation.DBGrid2KeyPress(Sender: TObject; var Key: char);
begin



end;

procedure TNavigation.ResizeColumns(Sender: TObject);
var
  wid, count, total_wid: integer;
begin
  total_wid := 0;
  for count := 0 to 5 do                           // Second counter changes to be all column less one
      Begin
         total_wid := total_wid + dbGrid1.Columns[0].Width;
      end;

  wid := dbGrid1.width - total_wid - 35;          // use GetSystemMetrics(SM_CYVSCROLL) for scrollbar width in Windows
  dbGrid1.Columns[1].Width := wid;
                                                  //Debugging: ShowMessage(IntToStr(dbGrid1.Columns[0].Width) +'+'+IntToStr(wid));

end;

procedure TNavigation.DeleteClick(Sender: TObject);
var message: string;
begin
  if not DBGrid1.DataSource.DataSet.IsEmpty then
  Begin
  message := 'Are you sure that you want to delete this project.'+sLineBreak+'Deleting the project will delete all of the time entries '+sLineBreak+'for this project also.';
  case QuestionDlg ('Delete item.',message,mtCustom,[mrYes,'Delete Selection', mrNo, 'Cancel'],'') of
      mrYes:
        Begin
          deleteItem(Navigation);
        end;
     end;
  end;
end;

procedure TNavigation.ExportButtonClick(Sender: TObject);
var LastID: integer;
    fn, filepath: string;
Begin
     SQLQuery2.SQL.Text := 'select projects.Proj_PK, projects.Proj_Name,  time.time_ProjectFK, time.Time_Date, time.Time_Hours, time.Time_Start, time.Time_End, Cast(time.Time_Memo as text) as Time_Memo from time inner join projects on projects.Proj_PK=time.time_ProjectFK';
     SQLQuery2.ExecSQL;
     SQLQuery2.Open;
     SQLQuery2.Refresh;

     XMLXSDExporter1.Filename := '';
     filepath := ExtractFilePath(SaveExport.Filename);
     SaveExport.Filename := '';
     SaveExport.InitialDir := filepath;

     if SaveExport.Execute then
     Begin
     fn := SaveExport.Filename;

     XMLXSDExporter1.FileName := ChangeFileExt(fn, '.xls');

     if FileExists(SaveExport.Filename) then
         case QuestionDlg ('File Exists','This file already exists.  Overwrite file?',mtCustom,[mrYes,'Overwrite file.', mrNo, 'Choose another filename.'],'') of
              mrYes:
                begin
                  // The export code
                  //LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number
                  //DBGrid1.DataSource.Dataset.First;
                  XMLXSDExporter1.execute;
                  //SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
                end;
              mrNo:  ExportButtonClick(Navigation);
         end;

     // The export code
     //LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number
     //DBGrid1.DataSource.Dataset.First;
     XMLXSDExporter1.execute;
     //SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
     end;

end;

procedure TNavigation.FilterDateChange(Sender: TObject);
begin
  TodayTabShow(Navigation);
end;

procedure TNavigation.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     volcano_ini.Save;
end;

procedure TNavigation.FormResize(Sender: TObject);
begin
  //Button1Click(Button1);
end;

procedure TNavigation.InactiveCheckChange(Sender: TObject);
begin
  Button1Click(Navigation);
end;

procedure TNavigation.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  Begin
      SQLQuery1.close;
      ProjectsDatabase.Connected:= False;
      SQLTransaction1.Active:= False;
      ProjectsDatabase.DatabaseName := OpenDialog1.Filename;
      StatusBar1.Panels[0].Text := ProjectsDatabase.DatabaseName;
      volcano_ini.Save;
    Button1Click(Button1);
 end;
end;

procedure TNavigation.MenuItem4Click(Sender: TObject);
begin
  ShowMessage('Volcano - A time tracking program.'+sLineBreak+sLineBreak+'Written by John van Dijk'+sLineBreak+sLineBreak+'This is free and unencumbered software released into the public domain.'+sLineBreak+''+sLineBreak+'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.');
end;

procedure TNavigation.MenuItem5Click(Sender: TObject);

  var LastID: integer;
      fn, filepath: string;
  Begin
       SQLQuery2.SQL.Text := 'select projects.Proj_PK, projects.Proj_Name,  time.time_ProjectFK, time.Time_Date, time.Time_Hours, time.Time_Start, time.Time_End, Cast(time.Time_Memo as text) as Time_Memo from time inner join projects on projects.Proj_PK=time.time_ProjectFK';
       SQLQuery2.ExecSQL;
       SQLQuery2.Open;

       XMLXSDExporter1.Filename := '';
       filepath := ExtractFilePath(SaveExport.Filename);
       SaveExport.Filename := '';
       SaveExport.InitialDir := filepath;

       SaveExport.Execute;
       fn := SaveExport.Filename;

       XMLXSDExporter1.FileName := ChangeFileExt(fn, '.xls');

       if FileExists(SaveExport.Filename) then
           case QuestionDlg ('File Exists','This file already exists.  Overwrite file?',mtCustom,[mrYes,'Overwrite file.', mrNo, 'Choose another filename.'],'') of
                mrYes:
                  begin
                    // The export code
                    //LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number
                    //DBGrid1.DataSource.Dataset.First;
                    XMLXSDExporter1.execute;
                    //SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
                  end;
                mrNo:  ExportButtonClick(Navigation);
           end;

       // The export code
       //LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number
       //DBGrid1.DataSource.Dataset.First;
       SQLQuery2.First;
       XMLXSDExporter1.execute;
       //SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number

end;

procedure TNavigation.NewFileClick(Sender: TObject);
var tempDBname: string;
begin
  NewFileSave.Filename := '';
  tempDBname := ProjectsDatabase.DatabaseName;

  if NewFileSave.Execute then
  Begin
    SQLQuery1.Close;
    SQLTransaction1.Active:= False;
    ProjectsDatabase.Connected:= False;
    DeleteFile(NewFileSave.Filename);
    SQLQuery1.SQL.Text :=  'CREATE TABLE "Projects" ('+
            '"Proj_PK" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
            '"Proj_Name" TEXT NOT NULL,'+
            '"Proj_StartDate" TEXT,'+
            '"Proj_EndDate" TEXT,'+
            '"Proj_Description" TEXT,'+
            '"Proj_Active" INTEGER NOT NULL'+
        ');';

    ProjectsDatabase.DatabaseName :=  NewFileSave.Filename;
    ProjectsDatabase.Connected:= True;
    SQLQuery1.ExecSQL;
    //SQLQuery1.Close;

    SQLQuery1.SQL.Text :='CREATE TABLE "time" ('+
            '"Time_PK" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'+
            '"Time_ProjectFK" INTEGER NOT NULL,'+
            '"Time_Date" TEXT,'+
            '"Time_Hours" TEXT,'+
            '"Time_Start" TEXT,'+
            '"Time_End" TEXT,'+
            '"Time_Memo" TEXT'+
        ');';
    SQLQuery1.ExecSQL;
      SQLTransaction1.Active:= True;
      SQLTransaction1.Commit;
      Button1Click(Navigation);
    End;

end;

procedure TNavigation.deleteItem(Sender: TObject);
var query_string, id: string;
begin
  id := SQLQuery1.Fields[0].AsString;
  query_string := 'delete  from projects where Proj_PK='+id;
  SQLQuery1.SQL.Text := query_string;

  SQLQuery1.ExecSQL;
  //SQLTransaction1.Commit;

  query_string := 'delete  from time where Time_ProjectFK='+id;
  SQLQuery1.SQL.Text := query_string;

  SQLQuery1.ExecSQL;
  SQLTransaction1.Commit;

  //SQLQuery1.close;
  Button1Click(Button1);
end;

procedure TNavigation.NewProjectClick(Sender: TObject);
begin

  Form1.RecordID := -1;
  Form1.ActivateForm := True;

  Form1.ShowModal;

  //SQLQuery1.Open;
  //SQLQuery1.Edit;
  //SQLQuery1.UpdateMode:=UpWhereChanged;
  //SQLQuery1.ApplyUpdates;
  SQLTransaction1.Commit;
  //SQLQuery1.Close;
  Button1Click(Button1);
end;

procedure TNavigation.EditClick(Sender: TObject);
begin
     // Form1.RecordID := SQLQuery1.Fields[0].AsInteger;
     //Form1.ActivateForm := True;
     //
     //Form1.ShowModal;
     //SQLTransaction1.Commit;
     //Button1Click(Button1);
     EditRecord(Navigation);
end;

procedure TNavigation.EditRecord(Sender: TObject);
var LastID: integer;
Begin
  LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number

  if SQLQuery1.Fields[0].AsString <> '' then
  begin
    Form1.RecordID := SQLQuery1.Fields[0].AsInteger;
    Form1.ActivateForm := True;

    Form1.ShowModal;
    SQLTransaction1.Commit;
  end;
  Button1Click(Button1);

  SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
end;

procedure TNavigation.TabSheet1Show(Sender: TObject);
begin
  SQLQuery1.Close;
  StatusBar1.Panels[1].Text := '';
  Button1Click(Navigation);
end;

procedure TNavigation.TodayTabEnter(Sender: TObject);
begin

end;

procedure TNavigation.TimeEntriesClick(Sender: TObject);
var LastID: integer;
begin
  LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number

  Entries.RecordID := SQLQuery1.Fields[0].AsInteger;
  Entries.ProjectName := SQLQuery1.Fields[1].AsString;
  Entries.ShowModal;
  SQLTransaction1.Commit;
  Button1Click(Button1);

  SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
end;

procedure TNavigation.TimeEntryClick(Sender: TObject);
var LastID: integer;
begin
  LastID := SQLQuery1.FieldByName('ID').AsInteger;         // Save the last row number

  TimeForm.ProjectID := SQLQuery1.Fields[0].AsInteger;
  TimeForm.ProjectName := SQLQuery1.Fields[1].AsString;
  TimeForm.ActivateForm := True;
  TimeForm.NewTime := True;
  TimeForm.ShowModal;

  SQLTransaction1.Commit;
  SQLQuery1.Close;
  SQLQuery1.Open;

  SQLQuery1.Locate('ID', LastID, []);                     // Go back to the last row number
end;

procedure TNavigation.TodayTabExit(Sender: TObject);
begin
  //
end;

procedure TNavigation.TodayTabShow(Sender: TObject);
var DateForFilter, sum : String;
begin
  DateForFilter := FilterDate.Text;

  SQLQuery1.Close;
  // Find the number of hours.
  SQLQuery1.SQL.text :='Select sum(Time_Hours) from time where Time_Date='+chr(39)+DateForFilter+chr(39);
  SQLQuery1.Open;

  sum :=  SQLQuery1.Fields[0].AsString;
  StatusBar1.Panels[1].Text := 'Total Hours: '+ sum;
  SQLQuery1.Close;

  // Populate the Grid
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'select projects.Proj_PK, time.Time_PK, Cast(projects.Proj_Name as text) as Proj_Name,  time.time_ProjectFK, Cast(time.Time_Date as Text) as Time_Date, Cast(time.Time_Hours as Text) as Hours, Cast(time.Time_Start as Text) as Time_Start, Cast(time.Time_End as Text) as Time_End , Cast(time.Time_Memo as text) as Time_Memo from time inner join projects on projects.Proj_PK=time.time_ProjectFK where time.Time_Date='+chr(39)+DateForFilter+chr(39)+' ORDER BY time.Time_Start';
  SQLQuery1.ExecSQL;
  SQLQuery1.Open;
  SQLQuery1.Refresh;


  dbGrid2.Columns[0].visible := False;
  //dbGrid2.Columns[1].Width := 100;
  //dbGrid2.Columns[2].Width := 64;
  //dbGrid2.Columns[3].Width := 64;
  //dbGrid2.Columns[4].Width := 64;
  //dbGrid2.Columns[5].Width := 135;
  Navigation.ActiveControl := DBGrid2;
end;

procedure TNavigation.XMLXSDExporter1ExportRow(Sender: TObject;
  var AllowExport: Boolean);
begin

end;

procedure TNavigation.DBGrid1DblClick(Sender: TObject);
begin
  //ShowMessage(IntToStr(DBGrid1.DataSource.DataSet.RecNo));
  //ShowMessage(SQLQuery1.Fields[0].AsString);       // SSQLQuery1 is the Dataset
                                                   // Fields[0] is the Proj_PK
 // EditRecord(Navigation);
  TimeEntriesClick(Navigation);
end;

end.

