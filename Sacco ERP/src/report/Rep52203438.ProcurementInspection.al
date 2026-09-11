report 52203438 "Procurement Inspection"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Procurement Inspection.rdl';

    dataset
    {
        dataitem("Inspection Header"; "Procurement Inspection")
        {
            column(Logo; CompInfo.Picture)
            {
            }
            column(Watermark;'')
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(CompAddress; CompInfo.Address)
            {
            }
            column(CompAddress2; CompInfo."Address 2")
            {
            }
            column(CompCity; CompInfo.City)
            {
            }
            column(CompPhone; CompInfo."Phone No.")
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(Currency; Currency)
            {
            }
            column(No; "Inspection Header"."No.")
            {
            }
            column(LPONo; "Inspection Header"."LPO No")
            {
            }
            column(PreparedBy; PreparedBy)
            {
            }
            column(ReviewedBy; "Inspection Header"."Reviewed By")
            {
            }
            column(SupplierNo; "Inspection Header"."Supplier No.")
            {
            }
            column(SupplierName; "Inspection Header"."Supplier Name")
            {
            }
            column(Date; "Inspection Header".Date)
            {
            }
            column(RFQNo; "Inspection Header"."RFQ No.")
            {
            }
            column(RFQDate; "Inspection Header"."RFQ Date")
            {
            }
            column(LPODate; "Inspection Header"."LPO Date")
            {
            }
            column(TotalValue; "Inspection Header"."Total Value")
            {
            }
            column(InvoiceNo; "Inspection Header"."Invoice No.")
            {
            }
            column(DNoteNo; "Inspection Header"."D Note No.")
            {
            }
            column(CompletionDate; "Inspection Header"."Completion/Delivery Date")
            {
            }
            column(FirstApprover; "1stapprover")
            {
            }
            column(SecondApprover; "2ndapprover")
            {
            }
            column(ThirdApprover; "3rdapprover")
            {
            }
            column(FourthApprover; "4thapprover")
            {
            }
            column(FirstApproverDate; "1stapproverdate")
            {
            }
            column(SecondApproverDate; "2ndapproverdate")
            {
            }
            column(ThirdApproverDate; "3rdapproverdate")
            {
            }
            column(FourthApproverDate; "4thapproverdate")
            {
            }
            column(FirstApproverSignature; UserRecApp1.Signature)
            {
            }
            column(SecondApproverSignature; UserRecApp2.Signature)
            {
            }
            column(ThirdApproverSignature; UserRecApp3.Signature)
            {
            }
            column(FourthApproverSignature; UserRecApp4.Signature)
            {
            }
            dataitem("Inspection Lines"; "Inspection Lines")
            {
                DataItemLink = "No."=FIELD("No.");

                column(Description; "Inspection Lines".Description)
                {
                }
                column(Qty; "Inspection Lines".Quantity)
                {
                }
                column(UOM; "Inspection Lines".UoM)
                {
                }
                column(UnitCost; "Inspection Lines"."Unit Cost")
                {
                }
                column(TotalCost; "Inspection Lines"."Total Cost")
                {
                }
            }
            trigger OnAfterGetRecord();
            begin
                UserRec.RESET;
                UserRec.SETRANGE("User Name", "Inspection Header"."Created By");
                IF UserRec.FINDFIRST THEN PreparedBy:=UserRec."Full Name";
                if PurchOrder.Get(PurchOrder."Document Type"::Order, "LPO No")then begin
                    if PurchOrder."Currency Code" <> '' then Currency:=PurchOrder."Currency Code"
                    else
                        Currency:=GenLedgerSetup."LCY Code";
                end;
                //Approvers
                ApprovalEntries.RESET;
                ApprovalEntries.SETRANGE(ApprovalEntries."Table ID", Database::"Procurement Inspection");
                ApprovalEntries.SETRANGE(ApprovalEntries."Document No.", "Inspection Header"."No.");
                ApprovalEntries.SETRANGE(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                IF ApprovalEntries.FIND('-')THEN BEGIN
                    i:=0;
                    REPEAT i:=i + 1;
                        IF i = 1 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Sender ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "1stapprover":=Users."Full Name";
                            end;
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "2ndapprover":=Users."Full Name";
                                "3rdapprover":=Users."Full Name";
                                "4thapprover":=Users."Full Name";
                            end;
                            "1stapproverdate":=ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp1.GET(ApprovalEntries."Sender ID")THEN UserRecApp1.CALCFIELDS(UserRecApp1.Signature);
                            IF UserRecApp2.GET(ApprovalEntries."Approver ID")THEN UserRecApp2.CALCFIELDS(UserRecApp2.Signature);
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID")THEN UserRecApp3.CALCFIELDS(UserRecApp3.Signature);
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID")THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                        IF i = 2 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "3rdapprover":=Users."Full Name";
                                "4thapprover":=Users."Full Name";
                            end;
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID")THEN UserRecApp3.CALCFIELDS(UserRecApp3.Signature);
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID")THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                        IF i = 3 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "4thapprover":=Users."Full Name";
                            end;
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID")THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                    UNTIL ApprovalEntries.NEXT = 0;
                end;
            end;
        }
    }
    trigger OnPreReport();
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        GenLedgerSetup.GET;
        GenLedgerSetup.TestField("LCY Code");
    end;
    var CompInfo: Record "Company Information";
    PurchOrder: Record "Purchase Header";
    UserRec: Record User;
    PreparedBy: Text;
    GenLedgerSetup: Record "General Ledger Setup";
    ApprovalEntries: Record "Approval Entry";
    "1stapprover": Text[100];
    "2ndapprover": Text[100];
    "3rdapprover": Text[100];
    "4thapprover": Text[100];
    i: Integer;
    "1stapproverdate": DateTime;
    "2ndapproverdate": DateTime;
    "3rdapproverdate": DateTime;
    "4thapproverdate": DateTime;
    UserRecApp1: Record "User Setup";
    UserRecApp2: Record "User Setup";
    UserRecApp3: Record "User Setup";
    UserRecApp4: Record "User Setup";
    Users: Record User;
    Currency: Code[20];
}
