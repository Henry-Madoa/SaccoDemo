page 52203814 "Milestone Extension Entries"
{
    ApplicationArea = All;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Milestone Extension Entries";

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
                field("Milestone Code"; Rec."Milestone Code")
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
