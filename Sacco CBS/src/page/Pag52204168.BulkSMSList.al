page 52204168 "Bulk SMS List"
{
    PageType = List;
    Caption = 'Bulk SMS';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Bulk SMS Header";
    CardPageId = "Bulk SMS";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Sent;

                trigger OnAction()
                var
                    BulkSMSLines: Record "Bulk SMS Lines";
                begin
                    BulkSMSLines.Reset();
                    BulkSMSLines.SetRange("No.", Rec."No.");
                    if BulkSMSLines.FindSet() then BulkSMSLines.DeleteAll();
                    Commit();
                    Clear(BulkSMSUpload);
                    BulkSMSUpload.SetBulkSMSNo(Rec."No.");
                    BulkSMSUpload.Run();
                    ;
                end;
            }
            action("Populate All Members")
            {
                ApplicationArea = Basic, Suite;
                Image = AddContacts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Sent;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.PopulateBulkSMSMemberList(Rec."No.");
                end;
            }
            action(Process)
            {
                ApplicationArea = Basic, Suite;
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Sent;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.SendBulkSMS(Rec."No.");
                end;
            }
        }
    }
    var
        BulkSMSUpload: xmlport "Import BulkSMS";
}
