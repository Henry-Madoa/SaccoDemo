page 52204177 "Customer Feedback"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Customer Feedback";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoapClient;
                }
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoapClient;
                }
                field(Details; Rec.Details)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoapClient;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoapClient;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoapClient;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        isSoapClient := (CurrentClientType = clienttype::SOAP);
    end;

    var
        isSoapClient: Boolean;
}
