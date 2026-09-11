page 52204094 "ATM Type"
{
    PageType = Card;
    SourceTable = "ATM Types";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Settlment Account"; Rec."ATM Settlment Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Charges Setup")
            {
                label("*****General Transactions Setup*****")
                {
                    Caption = '*****General Transactions Setup*****';
                    Style = Favorable;
                }
                field("Application Charge"; Rec."Application Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Importance = Promoted;
                }
                field("Utility Payments"; Rec."Utility Payments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withdrawal Code (Coop)"; Rec."Withdrawal (Coop)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withdrawal (VISA)"; Rec."Withdrawal (VISA)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Airtime Purchase"; Rec."Airtime Purchase")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****POS Transaction Charges*****")
                {
                    Caption = '*****POS Transaction Charges*****';
                    Style = StrongAccent;
                }
                field("POS Balance Enquiry"; Rec."POS Balance Enquiry")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Benefit Cash Withdrawal"; Rec."POS Benefit Cash Withdrawal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Card Deposit"; Rec."POS Card Deposit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Cash Deposit"; Rec."POS Cash Deposit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Cash Withdrawal"; Rec."POS Cash Withdrawal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS M Banking"; Rec."POS M Banking")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Ministatement"; Rec."POS Ministatement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Purchase (CBack)"; Rec."POS Purchase (CBack)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS Purchase (Normal)"; Rec."POS Purchase (Normal)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("POS School Payment"; Rec."POS School Payment")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Cards; "ATM Cards")
            {
                Caption = 'Cards';
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "ATM Type"=field(Code);
            }
        }
    }
}
