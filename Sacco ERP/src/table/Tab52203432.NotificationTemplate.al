table 52203432 "Notification Template"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Notification Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Email,SMS';
            OptionMembers = Email, SMS;
        }
        field(3; Source; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Impending leave,Leave Application,Impending Procurement Process';
            OptionMembers = "Impending leave", "Leave Application", "Impending Procurement Process";
        }
        field(4; Subject; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Body; BLOB)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Table ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
        }
    }
    [Scope('Cloud')]
    procedure SetEmailBody(EmailBody: Text)
    var
    //TempBlob: Record TempBlob temporary;
    begin
        Clear(Body);
        if EmailBody = '' then exit;
    // TempBlob.Blob := Body;
    // TempBlob.WriteAsText(EmailBody,TEXTENCODING::UTF8);
    // Body := TempBlob.Blob;
    //Rec.Modify;
    end;
    [Scope('Cloud')]
    procedure GetEmailBody(): Text begin
        CalcFields(Body);
        exit(GetEmailDescriptionCalculated);
    end;
    [Scope('Cloud')]
    procedure GetEmailDescriptionCalculated(): Text var
        // TempBlob: Record TempBlob temporary;
        CR: Text[1];
    begin
        if not Body.HasValue then exit('');
        CR[1]:=10;
    // TempBlob.Blob := Body;
    // exit(TempBlob.ReadAsText(CR, TEXTENCODING::UTF8));
    end;
}
