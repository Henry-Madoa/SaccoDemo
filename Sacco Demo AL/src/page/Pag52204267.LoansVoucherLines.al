page 52204267 "Loans Voucher Lines"
{
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Payment Voucher Lines";
    SourceTableView = SORTING("No.", "Line No");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount To Be Paid';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
            }
        }
    }
}
