table 52204048 "Loan Guarantees"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Loan Guarantees";
    LookupPageId = "Loan Guarantees";

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; code[20])
        {
            TableRelation = members;

            trigger OnValidate()
            var
                LoanRecoveries: Record "Loan Recoveries";
            begin
                LoansManagement.CheckOkToGuarantee("Member No.", "Loan No");
                if Member.Get("Member No.") then "Member Name" := Member."Full Name";
                "Member Deposits" := LoansManagement.GetMemberDeposits("Member No.");
                "Multiplied Deposits" := LoansManagement.GetGuarantorMultiplier * LoansManagement.GetMemberDeposits("Member No.");
                if isSelf then begin
                    "Available Guarantee" := LoansManagement.GetSelfGuaranteeEligibility("Member No.");
                    LoanRecoveries.Reset;
                    LoanRecoveries.SetRange("Loan No", "Loan No");
                    LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                    if LoanRecoveries.FindSet then begin
                        LoanRecoveries.CalcSums(Amount);
                        "Available Guarantee" += LoanRecoveries.Amount;
                    end;
                end else
                    "Available Guarantee" := LoansManagement.GetNonSelfGuaranteeEligibility("Member No.");
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Member Deposits"; Decimal)
        {
            Editable = false;
        }
        field(5; "Multiplied Deposits"; Decimal)
        {
            Editable = false;
        }
        field(6; "Guaranteed Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Guaranteed Amount" > "Available Guarantee" then
                    Error('You can only guarantee upto %1', "Available Guarantee");
            end;
        }
        field(7; "Outstanding Guarantees"; Decimal)
        {
            Editable = false;
        }
        field(8; "Available Guarantee"; Decimal)
        {
            Editable = false;
        }
        field(9; "Self Guarantee"; Decimal)
        {
            Editable = false;
        }
        field(10; "Intial Substitution"; Decimal)
        {
            Editable = false;
        }
        field(11; Self; Boolean)
        {
            Editable = false;
        }
        field(12; Substituted; Boolean)
        {
            Editable = false;
        }
        field(13; "Substituted By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(14; "Document No."; Code[20])
        {
            Editable = false;
        }
        field(15; "Loan Owner"; code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Loans."Member No." where("No." = field("Loan No")));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Member No.", "Loan No")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        CheckLoanStatus;
    end;

    trigger OnModify()
    begin
        CheckLoanStatus;
    end;

    trigger OnInsert()
    begin
        CheckLoanStatus;
    end;

    var
        Member: Record Members;
        LoansManagement: Codeunit "Loans Management";
        Loans: Record Loans;

    procedure FnSendSMSToGuarantor(Var LoanNo: Code[20]; var MemberNo: Code[20])
    var
        ObjSMSMgt: Codeunit "Notifications Management";
        SMSText: Text;
        SMSNo: Text;
        SMSSource: Code[20];
        ObjLoanGuarantee: Record "Loan Guarantees";
        ObjMemberMgt: Codeunit "Member Management";
        ObjLoanApp: Record Loans;
    begin
        SMSSource := '';
        SMSText := '';
        SMSNo := '';
        ObjLoanGuarantee.reset;
        ObjLoanGuarantee.SetRange("Loan No", LoanNo);
        ObjLoanGuarantee.SetRange("Member No.", MemberNo);
        if ObjLoanGuarantee.findset then begin
            ObjLoanApp.Get(LoanNo);
            repeat
                SMSSource := 'LOAN_GUARANTOR';
                SMSText := StrSubstNo('Dear %1, You have guaranteed %2 (MNo: %3) for a %4 of KES %5. If this was not authorized, please contact us immediately.', ObjLoanApp."Member Name", ObjLoanGuarantee."Member Name", ObjLoanGuarantee."Member No.", ObjLoanApp."Product Description", Format(ObjLoanGuarantee."Guaranteed Amount"));
                SMSNo := ObjMemberMgt.GetMemberPhoneNo(ObjLoanGuarantee."Member No.");
                ObjSMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            until ObjLoanGuarantee.next = 0;
        end;
    end;

    local procedure isSelf() Success: boolean
    Var
        Loans: Record Loans;
    begin
        if Loans.Get("Loan No") then begin
            if "Member No." = Loans."Member No." then
                exit(true)
            else
                exit(false);
        end;
    end;

    local procedure CheckLoanStatus()
    begin
        // If Loans.Get("Loan No") then
        //     Loans.TestField(Status, Loans.Status::Open);
    end;
}
