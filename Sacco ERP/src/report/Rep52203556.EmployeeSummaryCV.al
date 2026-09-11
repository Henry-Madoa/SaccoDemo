report 52203556 "Employee Summary CV"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Summary CV.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            column(JobDescription_Employee; Employee."Job Title")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            column(EMail_Employee; Employee."E-Mail")
            {
            }
            column(MobilePhoneNo_Employee; Employee."Mobile Phone No.")
            {
            }
            column(PhoneNo_Employee; Employee."Phone No.")
            {
            }
            column(CountryRegionCode_Employee; Employee."Country/Region Code")
            {
            }
            column(SHIFNumber_Employee; Employee."SHIF No.")
            {
            }
            column(NSSFNumber_Employee; Employee."NSSF No.")
            {
            }
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            column(MaritalStatus_Employee; Employee."Marital Status")
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            column(FirstName_Employee; Employee."First Name")
            {
            }
            column(MiddleName_Employee; Employee."Middle Name")
            {
            }
            column(LastName_Employee; Employee."Last Name")
            {
            }
            column(Initials_Employee; Employee.Initials)
            {
            }
            dataitem("Employee Qualification"; "Employee Qualification")
            {
                column(EmployeeNo_EmployeeQualification; "Employee Qualification"."Employee No.")
                {
                }
                column(LineNo_EmployeeQualification; "Employee Qualification"."Line No.")
                {
                }
                column(QualificationCode_EmployeeQualification; "Employee Qualification"."Qualification Code")
                {
                }
                column(FromDate_EmployeeQualification; "Employee Qualification"."From Date")
                {
                }
                column(ToDate_EmployeeQualification; "Employee Qualification"."To Date")
                {
                }
                column(Type_EmployeeQualification; "Employee Qualification".Type)
                {
                }
                column(Description_EmployeeQualification; "Employee Qualification".Description)
                {
                }
                column(InstitutionCompany_EmployeeQualification; "Employee Qualification"."Institution/Company")
                {
                }
                column(Cost_EmployeeQualification; "Employee Qualification".Cost)
                {
                }
                column(CourseGrade_EmployeeQualification; "Employee Qualification"."Course Grade")
                {
                }
                column(EmployeeStatus_EmployeeQualification; "Employee Qualification"."Employee Status")
                {
                }
                column(Comment_EmployeeQualification; "Employee Qualification".Comment)
                {
                }
                column(ExpirationDate_EmployeeQualification; "Employee Qualification"."Expiration Date")
                {
                }
            }
            dataitem("Employee Work History"; "Employee Work History")
            {
                column(EmployeeNo_EmployeeWorkHistory; "Employee Work History"."Employee No.")
                {
                }
                column(LineNo_EmployeeWorkHistory; "Employee Work History"."Line No.")
                {
                }
                column(FromDate_EmployeeWorkHistory; "Employee Work History"."From Date")
                {
                }
                column(ToDate_EmployeeWorkHistory; "Employee Work History"."To Date")
                {
                }
                column(WorkDone_EmployeeWorkHistory; "Employee Work History"."Work Done")
                {
                }
                column(InstitutionCompany_EmployeeWorkHistory; "Employee Work History"."Institution/Company")
                {
                }
                column(EmployeeStatus_EmployeeWorkHistory; "Employee Work History"."Employee Status")
                {
                }
                column(Comment_EmployeeWorkHistory; "Employee Work History".Comment)
                {
                }
                column(PositionHeld_EmployeeWorkHistory; "Employee Work History"."Position Held")
                {
                }
                column(KeyExperience_EmployeeWorkHistory; "Employee Work History"."Key Experience")
                {
                }
                column(SalaryonLeaving_EmployeeWorkHistory; "Employee Work History"."Salary on Leaving")
                {
                }
                column(ReasonForLeaving_EmployeeWorkHistory; "Employee Work History"."Reason For Leaving")
                {
                }
                column(Comments_EmployeeWorkHistory; "Employee Work History".Comments)
                {
                }
            }
            dataitem("Employee Languages"; "Employee Languages")
            {
                column(EmployeeNo_EmployeeLanguages; "Employee Languages"."Employee No")
                {
                }
                column(Language_EmployeeLanguages; "Employee Languages".Language)
                {
                }
                column(Read_EmployeeLanguages; "Employee Languages".Read)
                {
                }
                column(Write_EmployeeLanguages; "Employee Languages".Write)
                {
                }
                column(Speak_EmployeeLanguages; "Employee Languages".Speak)
                {
                }
            }
            dataitem("Employee Beneficiaries"; "Employee Beneficiaries")
            {
                column(No_EmployeeBeneficiaries; "Employee Beneficiaries"."No.")
                {
                }
                column(EmployeeNo_EmployeeBeneficiaries; "Employee Beneficiaries"."Employee No.")
                {
                }
                column(FullNames_EmployeeBeneficiaries; "Employee Beneficiaries"."Full Names")
                {
                }
                column(IDBirthCertificateNo_EmployeeBeneficiaries; "Employee Beneficiaries"."ID/Birth Certificate No.")
                {
                }
                column(DateofBirth_EmployeeBeneficiaries; "Employee Beneficiaries"."Date of Birth")
                {
                }
                column(PhoneNo_EmployeeBeneficiaries; "Employee Beneficiaries"."Phone No.")
                {
                }
                column(EmailAddress_EmployeeBeneficiaries; "Employee Beneficiaries"."Email Address")
                {
                }
                column(Entitlement_EmployeeBeneficiaries; "Employee Beneficiaries".Entitlement)
                {
                }
                column(Relationship_EmployeeBeneficiaries; "Employee Beneficiaries".Relationship)
                {
                }
                column(Gender_EmployeeBeneficiaries; "Employee Beneficiaries".Gender)
                {
                }
                column(Beneficiary_EmployeeBeneficiaries; "Employee Beneficiaries".Beneficiary)
                {
                }
                column(Percentage_EmployeeBeneficiaries; "Employee Beneficiaries".Percentage)
                {
                }
                column(Comments_EmployeeBeneficiaries; "Employee Beneficiaries".Comments)
                {
                }
                column(Age_EmployeeBeneficiaries; "Employee Beneficiaries".Age)
                {
                }
                column(Type_EmployeeBeneficiaries; "Employee Beneficiaries".Type)
                {
                }
            }
            dataitem("Employee Depandants"; "Employee Depandants")
            {
                column(LineNo_EmployeeDepandants; "Employee Depandants"."Line No.")
                {
                }
                column(EmployeeNo_EmployeeDepandants; "Employee Depandants"."Employee No.")
                {
                }
                column(FullName_EmployeeDepandants; "Employee Depandants"."Full Name")
                {
                }
                column(IDBirthCertificateNo_EmployeeDepandants; "Employee Depandants"."ID/Birth Certificate No.")
                {
                }
                column(DateofBirth_EmployeeDepandants; "Employee Depandants"."Date of Birth")
                {
                }
                column(Age_EmployeeDepandants; "Employee Depandants".Age)
                {
                }
                column(Relationship_EmployeeDepandants; "Employee Depandants".Relationship)
                {
                }
                column(Gender_EmployeeDepandants; "Employee Depandants".Gender)
                {
                }
                column(IsStudent_EmployeeDepandants; "Employee Depandants"."Is Student")
                {
                }
            }
            dataitem("Employee Relative"; "Employee Relative")
            {
                column(EmployeeNo_EmployeeRelative; "Employee Relative"."Employee No.")
                {
                }
                column(LineNo_EmployeeRelative; "Employee Relative"."Line No.")
                {
                }
                column(RelativeCode_EmployeeRelative; "Employee Relative"."Relative Code")
                {
                }
                column(FirstName_EmployeeRelative; "Employee Relative"."First Name")
                {
                }
                column(MiddleName_EmployeeRelative; "Employee Relative"."Middle Name")
                {
                }
                column(LastName_EmployeeRelative; "Employee Relative"."Last Name")
                {
                }
                column(BirthDate_EmployeeRelative; "Employee Relative"."Birth Date")
                {
                }
                column(PhoneNo_EmployeeRelative; "Employee Relative"."Phone No.")
                {
                }
                column(RelativesEmployeeNo_EmployeeRelative; "Employee Relative"."Relative's Employee No.")
                {
                }
                column(Comment_EmployeeRelative; "Employee Relative".Comment)
                {
                }
                column(IDBirthCertificateNo_EmployeeRelative; "Employee Relative"."ID/Birth Certificate No.")
                {
                }
                column(EmailAddress_EmployeeRelative; "Employee Relative"."Email Address")
                {
                }
                column(Entitlement_EmployeeRelative; "Employee Relative".Entitlement)
                {
                }
                column(Gender_EmployeeRelative; "Employee Relative".Gender)
                {
                }
                column(DateofBirth_EmployeeRelative; "Employee Relative"."Date of Birth")
                {
                }
                column(Age_EmployeeRelative; "Employee Relative".Age)
                {
                }
            }
        }
    }
}
