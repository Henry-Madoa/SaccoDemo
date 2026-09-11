page 52203645 "Final Dues Calculations"
{
    PageType = ListPart;
    SourceTable = "Final Dues Calculation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Exit No"; Rec."Exit No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Days Balance"; Rec."Days Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount To Pay"; Rec."Amount To Pay")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Include in Payment"; Rec."Include in Payment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
