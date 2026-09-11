page 52203652 "Disciplinary Case subforms"
{
    PageType = ListPart;
    SourceTable = "Disciplinary Case Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No"; Rec."Employee No")
                {
                    Editable = NewStageEditable;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Offence Category"; Rec."Offence Category")
                {
                    Editable = NewStageEditable;
                }
                field("Offence Category Description"; Rec."Offence Category Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Offence Code"; Rec."Offence Code")
                {
                    Editable = NewStageEditable;
                }
                field("Offence Description"; Rec."Offence Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Date of offence"; Rec."Date of offence")
                {
                    Editable = NewStageEditable;
                }
                field("Commitee Decision"; Rec."Commitee Decision")
                {
                    Editable = ReportedStageEditable;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        ControlAppearance();
    end;
    var DisciplinaryCaseHeader: Record "Disciplinary Case Header";
    ReportedStageEditable: Boolean;
    NewStageEditable: Boolean;
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
