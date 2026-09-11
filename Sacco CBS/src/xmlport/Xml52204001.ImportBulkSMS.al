xmlport 52204001 "Import BulkSMS"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
        textelement(BulkSMS)
        {
            tableelement("BulkSMSLines";
            "Bulk SMS Lines")
            {
                fieldattribute(MemberName;
                BulkSMSLines."Full Name")
                {
                }
                fieldattribute(PhoneNo;
                BulkSMSLines."Phone No")
                {
                }
                trigger OnBeforeInsertRecord()
                begin
                    BulkSMSLines."No." := DocumentNo;
                end;
            }
        }
    }
    procedure SetBulkSMSNo(CheckNo: code[20])
    var
    begin
        DocumentNo := CheckNo;
    end;

    var
        DocumentNo: Code[20];
}
