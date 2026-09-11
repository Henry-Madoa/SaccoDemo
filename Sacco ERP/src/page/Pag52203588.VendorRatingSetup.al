page 52203588 "Vendor Rating Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Vendor Rating";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(factor; Rec.factor)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the point/factor.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the description.';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the number';
                    Visible = false;
                }
            }
        }
    }
}
