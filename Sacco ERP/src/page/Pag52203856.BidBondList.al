page 52203856 "Bid Bond List"
{
    ApplicationArea = All;
    CardPageID = "Bid Bond Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Tender Bid Bonds";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tender Status"; Rec."Tender Status")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action("Report")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
            }
        }
    }
}
