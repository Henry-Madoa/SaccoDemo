page 52203820 "Tender on Mandatory Evaluation"
{
    ApplicationArea = All;
    CardPageID = "Tender Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Procurement Request";
    SourceTableView = WHERE("Procurement Method"=Filter('Open Tendering'|'Restricted Tendering'), "Tender Status"=CONST("Mandatory Req Evaluation"));

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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                }
                field("Requisiton No"; Rec."Requisiton No")
                {
                    ApplicationArea = All;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = All;
                }
                field("Supplier Category"; Rec."Supplier Category")
                {
                    ApplicationArea = All;
                }
                field("Tender Opening Date"; Rec."Tender Opening Date")
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
