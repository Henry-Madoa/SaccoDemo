table 52203455 "Request for Payment Lines"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Creditor No."; Code[20])
        {
            trigger OnLookup()
            begin
                if "Source Document" = "Source Document"::"Purchase Order" then begin
                    Supplier.Reset;
                    if PAGE.RunModal(PAGE::"Vendor List", Supplier) = ACTION::LookupOK then begin
                        Validate("Creditor No.", Supplier."No.");
                    end;
                end
                else if "Source Document" = "Source Document"::"Travel Order" then begin
                        Staff.Reset;
                        Staff.SetFilter("Customer Posting Group", '%1|%2', 'TRAVEL', 'CREDIT');
                        if PAGE.RunModal(PAGE::"Customer List", Staff) = ACTION::LookupOK then begin
                            Validate("Creditor No.", Staff."No.");
                        end;
                    end
                    else if "Source Document" = "Source Document"::"Supplier Invoice" then begin
                            Supplier.Reset;
                            if PAGE.RunModal(PAGE::"Vendor List", Supplier) = ACTION::LookupOK then begin
                                Validate("Creditor No.", Supplier."No.");
                            end;
                        end;
            end;
            trigger OnValidate()
            begin
                if("Source Document" = "Source Document"::"Purchase Order") or ("Source Document" = "Source Document"::"Supplier Invoice")then begin
                    if Supplier.Get("Creditor No.")then "Name of Creditor":=Supplier.Name
                    else
                        Error('The creditor No. %1 does not exist in the Vendors list. Create it.', "Creditor No.");
                end
                else if "Source Document" = "Source Document"::"Travel Order" then begin
                        if Staff.Get("Creditor No.")then "Name of Creditor":=Staff.Name
                        else
                            Error('The Staff No. %1 does not exist in the Staff Customer list. Create it.', "Creditor No.");
                    end;
            end;
        }
        field(4; "Name of Creditor"; Text[50])
        {
        }
        field(5; "Invoice No."; Code[35])
        {
        }
        field(6; "Source Document No."; Code[20])
        {
            trigger OnLookup()
            begin
                if "Source Document" = "Source Document"::"Purchase Order" then begin
                    LPO.Reset;
                    LPO.SetRange(Status, LPO.Status::Released);
                    if PAGE.RunModal(PAGE::"Purchase Order List", LPO) = ACTION::LookupOK then begin
                        Validate("Source Document No.", LPO."No.");
                    end;
                end
                else if "Source Document" = "Source Document"::"Travel Order" then begin
                        ITO.Reset;
                        ITO.SetRange("Request Type", ITO."Request Type"::Imprest);
                        ITO.SetRange(Status, ITO.Status::Approved);
                        if PAGE.RunModal(PAGE::"Imprest Requests", ITO) = ACTION::LookupOK then begin
                            Validate("Source Document No.", ITO."No.");
                        end;
                    end
                    else if "Source Document" = "Source Document"::"Supplier Invoice" then begin
                            Invoice.Reset;
                            if "Creditor No." <> '' then Invoice.SetRange("Buy-from Vendor No.", "Creditor No.");
                            if PAGE.RunModal(PAGE::"Posted Purchase Invoices", Invoice) = ACTION::LookupOK then begin
                                Validate("Source Document No.", Invoice."No.");
                                Validate("Creditor No.", Invoice."Buy-from Vendor No.");
                                "Invoice No.":=Invoice."Vendor Invoice No.";
                            end;
                        end end;
            trigger OnValidate()
            begin
                if "Source Document" = "Source Document"::"Purchase Order" then begin
                    // LPO.RESET;
                    if LPO.Get(LPO."Document Type"::Order, "Source Document No.")then begin
                        LPO.CalcFields("Amt. Rcd. Not Invoiced (LCY)");
                        Amount:=LPO."Amt. Rcd. Not Invoiced (LCY)";
                        "Global Dimension 1 Code":=LPO."Shortcut Dimension 1 Code";
                        "Global Dimension 2 Code":=LPO."Shortcut Dimension 2 Code";
                        "Being Payment for":=LPO."Posting Description";
                        "Currency Code":=LPO."Currency Code";
                    end;
                end
                else if "Source Document" = "Source Document"::"Travel Order" then begin
                        //ITO.RESET;
                        if ITO.Get("Source Document No.")then begin
                            ITO.CalcFields("Request Amount");
                            Amount:=ITO."Request Amount";
                            "Global Dimension 1 Code":=ITO."Global Dimension 1 Code";
                            "Global Dimension 2 Code":=ITO."Global Dimension 2 Code";
                            "Being Payment for":=ITO.Justification;
                        end;
                    end
                    else if "Source Document" = "Source Document"::"Supplier Invoice" then begin
                            if Invoice.Get("Source Document No.")then begin
                                Invoice.CalcFields("Amount Including VAT");
                                Amount:=Invoice."Amount Including VAT";
                                "Global Dimension 1 Code":=Invoice."Shortcut Dimension 1 Code";
                                "Global Dimension 2 Code":=Invoice."Shortcut Dimension 2 Code";
                                "Currency Code":=Invoice."Currency Code";
                                "Being Payment for":=Invoice."Posting Description";
                            end;
                        end;
            end;
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Department';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(9; "Global Dimension 2 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(10; "Global Dimension 3 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(11; "Being Payment for"; Text[250])
        {
            Caption = 'Naration';
        }
        field(12; "Source Document"; Option)
        {
            OptionCaption = 'Purchase Order,Travel Order,Supplier Invoice';
            OptionMembers = "Purchase Order", "Travel Order", "Supplier Invoice";
        }
        field(13; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(14; "Purchase Invoice Amount"; Decimal)
        {
            Editable = false;
        }
        field(15; "Outstanding Amount"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Line No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." <> '' then begin
            if Header.Get("No.")then begin
                "Source Document":=Header."Source Document";
                Validate("Creditor No.", Header."Creditor No.");
            end;
        end;
    end;
    var AdvancedFinanceSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    Supplier: Record Vendor;
    LPO: Record "Purchase Header";
    ITO: Record "Request Header";
    Staff: Record Customer;
    Invoice: Record "Purch. Inv. Header";
    Header: Record "Request for Payment";
    procedure ViewSourceDocument()
    begin
        if "Source Document" = "Source Document"::"Purchase Order" then begin
            LPO.Reset;
            LPO.SetRange("No.", "Source Document No.");
            PAGE.Run(PAGE::"Purchase Order", LPO);
        end
        else if "Source Document" = "Source Document"::"Travel Order" then begin
                ITO.Reset;
                ITO.SetRange("No.", "Source Document No.");
                PAGE.Run(PAGE::"Imprest Requests", ITO);
            end
            else if "Source Document" = "Source Document"::"Supplier Invoice" then begin
                    Invoice.Reset;
                    Invoice.SetRange("No.", "Source Document No.");
                    PAGE.RunModal(PAGE::"Posted Purchase Invoice", Invoice);
                end;
    end;
}
