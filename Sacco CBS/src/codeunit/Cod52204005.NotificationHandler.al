codeunit 52204005 "Notification Handler"
{
    // procedure OpenApprovalDocument(Notification: Notification)
    // var
    //     SalesHeader: Record "Sales Header";
    //     DocNo: Code[20];
    //     SalesOrderPage: Page "Sales Order";
    // begin
    //     DocNo := Notification.GetData('DocNo');
    //     if SalesHeader.Get("Document Type"::Order, DocNo) then begin
    //         PAGE.Run(PAGE::"Sales Order", SalesHeader);
    //     end else
    //         Message('Sales Order %1 not found.', DocNo);
    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnSendNotification', '', true, true)]
    // local procedure OnSendNotification(WorkflowStepInstance: Record "Workflow Step Instance")
    // var
    //     NotificationEntry: Record "Notification Entry";
    // begin
    //     NotificationEntry.Init();
    //     NotificationEntry."User ID" := WorkflowStepInstance."Recipient User ID";
    //     NotificationEntry."Notification Type" := NotificationEntry."Notification Type"::Information;
    //     NotificationEntry."Notification Text" := StrSubstNo('Approval required for %1', WorkflowStepInstance."Record Caption");
    //     NotificationEntry.Insert();
    // end;
    procedure OpenCustomerCard(MyNotification: Notification)
    var
        CustNo: Code[20];
        Customer: Record Customer;
    begin
        CustNo := MyNotification.GetData('CustNo');
        if Customer.Get(CustNo) then Page.Run(Page::"Customer Card", Customer);
    end;

    var
        myInt: Integer;
}
