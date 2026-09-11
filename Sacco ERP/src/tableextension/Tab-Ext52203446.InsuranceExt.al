tableextension 52203446 "Insurance Ext" extends Insurance
{
    fields
    {
        field(50000; "Insurance Tenure"; Integer)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.Testfield("Effective Date");
                if "Insurance Tenure" <> 0 then "Expiration Date":=CalcDate(StrSubstNo('<%1M-1D>', "Insurance Tenure"), "Effective Date")
                else
                    "Expiration Date":=0D;
            end;
        }
    }
    trigger OnInsert()
    begin
    end;
}
