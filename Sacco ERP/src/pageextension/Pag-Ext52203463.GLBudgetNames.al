pageextension 52203463 "G/L Budget Names" extends "G/L Budget Names"
{
    layout
    {
        // Add changes to page layout here
        addafter(Blocked)
        {
            field(Status; Rec.Status)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status := Rec.Status::Open;
    end;
}
