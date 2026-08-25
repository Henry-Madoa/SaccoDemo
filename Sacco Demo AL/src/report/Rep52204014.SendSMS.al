report 52204014 "Send SMS"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = True;

    dataset
    {
        dataitem(Members; Members)
        {
            trigger OnAfterGetRecord()
            begin
                if Message = '' then
                    Error('Please Fill In the SMS Message');
                PhoneNo := "Mobile Phone No.";
                NotificationsMgt.SendSms(PhoneNo, Message, "No.");
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("SMS Message")
                {
                    field(Message; Message)
                    {
                        MultiLine = true;
                        ShowMandatory = true;
                    }
                }
            }
        }
    }
    var
        Message: Text[1000];
        PhoneNo: Text[250];
        NotificationsMgt: Codeunit "Notifications Management";
}
