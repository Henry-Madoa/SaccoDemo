page 52203880 "Fuel Logs - Submitted"
{
    ApplicationArea = All;
    CardPageID = "Fuel Requisition Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Fuel Requisition";
    SourceTableView = WHERE(Posted=CONST(true));
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Fueling Date"; Rec."Fueling Date")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Payment Method"; Rec."Payment Method")
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
