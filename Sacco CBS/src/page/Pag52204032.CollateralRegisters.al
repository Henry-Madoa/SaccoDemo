page 52204032 "Collateral Registers"
{
    PageType = list;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Collateral Register";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collateral Type"; Rec."Collateral Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collateral Description"; Rec."Collateral Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("County Name"; Rec."County Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Serial/Reg No."; Rec."Serial/Reg No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Caollateral Value"; Rec."Collateral Value")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Guarantee; Rec.Guarantee)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Linked Loan Balance"; Rec."Linked Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collateral Balance"; Rec.Guarantee - Rec."Linked Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Owner Name"; Rec."Owner Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Owner ID No"; Rec."Owner ID No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Owner Phone No."; Rec."Owner Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Expiry Date"; Rec."Insurance Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Car Track Due Date"; Rec."Car Track Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
        area(FactBoxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Member No.");
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Register)
            {
                ApplicationArea = Basic, Suite;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                RunObject = report "Collateral Register";
            }
            action(Released)
            {
                ApplicationArea = Basic, Suite;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                RunObject = report "Collateral Release";
            }
        }
        area(Processing)
        {
            action("View Card")
            {
                ApplicationArea = Basic, Suite;
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Collateral Application";
                RunPageLink = "No." = field("No.");
            }
            action("Linked Loans")
            {
                ApplicationArea = Basic, Suite;
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Collateral Linked Loans";
                RunPageLink = "No." = field("No.");
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        isOpen := (Rec.Status = Rec.Status::Available);
        Rec.UpdateCollateralRegister;
    end;

    var
        isOpen: boolean;
        LoansMgt: Codeunit "Loans Management";
}
