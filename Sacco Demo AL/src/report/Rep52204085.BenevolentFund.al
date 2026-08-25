report 52204085 "Benevolent Fund"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Benevolent Fund.rdl';

    dataset
    {
        dataitem("Receipt"; "Benevolent Fund")
        {
            RequestFilterFields = "Member No.";

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
            column(CompanyLocation; CompanyInformation.City)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."E-Mail")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(Document_No; Receipt."No.")
            {
            }
            column(Payment_Amount; Receipt."Payment Amount")
            {
            }
            column(KIN_Relationship; Relationship)
            {
            }
            column(Payment_Type; "Payment Type")
            {
            }
            column(Member_No; "Member No.")
            {
            }
            column(KIN_Name; "KIN Name")
            {
            }
            column(KIN_DOB; Receipt."Kin DOB")
            {
            }
            column(Posting_Date; Receipt."Posting Date")
            {
            }
            column(Full_Name; Receipt."Full Name")
            {
            }
            column(Processed_On; Receipt."Processed on")
            {
            }
            column(Paying_Account_No; Receipt."Paying Account No")
            {
            }
            column(Posting_Description; Receipt."Posting Description")
            {
            }
            column(KinDetail; Receipt."Kin")
            {
            }
            column(CreatedBy_Receipt; Receipt."Created By")
            {
            }
            column(CreatedOn_Receipt; Receipt."Created On")
            {
            }
            column(AmountInWords; NumberText[1] + ' ' + NumberText[2])
            {
            }
            trigger OnAfterGetRecord()
            begin
                GLsetup.GET;
                CurrencyCodeText := GLsetup."LCY Code";
                Clear(NumberText);
                Relationship := Format("KIN Relationship");
                AmountToWords.FormatNoText(NumberText, "Payment Amount", CurrencyCodeText);
                if "Payment Type" = "Payment Type"::"Principal Member" then begin
                    Relationship := 'Self';
                    "KIN Name" := "Full Name";
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        GLsetup: Record "General Ledger Setup";
        NumberText: array[2] of Text[80];
        AmountToWords: Codeunit "Amount To Words";
        CurrencyCodeText: Code[10];
        Relationship: Text;
}
