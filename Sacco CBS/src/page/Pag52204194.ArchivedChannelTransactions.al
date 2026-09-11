page 52204194 "Archived Channel Transactions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Archived Channel Transactions";
    SourceTableView = sorting("Entry No") order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Reference"; Rec."Account Reference")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Refrence Code"; Rec."Payment Refrence Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cr_Member No"; Rec."Cr_Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Member Name"; Rec."Credit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cr_Account No"; Rec."Cr_Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Dr_Member No"; Rec."Dr_Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Member Name"; Rec."Debit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Dr_Account No"; Rec."Dr_Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Utility Code"; Rec."Utility Code")
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
                field("Payment Confirmation Time"; Rec."Confirmation Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
