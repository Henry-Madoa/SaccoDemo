pageextension 52204014 "Payment Schedule" extends "Payment Schedule"
{
    layout
    {
        addafter("FOSA Account")
        {
            field("Allowance Code"; Rec."Allowance Code")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                Editable = ((Rec."Payment Type" = Rec."Payment Type"::"Board Allowances") or (Rec."Payment Type" = Rec."Payment Type"::"Staff Bulk Payment"));
            }
        }
    }
}
