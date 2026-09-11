page 52203932 "Posted Vehicle Repair"
{
    ApplicationArea = All;
    CardPageID = "Vehicle Repair Card";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Vehicle Repair Header";
    SourceTableView = WHERE(Status=CONST(Approved), Posted=CONST(true));

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
