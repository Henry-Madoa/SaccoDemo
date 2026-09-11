page 52203453 "Payment Schedule"
{
    PageType = List;
    SourceTable = "Payment Schedule";

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FOSA Account"; Rec."FOSA Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Allowance Amount"; Rec."Net Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
