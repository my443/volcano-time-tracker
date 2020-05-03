unit TimeEntry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn;

type

  { TTimeForm }

  TTimeForm = class(TForm)
    SaveButton: TButton;
    CancelButton: TButton;
    DateEdit1: TDateEdit;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StartTime: TEdit;
    EndTime: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    ProjName: TMemo;
    Hours: TEdit;

    procedure CancelButtonClick(Sender: TObject);
    procedure DateEdit1KeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure HoursExit(Sender: TObject);
    procedure ConvertToHHHH(var min: integer);
    procedure HoursKeyPress(Sender: TObject; var Key: char);
    procedure TimeInsert();

    Function CloseForm():Boolean;
    procedure Memo1Enter(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  var   RecordID: integer;
        ActivateForm: boolean;
        ProjectID:   integer;
        ProjectName: string;
        NewTime: boolean;
  end;

var
  TimeForm: TTimeForm;

implementation
var
   closeNoQuestion: Boolean;
   projectName: string;

{$R *.lfm}

{ TTimeForm }

procedure TTimeForm.HoursExit(Sender: TObject);
var
   s: String;
   iValue, iCode, r: Integer;
begin
   s := Hours.Text;
   val(s, iValue, iCode);
   if (icode <> 0) or (ivalue <> 0) then
   Begin
      ShowMessage(FloatToStr(StrToFloat(Hours.Text) * 60));
      EndTime.Text := FloatToStr(StrToInt(StartTime.Text) + (StrToFloat(Hours.Text) * 60));
      ConvertToHHHH(iCode);
   end
   else
       ShowMessage('You entered '+Hours.Text);


end;

procedure TTimeForm.FormActivate(Sender: TObject);

begin
   ShortDateFormat := 'mm/dd/yy';
  if ActivateForm = True then
  begin


  if NewTime = True then
  begin
  SQLQuery1.SQL.text:='Select * from time';
  SQLQuery1.Open;

  DateEdit1.Date := Now;
  Hours.Text     := '0';
  StartTime.Text := '-';
  EndTime.Text   := '-';
  Memo1.Text     := 'Memo1';
  end
  else
  begin
    SQLQuery1.Close;
    SQLQuery1.SQL.text:='Select Time_PK as ID, Cast(Time_Date as Text) as Time_Date, Cast(Time_Hours as Text) as Hours, Cast(Time_Start as Text) as Time_Start, Cast(Time_End as Text) as Time_End, cast(Time_Memo as Text) as Memo from time where ID='+chr(39)+IntToStr(RecordID)+chr(39);
    SQLQuery1.Open;

    DateEdit1.Date := StrToDateTime(SQLQuery1.Fields[1].AsString);
    Hours.Text     := SQLQuery1.Fields[2].AsString;
    StartTime.Text := SQLQuery1.Fields[3].AsString;
    EndTime.Text   := SQLQuery1.Fields[4].AsString;
    Memo1.Text     := SQLQuery1.Fields[5].AsString;
  end;

  Label1.Caption := 'Project # '+IntToStr(ProjectID);
  ProjName.Caption := ProjectName;

  closeNoQuestion := False;

  SQLQuery1.close;
  end;

  ActivateForm := False;

  TimeForm.ActiveControl := TimeForm.Hours;      // Has to be the last thing that happesn
  Hours.SelectAll;
end;

procedure TTimeForm.CancelButtonClick(Sender: TObject);
begin
  TimeForm.Close;
end;

procedure TTimeForm.DateEdit1KeyPress(Sender: TObject; var Key: char);
begin

end;

Function TTimeForm.CloseForm():Boolean ;

Begin

  {This asks the question whether you want to save or not.
  If you want to quit it closes the dialog.
  Otherwise it returns you to the dialog.}
  case QuestionDlg ('Confirm Cancel.','Are you sure that you want to close without saving?',mtConfirmation,[mrYes, mrNo],'') of
      mrYes: CloseForm := True;
      mrNo : CloseForm := False;
  end;

end;

procedure TTimeForm.Memo1Enter(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TTimeForm.SaveButtonClick(Sender: TObject);
begin
     TimeInsert();

end;

procedure TTimeForm.TimeInsert;
var emptydate : boolean;
begin
emptydate := false;

if DateEdit1.text='' then
   Begin
   ShowMessage('Date field cannot be empty.');
   emptydate := true;
   end
Else
    Begin
      if NewTime = True then
      Begin

      SQLQuery1.Open;
      SQLQuery1.SQL.text:='INSERT INTO time VALUES (:Time_PK, :Time_ProjectFK, :Time_Date, :Time_Hours, :Time_Start, :Time_End, :Time_Memo)';
      SQLQuery1.Params.ParamByName('Time_ProjectFK').AsString         := IntToStr(ProjectID);
      SQLQuery1.Params.ParamByName('Time_Date').AsString         := DateEdit1.text;
      SQLQuery1.Params.ParamByName('Time_Hours').AsString        := Hours.text;
      SQLQuery1.Params.ParamByName('Time_Start').AsString        := StartTime.text;
      SQLQuery1.Params.ParamByName('Time_End').AsString        := EndTime.text;
      SQLQuery1.Params.ParamByName('Time_Memo').AsString        := Memo1.text;

      SQLQuery1.ExecSQL;
      //SQLTransaction1.commit;
      end
      Else
      Begin
        //SQLQuery1.Close;
        //SQLQuery1.Open;
        SQLQuery1.SQL.text:='UPDATE TIME SET  Time_Date = :Time_Date,  Time_Hours = :Time_Hours, Time_Start = :Time_Start, Time_End = :Time_End, Time_Memo =:Time_Memo WHERE Time_PK='+chr(39)+IntToStr(RecordID)+chr(39);

        SQLQuery1.Params.ParamByName('Time_Date').AsString        := DateEdit1.text;
        SQLQuery1.Params.ParamByName('Time_Hours').AsString        := Hours.text;
        SQLQuery1.Params.ParamByName('Time_Start').AsString        := StartTime.text;
        SQLQuery1.Params.ParamByName('Time_End').AsString          := EndTime.text;
        SQLQuery1.Params.ParamByName('Time_Memo').AsString         := Memo1.text;

        SQLQuery1.ExecSQL;
        SQLTransaction1.commit;
        //SQLQuery1.Close;
      end;
      closeNoQuestion := True;                 // Set it so that no question is asked.
      TimeForm.Close;
  end;

end;


procedure TTimeForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

       if closeNoQuestion = False then
            if CloseForm() = False then
                 CanClose := False
            else
               TimeForm.Close
       else
           TimeForm.Close;
       closeNoQuestion := False;               // Has to be set to false, or else the next
                                               // time you open the form, it remembers the previous
                                               // value.
       //Proj_Name_Edit.Text := projectName;
end;

procedure TTimeForm.ConvertToHHHH(var min: integer);
var remainingMinutes: integer;
    hours_calc: double;
begin
     min := 1235;
     remainingMinutes := min mod 60;
     ShowMessage(IntToStr(remainingMinutes));

     hours_calc := ((min - remainingMinutes) / 60);
     ShowMessage(FloatToStr(hours_calc));

end;

procedure TTimeForm.HoursKeyPress(Sender: TObject; var Key: char);
begin
  {* http://www.festra.com/eng/snip05.htm *}
  if not (Key in [#8, '0'..'9', DecimalSeparator]) then begin
    ShowMessage('Invalid key: ' + Key);
    Key := #0;
  end
  else if (Key = DecimalSeparator) and
          (Pos(Key, Hours.Text) > 0) then begin
    ShowMessage('Invalid Key: twice ' + Key);
    Key := #0;
  end;
end;

end.

