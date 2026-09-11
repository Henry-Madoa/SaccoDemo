page 52203852 "Direct Procurement List"
{
    ApplicationArea = All;
    CardPageID = "Direct Procurement Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Procurement Request";
    SourceTableView = WHERE("Procurement Method"=CONST("Direct Procurement"), "Direct Procurement Status"=CONST(New), Archived=CONST(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Title; Rec.Title)
                {
                }
                field("Requisiton No"; Rec."Requisiton No")
                {
                }
                field("Creation Date"; Rec."Creation Date")
                {
                }
                field("Current Budget"; Rec."Current Budget")
                {
                }
                field("Supplier Category"; Rec."Supplier Category")
                {
                }
                field("Tender Opening Date"; Rec."Tender Opening Date")
                {
                }
            }
        }
    }
    actions
    {
    }
}
