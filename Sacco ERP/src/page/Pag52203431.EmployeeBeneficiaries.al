page 52203431 "Employee Beneficiaries"
{
    PageType = List;
    SourceTable = "Employee Beneficiaries";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Full Names"; Rec."Full Names")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Relationship; Rec.Relationship)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ID/Birth Certificate No."; Rec."ID/Birth Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        EmployeeBeneficiaries.Reset;
        EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
        if EmployeeBeneficiaries.FindSet then begin
            EmployeeBeneficiaries.CalcSums(Percentage);
            if EmployeeBeneficiaries.Percentage > 100 then Error('Percentage cannot be higher than 100%');
        end;
        EmployeeBeneficiaries.Reset;
        EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
        if EmployeeBeneficiaries.FindSet then begin
            EmployeeBeneficiaries.CalcSums(Percentage);
            if EmployeeBeneficiaries.Percentage < 100 then Error('Percentage does not add up to 100%');
        end;
        EmployeeBeneficiaries.Reset;
        EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
        EmployeeBeneficiaries.SetRange(Type, EmployeeBeneficiaries.Type::Adult);
        if EmployeeBeneficiaries.FindSet then begin
            repeat EmployeeBeneficiaries.TestField("ID/Birth Certificate No.");
            until EmployeeBeneficiaries.Next = 0;
        end;
        EmployeeBeneficiaries.Reset;
        EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
        EmployeeBeneficiaries.SetRange(Type, EmployeeBeneficiaries.Type::Minor);
        if EmployeeBeneficiaries.FindSet then begin
            repeat EmployeeBeneficiaries.TestField(Comments);
            until EmployeeBeneficiaries.Next = 0;
        end;
    // EmployeeBeneficiaries.Reset;
    // EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
    // if EmployeeBeneficiaries.FindSet then begin
    //     repeat
    //         EmployeeBeneficiaries.TestField(Percentage);
    //     until EmployeeBeneficiaries.Next = 0;
    // end;
    end;
    var EmployeeBeneficiaries: Record "Employee Beneficiaries";
}
