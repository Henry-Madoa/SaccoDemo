codeunit 52203471 "Disciplinary management"
{
    var HumanResourceMgmt: Codeunit "Human Resource Management";
    procedure ReportDisciplinaryCase(DisciplinaryCaseHeader: Record "Disciplinary Case Header")
    var
        DisciplinaryCaseLines: Record "Disciplinary Case Lines";
    begin
        with DisciplinaryCaseHeader do begin
            Validate(Status, DisciplinaryCaseHeader.Status::Reported);
            if Modify(true)then Message('Case No. %1 has been successfully reported', DisciplinaryCaseHeader.No);
        end;
    end;
    procedure ArchiveDisciplinaryCase(DisciplinaryCaseHeader: Record "Disciplinary Case Header")
    begin
        with DisciplinaryCaseHeader do begin
            Validate(Status, DisciplinaryCaseHeader.Status::Archived);
            if Modify(true)then Message('Case No. %1 has been successfully Archived', DisciplinaryCaseHeader.No);
        end;
    end;
}
