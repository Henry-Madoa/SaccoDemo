page 52203758 "Contract Details"
{
    PageType = ListPart;
    SourceTable = "C.Employee Contract Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("COntract Description"; Rec."COntract Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Period"; Rec."Contract Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Contract"; Rec."Current Contract")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No."; Rec."Change No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        DetailsEditable:=false;
        if Rec."Current Contract" then DetailsEditable:=false
        else
            DetailsEditable:=true end;
    trigger OnAfterGetRecord()
    begin
        DetailsEditable:=false;
        if Rec."Current Contract" then DetailsEditable:=false
        else
            DetailsEditable:=true end;
    trigger OnInit()
    begin
        DetailsEditable:=false;
        if Rec."Current Contract" then DetailsEditable:=false
        else
            DetailsEditable:=true end;
    trigger OnOpenPage()
    begin
        DetailsEditable:=false;
        if Rec."Current Contract" then DetailsEditable:=false
        else
            DetailsEditable:=true end;
    var DetailsEditable: Boolean;
}
