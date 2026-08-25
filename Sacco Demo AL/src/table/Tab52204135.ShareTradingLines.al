table 52204135 "Share Trading Lines"
{
    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members."No." where(Status = const(Active));

            trigger OnValidate()
            begin
                if Members.Get("Member No.") then "Member Name" := Members."Full Name";
                "Bid Date" := CreateDateTime(Today, Time);
                if ShareFloating.Get("Document No.") then begin
                    if "Member No." = ShareFloating."Member No." then Error('You Cannot Buy Your Own Shares');
                    SaccoProducts.Reset;
                    SaccoProducts.SetRange("Product Posting Type", SaccoProducts."Product Posting Type"::"Share Trading Account");
                    if SaccoProducts.FindFirst then "Minimum Balance" := SaccoProducts."Minimum Balance";
                    "Account No" := MemberMgmt.GetMemberAccount("Member No.", ProductPostingType::"Share Trading Account");
                end;
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Bid Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Account No");
                if ShareFloating.Get("Document No.") then begin
                    CalcFields("Account Balance");
                    if "Account Balance" < "Minimum Balance" then Error('You Do not have the Minimum Balance to Bid');
                    ShareFloating.Validate("Charge Amount");
                    if "Bid Price" < ShareFloating."Minimum Acceptable Price" then Error('You Can Only Bid From %1', ShareFloating."Minimum Acceptable Price");
                    if "Bid Price" > ShareFloating."Par Value" then Error('You Can Only Bid To %1', ShareFloating."Par Value");
                    Shares := ShareFloating."Shares to Float";
                    "Total Amount" := Shares * "Bid Price";
                    "Total Amount" += ShareFloating."Charge Amount";
                    Charges := ShareFloating."Charge Amount";
                end;
            end;
        }
        field(5; "Bid Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Account Balance"; Decimal)
        {
            CalcFormula = - Sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor No." = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; Awarded; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Shares; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Bought; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(13; "Minimum Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(45; Source; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Walking,App,Ussd,Portal';
            OptionMembers = Walking,App,Ussd,Portal;
        }
        field(46; Charges; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Member No.")
        {
            Clustered = true;
        }
    }
    var
        Members: Record Members;
        ShareFloating: Record "Share Floating";
        Vendor: Record Vendor;
        SaccoProducts: Record "Sacco Products";
        MemberMgmt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";
}
