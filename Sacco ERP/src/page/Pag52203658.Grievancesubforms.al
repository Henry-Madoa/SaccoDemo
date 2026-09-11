page 52203658 "Grievance subforms"
{
    PageType = ListPart;
    SourceTable = "Disciplinary Case Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Grievance Description"; Rec."Grievance Description")
                {
                    Editable = NewStageEditable;
                }
                field("Hr Comments"; Rec."Hr Comments")
                {
                    Editable = ReportedStageEditable;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
    end;
    trigger OnAfterGetRecord()
    begin
    end;
    trigger OnOpenPage()
    begin
        ControlAppearance();
    end;
    var DisciplinaryCaseHeader: Record "Disciplinary Case Header";
    ReportedStageEditable: Boolean;
    NewStageEditable: Boolean;
    HrCommentsEditable: Boolean;
    UserCommentsEditable: Boolean;
    local procedure ControlAppearance()
    begin
        if DisciplinaryCaseHeader.Get(Rec."Disciplinary No")then begin
            if DisciplinaryCaseHeader.Status in[DisciplinaryCaseHeader.Status::Reported]then ReportedStageEditable:=true
            else
                ReportedStageEditable:=false;
            if DisciplinaryCaseHeader.Status in[DisciplinaryCaseHeader.Status::New]then NewStageEditable:=true
            else
                NewStageEditable:=false;
        end;
    end;
}
