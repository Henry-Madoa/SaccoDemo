report 52203600 "Email Payslips"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE(Status=CONST(Active), "E-Mail"=filter(<>''));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.Get;
                Clear(Recepients);
                Clear(Subject);
                Clear(Body);
                Recepients.Add(Employee."E-Mail");
                Subject:=StrSubstNo('%1 Payslip', Format(StartDate, 0, '<Month Text> <Year4>'));
                Body:='Dear ' + Employee.FullName;
                Body+='<br></br>';
                Body+='Please Find attached ' + Format(StartDate, 0, '<Month Text> <Year4>') + ' payslip';
                Body+='<br></br>';
                Body+='For enquiries, contact HR Department through ' + CompanyInformation."E-Mail";
                Body+='<br></br>';
                Body+='Regards,';
                Body+='<br></br>';
                Body+='HRMIS.';
                TempBlob.CreateOutStream(outStreamReport);
                TempBlob.CreateInStream(inStreamReport);
                Emp.Reset;
                Emp.SetRange("No.", Employee."No.");
                Emp.SetRange("Period Filter", StartDate);
                RecRef.GetTable(Emp);
                Report.SaveAs(Report::Payslip, Employee."No.", ReportFormat::Pdf, outStreamReport, RecRef);
                CommunicationsMgmt.SendEmailWithAttachement(Recepients, Subject, Body, Subject, AttachmentType::PDF, inStreamReport);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    ApplicationArea = All;
                    Editable = not StartDateEditable;
                    TableRelation = "Payroll Periods" where(Closed=const(true));
                }
            }
        }
    }
    var StartDate: Date;
    RecRef: RecordRef;
    TempBlob: Codeunit "Temp Blob";
    outStreamReport: OutStream;
    inStreamReport: InStream;
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    Recepients: List of[Text];
    AttachmentType: Option PDF, Excel, Word;
    Subject: Text;
    Body: Text;
    StartDateEditable: Boolean;
    Emp: Record Employee;
    CompanyInformation: Record "Company Information";
    procedure IntiateStartDate(startDate_var: Date)
    begin
        StartDate:=startDate_var;
        StartDateEditable:=false;
    end;
}
