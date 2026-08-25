page 52204179 "Member Images FactBox"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Members;
    Caption = 'Images';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group("&Passport Image")
            {
                field("Member Image"; Rec."Passport Size Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("&Signature")
            {
                field("Signature Card"; Rec.Signature)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
