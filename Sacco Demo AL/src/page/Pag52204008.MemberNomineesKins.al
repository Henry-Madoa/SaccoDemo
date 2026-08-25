page 52204008 "Member Nominees/Kins"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Nominee/Kin";
    CardPageId = "Member Nominee/Kin";
    Editable = false;
    ModifyAllowed = false;

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
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field("Relative Code"; Rec."Relative Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification Type"; Rec."Identification Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification No."; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not Rec."IPRS Uneditability";
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not Rec."IPRS Uneditability";
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Visible = Rec."Document Type" = Rec."Document Type"::Benevolent;
                }
                field(Allocation; Rec.Allocation)
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Visible = Rec."Document Type" = Rec."Document Type"::Nominee;
                }
                field("Add As Next of Kin"; Rec."Add As Next of Kin")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    Visible = Rec."Document Type" = Rec."Document Type"::Nominee;
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot update Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
        if not MemberApplication.Get(Rec."Source Code") and not MemberEditting.Get(Rec."Source Code") then Error('You cannot modify this record');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
        if not MemberApplication.Get(Rec."Source Code") and not MemberEditting.Get(Rec."Source Code") then Error('You cannot delete this record');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
        if not MemberApplication.Get(Rec."Source Code") and not MemberEditting.Get(Rec."Source Code") then Error('You cannot add a new record');
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
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberEditting: Record "Member Editing";
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
}
