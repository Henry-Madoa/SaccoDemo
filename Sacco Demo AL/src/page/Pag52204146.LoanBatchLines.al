page 52204146 "Loan Batch Lines"
{
    PageType = Listpart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Batch Lines";
    InsertAllowed = false;
    //DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applied Amount"; Rec."Applied Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Insurance Amount"; Rec."Insurance Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Total Recoveries"; Rec."Total Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
