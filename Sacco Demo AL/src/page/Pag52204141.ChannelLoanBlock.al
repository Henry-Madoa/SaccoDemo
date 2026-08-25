page 52204141 "Channel Loan Block"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Loan Blocking";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    var
        UserSetup: Record "User Setup";
        PermError: Label 'You do not have permissions to perform the current activity. Kindly contact the system administrator.';
    begin
        if UserSetup.Get(UserId) then begin
            if not UserSetup."Can Unblock Mobile Banking" then Error(PermError);
        end;
    end;
}
