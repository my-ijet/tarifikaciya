﻿uses
  'users.pas',
  'service.pas',
  'spravochniky.pas',
  'otchety.pas',
  'tarifikation.pas';

procedure Tarifikation_MainTabs_OnChange (Sender: TObject);
begin

  case Tarifikation.MainTabs.ActivePageIndex of
    0: begin Tarifikation_FilterTarTables; end;
    1: begin FillRequisites; end;
    2: begin PrepareSpravochniky; end;
    3: begin end;
  end;

end;

begin
end.
