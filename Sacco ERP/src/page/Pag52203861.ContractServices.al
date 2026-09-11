page 52203861 "Contract Services"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Contract Services";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Service; Rec.Service)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("G/L Account"; Rec."G/L Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
