report 52204056 "Defaulter 2nd Notice"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Defaulter 2nd Notice.rdl';

    dataset
    {
        dataitem("Notice Lines"; "Defaulter Notice Lines")
        {
            RequestFilterFields = "Loan No";

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
            column(CompanySignature; CompanyInformation.Signature)
            {
            }
            column(No_; "No.")
            {
            }
            column(Defaulted_Days; "Defaulted Days")
            {
            }
            column(NoticeDate; DefaulterNotice."Notice Date")
            {
            }
            column(MemberFirstName; Member."First Name")
            {
            }
            column(MemberName; Member.FullName)
            {
            }
            column(MemberPhoneNo; Member."Mobile Phone No.")
            {
            }
            column(MemberEmail; Member."E-Mail")
            {
            }
            dataitem(Loans; Loans)
            {
                DataItemLink = "No." = field("Loan No");
                CalcFields = "Loan Balance", "Monthly Principal", "Principal Balance", "Interest Balance", "Last Pay Date";

                column(Application_No; "No.")
                {
                }
                column(Product_Code; "Product Code")
                {
                }
                column(Product_Description; UpperCase("Product Description"))
                {
                }
                column(Total_Arrears; "Total Arrears")
                {
                }
                column(Posting_Date; "Posting Date")
                {
                }
                column(Approved_Amount; "Approved Amount")
                {
                }
                column(Monthly_Principal; "Monthly Principal")
                {
                }
                column(Loan_Balance; "Loan Balance")
                {
                }
                column(Defaulted_Installments; "Defaulted Installments")
                {
                }
                column(Principal_Balance; "Principal Balance")
                {
                }
                column(Interest_Balance; "Interest Balance")
                {
                }
                column(Last_Pay_Date; "Last Pay Date")
                {
                }
                dataitem(LoanGuarantees; "Loan Guarantees")
                {
                    DataItemLink = "Loan No" = field("No.");
                    DataItemTableView = where(Substituted = const(false));

                    column(LoanGuarantees_MemberNo; "Member No.")
                    {
                    }
                    column(LoanGuarantees_MemberName; "Member Name")
                    {
                    }
                    column(LoanGuarantees_GuaranteedAmount; "Guaranteed Amount")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if LoanGuarantees."Member No." = '' then CurrReport.Skip;
                    end;
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture, Signature);
                if Member.Get("Member No") then;
                if DefaulterNotice.Get("No.") then;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DefaulterNotice: Record "Defaulter Notice";
        Member: Record Members;
}
