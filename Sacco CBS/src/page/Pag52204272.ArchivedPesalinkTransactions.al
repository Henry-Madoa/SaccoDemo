page 52204272 "Archived Pesalink Transactions"
{
    PageType = List;
    SourceTable = "Archived PesaLink Transactions";
    ApplicationArea = All;
    UsageCategory = History;
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
                field("Reference Number"; Rec."Reference Number")
                {
                }
                field("Payment Refrence Code"; Rec."Payment Refrence Code")
                {
                }
                field("Transaction Direction"; Rec."Transaction Direction")
                {
                }
                field("Channel Code"; Rec."Channel Code")
                {
                }
                field("Source Account Number"; Rec."Source Account Number")
                {
                }
                field("Source Bank Code"; Rec."Source Bank Code")
                {
                }
                field(Amount; Rec.Amount)
                {
                }
                field(Currency; Rec.Currency)
                {
                }
                field("Member No."; Rec."Member No.")
                {
                }
                field("FOSA Account Number"; Rec."FOSA Account Number")
                {
                }
                field("Destination Account Number"; Rec."Destination Account Number")
                {
                }
                field("Destination Bank Code"; Rec."Destination Bank Code")
                {
                }
                field(Narration; Rec.Narration)
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Comments; Rec.Comments)
                {
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                }
                field("Posting Time"; Rec."Posting Time")
                {
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                }
                field(SystemId; Rec.SystemId)
                {
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                }
            }
        }
    }
}
