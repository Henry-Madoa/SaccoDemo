page 52203846 "Contract Extension SubForm"
{
    ApplicationArea = All;
    PageType = ListPart;
    SourceTable = "Contract Extension Milestone";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Milestone Code"; Rec."Milestone Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Milestone Description"; Rec."Milestone Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Period; Rec.Period)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Extension Period"; Rec."Extension Period")
                {
                    ApplicationArea = All;
                }
                field("New End Date"; Rec."New End Date")
                {
                    ApplicationArea = All;
                }
                field("Reason For Extension"; Rec."Reason For Extension")
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
