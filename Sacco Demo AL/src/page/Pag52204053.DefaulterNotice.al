page 52204053 "Defaulter Notice"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Defaulter Notice";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Rec.Processed;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Date"; Rec."Notice Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("First Notice Sent On"; Rec."First Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Second Notice Sent On"; Rec."Second Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Third Notice Sent On"; Rec."Third Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Notice Lines"; "Notice Lines")
            {
                Editable = not Rec.Processed;
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            group("Audit Trail")
            {
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
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
            action("Populate Defaulters")
            {
                ApplicationArea = Basic, Suite;
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    if Confirm('Do you want to populate') then begin
                        LoansMgt.PopulateDefaulters(Rec."No.");
                    end;
                end;
            }
            action("Send [1st] Notices")
            {
                ApplicationArea = Basic, Suite;
                Image = SendAsPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    if Confirm('Are you sure you want to send first notice to the member?') then begin
                        LoansMgt.SendNotice(Rec."No.", 0);
                    end;
                end;
            }
            action("Send [2nd] Notices")
            {
                ApplicationArea = Basic, Suite;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    if Confirm('Are you sure you want to send second notice to the member?') then begin
                        LoansMgt.SendNotice(Rec."No.", 1);
                    end;
                end;
            }
            action("Send [3rd] Notice")
            {
                ApplicationArea = Basic, Suite;
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    ConfirmMsg: Label 'Are you sure you want to send third notice to the member?';
                begin
                    if Confirm(ConfirmMsg) then begin
                        LoansMgt.SendNotice(Rec."No.", 2);
                    end;
                end;
            }
        }
    }
    var
        LoansMgt: Codeunit "Loans Management";
}
