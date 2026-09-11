page 52203937 "Fuel Requisition Pending A"
{
    ApplicationArea = All;
    CardPageID = "Fuel Requisition Card";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Fuel Requisition";
    SourceTableView = WHERE(Posted=CONST(false), Status=CONST("Pending Approval"));

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
