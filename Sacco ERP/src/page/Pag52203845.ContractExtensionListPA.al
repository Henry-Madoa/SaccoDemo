page 52203845 "Contract Extension List PA"
{
    ApplicationArea = All;
    CardPageID = "Contract Extension Card";
    PageType = List;
    SourceTable = "Contract Extension";
    SourceTableView = WHERE(Status=CONST("Pending Approval"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Extension No"; Rec."Extension No")
                {
                    ApplicationArea = All;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ApplicationArea = All;
                }
                field("Contract Title"; Rec."Contract Title")
                {
                    ApplicationArea = All;
                }
                field("Initial End Date"; Rec."Initial End Date")
                {
                    ApplicationArea = All;
                }
                field("Initial Period"; Rec."Initial Period")
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
