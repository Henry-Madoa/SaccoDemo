page 52203896 "WorkTicket Form Request Lines"
{
    ApplicationArea = All;
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "WorkTicket Form Request Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field("Work Ticket No."; Rec."Work Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Place Of Departure"; Rec."Place Of Departure")
                {
                    ApplicationArea = All;
                }
                field(Destination; Rec.Destination)
                {
                    ApplicationArea = All;
                }
                field("Reason For Travel"; Rec."Reason For Travel")
                {
                    ApplicationArea = All;
                }
                field("Authorizing Officer"; Rec."Authorizing Officer")
                {
                    ApplicationArea = All;
                }
                field("Fuel Log No."; Rec."Fuel Log No.")
                {
                    ApplicationArea = All;
                }
                field("Oil Drawn (litres)"; Rec."Oil Drawn (litres)")
                {
                    ApplicationArea = All;
                }
                field("Fuel Drawn (litres)"; Rec."Fuel Drawn (litres)")
                {
                    ApplicationArea = All;
                }
                field("Time Out"; Rec."Time Out")
                {
                    ApplicationArea = All;
                }
                field("Date In"; Rec."Date In")
                {
                    ApplicationArea = All;
                }
                field("Time In"; Rec."Time In")
                {
                    ApplicationArea = All;
                }
                field("Mileage at Start (kms)"; Rec."Mileage at Start (kms)")
                {
                    ApplicationArea = All;
                }
                field("Mileage at End (kms)"; Rec."Mileage at End (kms)")
                {
                    ApplicationArea = All;
                }
                field("Distance Travelled (kms)"; Rec."Distance Travelled (kms)")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
    }
}
