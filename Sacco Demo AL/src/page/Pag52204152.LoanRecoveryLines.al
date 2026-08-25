page 52204152 "Loan Recovery Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Recovery Lines";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Deposits"; Rec."Member Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Guarantee"; Rec."Outstanding Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Type"; Rec."Recovery Type")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Recovery Amount"; Rec."Recovery Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
