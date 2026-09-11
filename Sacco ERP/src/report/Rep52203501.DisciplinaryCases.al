report 52203501 "Disciplinary Cases"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Disciplinary Cases.rdlc';

    dataset
    {
        dataitem("Disciplinary Case Header"; "Disciplinary Case Header")
        {
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(No_DisciplinaryCaseHeader; "Disciplinary Case Header".No)
            {
            }
            column(CreatedBy_DisciplinaryCaseHeader; "Disciplinary Case Header"."Created By")
            {
            }
            column(CreatedOn_DisciplinaryCaseHeader; "Disciplinary Case Header"."Created On")
            {
            }
            column(EmployeeNo_DisciplinaryCaseHeader; "Disciplinary Case Header"."Employee No")
            {
            }
            column(EmployeeName_DisciplinaryCaseHeader; "Disciplinary Case Header"."Employee Name")
            {
            }
            column(GlobalDimension1Code_DisciplinaryCaseHeader; "Disciplinary Case Header"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_DisciplinaryCaseHeader; "Disciplinary Case Header"."Global Dimension 2 Code")
            {
            }
            column(NoSeries_DisciplinaryCaseHeader; "Disciplinary Case Header"."No. Series")
            {
            }
            column(Status_DisciplinaryCaseHeader; "Disciplinary Case Header".Status)
            {
            }
            dataitem("Disciplinary Case Lines"; "Disciplinary Case Lines")
            {
                DataItemLink = "Disciplinary No"=FIELD(No);

                column(DisciplinaryNo_DisciplinaryCaseLines; "Disciplinary Case Lines"."Disciplinary No")
                {
                }
                column(EmployeeNo_DisciplinaryCaseLines; "Disciplinary Case Lines"."Employee No")
                {
                }
                column(EmployeeName_DisciplinaryCaseLines; "Disciplinary Case Lines"."Employee Name")
                {
                }
                column(OffenceCode_DisciplinaryCaseLines; "Disciplinary Case Lines"."Offence Code")
                {
                }
                column(OffenceCategory_DisciplinaryCaseLines; "Disciplinary Case Lines"."Offence Category")
                {
                }
                column(Dateofoffence_DisciplinaryCaseLines; "Disciplinary Case Lines"."Date of offence")
                {
                }
                column(CommiteeDecision_DisciplinaryCaseLines; "Disciplinary Case Lines"."Commitee Decision")
                {
                }
                column(OffenceDescription_DisciplinaryCaseLines; "Disciplinary Case Lines"."Offence Description")
                {
                }
                column(OffenceCategoryDescription_DisciplinaryCaseLines; "Disciplinary Case Lines"."Offence Category Description")
                {
                }
                column(JobGroup; JobGroup)
                {
                }
                column(JobTitle; JobTitle)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    JobGroup:='';
                    JobTitle:='';
                    if Employee.Get()then begin
                        JobGroup:=Employee."Job Scale";
                        JobTitle:=Employee."Job Title";
                    end;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    JobGroup: Text;
    JobTitle: Text;
    Employee: Record Employee;
}
