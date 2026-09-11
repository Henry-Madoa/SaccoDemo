page 52203784 "Goods Receipt List"
{
    ApplicationArea = All;
    CardPageID = "Goods Receipt Note Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Goods Receipt Note";
    SourceTableView = WHERE(Status=CONST(New), Posted=CONST(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                }
                field("Employee No."; Rec."Employee No.")
                {
                }
                field("Employee Name"; Rec."Employee Name")
                {
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Posted; Rec.Posted)
                {
                }
            }
        }
    }
    actions
    {
    }
}
