table 52204104 "Channel Loan Application"
{
    DataClassification = ToBeClassified;
    DataCaptionFields = "No.", "Member Name", "Product Description", "Approved Amount", Status;
    LookupPageId = "Channel Loan Applications";
    DrillDownPageId = "Channel Loan Applications";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Members.Get("Member No.") then begin
                    "Member Name" := Members."Full Name";
                end;
                LoansManagement.PopulateChannelAppraisalParameters(Rec);
                "Share Capital" := LoansManagement.GetMemberShares("Member No.");
                Deposits := LoansManagement.GetMemberDeposits("Member No.");
                "Total Loans" := LoansManagement.GetMemberLoans("Member No.");
                if "Product Code" <> '' then
                    Validate("Product Code");
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), "Product Posting Type" = const("Loan Account"));

            trigger OnValidate()
            var
                MemberDeposits: Decimal;
                Member: Record Members;
                LoansManagement: Codeunit "Loans Management";
                EndDate: Date;
            begin
                if SaccoProducts.Get("Product Code") then begin
                    SaccoProducts.TestField("Interest Repayment Method");
                    Rec.TestField("Member No.");
                    Member.Get(Rec."Member No.");
                    MemberDeposits := LoansManagement.GetMemberDeposits(Member."No.");
                    if SaccoProducts."Appraise with 0 Deposits" = false then begin
                        if MemberDeposits <= 0 then Error('You Cannot Appraise %1 With %2 Deposits', SaccoProducts.Description, MemberDeposits);
                    end;
                    /* Henry       if ProductSetup."Salary Based" then
                               "Qualified Salarywise" := LoansManagement.AppraiseFosaSalary(Member."No.", "Product Code", "No.");
                    */
                    if MemberDeposits < SaccoProducts."Minimum Deposit Balance" then Error('You Cannot Appraise %1 With %2 Deposits', SaccoProducts.Description, MemberDeposits);
                    "Product Description" := SaccoProducts.Description;
                    "Interest Rate" := SaccoProducts."Interest Rate";
                    "Interest Repayment Method" := SaccoProducts."Interest Repayment Method";
                    "Rate Type" := SaccoProducts."Rate Type";
                    Installments := SaccoProducts."Ordinary Default Intallments";
                    "Mode of Disbursement" := Rec."Mode of Disbursement"::"FOSA (Full)";
                    "Disbursement Account" := LoansManagement.GetFOSAAccount(Rec."Member No.");
                    "Interest Repayment Method" := SaccoProducts."Interest Repayment Method";
                    "Salary Based" := SaccoProducts."Salary Based";
                    Validate(Installments);
                    "Maximum Repayment Period" := SaccoProducts."Maximum Installments";
                    LoansManagement.PopulateChannelAppraisalParameters(Rec);
                    EndDate := CalcDate('CM', "Application Date");
                    if Date2DMY("Application Date", 1) < SaccoProducts."Repayment Cutoff Date" then
                        "Prorated Days" := EndDate - "Application Date"
                    else
                        "Prorated Days" := 0;
                end;
            end;
        }
        field(5; "Product Description"; Text[50])
        {
            Editable = false;
        }
        field(6; "Applied Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                Validate("Loan Amount", "Applied Amount");
            end;
        }
        field(7; "Loan Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                LoansManagement.ValidateChannelAppraisal(Rec);
                Validate("Insurance Amount");
            end;
        }
        field(8; "Approved Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                LoansManagement.ValidateChannelAppraisal(Rec);
                Validate("Insurance Amount");
            end;
        }
        field(9; "Interest Rate"; Decimal)
        {
            Editable = false;
            DecimalPlaces = 5;
        }
        field(10; "Interest Repayment Method"; Enum "Loan Rate Type")
        {
            Editable = false;
        }
        field(11; Installments; Integer)
        {
            trigger OnValidate()
            var
                InterestBands: Record "Product Interest Bands";
                InterestNotexisterr: Label 'The Interest band for %1 %2 does not exist!';
            begin
                InterestBands.Reset();
                InterestBands.SetRange(Active, true);
                InterestBands.SetRange("Source Code", "Product Code");
                InterestBands.SetFilter("Min Installments", '<=%1', Installments);
                InterestBands.SetFilter("Max Installments", '>=%1', Installments);
                if InterestBands.FindFirst() then
                    "Interest Rate" := InterestBands."Interest Rate"
                else
                    Error(InterestNotexisterr, "Product Description", Installments);
            end;
        }
        field(12; "Application Date"; Date)
        {
            Editable = false;
        }
        field(13; "Repayment Start Date"; Date)
        {
            Editable = false;
        }
        field(14; "Repayment End Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            var
                LoansManagement: codeunit "Loans Management";
            begin
                "Repayment Start Date" := LoansManagement.GetRepaymentChannelStartDate(Rec);
                if "Repayment Start Date" <> 0D then
                    "Repayment End Date" := CalcDate(Format(Installments) + 'M', "Repayment Start Date");
            end;
        }
        field(15; "Payment Date"; Date)
        {
        }
        field(16; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(17; "Charges Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Charges".Amount where("No." = field("No.")));
            Editable = false;
        }
        field(18; "Mode of Disbursement"; Enum "Mode of Disbursement")
        {
            InitValue = 0;
        }
        field(19; "Disbursement Account"; Code[20])
        {
            TableRelation = if ("Mode of Disbursement" = filter("FOSA (Full)" | "FOSA (Partial)")) Vendor where("Member No." = field("Member No."), "Account Type" = const("Sacco"), "Product Posting Type" = const("Withdrawable Deposit"))
            else if ("Mode of Disbursement" = const(BOSA)) "G/L Account" where(Blocked = const(false), "Account Type" = const(Posting), "Account Category" = const(Liabilities));
        }
        field(20; "First Disbursement"; Decimal)
        {
            trigger OnValidate()
            begin
                TestField("Approved Amount");
                CalcFields("Total Recoveries", "Charges Amount");
                if "First Disbursement" > "Approved Amount" then Error('You cannot disburse %1 which is the Approved Amount', "Approved Amount");
                If ("Total Recoveries" + "Charges Amount") > "First Disbursement" then Error('You cannot Disburse Less than %1', ("Total Recoveries" + "Charges Amount"));
            end;
        }
        field(21; "Fully Disbursed"; Boolean)
        {
            Editable = false;
        }
        field(22; "Posting Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            var
                EndDate: Date;
            begin
                Validate("Repayment End Date");
            end;
        }
        field(23; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(24; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(25; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(27; "Created On"; Date)
        {
            Editable = false;
        }
        field(26; "Reviewed By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(28; "Reviewed On"; Date)
        {
            Editable = false;
        }
        field(29; Posted; Boolean)
        {
            Editable = false;
        }
        field(30; "Principal Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Principal Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(31; "Interest Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Interest Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(32; "Total Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Monthly Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(33; "Loan Account"; code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        field(34; "Billing Account"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        field(35; "Posted On"; DateTime)
        {
            Editable = false;
        }
        field(36; "Accrued Interest"; decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Interest Accrual".Amount where("Loan No." = field("No."), "Entry Type" = const("Interest Accrual")));
        }
        field(37; "Sales Representative"; code[20])
        {
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                SalesPerson: Record "Salesperson/Purchaser";
            begin
                if SalesPerson.Get("Sales Representative") then "Sales Representative Name" := SalesPerson.Name;
            end;
        }
        field(38; "Sales Representative Name"; Text[150])
        {
            Editable = false;
        }
        field(39; Disbursements; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Loan Disbursal"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(40; "Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
        }
        field(41; "Principal Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid")));
        }
        field(42; "Principal Balance - At Date"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid")));
        }
        field(43; "Interest Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Interest Due" | "Interest Paid")));
        }
        field(44; "Penalty Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Penalty Paid" | "Penalty Due")));
        }
        field(45; "Rate Type"; Option)
        {
            OptionMembers = "Per-Annum","Per Month","Fixed";
            Editable = false;
        }
        field(46; "Loan Classification"; Option)
        {
            OptionMembers = Performing,Watch,Substandard,Doubtfull,Loss;
            Editable = false;
        }
        field(47; "Defaulted Days"; Integer)
        {
            Editable = false;
        }
        field(48; "Principal Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Principal Paid")));
        }
        field(49; "Interest Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Interest Paid")));
        }
        field(50; "Penalty Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Penalty Paid")));
        }
        field(51; Closed; Boolean)
        {
            Editable = false;
        }
        field(52; "Total Interest Due"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Interest Due")));
        }
        field(53; "Total Penalty Due"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Penalty Due")));
        }
        field(54; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(55; "Cheque No."; code[30])
        {
        }
        field(56; "Freeze Penalty"; Boolean)
        {
        }
        field(57; Disbursed; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Detailed Vendor Ledg. Entry" where("Document No." = field("No."), "Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Loan Disbursal")));
        }
        field(58; "Monthly Installment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = max("Loan Schedule"."Monthly Repayment" where("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(59; "Application Status"; Option)
        {
            Editable = false;
            OptionMembers = Application,Appraisal,Disbursed,Rejected,Reversed;
        }
        field(60; "Share Capital"; Decimal)
        {
            Editable = false;
        }
        field(61; Deposits; Decimal)
        {
            Editable = false;
        }
        field(62; "Total Loans"; Decimal)
        {
            Editable = false;
        }
        field(63; "Sector Code"; Code[20])
        {
            TableRelation = "Economic Sectors";
        }
        field(64; "Sub Sector Code"; Code[20])
        {
            TableRelation = "Economic Subsectors"."Sub Sector Code" where("Sector Code" = field("Sector Code"));
        }
        field(65; "Sub-Susector Code"; Code[20])
        {
            TableRelation = "Economic Sub-subsector"."Sub-Subsector Code" where("Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code"));
        }
        field(66; Witness; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                LoansManagement.CheckOkToWitness(Witness, "No.");
            end;
        }
        field(67; "Loan Batch No."; Code[20])
        {
        }
        field(68; "Prorated Days"; Integer)
        {
        }
        field(69; "Prorated Interest"; Decimal)
        {
        }
        field(70; "Insurance Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            var
                LoanProduct: Record "Sacco Products";
            begin
                if LoanProduct.Get("Product Code") then begin
                    if "Approved Amount" = 0 then begin
                        if "Loan Amount" > LoanProduct."Insurance Factor" then
                            "Insurance Amount" := ("Loan Amount" - LoanProduct."Insurance Factor") * LoanProduct."Insurance Rate" * 0.01
                        else
                            "Insurance Amount" := 0;
                    end
                    else begin
                        if "Approved Amount" > LoanProduct."Insurance Factor" then
                            "Insurance Amount" := ("Approved Amount" - LoanProduct."Insurance Factor") * LoanProduct."Insurance Rate" * 0.01
                        else
                            "Insurance Amount" := 0;
                    end;
                end
                ELSE
                    "Insurance Amount" := 0;
            end;
        }
        field(71; "Recovery Mode"; Enum "Recovery Modes")
        {
        }
        field(72; "New Monthly Installment"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                // if xRec."New Monthly Installment" < LoansManagement.PopulateMinimumContribution("No.") then
                //     "New Monthly Installment" := LoansManagement.PopulateMinimumContribution("No.");
            end;
        }
        field(73; "Pay to Bank Code"; Code[20])
        {
            TableRelation = "External Banks";
        }
        field(74; "Pay to Branch Code"; Code[20])
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code" = field("Pay to Bank Code"));
        }
        field(75; "Pay to Account No"; Code[50])
        {
        }
        field(76; "Pay to Account Name"; Text[100])
        {
        }
        field(77; "Appraisal Commited"; Boolean)
        {
            Editable = false;
        }
        field(78; "Net Change-Principal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid"), "Posting Date" = field("Date Filter"), "Loan No." = field("No.")));
            Editable = false;
        }
        field(79; "Total Arrears"; Decimal)
        {
            Editable = false;
        }
        field(80; "Principal Arrears"; Decimal)
        {
            Editable = false;
        }
        field(81; "Interest Arrears"; Decimal)
        {
            Editable = false;
        }
        field(82; "Defaulted Installments"; Integer)
        {
            Editable = false;
        }
        field(83; "Portal Status"; Option)
        {
            OptionMembers = New,Submitted,Processing;
        }
        field(84; "Source Type"; Enum "Loan Source Types")
        {
        }
        field(85; "Rejection Remarks"; Text[250])
        {
        }
        field(86; "Total Securities"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Securities".Guarantee where("Loan No" = field("No.")));
            Editable = false;
        }
        field(87; "Total Guarantees"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Loan No" = field("No.")));
        }
        field(88; "Self Guarantee"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Loan No" = field("No."), "Member No." = field("Member No.")));
        }
        field(89; "Monthly Principal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = max("Loan Schedule"."Principal Repayment" where("Loan No." = field("No."), "Expected Date" = Field("Date Filter")));
            Editable = false;
        }
        field(90; Restructured; Boolean)
        {
        }
        field(91; "Rescheduled Installment"; Decimal)
        {
        }
        field(92; "Maximum Repayment Period"; Integer)
        {
            Editable = false;
        }
        field(93; "Last Interest Charge"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" WHERE("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Interest Due"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(94; "Total Recoveries"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recoveries".Amount where("Loan No" = field("No.")));
            Editable = false;
        }
        field(95; "Submitted On"; DateTime)
        {
        }
        field(96; "Loan Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(97; "Loan Created On"; DateTime)
        {
            Editable = false;
        }
        field(98; "Recoveries Commissions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recoveries"."Commission Amount" where("Loan No" = field("No.")));
            Editable = false;
        }
        field(99; "Qualified Salarywise"; Decimal)
        {
            Editable = false;
        }
        field(100; "Last Pay Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" where("Loan No." = field("No."), "Vendor No." = field("Loan Account"), "Sacco Transaction Type" = filter("Interest Paid" | "Principal Paid")));
            Editable = false;
        }
        field(101; "Staff No"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Payroll No." where("No." = field("Member No.")));
            Editable = false;
        }
        field(102; "Employer Code"; Code[20])
        {
            TableRelation = Employers;
            FieldClass = FlowField;
            CalcFormula = lookup(members."Employer Code" where("No." = field("Member No.")));
            Editable = false;
        }
        field(103; "Mobile Loan Net"; Decimal)
        {
            Editable = false;
        }
        field(104; "Payment Refrence Code"; Code[20])
        {
            Editable = false;
        }
        field(105; "Monthly Interest"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = max("Loan Schedule"."Interest Repayment" where("Loan No." = field("No."), "Expected Date" = Field("Date Filter")));
            Editable = false;
        }
        field(106; "Mobile Loan"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Sacco Products"."Mobile Loan" where(Code = field("Product Code")));
        }
        field(107; Earnings; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Income)));
        }
        field(108; Deductions; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Deduction)));
        }
        field(109; "Net Income"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No.")));
        }
        field(110; "Salary Based"; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Product Code", "Member No.", "Member Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Member No.", "Member Name", "Product Code", "Product Description")
        {
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        Members: Record Members;
        SaccoProducts: Record "Sacco Products";
        LoanCharges: Record "Product Charge Setup";
        LoansManagement: Codeunit "Loans Management";

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("Loan Nos.");
        if "No." = '' then begin
            "No." := NoSeries.GetNextNo(SaccoSetup."Online Loan Nos.", Today, true);
        end;
        "Application Date" := WorkDate;
        "Posting Date" := WorkDate;
        "Created By" := UserId;
        "Created On" := WorkDate;
        if CurrentClientType = CurrentClientType::SOAP then begin
            "Source Type" := "Source Type"::Channels;
            "Sales Representative" := 'PORTAL';
            "Sales Representative Name" := 'PORTAL';
        end;
    end;
}
