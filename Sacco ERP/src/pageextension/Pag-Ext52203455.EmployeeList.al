pageextension 52203455 "Employee List" extends "Employee List"
{
    layout
    {
        // Add changes to page layout here
        modify("No.")
        {
            StyleExpr = Style;
        }
        modify("First Name")
        {
            StyleExpr = Style;
        }
        modify("Last Name")
        {
            StyleExpr = Style;
        }
        modify("Job Title")
        {
            StyleExpr = Style;
        }
        modify("Phone No.")
        {
            StyleExpr = Style;
        }
        modify("Search Name")
        {
            StyleExpr = Style;
        }
        modify(Comment)
        {
            StyleExpr = Style;
        }
        addafter(Comment)
        {
            field(Status; Rec.Status)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Employee Status"; Rec."Employee Status")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field(Gender; Rec.Gender)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Job Code"; Rec."Job Code")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
        addafter(Control1905767507)
        {
            part(Control5; "Employee Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No.");
            }
            part(Control17; "Leave Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetStyle;
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle;
    end;

    local procedure SetStyle()
    begin
        Style := '';
        if EmployeeMaster."Contract End Date" <> 0D then begin
            ContractYear := Date2DMY(EmployeeMaster."Contract End Date", 3);
            ContractMonth := Date2DMY(EmployeeMaster."Contract End Date", 2);
            Year := Date2DMY(Today, 3);
            //Style:
            if ((ContractYear = Year) and ((ContractMonth - Month) = 1)) then
                Style := 'StrongAccent'
            else if ((ContractYear = Year) and (ContractMonth = Month)) then Style := 'Ambiguous';
            if (EmployeeMaster."Contract End Date" < Today) then Style := 'Unfavorable';
        end;
    end;

    var
        EmployeeMaster: Record Employee;
        Style: Text[20];
        ContractYear: Integer;
        ContractMonth: Integer;
        Year: Integer;
        Month: Integer;
}
