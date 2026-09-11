report 52203444 "Email LPO"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                if "Purchase Header"."Buy-from Vendor No." = '' then Error('Vendor has not been selected.');
                if Supplier.Get("Purchase Header"."Buy-from Vendor No.")then Supplier.TestField("E-Mail");
                ProcurementManagement.GenerateLPOEmail("Purchase Header");
                Message('Email Sent.');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
            //Comment by Ibrahim 
            /*field(MonthBeginDate; MonthBeginDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Month Begin Date';
                    }*/
            }
        }
    }
    var MonthBeginDate: Date;
    ProcurementManagement: Codeunit "Procurement Management";
    Supplier: Record Vendor;
}
