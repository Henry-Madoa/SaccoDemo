report 52203520 "Notify Employee"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                field("Employee No"; EmployeeNo)
                {
                    TableRelation = Employee."No." where("Nature Of Employment"=filter(<>Board), "Employee Status"=FILTER(Active|OnLeave));

                    trigger OnValidate()
                    begin
                        if Employee.Get(EmployeeNo)then EmailAddress:=Employee."E-Mail";
                    end;
                }
                field("Email Address"; EmailAddress)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Subject; Subject)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Body; MailBody)
                {
                    ColumnSpan = 5;
                    RowSpan = 10;
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if not Confirm('Are you sure you want to send email?')then exit;
        if EmployeeNo = '' then Error('You must specify Email Address');
        if Subject = '' then if MailBody = '' then Error('You must specify Mail Body');
        if Employee.Get(EmployeeNo)then begin
            CountNoEmployees+=1;
            Clear(Recipients);
            Recipients.Add(EmailAddress);
            Subject:=Subject;
            Body:=MailBody;
            CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
        end;
        if CountNoEmployees >= 1 then if CountNoEmployees = 0 then Message('No Emails were sent');
    end;
    var Employee: Record Employee;
    MailBody: Text;
    Subject: Text;
    Recipients: List of[Text];
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    CountNoEmployees: Integer;
    Body: Text;
    EmailAddress: Text;
    EmployeeNo: Code[50];
}
