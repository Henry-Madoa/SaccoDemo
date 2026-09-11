report 52203441 "Purchase Order"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/PurchaseOrder.rdl';

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            column(CompanyName; UpperCase(CompanyInformation.Name))
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(BuyfromVendorName_PurchaseHeader; PurchaseHeader."Buy-from Vendor Name")
            {
            }
            column(BuyfromVendorNo_PurchaseHeader; PurchaseHeader."Buy-from Vendor No.")
            {
            }
            column(BuyfromAddress_PurchaseHeader; PurchaseHeader."Buy-from Address")
            {
            }
            column(BuyfromAPhoneNumber_PurchaseHeader; Vendor."Phone No.")
            {
            }
            column(BuyfromAEmail_PurchaseHeader; Vendor."E-Mail")
            {
            }
            column(No_PurchaseHeader; PurchaseHeader."No.")
            {
            }
            column(OrderDate_PurchaseHeader; PurchaseHeader."Order Date")
            {
            }
            column(CurrencyCode; CurrencyCode)
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
            column(FirstApproverSignature; UserSetup[1].Signature)
            {
            }
            column(SecondApproverSignature; UserSetup[2].Signature)
            {
            }
            column(ThirdApproverSignature; UserSetup[3].Signature)
            {
            }
            column(FourthApproverSignature; UserSetup[4].Signature)
            {
            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = FIELD("No.");

                column(Type_PurchaseLine; "Purchase Line".Type)
                {
                }
                column(No_PurchaseLine; "Purchase Line"."No.")
                {
                }
                column(Description_PurchaseLine; "Purchase Line".Description)
                {
                }
                column(UnitofMeasure_PurchaseLine; "Purchase Line"."Unit of Measure")
                {
                }
                column(Quantity_PurchaseLine; "Purchase Line".Quantity)
                {
                }
                column(ShortcutDimension1Code_PurchaseLine; "Purchase Line"."Shortcut Dimension 1 Code")
                {
                }
                column(ShortcutDimension2Code_PurchaseLine; "Purchase Line"."Shortcut Dimension 2 Code")
                {
                }
                column(LineAmount_PurchaseLine; "Purchase Line"."Line Amount")
                {
                }
                column(UnitCost_PurchaseLine; "Purchase Line"."Unit Cost")
                {
                }
                column(LineDiscountAmount_PurchaseLine; "Purchase Line"."Line Discount Amount")
                {
                }
                column(VatableAmount_PurchaseLine; "Purchase Line"."VAT Amount")
                {
                }
                column(AmountInclVAT_PurchaseLine; "Purchase Line"."Amount Including VAT")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
                if PurchaseHeader."Currency Code" <> '' then
                    CurrencyCode := PurchaseHeader."Currency Code"
                else begin
                    GeneralLegderSetup.Get;
                    CurrencyCode := GeneralLegderSetup."LCY Code";
                end;
                //Approvers
                ApprovalEntries.RESET;
                ApprovalEntries.SetCurrentKey("Sequence No.", "Date-Time Sent for Approval");
                ApprovalEntries.SETRANGE(ApprovalEntries."Table ID", Database::"Purchase Header");
                ApprovalEntries.SETRANGE(ApprovalEntries."Document No.", PurchaseHeader."No.");
                //ApprovalEntries.SETRANGE(Comment, false);
                ApprovalEntries.SETRANGE(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                IF ApprovalEntries.FindSet THEN BEGIN
                    i := 0;
                    REPEAT
                        i := i + 1;
                        IF i = 1 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Sender ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "1stapprover" := Users."Full Name";
                            end;
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "2ndapprover" := Users."Full Name";
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "1stapproverdate" := ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[1].GET(ApprovalEntries."Sender ID") THEN UserSetup[1].CALCFIELDS(UserSetup[1].Signature);
                            IF UserSetup[2].GET(ApprovalEntries."Approver ID") THEN UserSetup[2].CALCFIELDS(UserSetup[2].Signature);
                            IF UserSetup[3].GET(ApprovalEntries."Approver ID") THEN UserSetup[3].CALCFIELDS(UserSetup[3].Signature);
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                        IF i = 2 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[3].GET(ApprovalEntries."Approver ID") THEN UserSetup[3].CALCFIELDS(UserSetup[3].Signature);
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                        IF i = 3 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "4thapprover" := Users."Full Name";
                            end;
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                    UNTIL ApprovalEntries.NEXT = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
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
        UserSetup: array[4] of Record "User Setup";
        Users: Record User;
        CurrencyCode: Code[10];
        GeneralLegderSetup: Record "General Ledger Setup";
}
