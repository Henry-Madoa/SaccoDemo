report 52203546 "Sacco Deductions Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Sacco Deductions Report.rdl';

    dataset
    {
        dataitem("Payroll Transaction Code"; "Payroll Transaction Code")
        {
            DataItemTableView = WHERE("Coop Parameter"=FILTER(Shares|loan|"loan Interest"));

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
            column(Prepared_By_;'Prepared By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Verified_By_;'Verified By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Audited_By_;'Audited By...............................................Sign.............................................Date.............................................')
            {
            }
            column(Approved_By_;'Approved By.............................................Sign.............................................Date.............................................')
            {
            }
            dataitem(PayrollPeriodTransaction; "Payroll Period Transaction")
            {
                RequestFilterFields = "Payroll Period";
                DataItemLink = "Transaction Code"=field(Code);

                column(EmployeeCode_PayrollPeriodTransaction; PayrollPeriodTransaction."Employee Code")
                {
                }
                column(TransactionCode_PayrollPeriodTransaction; PayrollPeriodTransaction."Transaction Code")
                {
                }
                column(TransactionName_PayrollPeriodTransaction; PayrollPeriodTransaction."Transaction Name")
                {
                }
                column(Amount_PayrollPeriodTransaction; PayrollPeriodTransaction.Amount)
                {
                }
                column(Balance_PayrollPeriodTransaction; PayrollPeriodTransaction.Balance)
                {
                }
                column(PayrollPeriod_PayrollPeriodTransaction; PayrollPeriodTransaction."Payroll Period")
                {
                }
                dataitem(Employee; Employee)
                {
                    DataItemLink = "No."=field("Employee Code");

                    column(FullName_Employee; Employee.FullName)
                    {
                    }
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if PayrollPeriodTransaction.GetFilter(PayrollPeriodTransaction."Payroll Period") = '' then Error('You must specify the payroll period');
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
}
