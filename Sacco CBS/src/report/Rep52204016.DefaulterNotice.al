report 52204016 "Defaulter Notice"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Defaulter Notice.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            RequestFilterFields = "Member No.";
            CalcFields = "Loan Balance", "Monthly Principal";

            column(Application_No; "No.")
            {
            }
            column(Main_Member_Name; "Member Name")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
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
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanySignature; CompanyInformation.Signature)
            {
            }
            column(Approved_Amount; Format("Approved Amount"))
            {
            }
            column(Total_Arrears; "Total Arrears")
            {
            }
            column(NoticeDate; NoticeDate)
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Monthly_Principal; Format(Round("Monthly Principal", 1, '>')))
            {
            }
            column(Loan_Balance; Format(Round("Loan Balance", 1, '>')))
            {
            }
            column(Defaulted_Installments; "Defaulted Installments")
            {
            }
            column(MemberAddress; MemberInfo[1])
            {
            }
            column(MemberEmail; MemberInfo[2])
            {
            }
            dataitem("Loan Guarantees"; "Loan Guarantees")
            {
                DataItemLink = "Loan No" = field("No.");
                DataItemTableView = where(Substituted = const(false));

                column(Member_No; "Member No.")
                {
                }
                column(Member_Name; "Member Name")
                {
                }
                column(Guaranteed_Amount; "Guaranteed Amount")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                Clear(MemberInfo);
                Members.Get("Member No.");
                MemberInfo[1] := Members.Address;
                MemberInfo[2] := Members."E-Mail";
                if NoticeDate = 0D then NoticeDate := WorkDate;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture, Signature);
            end;
        }
    }
    var
        NoticeDate: Date;
        CompanyInformation: Record "Company Information";
        PayrollNo: Code[20];
        MemberMgt: Codeunit "Member Management";
        IssueDate: Date;
        MemberInfo: array[10] of Text[100];
        Members: Record Members;
}
