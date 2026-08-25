page 52204205 "Headlines"
{
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
            field(Headline1; Text001)
            {
            }
            field(Headline2; 'You have made a total of ' + Format(loans) + ' loan application(s)')
            {
            }
            field(Headline3; 'Total Placements')
            {
            }
            field(Headline4; 'Loans Disbursed')
            {
            }
            field(Headline5; 'Fixed Deposits Created ' + Format(loans))
            {
            }
            field(HeadLine6; GetHighestLoanAmount())
            {
            }
        }
    }
    trigger OnOpenPage()
    var
        Users: Record User;
    begin
        LoanApplications.Reset();
        LoanApplications.SetRange("Created By", UserId);
        if LoanApplications.FindSet() then loans := LoanApplications.Count;
        if Users.Get(UserSecurityId()) then Text001 := 'Hello ' + Users."Full Name"
    end;

    local procedure GetHighestLoanAmount() LoanText: Text[250]
    var
        Loans: Record Loans;
    begin
        LoanText := '';
        Loans.Reset();
        Loans.SetRange(Posted, true);
        Loans.SetCurrentKey("Approved Amount");
        Loans.SetAscending("Approved Amount", false);
        if Loans.FindFirst() then LoanText := 'Your highest Loan is ' + Loans."Product Description" + ' to ' + Loans."Member Name" + ' of ' + Format(Loans."Approved Amount");
        exit(LoanText);
    end;

    var
        UserSetup: Record "User Setup";
        Text001: Text[250];
        LoanApplications: Record Loans;
        loans: Integer;
}
