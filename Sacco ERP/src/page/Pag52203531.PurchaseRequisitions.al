page 52203531 "Purchase Requisitions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Requisition Header";
    CardPageId = "Purchase Requisition";
    SourceTableView = WHERE("Requisition Type"=CONST("Purchase Requisition"));

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
                field("Employee Code"; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reason; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Raised by"; Rec."Raised by")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition Type"; Rec."Requisition Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Needed By Date"; Rec."Needed By Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Procurement Admin" then Rec.SetRange("Raised by", UserId);
        end;
    end;
    var UserSetup: Record "User Setup";
    LoginMgmt: Codeunit "User Management Ext";
}
