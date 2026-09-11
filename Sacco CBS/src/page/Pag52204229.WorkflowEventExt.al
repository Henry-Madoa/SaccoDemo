page 52204229 "Workflow Event Ext"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Workflow Event";
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Function Name"; Rec."Function Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request Page ID"; Rec."Request Page ID")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
