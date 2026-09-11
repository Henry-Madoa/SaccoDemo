table 52204066 "Channel Guarantor Requests"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            trigger OnValidate()
            begin
                IF LoanApplication.GET("Loan No") THEN AppliedAmount := LoanApplication."Applied Amount";
                ApplicantName := LoanApplication."Member Name";
                Applicant := LoanApplication."Member No.";
                "Application Date" := LoanApplication."Application Date";
                "Product Name" := LoanApplication."Product Description";
                "Loan Type" := LoanApplication."Product Code";
            end;
        }
        field(2; "ID No"; Code[20])
        {
            trigger OnValidate()
            var
                OnlineGuarantorReq: Record "Channel Guarantor Requests";
                LoansMgt: Codeunit "Loans Management";
                Self, NonSelf : Decimal;
            begin
                /* IF Member.GET("ID No") THEN begin
                     "Member Name" := Member."Full Name";
                     if Member."Guarantee Blocked" = true then
                         Error('The Member No/ID No Does Not Exist');
                 end else begin*/
                Member.Reset();
                Member.SetRange("Identification No.", "ID No");
                Member.SetRange("Guarantee Blocked", false);
                if Member.FindFirst() then
                    "Member Name" := Member."Full Name"
                else
                    Error('The Member No/ID No Does Not Exist');
                "Member No" := Member."No.";
                PhoneNo := Member."Mobile Phone No.";
                OnlineGuarantorReq.Reset();
                if "Request Type" = "Request Type"::Guarantor then OnlineGuarantorReq.SetRange("Request Type", OnlineGuarantorReq."Request Type"::Witness);
                if "Request Type" = "Request Type"::Witness then OnlineGuarantorReq.SetRange("Request Type", OnlineGuarantorReq."Request Type"::Guarantor);
                OnlineGuarantorReq.SetRange("ID No", "ID No");
                OnlineGuarantorReq.SetRange("Loan No", "Loan No");
                if OnlineGuarantorReq.FindSet() then Error('You cannot use the same member as a guarantor and a witness');
                if LoanApplication.Get("Loan No") then begin
                    if "Request Type" = "Request Type"::Witness then begin
                        if Member.Get(LoanApplication."Member No.") then begin
                            if Member."Identification No." = "ID No" then Error('You Cannot be your own witness');
                        end;
                    end;
                end;
                Self := 0;
                NonSelf := 0;
                LoansMgt.GetSelfGuaranteeAmount("Member No", Self, NonSelf);
                "Available Self Guarantee" := LoansMgt.GetSelfGuaranteeEligibility("Member No");
                "Available Deposits" := LoansMgt.GetNonSelfGuaranteeEligibility("Member No");
                //     LoansManagement.ValidateOnlineMemberGuarantee(Rec);
                //     "Guarantor Value" := LoansManagement.GetGuarantorValue("Member No");
            end;
        }
        field(3; "Member Name"; Text[200])
        {
            Editable = false;
        }
        field(4; "Loan Principal"; Decimal)
        {
        }
        field(5; Status; Enum "Document Status")
        {
        }
        field(6; "Loan Submitted"; Boolean)
        {
        }
        field(7; "PhoneNo"; Code[30])
        {
        }
        field(8; "AppliedAmount"; Integer)
        {
        }
        field(9; Applicant; Code[60])
        {
        }
        field(10; ApplicantName; Code[200])
        {
        }
        field(11; "Rejection Reason"; Text[300])
        {
        }
        field(12; "Guarantor Value"; Decimal)
        {
        }
        field(13; "Amount Accepted"; Decimal)
        {
        }
        field(14; "Request Type"; Option)
        {
            OptionMembers = Guarantor,Witness,Substitution;
        }
        field(15; "Requested Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                LoansManagement.SendGuarantorRequestCommunication(Rec, "Requested Amount");
            end;
        }
        field(16; "Member No"; Code[20])
        {
        }
        field(17; "Application Date"; Date)
        {
        }
        field(18; "Loan Type"; Code[20])
        {
        }
        field(19; "Product Name"; Text[100])
        {
        }
        field(20; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(21; "Responded On"; DateTime)
        {
            Editable = false;
        }
        field(22; "Available Self Guarantee"; Decimal)
        {
        }
        field(23; "Available Deposits"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Loan No", "ID No", "Request Type")
        {
            Clustered = true;
        }
    }
    var
        Member: Record Members;
        LoanApplication: Record "Channel Loan Application";
        LoansManagement: Codeunit "Loans Management";

    trigger OnInsert()
    var
        OnlineGuarantorReq: Record "Channel Guarantor Requests";
    begin
        OnlineGuarantorReq.Reset();
        if "Request Type" = "Request Type"::Guarantor then OnlineGuarantorReq.SetRange("Request Type", OnlineGuarantorReq."Request Type"::Witness);
        if "Request Type" = "Request Type"::Witness then OnlineGuarantorReq.SetRange("Request Type", OnlineGuarantorReq."Request Type"::Guarantor);
        OnlineGuarantorReq.SetRange("ID No", "ID No");
        OnlineGuarantorReq.SetRange("Loan No", "Loan No");
        if OnlineGuarantorReq.FindSet() then Error('You cannot use the same member as a guarantor and a witness');
        if LoanApplication.Get("Loan No") then begin
            if "Request Type" = "Request Type"::Witness then begin
                if Member.Get(LoanApplication."Member No.") then begin
                    if Member."Identification No." = "ID No" then Error('You Cannot be your own witness');
                end;
            end;
        end;
        "Created On" := CurrentDateTime;
    end;
}
