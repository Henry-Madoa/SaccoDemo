page 52203559 "Vendor Payment Details"
{
    PageType = ListPart;
    SourceTable = "Payee Bank Details";
    Caption = 'Bank Details';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Branch Code"; Rec."Branch Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Branch Name"; Rec."Branch Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Branch Address"; Rec."Branch Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Beneficiary Name"; Rec."Beneficiary Name")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                }
                field("Bank Account Number"; Rec."Bank Account Number")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                }
                field("Other Bank Details"; Rec."Other Bank Details")
                {
                    Caption = 'Other details';
                    ApplicationArea = Basic, Suite;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
