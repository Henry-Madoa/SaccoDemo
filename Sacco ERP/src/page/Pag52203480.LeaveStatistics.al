page 52203480 "Leave Statistics"
{
    PageType = CardPart;
    SourceTable = Employee;

    layout
    {
        area(content)
        {
            field("Allocated Leave Days"; Rec."Allocated Leave Days")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Reimbursed Leave Days"; Rec."Reimbursed Leave Days")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Total Leave Days Taken"; Rec."Total Leave Days Taken")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Annual Leave Balance"; Rec."Annual Leave Balance")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Martenity Leave Balance"; Rec."Martenity Leave Balance")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Study Leave Balance"; Rec."Study Leave Balance")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Partenity Leave Balance"; Rec."Partenity Leave Balance")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Compasionate Leave Balance"; Rec."Compasionate Leave Balance")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Overtime Leave Balance"; Rec."Overtime Leave Balance")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Overtime Leave Balance field.', Comment = '%';
            }
            field("No."; Rec."No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
