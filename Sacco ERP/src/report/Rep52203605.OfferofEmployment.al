report 52203605 "Offer of Employment"
{
    // version THL- HRM 1.0
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Offer of Employment.rdlc';

    dataset
    {
        dataitem(Applicant; Applicant)
        {
            column(Logo; CompInfo.Picture)
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(OfferDate; Format(Today, 0, 4))
            {
            }
            column(FullName; Applicant."First Name" + ' ' + Applicant."Middle Name" + ' ' + Applicant."Last Name")
            {
            }
            column(POBox; Applicant."Postal Address")
            {
            }
            column(City; Applicant.City)
            {
            }
            column(FirstName; Applicant."First Name")
            {
            }
            column(Title; ReportTitle)
            {
            }
            column(BeforeTitle; BeforeTitle)
            {
            }
            column(JobTitle; Applicant."Job ID")
            {
            }
            column(EffectiveDate; Applicant."Employment Date")
            {
            }
            column(OfficeLocation; Applicant."Office Location")
            {
            }
            column(ProbationPeriod; Applicant."Probation Period")
            {
            }
            column(ProbationTerminationPeriod; Applicant."Probation Termination Notice")
            {
            }
            column(AnnualLeaveDays; Applicant."Annual Leave Days")
            {
            }
            column(LeaveNoticePeriod; Applicant."Leave Notice Period")
            {
            }
            column(ContractTerminationNotice; Applicant."Contract Termination Notice")
            {
            }
            column(HoursWorkedPerWeek; Applicant."Hours Worked Per Week")
            {
            }
            column(DaysWorkedPerWeek; Applicant."Days Worked Per Week")
            {
            }
            column(ReportingTime; Applicant."Reporting Time")
            {
            }
            column(ClosingTime; Applicant."Closing Time")
            {
            }
            column(LunchBreakDuration; Applicant."Lunch Break Duration")
            {
            }
            column(LunchStartTime; Applicant."Lunch Start Time")
            {
            }
            column(LunchEndTime; Applicant."Lunch End Time")
            {
            }
            column(FirstDayOfWeek; Applicant."Week Start Day")
            {
            }
            column(LastDayOfWeek; Applicant."Week End Day")
            {
            }
            column(OfferSignedBy; Applicant."Offer Signed By")
            {
            }
            column(EarningOne; Earning[1])
            {
            }
            column(EarningTwo; Earning[2])
            {
            }
            column(EarningThree; Earning[3])
            {
            }
            column(AmountOne; EarningAmount[1])
            {
            }
            column(AmountTwo; EarningAmount[2])
            {
            }
            column(AmountThree; EarningAmount[3])
            {
            }
            column(LCYCode; GLSetup."LCY Code")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if CopyStr(Applicant."Job ID", 1, 1)in['A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u']then BeforeTitle:='an'
                else
                    BeforeTitle:='a';
                i:=0;
                ApplicantOffers.Reset;
                ApplicantOffers.SetRange("Applicant No.", Applicant."No.");
                if ApplicantOffers.Find('-')then begin
                    repeat i:=i + 1;
                        if Earn.Get(ApplicantOffers."Earning Code")then Earning[i]:=Earn.Name;
                        EarningAmount[i]:=ApplicantOffers.Amount;
                    until ApplicantOffers.Next = 0;
                end;
                GLSetup.Get;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Print Without Logo"; PrintWithoutLogo)
                {
                    ApplicationArea = All;
                }
            }
        }
        actions
        {
        }
    }
    labels
    {
    }
    trigger OnPreReport()
    begin
        if not PrintWithoutLogo then begin
            CompInfo.Get;
            CompInfo.CalcFields(Picture);
        end;
    end;
    var CompInfo: Record "Company Information";
    PrintWithoutLogo: Boolean;
    ReportTitle: Label 'RE: LETTER OF OFFER';
    BeforeTitle: Text;
    ApplicantOffers: Record "Applicant Offers";
    Earn: Record "Payroll Transaction Code";
    Earning: array[3]of Text;
    EarningAmount: array[3]of Decimal;
    i: Integer;
    GLSetup: Record "General Ledger Setup";
}
