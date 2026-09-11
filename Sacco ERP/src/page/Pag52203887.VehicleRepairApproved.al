page 52203887 "Vehicle Repair Approved"
{
    ApplicationArea = All;
    CardPageID = "Vehicle Repair Card";
    PageType = List;
    SourceTable = "Vehicle Repair Header";
    SourceTableView = WHERE(Status=CONST(Approved));
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
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Mileage at Service (kms)"; Rec."Mileage at Service (kms)")
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
