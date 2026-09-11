page 52203858 "Tender Bidders-Bond"
{
    ApplicationArea = All;
    PageType = ListPart;
    SourceTable = "Tender Suppliers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bid Bond Amount"; Rec."Bid Bond Amount")
                {
                    ApplicationArea = All;
                }
                field("Bid Bond Start Date"; Rec."Bid Bond Start Date")
                {
                    ApplicationArea = All;
                }
                field("Bid Bond End Date"; Rec."Bid Bond End Date")
                {
                    ApplicationArea = All;
                }
                field("Bond Status"; Rec."Bond Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
    }
}
