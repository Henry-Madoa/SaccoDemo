page 52204020 "Member Images"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Members;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(Member)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Images)
            {
                field("Front ID Image"; Rec."Front ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Back ID Image"; Rec."Back ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Image"; Rec."Passport Size Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Signature Card"; Rec.Signature)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
