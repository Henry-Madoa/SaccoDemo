page 52203432 "Leave Adj. Employee Lookup"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = Employee;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Initials; Rec.Initials)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        if CloseAction in[ACTION::OK, ACTION::LookupOK]then begin
            Employee.Reset;
            CurrPage.SetSelectionFilter(Employee);
            if Employee.FindFirst then begin
                Window.Open('Copying Employee Info. \Employee #1#');
                repeat Window.Update(1, Employee.FullName);
                    LeaveAdjustmentsLine.Init;
                    LeaveAdjustmentsLine."No.":=AdjNo;
                    LeaveAdjustmentsLine."Employee No.":=Employee."No.";
                    LeaveAdjustmentsLine."Processed Date":=0D;
                    LeaveAdjustmentsLine."Employee Name":=Employee.FullName;
                    LeaveAdjustmentsLine."Adjustment Days":=Daiz;
                    LeaveAdjustmentsLine.Insert;
                until Employee.Next = 0;
                Window.Close;
            end;
        end;
    end;
    var LeaveAdjustmentsLine: Record "Leave Adjustment Line";
    Employee: Record Employee;
    Window: Dialog;
    AdjNo: Code[20];
    Daiz: Integer;
    procedure InitializePaarams(Adj: Code[20]; Dayss: Integer)
    begin
        AdjNo:=Adj;
        Daiz:=Dayss;
    end;
}
