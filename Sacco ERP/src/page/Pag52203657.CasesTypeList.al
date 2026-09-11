page 52203657 "Cases Type List"
{
    PageType = List;
    SourceTable = "Cases List";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Case Code"; Rec."Case Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Case Desription"; Rec."Case Desription")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Case Category"; Rec."Case Category")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
