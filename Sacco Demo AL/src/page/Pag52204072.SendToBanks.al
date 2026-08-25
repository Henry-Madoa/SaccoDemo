page 52204072 "Send To Banks"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "FOSA Transactions";
    CardPageId = "Send To Bank";
    SourceTableView = where("Document Type" = const("Send to Bank"));
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source No"; Rec."Source No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field(Denominations; Rec.Denominations)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Destination No"; Rec."Destination No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        TellerSetup: Record "Teller Setup";
    begin
        tellerSetup.Get(UserId, tellerSetup."Setup Type"::Treasury);
        Rec.FilterGroup(2);
        Rec.SetRange("Created By", UserId);
        Rec.FilterGroup(0);
    end;
}
