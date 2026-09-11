page 52204039 "Loan Calculator Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Lists;
    SourceTable = "Loan Calculator Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Calculator No"; Rec."Calculator No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = FieldEditability;
                }
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = FieldEditability;
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Date"; Rec."Expected Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Amount"; Rec."Interest Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Installment Amount"; Rec."Installment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Running Balance"; Rec."Running Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        FieldEditability := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        FieldEditability := LoginMgmt.IsWebServiceUser;
    end;

    var
        FieldEditability: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
}
