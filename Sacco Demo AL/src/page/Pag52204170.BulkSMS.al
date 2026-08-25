page 52204170 "Bulk SMS"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Bulk SMS Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Rec.Sent;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Message; Rec.Message)
                {
                    MultiLine = true;
                    ShowMandatory = true;
                }
            }
            part(Lines; "Bulk SMS Lines")
            {
                Editable = not Rec.Sent;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
            group("Audit Trail")
            {
                Editable = false;

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sent; Rec.Sent)
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
            action(Send)
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
