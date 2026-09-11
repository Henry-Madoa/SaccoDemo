report 52204032 "Member Guarantees"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Member Guarantees.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.";

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
            column("CompanyWebsite"; CompanyInformation."Home Page")
            {
            }
            column(Deposits; Deposits)
            {
            }
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(MaxSelfGuarantee; MaxSelfGuarantee)
            {
            }
            column(MaxNonSelfGuarantee; MaxNonSelfGuarantee)
            {
            }
            dataitem("Loan Guarantees"; "Loan Guarantees")
            {
                DataItemLink = "Member No." = field("No.");
                DataItemTableView = sorting("Member No.");

                column(Loan_No; "Loan No")
                {
                }
                column(Member_Deposits; "Member Deposits")
                {
                }
                column(Guaranteed_Amount; "Guaranteed Amount")
                {
                }
                column(Substituted; Substituted)
                {
                }
                column(Substitute; ("Intial Substitution" > 0))
                {
                }
                column(Arrears; Arrears)
                {
                }
                column(LoanClassification; LoanClassification)
                {
                }
                column(OutstandingGrnt; OutstandingGrnt)
                {
                }
                column(IssueDate; IssueDate)
                {
                }
                column(OwnerNo; OwnerNo)
                {
                }
                column(OwnerName; OwnerName)
                {
                }
                column(LoanBalance; LoanBalance)
                {
                }
                column(ProductCode; ProductCode)
                {
                }
                column(ProductName; ProductName)
                {
                }
                column(LoanPrincipal; LoanPrincipal)
                {
                }
                column(LoanApprovedAmount; LoanApprovedAmount)
                {
                }
                column(PayrollNo; PayrollNo)
                {
                }
                column(ReplaceWith; ReplaceWith)
                {
                }
                column(ReplaceDate; ReplaceDate)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    OutstandingGrnt := 0;
                    LoanClassification := '';
                    PayrollNo := '';
                    Arrears := 0;
                    OwnerName := '';
                    OwnerNo := '';
                    ProductCode := '';
                    ProductName := '';
                    ReplaceWith := '';
                    LoanPrincipal := 0;
                    LoanBalance := 0;
                    Clear(IssueDate);
                    Clear(ReplaceDate);
                    if Loans.Get("Loan Guarantees"."Loan No") then begin
                        if Members1.Get(Loans."Member No.") then begin
                            PayrollNo := Members1."Payroll No.";
                            if PayrollNo = '' then PayrollNo := Members1."Payroll No.";
                        end;
                        Loans.CalcFields("Loan Balance");
                        IssueDate := Loans."Posting Date";
                        ProductCode := Loans."Product Code";
                        ProductName := Loans."Product Description";
                        OwnerName := Loans."Member Name";
                        OwnerNo := Loans."Member No.";
                        LoanBalance := Loans."Loan Balance";
                        LoanApprovedAmount := Loans."Approved Amount";
                        LoanPrincipal := Loans."Loan Amount";
                        LoanClassification := Format(Loans."Loan Classification");
                        Arrears := Loans."Total Arrears";
                        OutstandingGrnt := MemberMgt.GetOutstandingGuarantee(Loans."No.", "Loan Guarantees"."Member No.");
                        if OutstandingGrnt = 0 then CurrReport.Skip();
                        if Substituted then begin
                            if GuarantorHder.Get("Document No.") then ReplaceDate := GuarantorHder."Posting Date";
                            if ReplaceDate = 0D then ReplaceDate := dt2date(GuarantorHder."Created On");

                            GuarantorLines[1].Reset();
                            GuarantorLines[1].SetRange("No.", "Document No.");
                            GuarantorLines[1].SetRange("Security Code", "Member No.");
                            if GuarantorLines[1].FindSet() then begin
                                GuarantorDetLines[1].Reset();
                                GuarantorDetLines[1].SetRange("No.", "Document No.");
                                GuarantorDetLines[1].SetRange("Line No", GuarantorLines[1]."Line No");
                                if GuarantorDetLines[1].FindSet() then begin
                                    repeat
                                        ReplaceWith += (GuarantorDetLines[1]."Security Code" + ',');
                                    until GuarantorDetLines[1].Next() = 0;
                                end;
                            end;
                        end;
                        if StrLen(ReplaceWith) > 0 then
                            ReplaceWith := CopyStr(ReplaceWith, 1, StrLen(ReplaceWith) - 1);
                    end
                    else
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                MaxNonSelfGuarantee := 0;
                MaxSelfGuarantee := 0;
                MaxSelfGuarantee := LoansMGt.GetSelfGuaranteeEligibility("No.");
                MaxNonSelfGuarantee := LoansMGt.GetNonSelfGuaranteeEligibility("No.");
                Deposits := 0;
                Members.CalcFields("Total Deposits");
                Deposits := Members."Total Deposits";
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        PayrollNo: Code[20];
        MemberMgt: Codeunit "Member Management";
        Loans: Record Loans;
        OutstandingGrnt, Arrears, LoanPrincipal, LoanBalance, MaxSelfGuarantee, MaxNonSelfGuarantee, Deposits : Decimal;
        LoanClassification, OwnerNo, OwnerName, ProductCode, ProductName, ReplaceWith : Text;
        GuarantorDetLines: array[2] of Record "Loan Security Mgmt Det. Lines";
        GuarantorLines: array[2] of Record "Loan Security Mgmt Lines";
        GuarantorHder: Record "Loan Security Mgmt";
        IssueDate, ReplaceDate : Date;
        Members1: Record Members;
        LoansMGt: Codeunit "Loans Management";
        LoanApprovedAmount: Decimal;
}
