unit form2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, EditBtn, DbCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Memo1: TMemo;
    SaveButton: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Proj_Name_Edit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;

    procedure FormActivate(Sender: TObject);
    procedure Memo1Enter(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);

    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Proj_StartDateChange(Sender: TObject);
    procedure ProjectInsert();

    procedure updateProjectNum(Sender: TObject);

    Function CloseForm():Boolean;

  private
    { private declarations }


  public
    var   RecordID: integer;
          ActivateForm: boolean;
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
var
   closeNoQuestion: Boolean;
   projectName: string;

{$R *.lfm}

{ TForm1 }


procedure TForm1.Proj_StartDateChange(Sender: TObject);
begin

end;

Function TForm1.CloseForm():Boolean ;

Begin

  {This asks the question whether you want to save or not.
  If you want to quit it closes the dialog.
  Otherwise it returns you to the dialog.}
  case QuestionDlg ('Confirm Cancel.','Are you sure that you want to close without saving?',mtConfirmation,[mrYes, mrNo],'') of
      mrYes: CloseForm := True;
      mrNo : CloseForm := False;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     Form1.Close;
end;

procedure TForm1.ProjectInsert;
var emptydate : boolean;
begin
emptydate := false;

if (DateEdit1.text='') or (DateEdit2.Text = '') then
   Begin
   ShowMessage('Date field cannot be empty.');
   emptydate := true;
   end
Else
    Begin
    if RecordID = -1 then
      Begin

      SQLQuery1.Open;
      SQLQuery1.SQL.text:='INSERT INTO projects VALUES (:PK, :Proj_Name, :Proj_StartDate, :Proj_EndDate, :Proj_Description, :Proj_Active);';
      SQLQuery1.Params.ParamByName('Proj_Name').AsString         := Proj_Name_Edit.text;
      SQLQuery1.Params.ParamByName('Proj_StartDate').AsString    := DateEdit1.text;
      SQLQuery1.Params.ParamByName('Proj_EndDate').AsString      := DateEdit2.text;
      SQLQuery1.Params.ParamByName('Proj_Description').AsString  := Memo1.text;
      if Checkbox1.Checked = True then
          SQLQuery1.Params.ParamByName('Proj_Active').AsInteger  :=1
      else
          SQLQuery1.Params.ParamByName('Proj_Active').AsInteger  :=0;
      SQLQuery1.ExecSQL;
      SQLTransaction1.commit;
      end
      Else
      Begin
        SQLQuery1.Open;
        SQLQuery1.SQL.text:='UPDATE projects SET  Proj_name = :Proj_Name, Proj_StartDate= :Proj_StartDate, Proj_EndDate= :Proj_EndDate, Proj_Description= :Proj_Description, Proj_Active =:Proj_Active WHERE Proj_PK='+chr(39)+IntToStr(RecordID)+chr(39);
        SQLQuery1.Params.ParamByName('Proj_Name').AsString         := Proj_Name_Edit.text;
        SQLQuery1.Params.ParamByName('Proj_StartDate').AsString    := DateEdit1.text;
        SQLQuery1.Params.ParamByName('Proj_EndDate').AsString      := DateEdit2.text;
        SQLQuery1.Params.ParamByName('Proj_Description').AsString  := Memo1.text;
        if Checkbox1.Checked = True then
            SQLQuery1.Params.ParamByName('Proj_Active').AsInteger  :=1
        else
            SQLQuery1.Params.ParamByName('Proj_Active').AsInteger  :=0;
        SQLQuery1.ExecSQL;
        SQLTransaction1.commit;
      //SQLQuery1.Close;
      end;
      closeNoQuestion := True;                 // Set it so that no question is asked.
      Form1.Close;
    end;
end;

procedure TForm1.SaveButtonClick(Sender: TObject);
begin
     ProjectInsert();

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  closeNoQuestion := False ;
  if ActivateForm = True then
    Begin

  if RecordID = -1 then
  Begin
    SQLQuery1.SQL.text:='Select * FROM projects';
    SQLQuery1.Close;
    Proj_Name_Edit.Text := 'Project Name';                   // Assign a generic name to the project

    DateEdit1.Date := Now;
    DateEdit2.Date := Now+7;                          // Every project has a 7 day length assumed.

    Memo1.Text     := 'Project Description Here';
    Checkbox1.Checked := True;
  end
  else
  begin

    SQLQuery1.SQL.text:='Select * from projects where Proj_PK='+chr(39)+IntToStr(RecordID)+chr(39);

     SQLQuery1.Open;
     //SQLQuery1.Close;

    Proj_Name_Edit.Text    := SQLQuery1.Fields[1].AsString;

    DateEdit1.Date         := StrToDateTime(SQLQuery1.Fields[2].AsString);

    DateEdit2.Date         := StrToDateTime(SQLQuery1.Fields[3].AsString);
    Memo1.Text             := SQLQuery1.Fields[4].AsString;
    if StrToInt(SQLQuery1.Fields[5].AsString) = 0 then
       Checkbox1.Checked := False
    else
       Checkbox1.Checked := True;
  end;

  updateProjectNum(Form1);                          // Add the project number to the form

  Form1.ActiveControl := Form1.Proj_Name_Edit;      // Has to be the last thing that happesn
  Proj_Name_Edit.SelectAll;

    end;

  ActivateForm := False;

end;

procedure TForm1.Memo1Enter(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TForm1.updateProjectNum(Sender: TObject);
begin
   if RecordID = -1 then
      Label5.Caption := 'New Project'
   else
      Label5.Caption := 'Project # '+IntToStr(RecordID);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

     if closeNoQuestion = False then
          if CloseForm() = False then
               CanClose := False
          else
             Form1.Close
     else
         Form1.Close;
     closeNoQuestion := False;               // Has to be set to false, or else the next
                                             // time you open the form, it remembers the previous
                                             // value.
     Proj_Name_Edit.Text := projectName;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
ShortDateFormat := 'mm/dd/yy';
    SQLQuery1.SQL.text:='Select * FROM projects';     // This query can change to limit
    SQLQuery1.Close;
    closeNoQuestion := False;
    projectName := 'Project Name';                    // Assign a generic name to the project
    Proj_Name_Edit.Text := projectName;
    Form1.ActiveControl := Form1.Proj_Name_Edit;
end;

end.

