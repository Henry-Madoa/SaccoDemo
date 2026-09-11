xmlport 52204000 "Import Checkoff"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Checkoff";
            "Checkoff Upload")
            {
                fieldattribute(CheckNo;
                Checkoff."Check No")
                {
                }
                fieldattribute(Name;
                Checkoff."Uploaded Name")
                {
                }
                fieldattribute(Amount;
                Checkoff.Amount)
                {
                }
                fieldattribute(ProductCode;
                Checkoff."Product Code")
                {
                }
                trigger OnBeforeInsertRecord()
                begin
                    Checkoff."Document No" := DocumentNo;
                end;
            }
        }
    }
    procedure SetCheckoffNo(CheckNo: code[20])
    var
    begin
        DocumentNo := CheckNo;
    end;

    var
        DocumentNo: Code[20];
}
