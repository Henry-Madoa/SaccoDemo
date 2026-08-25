page 52204271 "Pesalink Transactions"
{
    PageType = List;
    SourceTable = "PesaLink Transactions";
    ApplicationArea = All;
    UsageCategory = History;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Reference Number"; Rec."Reference Number")
                {
                    Editable = false;
                }
                field("Payment Refrence Code"; Rec."Payment Refrence Code")
                {
                    Editable = false;
                }
                field("Transaction Direction"; Rec."Transaction Direction")
                {
                    Editable = false;
                }
                field("Channel Code"; Rec."Channel Code")
                {
                    Editable = false;
                }
                field("Source Account Number"; Rec."Source Account Number")
                {
                    Editable = false;
                }
                field("Source Bank Code"; Rec."Source Bank Code")
                {
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                }
                field(Currency; Rec.Currency)
                {
                    Editable = false;
                }
                field("Member No."; Rec."Member No.")
                {
                    Editable = false;
                }
                field("FOSA Account Number"; Rec."FOSA Account Number")
                {
                    Editable = false;
                }
                field("Destination Account Number"; Rec."Destination Account Number")
                {
                    Editable = false;
                }
                field("Destination Bank Code"; Rec."Destination Bank Code")
                {
                    Editable = false;
                }
                field(Narration; Rec.Narration)
                {
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
                field(Skip; Rec.Skip)
                {
                }
                field(Comments; Rec.Comments)
                {
                    Editable = false;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    Editable = false;
                }
                field("Posting Time"; Rec."Posting Time")
                {
                    Editable = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Editable = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    Editable = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    Editable = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    Editable = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    Editable = false;
                }
            }
        }
    }
}
