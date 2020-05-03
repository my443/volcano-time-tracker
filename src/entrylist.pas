unit entrylist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, ExtCtrls, StdCtrls, ComCtrls, TimeEntry;

type

  { TEntries }

  TEntries = class(TForm)
    CloseTime: TButton;
    DataSource1: TDataSource;
    SumDatasource: TDataSource;
    Proj_Title: TMemo;
    NewTime: TButton;
    EditTime: TButton;
    DeleteTime: TButton;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    SQLQuery1: TSQLQuery;
    SumTransaction: TSQLTransaction;
    StatusBar1: TStatusBar;
    SUMQuery: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure CloseTimeClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DeleteTimeClick(Sender: TObject);
    procedure EditTimeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NewTimeClick(Sender: TObject);
    procedure AddHours(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  var   RecordID: integer;
        ActivateForm: boolean;
        ProjectName: string;
        //NewTime: boolean;
  end;

var
  Entries: TEntries;

implementation

{$R *.lfm}

{ TEntries }

procedure TEntries.FormActivate(Sender: TObject);
var sum: String;
begin
   ShortDateFormat := 'mm/dd/yy';
   SQLQuery1.close;

   AddHours(Entries);

   // Then open the query to populate the grid.
   SQLQuery1.SQL.text:='Select Time_PK as ID, Cast(Time_Date as Text) as Time_Date, Cast(Time_Hours as Text) as Hours, Cast(Time_Start as Text) as Time_Start, Cast(Time_End as Text) as Time_End, cast(Time_Memo as Text) as Memo from time where Time_ProjectFK='+chr(39)+IntToStr(RecordID)+chr(39);

    //
    SQLQUERY1.Open;

    //ShowMessage(SQLQuery1.SQL.text);
    DBGrid1.Refresh;
    // You have to define the collumn widths programatically.
    //dbGrid1.Columns[0].Width := 35;
    dbGrid1.Columns[0].visible := False;
    dbGrid1.Columns[1].Width := 100;
    dbGrid1.Columns[2].Width := 64;
    dbGrid1.Columns[3].Width := 64;
    dbGrid1.Columns[4].Width := 64;
    dbGrid1.Columns[5].Width := 135;
    Proj_Title.Caption := ProjectName;
    //Proj_ID.Caption := 'Project # '+IntToStr(RecordID);

    StatusBar1.Panels[0].Text := 'Project # '+IntToStr(RecordID);
    SQLQUERY1.Fields[0].Visible:=False;


end;

procedure TEntries.FormCreate(Sender: TObject);
begin

end;

procedure TEntries.EditTimeClick(Sender: TObject);
begin
   TimeForm.Newtime := False;
   TimeForm.ProjectID   := RecordID;                     // Give the TimeForm the Project ID
   TimeForm.ProjectName := ProjectName;                 //Pass the Projectname to the timeform
   TimeForm.ActivateForm:= True;                        // Tell the form it is the first-time activation

   if SQLQuery1.Fields[0].AsString <> '' then
   begin
     TimeForm.RecordID := SQLQuery1.Fields[0].AsInteger; // Tell the TimeForm the time entry record selected.
     TimeForm.ShowModal;
     SQLQUERY1.REFRESH;
   end;
   AddHours(Entries);
   //ShowMessage(SQLQuery1.Fields[0].AsString);
end;

procedure TEntries.DeleteTimeClick(Sender: TObject);
var query_string, id, message: string;
begin
  if not DBGrid1.DataSource.DataSet.IsEmpty then
  Begin
     message := 'Are you sure that you want to delete this time Entry?';
     case QuestionDlg ('Delete item.',message,mtCustom,[mrYes,'Delete Selection', mrNo, 'Cancel'],'') of
      mrYes:
        Begin
          id := SQLQuery1.Fields[0].AsString;
          query_string := 'delete  from time where Time_PK='+id;
          SQLQuery1.SQL.Text := query_string;

          SQLQuery1.ExecSQL;
          SQLTransaction1.Commit;
          AddHours(Entries);
        end;
     end;
  end;

FormActivate(Entries);
end;

procedure TEntries.CloseTimeClick(Sender: TObject);
begin
  Entries.Close;
end;

procedure TEntries.DBGrid1CellClick(Column: TColumn);
begin
  EditTimeClick(Entries);
end;

procedure TEntries.DBGrid1DblClick(Sender: TObject);
begin
  EditTimeClick(Entries);
end;

procedure TEntries.NewTimeClick(Sender: TObject);
begin
  TimeForm.ProjectID := RecordID;
  TimeForm.ProjectName := ProjectName;
  TimeForm.ActivateForm := True;
  TimeForm.NewTime := True;
  TimeForm.ShowModal;
  SQLQuery1.Refresh;
  AddHours(Entries);
  //Navigation.SQLTransaction1.Commit;
  //Button1Click(Button1);
end;

procedure TEntries.AddHours(Sender: TObject);
var sum: string;
Begin
  SQLQuery1.close;

  // First find the number of hours.
  SQLQuery1.SQL.text :='Select sum(Time_Hours) from time where Time_ProjectFK='+chr(39)+IntToStr(RecordID)+chr(39);
  SQLQuery1.Open;

  sum :=  SQLQuery1.Fields[0].AsString;
  StatusBar1.Panels[1].Text := 'Total Hours: '+ sum;
  SQLQuery1.Close;

  // Then open the query to populate the grid.
  SQLQuery1.SQL.text:='Select Time_PK as ID, Cast(Time_Date as Text) as Time_Date, Cast(Time_Hours as Text) as Hours, Cast(Time_Start as Text) as Time_Start, Cast(Time_End as Text) as Time_End, cast(Time_Memo as Text) as Memo from time where Time_ProjectFK='+chr(39)+IntToStr(RecordID)+chr(39);

   //
   SQLQUERY1.Open;
End;


end.

