page 52203472 "Petty Cash Reimbursement"
{
    PageType = List;
    SourceTable = "Payment Schedule";

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Petty Cash Account"; Rec."Petty Cash Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Import Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ImportExcel;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup";

                trigger OnAction();
                begin
                    PettyCashReimbursement.GetHeader(Rec."PV No.");
                    PettyCashReimbursement.Run();
                end;
            }
        }
    }
    var PettyCashReimbursement: XmlPort "Petty Cash Reimbursement";
}
