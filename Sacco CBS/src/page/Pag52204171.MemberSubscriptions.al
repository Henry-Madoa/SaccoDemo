page 52204171 "Member Subscriptions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Subscriptions";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minmum Contribution"; Rec."Minimum Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberEditting: Record "Member Editing";
        UserSetup: Record "User Setup";

    trigger OnModifyRecord(): Boolean
    begin
        UserSetup.Get(UserId);
        if Member.Get(Rec."Source Code") and (not UserSetup."Can Update Subscriptions") then
            Error('You cannot update Members Details');
        if MemberApplication.Get(Rec."Source Code") then
            MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then
            MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        UserSetup.Get(UserId);
        if Member.Get(Rec."Source Code") and (not UserSetup."Can Update Subscriptions") then
            Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then
            MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then
            MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        UserSetup.Get(UserId);
        if Member.Get(Rec."Source Code") and (not UserSetup."Can Update Subscriptions") then
            Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then
            MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then
            MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;
}
