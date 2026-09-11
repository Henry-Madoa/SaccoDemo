table 52204014 Loans
{
    DataClassification = ToBeClassified;
    DataCaptionFields = "No.", "Member Name", "Product Description", "Approved Amount", Status;
    LookupPageId = Loans;
    DrillDownPageId = Loans;

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
                    "Member Category" := Members.Category;
                end;
                LoansManagement.PopulateAppraisalParameters(Rec);
                "Share Capital" := LoansManagement.GetMemberShares("Member No.");
                Deposits := LoansManagement.GetMemberDeposits("Member No.");
                "Total Loans" := LoansManagement.GetMemberLoans("Member No.");
                if "Product Code" <> '' then Validate("Product Code");
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
                    if ((Category <> Category::DEBT) and (Category <> Category::HR)) then
                        SaccoProducts.TestField("Interest Repayment Method");
                    Rec.TestField("Member No.");
                    Member.Get(Rec."Member No.");
                    MemberDeposits := LoansManagement.GetMemberDeposits(Member."No.");

                    if SaccoProducts."Appraise with 0 Deposits" = false then begin
                        if MemberDeposits <= 0 then
                            Error('You Cannot Appraise %1 With %2 Deposits', SaccoProducts.Description, MemberDeposits);
                    end;

                    if SaccoProducts."Salary Based" then
                        "Qualified Salarywise" := LoansManagement.AppraiseFosaSalary(Member."No.", "Product Code", "No.");
                    if MemberDeposits < SaccoProducts."Minimum Deposit Balance" then
                        Error('You Cannot Appraise %1 With %2 Deposits', SaccoProducts.Description, MemberDeposits);

                    "Product Description" := SaccoProducts.Description;
                    "Interest Rate" := SaccoProducts."Interest Rate";
                    "Interest Repayment Method" := SaccoProducts."Interest Repayment Method";
                    "Rate Type" := SaccoProducts."Rate Type";
                    Installments := SaccoProducts."Ordinary Default Intallments";
                    "Mode of Disbursement" := SaccoProducts."Mode of Disbursement";

                    if "Mode of Disbursement" in ["Mode of Disbursement"::"FOSA (Full)", "Mode of Disbursement"::"FOSA (Partial)"] then
                        "Disbursement Account" := LoansManagement.GetFOSAAccount(Rec."Member No.")
                    else
                        "Disbursement Account" := SaccoProducts."Disbursement Account";

                    "Interest Repayment Method" := SaccoProducts."Interest Repayment Method";
                    "Salary Based" := SaccoProducts."Salary Based";
                    "Dividend Based" := SaccoProducts."Dividend Based";
                    "Mobile Loan" := SaccoProducts."Mobile Loan";
                    Validate("Loan Multiplier", SaccoProducts."Loan Multiplier");
                    If SaccoProducts."Dividend Based" then
                        "Recovery Mode" := "Recovery Mode"::Dividend;

                    if (SaccoProducts."Mobile Loan" and (not SaccoProducts."Dividend Based")) then begin
                        if Member.Salaried then
                            "Recovery Mode" := "Recovery Mode"::Salary
                        else
                            "Recovery Mode" := "Recovery Mode"::Mpesa;
                    end;
                    If SaccoProducts."Mobile Loan" or SaccoProducts."Dividend Based" then
                        Category := Category::FOSA;

                    Validate(Installments);
                    "Maximum Repayment Period" := SaccoProducts."Maximum Installments";

                    LoansManagement.PopulateAppraisalParameters(Rec);

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
        field(6; "Requested Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                if Category in [Category::HR, Category::DEBT] then begin
                    "Loan Amount" := "Requested Amount";
                    "Approved Amount" := "Requested Amount";
                end;
            end;
        }
        field(7; "Loan Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                LoansManagement.ValidateAppraisal(Rec);
                Validate("Insurance Amount");
            end;
        }
        field(8; "Approved Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                LoansManagement.ValidateAppraisal(Rec);
                Validate("Insurance Amount");
            end;
        }
        field(9; "Interest Rate"; Decimal)
        {
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
                if ((Category <> Category::DEBT) and (Category <> Category::HR)) then begin
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
                "Repayment Start Date" := LoansManagement.GetRepaymentStartDate(Rec);
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
        field(17; "Loan Multiplier"; Decimal)
        {
            trigger OnValidate()
            begin
                if SaccoProducts.Get("Product Code") then begin
                    If SaccoProducts."Maximum Loan Multiplier" <> 0 then begin
                        if "Loan Multiplier" > SaccoProducts."Maximum Loan Multiplier" then
                            Error(StrSubstNo('Loan Multiplier cannot exceed %1', SaccoProducts."Maximum Loan Multiplier"));
                    end else
                        "Loan Multiplier" := SaccoProducts."Loan Multiplier";

                    if "Loan Multiplier" < SaccoProducts."Loan Multiplier" then
                        "Loan Multiplier" := SaccoProducts."Loan Multiplier";
                end;
            end;
        }
        field(18; "Charges Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Charges".Amount where("No." = field("No.")));
            Editable = false;
        }
        field(19; "Mode of Disbursement"; Enum "Mode of Disbursement")
        {
            InitValue = 0;
        }
        field(20; "Disbursement Account"; Code[20])
        {
            TableRelation = if ("Mode of Disbursement" = filter("FOSA (Full)" | "FOSA (Partial)")) Vendor where("Member No." = field("Member No."), "Account Type" = const("Sacco"), "Product Posting Type" = const("Withdrawable Deposit"))
            else if ("Mode of Disbursement" = const(BOSA)) "G/L Account" where(Blocked = const(false), "Account Type" = const(Posting), "Account Category" = Filter(Liabilities))
            else if ("Mode of Disbursement" = const("Receivable Account")) Customer where(Blocked = const(" "))
            else if ("Mode of Disbursement" = const("Debt Collector")) Vendor where(Blocked = const(" "), "Account Type" = const(Supplier));
        }
        field(21; "First Disbursement"; Decimal)
        {
            trigger OnValidate()
            begin
                TestField("Approved Amount");
                CalcFields("Total Recoveries", "Charges Amount");
                if "First Disbursement" > "Approved Amount" then Error('You cannot disburse %1 which is the Approved Amount', "Approved Amount");
                If ("Total Recoveries" + "Charges Amount") > "First Disbursement" then Error('You cannot Disburse Less than %1', ("Total Recoveries" + "Charges Amount"));
            end;
        }
        field(22; "Fully Disbursed"; Boolean)
        {
            Editable = false;
        }
        field(23; "Posting Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            var
                EndDate: Date;
            begin
                Validate("Repayment End Date");
            end;
        }
        field(24; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(25; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(26; Category; Option)
        {
            OptionMembers = " ",BOSA,FOSA,HR,DEBT;
            trigger OnValidate()
            begin
                Validate("Requested Amount");
            end;
        }
        field(27; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(28; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(29; Posted; Boolean)
        {
            Editable = false;
        }
        field(30; "Posted On"; DateTime)
        {
            Editable = false;
        }
        field(31; "Loan Account"; code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        field(32; "Interest Suspended"; Boolean)
        {
            Editable = false;
        }
        field(33; "Moratorium Start Date"; Date)
        {
            Editable = false;
        }
        field(34; "Moratorium End Date"; Date)
        {
            Editable = false;
        }
        field(35; "Debt Collector Type"; Option)
        {
            OptionMembers = " ",Internal_Collector,External_Collector;
        }
        field(36; "Debt Collector"; Code[20])
        {
            TableRelation = if ("Debt Collector Type" = const(Internal_Collector)) Employee where(Status = const(Active))
            else if ("Debt Collector Type" = const(External_Collector)) Vendor where("Account Type" = const(Supplier), Blocked = const(" "));
            trigger OnValidate()
            var
                Vendor: Record Vendor;
                Employee: Record Employee;
            begin
                if Vendor.Get("Debt Collector") then
                    "Debt Collector Name" := Vendor.Name;

                if Employee.Get("Debt Collector") then
                    "Debt Collector Name" := Employee.FullName;
            end;
        }
        field(37; "Debt Collector Name"; Text[80])
        {
            Editable = false;
        }
        field(38; "Loan Type"; Option)
        {
            OptionMembers = " ","New Loan","Restructued Loan";
        }
        field(39; "Sales Representative"; code[20])
        {
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                SalesPerson: Record "Salesperson/Purchaser";
            begin
                if SalesPerson.Get("Sales Representative") then "Sales Representative Name" := SalesPerson.Name;
            end;
        }
        field(40; "Sales Representative Name"; Text[150])
        {
            Editable = false;
        }
        field(41; "Principal Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Principal Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(42; "Interest Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Interest Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(43; "Total Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Monthly Repayment" WHERE("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(44; Disbursements; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Loan Disbursal"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(45; "Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
        }
        field(46; "Principal Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid")));
        }
        field(47; "Principal Balance - At Date"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid")));
        }
        field(48; "Interest Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Interest Due" | "Interest Paid")));
        }
        field(49; "Penalty Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Penalty Paid" | "Penalty Due")));
        }
        field(50; "Rate Type"; Option)
        {
            OptionMembers = "Per-Annum","Per Month","Fixed";
            Editable = false;
        }
        field(51; "Loan Classification"; Option)
        {
            OptionMembers = Performing,Watch,Substandard,Doubtfull,Loss;
            Editable = false;
        }
        field(52; "Defaulted Days"; Integer)
        {
            Editable = false;
        }
        field(53; "Principal Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Principal Paid")));
        }
        field(54; "Interest Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Interest Paid")));
        }
        field(55; "Penalty Paid"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = CONST("Penalty Paid")));
        }
        field(56; Closed; Boolean)
        {
            Editable = false;
        }
        field(57; "Total Interest Due"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Interest Due")));
        }
        field(58; "Total Penalty Due"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Posting Date" = field("Date Filter"), "Vendor No." = field("Loan Account"), "Loan No." = field("No."), "Sacco Transaction Type" = filter("Penalty Due")));
        }
        field(59; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(60; "Cheque No."; code[30])
        {
        }
        field(61; "Freeze Penalty"; Boolean)
        {
        }
        field(62; Disbursed; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Detailed Vendor Ledg. Entry" where("Document No." = field("No."), "Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Loan Disbursal")));
        }
        field(63; "Monthly Installment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = max("Loan Schedule"."Monthly Repayment" where("Loan No." = field("No."), "Expected Date" = field("Date Filter")));
        }
        field(64; "Application Status"; Option)
        {
            Editable = false;
            OptionMembers = Application,Appraisal,Disbursed,Rejected,Reversed;
        }
        field(65; "Share Capital"; Decimal)
        {
            Editable = false;
        }
        field(66; Deposits; Decimal)
        {
            Editable = false;
        }
        field(67; "Total Loans"; Decimal)
        {
            Editable = false;
        }
        field(68; "Sector Code"; Code[20])
        {
            TableRelation = "Economic Sectors";
        }
        field(69; "Sector Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Economic Sectors"."Sector Name" where("Sector Code" = field("Sector Code")));
        }
        field(70; "Sub Sector Code"; Code[20])
        {
            TableRelation = "Economic Subsectors"."Sub Sector Code" where("Sector Code" = field("Sector Code"));
        }
        field(71; "Sub Sector Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Economic Subsectors"."Sub Sector Name" where("Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code")));
        }
        field(72; "Sub-Subsector Code"; Code[20])
        {
            TableRelation = "Economic Sub-subsector"."Sub-Subsector Code" where("Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code"));
        }
        field(73; "Sub-SubSector Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Economic Sub-subsector"."Sub-Subsector Description" where("Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code"), "Sub-Subsector Code" = field("Sub-Subsector Code")));
        }
        field(74; Witness; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                LoansManagement.CheckOkToWitness(Witness, "No.");
            end;
        }
        field(75; "Loan Batch No."; Code[20])
        {
        }
        field(76; "Prorated Days"; Integer)
        {
        }
        field(77; "Prorated Interest"; Decimal)
        {
        }
        field(78; "Insurance Amount"; Decimal)
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
        field(79; "Recovery Mode"; Enum "Recovery Modes")
        {
        }
        field(80; "New Monthly Installment"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                // if xRec."New Monthly Installment" < LoansManagement.PopulateMinimumContribution("No.") then
                //     "New Monthly Installment" := LoansManagement.PopulateMinimumContribution("No.");
            end;
        }
        field(81; "Pay to Bank Code"; Code[20])
        {
            TableRelation = "External Banks";
        }
        field(82; "Pay to Branch Code"; Code[20])
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code" = field("Pay to Bank Code"));
        }
        field(83; "Pay to Account No"; Code[50])
        {
        }
        field(84; "Pay to Account Name"; Text[100])
        {
        }
        field(85; "Appraisal Commited"; Boolean)
        {
            Editable = false;
        }
        field(86; "Net Change-Principal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = filter("Loan Disbursal" | "Principal Paid"), "Posting Date" = field("Date Filter"), "Loan No." = field("No.")));
            Editable = false;
        }
        field(87; "Total Arrears"; Decimal)
        {
            Editable = false;
        }
        field(88; "Principal Arrears"; Decimal)
        {
            Editable = false;
        }
        field(89; "Interest Arrears"; Decimal)
        {
            Editable = false;
        }
        field(90; "Defaulted Installments"; Integer)
        {
            Editable = false;
        }
        field(91; "Portal Status"; Option)
        {
            OptionMembers = New,Submitted,Processing;
        }
        field(92; "Source Type"; Enum "Loan Source Types")
        {
        }
        field(93; "Rejection Remarks"; Text[250])
        {
        }
        field(94; "Total Securities"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Securities".Guarantee where("Loan No" = field("No.")));
            Editable = false;
        }
        field(95; "Total Guarantees"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Loan No" = field("No.")));
        }
        field(96; "Self Guarantee"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Loan No" = field("No."), "Member No." = field("Member No.")));
        }
        field(97; "Monthly Principal"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = max("Loan Schedule"."Principal Repayment" where("Loan No." = field("No."), "Expected Date" = Field("Date Filter")));
            Editable = false;
        }
        field(98; Restructured; Boolean)
        {
        }
        field(99; "Rescheduled Installment"; Decimal)
        {
        }
        field(100; "Maximum Repayment Period"; Integer)
        {
            Editable = false;
        }
        field(101; "Last Interest Charge"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" WHERE("Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Interest Due"), "Loan No." = field("No."), "Posting Date" = field("Date Filter")));
            Editable = false;
        }
        field(102; "Total Recoveries"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recoveries".Amount where("Loan No" = field("No.")));
            Editable = false;
        }
        field(103; "Submitted On"; DateTime)
        {
        }
        field(104; "Loan Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(105; "Loan Created On"; DateTime)
        {
            Editable = false;
        }
        field(106; "Recoveries Commissions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recoveries"."Commission Amount" where("Loan No" = field("No.")));
            Editable = false;
        }
        field(107; "Qualified Salarywise"; Decimal)
        {
            Editable = false;
        }
        field(108; "Last Pay Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" where("Loan No." = field("No."), "Vendor No." = field("Loan Account"), "Sacco Transaction Type" = filter("Interest Paid" | "Principal Paid")));
            Editable = false;
        }
        field(109; "Last Penalty Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" where("Loan No." = field("No."), "Vendor No." = field("Loan Account"), "Sacco Transaction Type" = const("Penalty Due")));
            Editable = false;
        }
        field(110; "Staff No"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Payroll No." where("No." = field("Member No.")));
            Editable = false;
        }
        field(111; "Employer Code"; Code[20])
        {
            TableRelation = Employers;
            FieldClass = FlowField;
            CalcFormula = lookup(members."Employer Code" where("No." = field("Member No.")));
            Editable = false;
        }
        field(112; "Mobile Loan Net"; Decimal)
        {
            Editable = false;
        }
        field(113; "Payment Refrence Code"; Code[20])
        {
            Editable = false;
        }
        field(114; "Monthly Interest"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = max("Loan Schedule"."Interest Repayment" where("Loan No." = field("No."), "Expected Date" = Field("Date Filter")));
            Editable = false;
        }
        field(115; "Mobile Loan"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Sacco Products"."Mobile Loan" where(Code = field("Product Code")));
        }
        field(116; Earnings; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Income)));
        }
        field(117; Deductions; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Deduction)));
        }
        field(118; "Net Income"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No.")));
        }
        field(119; "Salary Based"; Boolean)
        {
            Editable = false;
        }
        field(120; "Dividend Based"; Boolean)
        {
            Editable = false;
        }
        field(121; "Portal Application No."; Code[20])
        {
            Editable = false;
            TableRelation = "Channel Loan Application";
        }
        field(122; "Posted By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(123; "Payable Advice"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loans Payable Advice".Amount where("Loan No" = field("No.")));
            Editable = false;
        }
        field(124; "Openning Balance"; Decimal)
        {
            Editable = false;
        }
        field(125; "Openning Interest Due Balance"; Decimal)
        {
            Editable = false;
        }
        field(126; "Openning Disbursed Balance"; Decimal)
        {
            Editable = false;
        }
        field(127; "Phone No"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Mobile Phone No." where("No." = field("Member No.")));
            Editable = false;
        }
        field(128; "Member Category"; Code[20])
        {
            TableRelation = "Member Categories";
            Editable = false;
        }
        field(129; "Appraised By"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Approval Entry"."Sender ID" where("Table ID" = CONST(Database::Loans), "Document No." = FIELD("No."), "Sequence No." = const(1)));
            Editable = false;
        }
        field(130; "Appraised On"; DateTime)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Approval Entry"."Date-Time Sent for Approval" where("Table ID" = CONST(Database::Loans), "Document No." = FIELD("No."), "Sequence No." = const(1)));
            Editable = false;
        }
        field(131; "Approved By"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Approval Entry"."Approver ID" where("Table ID" = CONST(Database::Loans), "Document No." = FIELD("No."), "Sequence No." = const(1)));
            Editable = false;
        }
        field(132; "Total Withdrawable Deposits"; Decimal)
        {
            Caption = 'FOSA Account Balance';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("Member No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("Withdrawable Deposit")));
        }
        field(133; "School Fee Savings"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("Member No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("School Fee Account")));
        }
        field(134; "Bridged Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recoveries".Amount where("Loan No" = field("No."), "Recovery Type" = const(Loan)));
        }
        field(135; "Skip Aging"; Boolean)
        {
            Editable = false;
            trigger OnValidate()
            begin
                if "Skip Aging" = true then begin
                    "Loan Classification" := "Loan Classification"::Performing;
                    "Defaulted Days" := 0;
                    "Defaulted Installments" := 0;
                    "Principal Arrears" := 0;
                    "Interest Arrears" := 0;
                    "Total Arrears" := 0;
                end;
            end;
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
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        Loans: Record Loans;

    trigger OnInsert()
    begin
        SaccoSetup.Get;
        UserSetup.Get(UserId);

        Loans.Reset();
        Loans.SetRange("Created By", UserId);
        Loans.SetRange(Status, Loans.Status::Open);
        if Loans.FindSet then begin
            if (Loans.Count > SaccoSetup."Max No. Of Open Loans") and (not UserSetup."Is System Admin") then
                Error(StrSubstNo('You have already %1 Open Loans,\\ Kindly work on Open Loans before creating another Loan Card.', Loans.Count));
        end;

        SaccoSetup.TestField("Loan Nos.");
        if "No." = '' then begin
            "No." := NoSeries.GetNextNo(SaccoSetup."Loan Nos.", Today, true);
            "Application Date" := WorkDate;
        end;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        if CurrentClientType = CurrentClientType::SOAP then begin
            "Source Type" := "Source Type"::Channels;
            "Sales Representative" := 'PORTAL';
            "Sales Representative Name" := 'PORTAL';
        end;

        if Employee.Get(UserSetup."Employee No.") then begin
            "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
            "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
        end;
    end;

    trigger OnRename()
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}
