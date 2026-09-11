page 52204135 "Channels Transactions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Transactions";
    SourceTableView = sorting("Entry No") order(descending);
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Account Reference"; Rec."Account Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Payment Refrence Code"; Rec."Payment Refrence Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cr_Member No"; Rec."Cr_Member No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Skip;
                }
                field("Credit Member Name"; Rec."Credit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cr_Account No"; Rec."Cr_Account No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Skip;
                }
                field("Dr_Member No"; Rec."Dr_Member No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Debit Member Name"; Rec."Debit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Dr_Account No"; Rec."Dr_Account No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Utility Code"; Rec."Utility Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Confirmation Time"; Rec."Confirmation Time")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Confirmed; Rec.Confirmed)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Skip; Rec.Skip)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not Rec.Posted;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ChannelsIntegrations: Codeunit "Channels Integrations";
                begin
                    ChannelsIntegrations.PostChannelTransactions;
                end;
            }
        }
    }
    var
        ReferenceCode: Code[20];

    var
        MemberAccountNo: Code[20];

    var
        PaybillAccountRef: Code[20];

    var
        PaybillTransactionTypes: Enum "Paybill Transaction Types";
}
