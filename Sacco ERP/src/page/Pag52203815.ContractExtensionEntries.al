page 52203815 "Contract Extension Entries"
{
    ApplicationArea = All;
    PageType = ListPart;
    SourceTable = "Contract Extension Entries";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Contract No"; Rec."Contract No")
                {
                    ApplicationArea = All;
                }
                field("Initial End Date"; Rec."Initial End Date")
                {
                    ApplicationArea = All;
                }
                field("Extension Period"; Rec."Extension Period")
                {
                    ApplicationArea = All;
                }
                field("New End Date"; Rec."New End Date")
                {
                    ApplicationArea = All;
                }
                field("Extension No"; Rec."Extension No")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
