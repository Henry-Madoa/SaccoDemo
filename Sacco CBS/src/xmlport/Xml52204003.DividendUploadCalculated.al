xmlport 52204003 "Dividend Upload Calculated"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Dividend Det. Entries";
            "Dividend Det. Entries")
            {
                AutoReplace = true;
                XmlName = 'UploadEntries';

                fieldattribute(A;
                "Dividend Det. Entries"."Member No.")
                {
                }
                fieldattribute(B;
                "Dividend Det. Entries"."Entry Type")
                {
                }
                fieldattribute(C;
                "Dividend Det. Entries".Code)
                {
                }
                fieldattribute(D;
                "Dividend Det. Entries".Description)
                {
                }
                fieldattribute(M;
                "Dividend Det. Entries"."Account Type")
                {
                }
                fieldattribute(E;
                "Dividend Det. Entries".Amount)
                {
                }
                fieldattribute(H;
                "Dividend Det. Entries"."Month Code")
                {
                }
                fieldattribute(I;
                "Dividend Det. Entries"."Month No.")
                {
                }
                fieldattribute(N;
                "Dividend Det. Entries"."Entry No")
                {
                }
                fieldattribute(O;
                "Dividend Det. Entries"."Destination Account")
                {
                }
                trigger OnBeforeInsertRecord();
                begin
                    "Dividend Det. Entries"."Dividend Code" := DividendCode;
                    "Dividend Det. Entries"."Pre Calculated" := true;
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
        }
        actions
        {
        }
    }
    trigger OnPostXmlPort();
    begin
        MESSAGE('Uploaded Successfully');
    end;

    var
        DividendCode: Code[20];
        Vendor: Record Vendor;

    procedure SetDivCode(DDCode: Code[50]);
    begin
        DividendCode := DDCode;
    end;
}
