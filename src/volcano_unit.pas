unit volcano_unit;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils;

implementation

Procedure getDataGrid();
Begin
  SQLQuery1.SQL.Text := 'Select Proj_PK, cast(Proj_Name as TEXT) as PROJECT FROM projects';
  ProjectsDatabase.Connected:= True;
  SQLTransaction1.Active:= True;
  SQLQuery1.Open;
end;

end.

