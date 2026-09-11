page 52204089 "Transaction Charge"
{
    PageType = Card;
    SourceTable = "Transaction Charges";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Transaction Type"; Rec."Posting Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(ControlAccount)
                {
                    ShowCaption = false;
                    Visible = ((Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Cash Deposit") or (Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::ATM) or (Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Bankers Cheque"));
                    field("Control Account"; Rec."Control Account")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            part(Control8; "Transaction Charges Setup")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Transaction Code" = FIELD(Code);
            }
            part(Control9; "Transaction Recoveries")
            {
                ApplicationArea = Basic, Suite;
                Visible = ((Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"End Month Salary") or (Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Cash Deposit") or (Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Cheque Deposit") or (Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Divinded Processing"));
                SubPageLink = Code = FIELD(Code);
            }
        }
    }
}
