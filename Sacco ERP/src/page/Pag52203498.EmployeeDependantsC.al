page 52203498 "Employee Dependants C"
{
    PageType = ListPart;
    SourceTable = "Employee Depandants Change";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Full Name"; Rec."Full Name")
                {
                    Editable = LineEditable;
                }
                field("ID/Birth Certificate No."; Rec."ID/Birth Certificate No.")
                {
                    Editable = LineEditable;
                }
                field("Is Student"; Rec."Is Student")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    Editable = LineEditable;
                }
                field(Age; Rec.Age)
                {
                    Editable = LineEditable;
                }
                field(Relationship; Rec.Relationship)
                {
                    Editable = LineEditable;
                }
                field(Gender; Rec.Gender)
                {
                    Editable = LineEditable;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ControlAppearance end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.Action:=Rec.Action::"New Addition";
    end;
    var LineEditable: Boolean;
    local procedure ControlAppearance()
    begin
        if Rec.Action in[Rec.Action::Retain]then LineEditable:=false
        else
            LineEditable:=true;
    end;
}
