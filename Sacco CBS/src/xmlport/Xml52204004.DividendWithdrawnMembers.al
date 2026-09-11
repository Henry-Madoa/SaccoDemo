xmlport 52204004 "Dividend Withdrawn Members"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Dividend Withdrawn Members";
            "Dividend Withdrawn Members")
            {
                AutoReplace = true;
                XmlName = 'UploadEntries';

                fieldattribute(A;
                "Dividend Withdrawn Members"."Member No")
                {
                }
                fieldattribute(B;
                "Dividend Withdrawn Members"."Member Name")
                {
                }
                trigger OnBeforeInsertRecord();
                begin
                    "Dividend Withdrawn Members"."Dividend Header" := DividendCode;
                    //"Dividend Det. Entries"."Pre Calculated":=TRUE;
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
