pageextension 52203433 "Sales Quote" extends "Sales Quote"
{
    actions
    {
        modify(Email)
        {
            Visible = false;
        }
        // Add changes to page actions here
        addafter(Email)
        {
            action("&Email")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send by &Email';
                Image = Email;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Prepare to mail the document. The Send Email window opens prefilled with the customer''s email address so you can add or edit information.';

                trigger OnAction()
                var
                    Recordr: RecordRef;
                begin
                    CompanyInfo.Get;
                    Clear(Recepient);
                    Recepient.Add(Rec."Sell-to E-Mail");
                    Body := '';
                    Body := 'Hi Dennis,';
                    Body += '<span style="font-family: Baskerville; color: black; FONT-SIZE: 11pt;">';
                    Body += '<span style="font-family: Baskerville; color: black;FONT-SIZE: 11pt;">';
                    Body += '<br><br>';
                    Body += 'This where the body message shoud be...  ';
                    Body += '<br/><br/>';
                    Body += 'Kindly find the attached supporting document for more details.';
                    Body += '<br/><br/>';
                    Body += 'Regards,';
                    Body += '<br/><br/></span>';
                    Body += 'Sales Department';
                    Body += '<br/>' + CompanyInfo.Name + '<br/></span>';
                    Mail.Create(Recepient, 'Sales Order No. ' + Rec."No.", Body, true);
                    SalesHeader.Get(Rec."Document Type", Rec."No.");
                    Recordr.GetTable(SalesHeader);
                    //Generate blob from report
                    TempBlob.CreateOutStream(outStreamReport);
                    TempBlob.CreateInStream(inStreamReport);
                    Report.SaveAs(Report::"Standard Sales - Quote", Rec."No.", ReportFormat::Pdf, outStreamReport, Recordr);
                    Mail.AddAttachment('Quote_' + Rec."No." + '.pdf', 'PDF', inStreamReport);
                    Email.OpenInEditorModally(Mail);
                end;
            }
        }
    }
    var
        CompanyInfo: Record "Company Information";
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recepient: List of [Text];
        SalesHeader: Record "Sales Header";
}
