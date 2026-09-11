page 52203735 "Score Cards"
{
    PageType = List;
    SourceTable = "Score Cards";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Rating; Rec.Rating)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Score %"; Rec."Score %")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
        UserSetup.TestField("HR Admin");
    end;
    var UserSetup: Record "User Setup";
}
