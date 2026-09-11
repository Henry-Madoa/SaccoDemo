report 52204013 "Payment Reminders"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = True;

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            //DataItemTableView = where(Posted = const(true), Closed = const(false));
            trigger OnAfterGetRecord()
            begin
                "Loan Application".CalcFields("Loan Balance");
                if "Loan Application"."Loan Balance" <= 0 then CurrReport.Skip();
                MInstallment := 0;
                TargetDate := DMY2Date(25, 02, 2021);
                LoanSchedule.Reset();
                LoanSchedule.SetRange("Loan No.", "Loan Application"."No.");
                LoanSchedule.SetRange("Expected Date", TargetDate);
                if LoanSchedule.FindFirst() then MInstallment := round(LoanSchedule."Monthly Repayment", 1, '>');
                SMS := 'Dear ' + "Loan Application"."Member Name" + ' Your ' + "Loan Application"."Product Description" + ' Monthly Installment of Ksh. ' + Format(MInstallment) + ' is Due on ' + Format(TargetDate) + '. Thank You';
                SMSSource := 'PAYMT_REM';
                PhoneNo := '0729143665';
                if MInstallment > 0 then NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
            end;
        }
    }
    var
        TargetDate: Date;
        PhoneNo: Text[250];
        SMS: Text[250];
        Members: Record Members;
        Amnt: Decimal;
        CompanyInformation: Record "Company Information";
        LoanSchedule: Record "Loan Schedule";
        MInstallment: Decimal;
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
}
