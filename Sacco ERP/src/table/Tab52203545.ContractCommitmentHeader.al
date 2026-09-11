table 52203545 "Contract Commitment Header"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Date; Date)
        {
        }
        field(3; "Created By"; Code[50])
        {
        }
        field(4; "Type of Commitment"; Option)
        {
            OptionCaption = 'Contracted Services,Salaries,,,,,,,,,,Other';
            OptionMembers = "Contracted Services", Salaries, , , , , , , , , , Other;
        }
        field(5; Commited; Boolean)
        {
        }
        field(6; "Total Amount"; Decimal)
        {
            CalcFormula = Sum("Contract Commitment Lines".Amount WHERE("No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(7; Narration; Text[30])
        {
        }
        field(8; "No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            AdvancedFinanceSetup.Get;
            AdvancedFinanceSetup.TestField("Contract Commitment Nos.");
            NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Contract Commitment Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=WorkDate;
        "Created By":=UserId;
    end;
    var AdvancedFinanceSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
}
