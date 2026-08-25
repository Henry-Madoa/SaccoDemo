table 52204139 "Employer Payroll Details"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Employer Payroll Details";
    DrillDownPageId = "Employer Payroll Details";
    fields
    {
        field(1; "Employer Code"; Code[20])
        {
        }
        field(2; "Upload Type"; Option)
        {
            OptionMembers = Salary,Checkoff,Bonus,Other;
        }
        field(3; Period; Date)
        {
            tableRelation = "Payroll Periods";
        }
        field(4; "Payroll Code"; Code[20])
        {
            trigger OnLookup()
            var
                Member: Record Members;
            begin
                Member.Reset();
                Member.SetRange(Status, Member.Status::Active);
                Member.SetRange("Employer Code", "Employer Code");
                if Page.RunModal(0, Member) = Action::LookupOK then begin
                    Validate("Payroll Code", Member."Payroll No.");
                    Name := Member.FullName;
                end;
            end;
        }
        field(5; Name; Text[80])
        {
        }
        field(6; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; Processed; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Employer Code", "Upload Type", Period, "Payroll Code", "Product Code")
        {
            Clustered = true;
        }
    }
}
