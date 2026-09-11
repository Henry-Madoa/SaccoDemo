page 52203552 "Procurement Inspections"
{
    // version THL- PRM 1.0
    CardPageID = "Procurement Inspection";
    PageType = List;
    SourceTable = "Procurement Inspection";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("LPO No"; Rec."LPO No")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field("RFQ No."; Rec."RFQ No.")
                {
                    ApplicationArea = All;
                }
                field("RFQ Date"; Rec."RFQ Date")
                {
                    ApplicationArea = All;
                }
                field("LPO Date"; Rec."LPO Date")
                {
                    ApplicationArea = All;
                }
                field("Total Value"; Rec."Total Value")
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("D Note No."; Rec."D Note No.")
                {
                    ApplicationArea = All;
                }
                field("Completion/Delivery Date"; Rec."Completion/Delivery Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
