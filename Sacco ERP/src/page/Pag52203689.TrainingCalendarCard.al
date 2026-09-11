page 52203689 "Training Calendar Card"
{
    PageType = Card;
    SourceTable = "Training Calender";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Calender Code"; Rec."Calender Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Period"; Rec."Current Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Opened by"; Rec."Opened by")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Opened On"; Rec."Opened On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Closed On"; Rec."Closed On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Closed By"; Rec."Closed By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var StatusEditable: Boolean;
    HrTrainingManagement: Codeunit "Training Mgmt";
}
