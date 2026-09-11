tableextension 52204001 "General Ledger Setup CBS" extends "General Ledger Setup"
{
    fields
    {
        field(5220400; "Product Application Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220401; "Product Editing Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220402; "Member Application Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220403; "Member Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220404; "Loan Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220405; "Loan Disbursement Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220406; "Collateral Release Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220407; "Member Charging Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220408; "Receipt Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220409; "FD Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220410; "Collateral Application Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220411; "Loan Repayment Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220412; "Maintenance Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220413; "Member Editing Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220414; "JV Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220415; "Calculator Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220416; "Cheque Deposit Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220417; "Standing Order Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220418; "FOSA Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220419; "Teller Transaction Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220420; "Salary Processing Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220421; "Checkoff Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220422; "Guarantor Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220423; "ATM Application Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220424; "Member Refund Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220425; "Member Exit Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220426; "BOSA Dividend Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220427; "FOSA Dividend Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220428; "Member Reactivation Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220429; "Cash Deposit Charges"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(5220430; "PesaLink Settlememt Account"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(5220431; "PesaLink Charges"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(5220432; "Cash Withdrawal Charges"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(5220433; "Inter Acc Transfer Charges"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(5220434; "Loan Repayment Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(5220435; "Balance Inquiry Charge"; Code[20])
        {
            TableRelation = "Channel Transaction Setup";
        }
        field(5220436; "Mini Statement Charge"; Code[20])
        {
            TableRelation = "Channel Transaction Setup";
        }
        field(5220437; "Full Statement Charge"; Code[20])
        {
            TableRelation = "Channel Transaction Setup";
        }
        field(5220438; "Interest Accrual Type"; Option)
        {
            Editable = false;
            OptionMembers = "Accrual Basis","Cash Basis";
        }
        field(5220439; "Loan Batch Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220440; "Defaulter Notice Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220441; "Loan Recovery Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220442; "Loan Restructure Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220443; "Cheque Book App. Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220444; "Cheque Clearance Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220445; "Inter Acc. Trans. Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220446; "Share Capital Trans. Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220447; "Acc. Opening Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220448; "Guarantor Notice Charge"; Decimal)
        {
        }
        field(5220449; "Guarantor Notice Inc. Acc."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220450; "Bulk SMS Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220451; "Checkoff Variation Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220452; "Channel Application Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220453; "Online Loan Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220454; "Minimum Deposit Cont."; Decimal)
        {
        }
        field(5220455; "Block SMS"; Boolean)
        {
        }
        field(5220456; "Guarantor Multiplier"; Decimal)
        {
        }
        field(5220457; "Self Guarantor Multiplier"; Decimal)
        {
        }
        field(5220458; "Defaulter Loan Product"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), "Product Posting Type" = const("Loan Account"));
        }
        field(5220459; "Payment Refrence Mandatory"; Boolean)
        {
        }
        field(5220460; "SMS Url"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(5220461; "EDMS Url"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(5220462; "IPRS Url"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(5220463; "IPRS Phone No."; Text[20])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(5220464; "Device Id"; Text[250])
        {
        }
        field(5220465; "Inter Acc. Transfer Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(5220466; "Inter Acc. Transfer Batch"; Code[10])
        {
        }
        field(5220467; "Member Acc. Activation Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(5220468; "Member Acc. Deativation Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(5220469; "Channel Transactins Nos."; Integer)
        {
            Description = 'Number of transactions entries to show on the channels';
        }
        field(5220470; "Money Laundary Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220471; "Money Laundary Limit"; Decimal)
        {
        }
        field(5220472; "Passport Size"; Decimal)
        {
        }
        field(5220473; "Identification Card Size"; Decimal)
        {
        }
        field(5220474; "Signature Size"; Decimal)
        {
        }
        field(5220475; "Share Trading Dimension Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Dimension;
        }
        field(5220476; "Share Trading Dimension No."; Integer)
        {
        }
        field(5220477; "Custodial Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220478; "Share Trading Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220479; "Share Bid Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220480; "Minimum Member Age (Yrs)"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5220481; "Country Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(5220482; "Dormancy Period"; DateFormula)
        {
        }
        field(5220483; "Withdrawal Period"; DateFormula)
        {
        }
        field(5220484; "Loan Repayment Start"; Option)
        {
            OptionMembers = "Begining of the Month","End of Month";
        }
        field(5220485; "ICT Admin Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5220486; "ICT Department Email"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(5220487; "Credit Department Email"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(5220488; "Marketing Department Email"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(5220489; "Opening Balance Acc."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(5220490; "Opening Balance Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5220491; "Lien Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5220492; "Benevolent Fund Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5220493; "NOK Amount"; Decimal)
        {
        }
        field(5220494; "Principal Member Amount"; Decimal)
        {
        }
        field(5220495; "Share Capital Grace Period"; DateFormula)
        {
        }
        field(5220496; "Validate Cash Denomination"; Boolean)
        {
        }
        field(5220497; "Sector Code"; Code[20])
        {
            TableRelation = "Economic Sectors";
        }
        field(5220498; "Sub Sector Code"; Code[20])
        {
            TableRelation = "Economic Subsectors"."Sub Sector Code" where("Sector Code" = field("Sector Code"));
        }
        field(5220499; "Sub-Subsector Code"; Code[20])
        {
            TableRelation = "Economic Sub-subsector"."Sub-Subsector Code" where("Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code"));
        }
        field(5220500; "Next Run Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5220501; "Mobile Withdrawal Alert Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5220502; "Mobile Loan Alert Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5220503; "Min. Interest Earning Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5220504; "Max No. Of Open Loans"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5220505; "Daily Interest Accrual"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
