report 52203450 "Store Requisition"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Store Requisition.rdl';

    dataset
    {
        dataitem(Payments; "Requisition Header")
        {
            RequestFilterFields = "No.";

            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(Watermark; GLSetup."Watermark Portrait")
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
            column(MTDText; MTDText)
            {
            }
            column(ROKTxt; ROKTxt)
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(Date; Payments."Requisition Date")
            {
            }
            column(No; Payments."No.")
            {
            }
            column(Payee; Payments."Employee Name")
            {
            }
            column(AmountInWords; NumberText[1])
            {
            }
            column(Bank; BankName)
            {
            }
            column(ChequeNo; Payments.Description)
            {
            }
            column(PaymentTo; Payments."Employee Name")
            {
            }
            column(OnBehalfOf; Payments."Employee Name")
            {
            }
            column(PaymentNarration; Payments.Description)
            {
            }
            column(Dept; Payments."Global Dimension 1 Code")
            {
            }
            column(Branch; Payments."Global Dimension 2 Code")
            {
            }
            column(LocationCode; Payments."Location Code")
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
            column(FirstApproverSignature; UserRecApp1."Signature Card")
            {
            }
            column(SecondApproverSignature; UserRecApp2."Signature Card")
            {
            }
            column(ThirdApproverSignature; UserRecApp3."Signature Card")
            {
            }
            column(FourthApproverSignature; UserRecApp4."Signature Card")
            {
            }
            column(Counter; Counter)
            {
            }
            dataitem("Requisition Lines"; "Requisition Lines")
            {
                DataItemLink = "Requisition No"=FIELD("No.");

                column(Description; "Requisition Lines".Description)
                {
                }
                column(Quantity; "Requisition Lines".Quantity)
                {
                }
                column(UoM; "Requisition Lines"."Unit of Measure")
                {
                }
                column(UnitCost; "Requisition Lines"."Unit Price")
                {
                }
                column(QuantityIssue; "Requisition Lines"."Quantity To Issue")
                {
                }
                column(QuantityApp; "Requisition Lines"."Quantity Approved")
                {
                }
                column(QtyStore; "Requisition Lines"."Quantity in Store")
                {
                }
                column(GrossAmount; "Requisition Lines".Amount)
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                Counter:=Counter + 1;
                GLsetup.Get;
                if Payments."Currency Code" <> '' then CurrencyCodeText:=Payments."Currency Code"
                else
                    CurrencyCodeText:=GLsetup."LCY Code";
                Payments.CalcFields(Amount);
                AmountToWords.FormatNoText(NumberText, Amount, CurrencyCodeText); //Approvers
                ApprovalEntries.Reset;
                ApprovalEntries.SetRange(ApprovalEntries."Table ID", 50200);
                ApprovalEntries.SetRange(ApprovalEntries."Document No.", Payments."No.");
                ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                if ApprovalEntries.Find('-')then begin
                    i:=0;
                    repeat i:=i + 1;
                        if i = 1 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Sender ID");
                            if Users.FindFirst then begin
                                "1stapprover":=Users."Full Name";
                            end;
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "2ndapprover":=Users."Full Name";
                            //"3rdapprover" := Users."Full Name";
                            //"4thapprover" := Users."Full Name";
                            end;
                            "1stapproverdate":=ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            // "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            //"4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp1.Get(ApprovalEntries."Sender ID")then UserRecApp1.CalcFields(UserRecApp1."Signature Card");
                            if UserRecApp2.Get(ApprovalEntries."Approver ID")then UserRecApp2.CalcFields(UserRecApp2."Signature Card");
                        /*if UserRecApp3.Get(ApprovalEntries."Approver ID") then
                                        UserRecApp3.CalcFields(UserRecApp3.Signature);
                                    if UserRecApp4.Get(ApprovalEntries."Approver ID") then
                                        UserRecApp4.CalcFields(UserRecApp4.Signature);*/
                        end;
                        if i = 2 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "3rdapprover":=Users."Full Name";
                            //"4thapprover" := Users."Full Name";
                            end;
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            //"4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp3.Get(ApprovalEntries."Approver ID")then UserRecApp3.CalcFields(UserRecApp3."Signature Card");
                        /*if UserRecApp4.Get(ApprovalEntries."Approver ID") then
                                        UserRecApp4.CalcFields(UserRecApp4.Signature);*/
                        end;
                        if i = 3 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "4thapprover":=Users."Full Name";
                            end;
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp4.Get(ApprovalEntries."Approver ID")then UserRecApp4.CalcFields(UserRecApp4."Signature Card");
                        end;
                    until ApprovalEntries.Next = 0;
                end;
            end;
            trigger OnPreDataItem()
            begin
                Counter:=0;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(CompInfo.Picture);
        CompInfo.CalcFields(Picture2);
        GLSetup.Get;
    //AdvancedFinanceSetup.CALCFIELDS("Watermark Portrait");
    end;
    var CompInfo: Record "Company Information";
    AmountToWords: Codeunit "Amount To Words";
    BankName: Text[100];
    OnesText: array[20]of Text[30];
    TensText: array[10]of Text[30];
    ExponentText: array[5]of Text[30];
    GLsetup: Record "General Ledger Setup";
    NumberText: array[2]of Text[80];
    CurrencyCodeText: Code[10];
    Counter: Integer;
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
    ROKTxt: label 'REPUBLIC OF KENYA';
    MTDText: label 'MECHANICAL AND TRANSPORT DIVISION';
}
