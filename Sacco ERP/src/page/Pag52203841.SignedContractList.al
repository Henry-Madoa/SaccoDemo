page 52203841 "Signed Contract List"
{
    ApplicationArea = All;
    CardPageID = "Contract Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Contract Header";
    SourceTableView = WHERE("Contract Status"=CONST(Signed));

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
                field("Requisition No"; Rec."Requisition No")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                }
                field("Tender Title"; Rec."Tender Title")
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
