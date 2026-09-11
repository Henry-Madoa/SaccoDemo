table 52203544 "Status of Fund"
{
    fields
    {
        field(1; Fund; Code[20])
        {
        }
        field(2; "Fund Name"; Text[50])
        {
        }
        field(3; Project; Code[20])
        {
        }
        field(4; "Project Name"; Text[50])
        {
        }
        field(5; Department; Code[20])
        {
        }
        field(6; FY; Code[20])
        {
        }
        field(7; "Total Allotment"; Decimal)
        {
            CalcFormula = -Sum("G/L Entry".Amount WHERE("G/L Account No."=FILTER('30002'|'40001'|'40002'|'40003'|'40004'), "Global Dimension 1 Code"=FIELD(Project), "Posting Date"=FIELD("Date Filter"), "Global Dimension 2 Code"=FIELD("Site Filter")));
            FieldClass = FlowField;
        }
        field(8; "Total Commitment"; Decimal)
        {
            CalcFormula = Sum("Commitment Entries"."Committed Amount" WHERE("Commitment Date"=FIELD("Date Filter"), "Global Dimension 1"=FIELD(Project), "Global Dimension 2"=FIELD("Site Filter")));
            FieldClass = FlowField;
        }
        field(9; "Total Obligation"; Decimal)
        {
            CalcFormula = -Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Posting Date"=FIELD("Date Filter"), "Initial Entry Global Dim. 1"=FIELD(Project), "Document Type"=FILTER(Invoice|"Credit Memo"), "Initial Entry Global Dim. 2"=FIELD("Site Filter")));
            FieldClass = FlowField;
        }
        field(10; "Total Disbursement"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."Amount LCY" WHERE("Global Dimension 1 Code"=FIELD(Project), Posted=CONST(true), "Posted Date"=FIELD("Date Filter"), "Global Dimension 2 Code"=FIELD("Site Filter"), "Account Type"=FILTER(<>"Bank Account")));
            FieldClass = FlowField;
        }
        field(11; "Total Open Commitment"; Decimal)
        {
            Description = 'Sum("Purchase Line"."Line Amount" WHERE (Shortcut Dimension 1 Code=FIELD(Project), Document Type=CONST(Order), Order Date=FIELD(Date Filter), Quantity Received=CONST(0), Shortcut Dimension 2 Code=FIELD(Site Filter), PO Status=FILTER(<>New)))';
            FieldClass = Normal;
        }
        field(12; "Total ULO"; Decimal)
        {
            CalcFormula = -Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Posting Date"=FIELD("Date Filter"), "Initial Entry Global Dim. 1"=FIELD(Project), "Initial Entry Global Dim. 2"=FIELD("Site Filter")));
            FieldClass = FlowField;
        }
        field(13; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(14; "Site Filter"; Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
    }
    keys
    {
        key(Key1; Fund, Project)
        {
        }
    }
}
