page 52204207 "Member View Reason Dialog"
{
    ApplicationArea = All;
    Caption = 'View Reason';
    PageType = StandardDialog;
    layout
    {
        area(Content)
        {
            field(Reason; Reason)
            {
                ShowMandatory = true;
                MultiLine = true;
                ApplicationArea = All;
                Caption = 'Reason';
            }
        }
    }

    var
        Reason: Text[100];

    procedure GetReason(): Text[100]
    begin
        exit(Reason);
    end;
}
