page 52204021 "Member Account Instructions"
{
    PageType = ListPart;
    SourceTable = "Member Account Instructions";
    Caption = 'Account Instructions';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Instruction; Rec.Instruction)
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
}
