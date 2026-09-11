page 52203582 "Procurement Plan Lines"
{
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = Listpart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Procurement Plan Lines";
    SourceTableView = SORTING("Document No", "Line No");
    InsertAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Plan Type"; Rec."Plan Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Procurement Method"; Rec."Procurement Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Cost (Base)"; Rec."Unit Cost (Base)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInit()
    begin
    end;
    var ProcurePlanLines: Record "Procurement Plan Lines";
    ProcuremntHdr: Record "Procurement Plans";
}
