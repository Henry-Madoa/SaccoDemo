page 52204125 "Employer Payroll Details"
{
    ApplicationArea = All;
    Caption = 'Employer Payroll Details';
    PageType = ListPart;
    SourceTable = "Employer Payroll Details";
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EmployerCode; Rec."Employer Code")
                {
                    visible = false;
                }
                field(UploadType; Rec."Upload Type")
                {
                    Editable = not Rec.Processed;
                }
                field("Payroll Code"; Rec."Payroll Code")
                {
                    Editable = not Rec.Processed;
                }
                field(Name; Rec.Name)
                {
                    Editable = not Rec.Processed;
                }
                field(Period; Rec.Period)
                {
                    Editable = not Rec.Processed;
                }
                field("Product Code"; Rec."Product Code")
                {
                    Editable = ((not Rec.Processed) and (Rec."Upload Type" = Rec."Upload Type"::Checkoff));
                }
                field(Amount; Rec.Amount)
                {
                    Editable = not Rec.Processed;
                }
                field(Processed; Rec.Processed)
                {
                    visible = false;
                }
            }
        }
    }
}
