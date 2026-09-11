page 52204014 "Member Application Referee"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Application Referees";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Full Names"; Rec."Full Names")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Relationship; Rec.Relationship)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
