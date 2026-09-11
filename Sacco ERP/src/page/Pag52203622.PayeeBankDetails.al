page 52203622 "Payee Bank Details"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Payee Bank Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Ben ID"; Rec."Ben ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Beneficiary Name"; Rec."Beneficiary Name")
                {
                    ApplicationArea = Basic, Suite;
                }
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
                field("Bank Address"; Rec."Branch Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Account Number"; Rec."Bank Account Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Telephone No"; Rec."Bank Telephone No")
                {
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
