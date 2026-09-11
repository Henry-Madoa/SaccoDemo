page 52204182 "Member Account Card"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Vendor;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(GeneralNames)
                {
                    ShowCaption = false;
                    Visible = ((not Rec."Business Account") and (Rec."Product Posting Type" <> Rec."Product Posting Type"::"Junior Account"));
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(BusinessAndJunior)
                {
                    ShowCaption = false;
                    Visible = ((Rec."Business Account") or (Rec."Product Posting Type" = Rec."Product Posting Type"::"Junior Account"));
                    field("Member Name"; Rec."Member Name")
                    {
                        Caption = 'Name';
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(BusinessLocation)
                {
                    ShowCaption = false;
                    Visible = Rec."Business Account";

                    field("Business Location"; Rec."Business Location")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Paybill Business Account No."; Rec."Paybill Business Account No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Can Prompt STK Push"; Rec."Can Prompt STK Push")
                    {
                        ApplicationArea = Basic, Suite;
                        StyleExpr = 'Strong';
                    }
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Uncleared Funds"; Rec."Uncleared Funds")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheques On Hand"; Rec."Cheques On Hand")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(BookBalance; BookBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    StyleExpr = 'Strong';
                }
                field("Cash Deposit Allowed"; Rec."Cash Deposit Allowed")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cash Transfer Allowed"; Rec."Cash Transfer Allowed")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cash Withdraw Allowed"; Rec."Cash Withdraw Allowed")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies which transactions with the vendor that cannot be processed, for example a vendor that is declared insolvent.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies which transactions with the vendor that cannot be processed, for example a vendor that is declared insolvent.';
                }
            }
        }
        area(FactBoxes)
        {
            part(Statistics; "Account Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Co&mments")
            {
                ApplicationArea = Comments;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Promoted = true;
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "Comment Sheet";
                RunPageLink = "Table Name" = const(Vendor),
                                  "No." = field("No.");
                ToolTip = 'View or add comments for the record.';
            }
            action("Unblock")
            {
                ApplicationArea = Basic, Suite;
                Image = BlanketOrder;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Promoted = true;
                Visible = (Rec.Blocked = Rec.Blocked::All) or (Rec.Blocked = Rec.Blocked::Payment);

                trigger OnAction()
                var
                    PermErr: Label 'You are not permited to perform the current activity, Kindly contact System Admin';
                    ConfirmMsg: Label 'You are about to Unblock %1, Do you wish to continue?';
                    SuccessMsg: Label 'Successful';
                    CommentLine: Record "Comment Line";
                begin
                    UserSetup.Get(UserId);
                    if not UserSetup."Member Accounts Blocking" then
                        Error(PermErr);

                    CommentLine.Reset();
                    CommentLine.SetRange("Table Name", CommentLine."Table Name"::Vendor);
                    CommentLine.SetRange("No.", Rec."No.");
                    CommentLine.SetRange(Date, WorkDate);
                    if not CommentLine.FindFirst then
                        Error('You need to add a comment first before Unblocking');

                    If Confirm(StrSubstNo(ConfirmMsg, Rec."No."), true, false) then begin
                        Rec.Status := Rec.Status::Active;
                        Rec.Blocked := Rec.Blocked::" ";
                        Rec.Modify(true);
                        Message(SuccessMsg);
                    end;
                end;
            }
            action("Block")
            {
                ApplicationArea = Basic, Suite;
                Image = InsertBalanceAccount;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Promoted = true;
                Visible = Rec.Blocked = Rec.Blocked::" ";

                trigger OnAction()
                var
                    Permerr: Label 'You are not permited to perform the current activity, Kindly contact System Admin';
                    ConfirmMsg: Label 'You are about to Block %1, Do you wish to continue?';
                    SuccessMsg: Label 'Successful';
                    CommentLine: Record "Comment Line";
                begin
                    UserSetup.Get(UserId);
                    if not UserSetup."Member Accounts Blocking" then Error(Permerr);
                    CommentLine.Reset();
                    CommentLine.SetRange("Table Name", CommentLine."Table Name"::Vendor);
                    CommentLine.SetRange("No.", Rec."No.");
                    CommentLine.SetRange(Date, WorkDate);
                    if not CommentLine.FindFirst then
                        Error('You need to add a comment first before blocking');

                    if Confirm(StrSubstNo(ConfirmMsg, Rec."No."), true, false) then begin
                        Rec.Status := Rec.Status::Inactive;
                        Rec.Blocked := Rec.Blocked::All;
                        Rec.Modify(true);
                        Message(SuccessMsg);
                    end;
                end;
            }
        }
    }
    var
        BookBalance: Decimal;
        UserSetup: Record "User Setup";

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Uncleared Funds", Balance);
        BookBalance := 0;
        BookBalance := Rec.Balance - Rec."Uncleared Funds";
    end;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        Members: Record Members;
        SMSMessage, SMSNo : Text[250];
        SMSSource: Code[20];
        SMSMgt: Codeunit "Notifications Management";
        SaccoSetup: Record "General Ledger Setup";
    begin
        UserSetup.Get(UserId);
        SMSSource := 'UNAUTHORISED_ACCESS';
        if Members.Get(Rec."Member No.") then begin
            if Members."Protected Account" = true then begin
                if UserSetup."View Protected Account" = false then
                    SMSMessage := UserId + ' tried to access a protected account ' + Rec."No." + ' at ' + Format(CurrentDateTime)
                else
                    SMSMessage := UserId + ' accessed a protected account ' + Rec."No." + ' at ' + Format(CurrentDateTime);
                SaccoSetup.Get;
                SaccoSetup.TestField("ICT Admin Phone No.");
                SMSNo := SaccoSetup."ICT Admin Phone No.";
                SMSMgt.SendSms(SMSNo, SMSMessage, SMSSource);
                Commit;
                if UserSetup."View Protected Account" = false then Error('The Account is protected. You are not authorised to view.');
            end;
        end;
    end;
}
