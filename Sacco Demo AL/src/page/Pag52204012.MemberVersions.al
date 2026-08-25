page 52204012 "Member Versions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Versions";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Las Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Alt. Phone No"; Rec."Alt. Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Channels; Rec.Channels)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Station Code"; Rec."Station Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Designation; Rec.Designation)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Payroll No."; Rec."Payroll No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Open Document")
            {
                ApplicationArea = Basic, Suite;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    MemberEditing: Record "Member Editing";
                    MemberUpdate: Page "Member Editing";
                begin
                    clear(MemberUpdate);
                    MemberEditing.Reset();
                    MemberEditing.SetRange("No.", Rec."Document No.");
                    if MemberEditing.FindSet() then begin
                        MemberUpdate.SetTableView(MemberEditing);
                        MemberUpdate.RunModal();
                    end;
                end;
            }
        }
    }
}
