page 52203663 "Employee Change Request"
{
    CardPageID = "Change Request Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Employee Change Request";
    SourceTableView = WHERE("Nature of Change"=FILTER(<>"Contract Renewal"|"New Contract"|"Asset Assignment"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Nature of Change"; Rec."Nature of Change")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance;
    end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance;
    end;
    var local procedure ControlPageAppearance()
    begin
        if Rec.Status in[Rec.Status::Open]then PageEditable:=true
        else
            PageEditable:=false;
    end;
    var PageEditable: Boolean;
}
