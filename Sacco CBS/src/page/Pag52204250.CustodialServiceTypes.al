page 52204250 "Custodial Service Types"
{
    PageType = List;
    SourceTable = "Custodia Service Types";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Service Type"; Rec."Service Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Service Description"; Rec."Service Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Frequency"; Rec."Charge Frequency")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Income Account"; Rec."Income Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grace Period"; Rec."Grace Period")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
