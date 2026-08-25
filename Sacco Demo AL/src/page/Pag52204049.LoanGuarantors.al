page 52204049 "Loan Guarantors"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Guarantees";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Member No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Deposits"; Rec."Member Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Guarantor Value"; Rec."Multiplied Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Outstanding Guarantees"; Rec."Outstanding Guarantees")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Guarantee"; Rec."Available Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount to Guarantee"; Rec."Guaranteed Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Self Guarantee"; Rec."Self Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Substituted; Rec.Substituted)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part(Member; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No.");
            }
            part(Images; "Member Images Factbox")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Member Image")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = LedgerBook;
                RunObject = page "Member Images";
                RunPageLink = "No." = field("Member No.");
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    var
        Loans: Record Loans;
}
