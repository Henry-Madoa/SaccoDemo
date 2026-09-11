page 52204224 "Deposits Lookup"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Vendor Ledger Entry";
    SourceTableView = WHERE("Sacco Transaction Type" = CONST(General));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Type"; Rec."Sacco Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Vendor.Name)
                {
                    Caption = 'Account Name';
                    Editable = false;
                }
                field(Positive; Rec.Positive)
                {
                    Editable = false;
                }
                field("Member No"; Rec."Member No.")
                {
                    Editable = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Vendor.GET(Rec."Vendor No.");
    end;

    trigger OnOpenPage()
    begin
        /*Rec.FILTERGROUP(2);
            Rec.SETRANGE("Transaction Type","Transaction Type"::Booking);
            Rec.SETRANGE(Open,TRUE);
                Rec.FILTERGROUP(0);
                */
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ShareFloatingLines: Record "Share Trading Lines";
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            VendorLedgerEntry.RESET;
            CurrPage.SETSELECTIONFILTER(VendorLedgerEntry);
            if VendorLedgerEntry.FINDLAST then begin
                VendorLedgerEntry.CALCFIELDS("Remaining Amount", Amount, "Original Amount");
                Vendor.GET(VendorLedgerEntry."Vendor No.");
                //if ((Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital") or (Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Registration Fee")) = false then begin
                // if DestinationType = DestinationType::"Project Sale" then begin
                //     ProjectPreSales.RESET;
                //     ProjectPreSales.SETRANGE("Transaction  No.", TransactionNumber);
                //     if not ProjectPreSales.FINDFIRST then begin
                //         ProjectPreSales.INIT;
                //         ProjectPreSales."Transaction  No." := TransactionNumber;
                //         ProjectPreSales."Allocation Type" := ProjectPreSales."Allocation Type"::Booking;
                //         //ProjectPreSales.VALIDATE("Refrence No.",VendorLedgerEntry."Document No.");
                //         ProjectPreSales.INSERT;
                //       end;
                //end else begin
                ShareTransferReceipt.RESET;
                ShareTransferReceipt.SETRANGE("Refrence No.", VendorLedgerEntry."Document No.");
                ShareTransferReceipt.SETRANGE("Document No.", TransactionNumber);
                if ShareTransferReceipt.FINDFIRST then ShareTransferReceipt.DELETEALL;
                ShareTransferReceipt.INIT;
                ShareTransferReceipt."Document No." := TransactionNumber;
                ShareTransferReceipt."Refrence No." := VendorLedgerEntry."Document No.";
                ShareTransferReceipt.Description := VendorLedgerEntry.Description;
                ShareTransferReceipt."Original Amount" := VendorLedgerEntry."Original Amount";
                ShareTransferReceipt."Remaining Amount" := ABS(VendorLedgerEntry."Remaining Amount");
                ShareTransferReceipt."Account No." := VendorLedgerEntry."Vendor No.";
                if ShareFloatingLines.Get(TransactionNumber, VendorLedgerEntry."Member No.") then begin
                    if ShareTransferReceipt."Remaining Amount" > ShareFloatingLines."Total Amount" then ShareTransferReceipt.Validate("Allocated Amount", ShareFloatingLines."Total Amount");
                end;
                ShareTransferReceipt.INSERT;
            end;
        end;
    end;

    var
        TransactionNumber: Code[20];
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        //ProjectPreSales: Record "Project Pre-Sales";
        DestinationType: Option "Project Sale","Share Trading";
        ShareTransferReceipt: Record "Share Transfer Receipt";
        Vendor: Record Vendor;

    [Scope('Cloud')]
    procedure SetParameters(TransactionCode: Code[20]; SourceType: Option "Project Sale","Share Trading")
    begin
        TransactionNumber := TransactionCode;
        DestinationType := SourceType;
    end;
}
