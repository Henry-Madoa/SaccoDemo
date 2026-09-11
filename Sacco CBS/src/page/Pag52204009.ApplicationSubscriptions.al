page 52204009 "Application Subscriptions"
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
                    Visible = isWebService;
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
                field("Minmum Contribution"; Rec."Minimum Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot update Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnAfterGetRecord()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    var
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberEditting: Record "Member Editing";
}
