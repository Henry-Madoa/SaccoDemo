report 52203515 "Notify Department Staff"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                field(Department; Department)
                {
                    CaptionClass = '1,1,1';
                    Caption = 'Global Dimension 1 Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
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
                field(Calender; AppraisalCalender)
                {
                    TableRelation = "Appraisal Calender"."Calendar Code";
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if not Confirm('Are you sure you want to send email?')then exit;
        if AppraisalCalender = '' then Error('You must specify appraisal calender');
        if Department = '' then Error('You must specify Subject');
        if MailBody = '' then Error('You must specify Mail Body');
        AppraisalHeader.Reset;
        AppraisalHeader.SetRange("Global Dimension 1 Code", Department);
        if AppraisalHeader.FindSet then begin
            repeat if Employee.Get(AppraisalHeader."Employee No")then begin
                    CountNoEmployees+=1;
                    Clear(Recipients);
                    Recipients.Add(Employee."E-Mail");
                    Subject:=Subject;
                    Body:=MailBody;
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            until AppraisalHeader.Next = 0;
        end;
        if CountNoEmployees >= 1 then if CountNoEmployees = 0 then Message('No Emails were sent');
    end;
    var Department: Code[50];
    Employee: Record Employee;
    MailBody: Text;
    Subject: Text;
    AppraisalHeader: Record "Appraisal Header";
    AppraisalCalender: Code[50];
    Recipients: List of[Text];
    CountNoEmployees: Integer;
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    Body: Text;
}
