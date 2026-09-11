report 52203423 "Cash Receipt"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Cash Receipt.rdl';

    dataset
    {
        dataitem("Receipt Header"; "Receipt Header")
        {
            column(Receipt_No_; "No.")
            {
            }
            column(Receiving_Account_Type; "Receipt Type")
            {
            }
            column(Receiving_Account_No_; "Bank Account")
            {
            }
            column(Receiving_Account_Name; "Bank Account Name")
            {
            }
            column(Posting_Date; "Posted Date")
            {
            }
            column(Posting_Description; Description)
            {
            }
            column(Amount; Amount)
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(External_Document_No_; "External Document No.")
            {
            }
            column(Payment_Method_Code; "Pay Mode")
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(AmountInWords; AmountInWords[1])
            {
            }
            dataitem("Receipt Lines"; "Receipt Lines")
            {
                DataItemLink = "No."=field("No.");

                column(Receipt_Type; "Receipt Type")
                {
                }
                column(Description; Description)
                {
                }
                column(AllocationAmount; Amount)
                {
                }
                column(Member_No_;'')
                {
                }
                column(MemberName;'Non Member')
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                Clear(AmountInWords);
                AmountToWords.FormatNoText(AmountInWords, Amount, '');
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    AmountToWords: Codeunit "Amount To Words";
    AmountInWords: array[2]of Text[250];
}
