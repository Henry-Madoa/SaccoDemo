report 52203519 "Leave Days Dropped"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Days Dropped.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
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
            column(DroppedDays; DaysDroped)
            {
            }
            column(OpeningBal; OpeningBal)
            {
            }
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
            column(LeaveYearCode; LeaveYearCode)
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                OpeningBal:=0;
                DaysDroped:=0;
                LeaveTypes.Reset;
                LeaveTypes.SetRange("Is Annual Leave", true);
                if LeaveTypes.FindFirst then begin
                    LeaveLedgerEntries.Reset;
                    LeaveLedgerEntries.SetRange("Leave Type", LeaveTypes.Code);
                    LeaveLedgerEntries.SetRange("Leave Entry Type", LeaveLedgerEntries."Leave Entry Type"::OpeinigBalance);
                    LeaveLedgerEntries.SetRange("Employee No.", Employee."No.");
                    LeaveLedgerEntries.SetRange("Leave Year Code", LeaveYearCode);
                    if LeaveLedgerEntries.FindSet then begin
                        LeaveLedgerEntries.CalcSums(Quantity);
                        OpeningBal:=LeaveLedgerEntries.Quantity;
                    end;
                    if Evaluate(YearIntLast, LeaveYearCode)then begin
                        YearIntCurrent:=YearIntLast - 1;
                        PreviousYear:=Format(YearIntCurrent);
                    end;
                    LeaveLedgerEntries.Reset;
                    LeaveLedgerEntries.SetRange("Leave Type", LeaveTypes.Code);
                    LeaveLedgerEntries.SetRange("Employee No.", Employee."No.");
                    LeaveLedgerEntries.SetRange("Leave Year Code", PreviousYear);
                    if LeaveLedgerEntries.FindSet then begin
                        LeaveLedgerEntries.CalcSums(Quantity);
                        DaysDroped:=LeaveLedgerEntries.Quantity - OpeningBal;
                    end;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Current Year"; LeaveYearCode)
                {
                    TableRelation = "Leave Calendar";
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    DaysDroped: Decimal;
    OpeningBal: Decimal;
    LeaveTypes: Record "Leave Types";
    LeaveLedgerEntries: Record "Leave Ledger Entries";
    PreviousYear: Code[50];
    YearIntLast: Integer;
    YearIntCurrent: Integer;
    LeaveYearCode: Code[50];
}
