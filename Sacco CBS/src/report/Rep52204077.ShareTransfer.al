report 52204077 "Share Transfer"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/ShareTransfer.rdlc';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            DataItemTableView = WHERE("Source Code" = FILTER('INTERACC' | 'STRADE'), Positive = CONST(true));

            column(MemberNo_VendorLedgerEntry; "Vendor Ledger Entry"."Member No.")
            {
            }
            column(EntryNo_VendorLedgerEntry; "Vendor Ledger Entry"."Entry No.")
            {
            }
            column(VendorNo_VendorLedgerEntry; "Vendor Ledger Entry"."Vendor No.")
            {
            }
            column(PostingDate_VendorLedgerEntry; "Vendor Ledger Entry"."Posting Date")
            {
            }
            column(DocumentNo_VendorLedgerEntry; "Vendor Ledger Entry"."Document No.")
            {
            }
            column(Description_VendorLedgerEntry; "Vendor Ledger Entry".Description)
            {
            }
            column(Amount_VendorLedgerEntry; "Vendor Ledger Entry".Amount)
            {
            }
            column(TransferToMemberNo; MemberInfo2[1])
            {
            }
            column(TransferTo; MemberInfo2[2])
            {
            }
            column(TransferToIDNo; MemberInfo2[3])
            {
            }
            column(TransferFromName; MemberInfo2[4])
            {
            }
            column(TransferFromIDNo; MemberInfo2[5])
            {
            }
            column(Charges; Charges)
            {
            }
            column(Logo; CompanyInformation.Picture)
            {
            }
            column(City; CompanyInformation.City)
            {
            }
            column(Address2; CompanyInformation."Address 2")
            {
            }
            column(Address; CompanyInformation.Address)
            {
            }
            column(Name; CompanyInformation.Name)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CLEAR(MemberInfo2);
                if Members.GET("Vendor Ledger Entry"."Member No.") then begin
                    MemberInfo2[4] := Members."Full Name";
                    MemberInfo2[5] := Members."Identification No.";
                end;
                VendorLedgerEntry.RESET;
                VendorLedgerEntry.SETRANGE("Document No.", "Vendor Ledger Entry"."Document No.");
                VendorLedgerEntry.SETRANGE(Positive, false);
                if VendorLedgerEntry.FINDSET then begin
                    MemberInfo2[1] := VendorLedgerEntry."Member No.";
                    if Members.GET(VendorLedgerEntry."Member No.") then begin
                        MemberInfo2[2] := Members."Full Name";
                        MemberInfo2[3] := Members."Identification No.";
                    end;
                end;
                Charges := 0;
                GLEntry.RESET;
                GLEntry.SETRANGE("System-Created Entry", false);
                GLEntry.SETRANGE("Document No.", "Vendor Ledger Entry"."Document No.");
                GLEntry.SETFILTER(Amount, '<0');
                GLEntry.SETRANGE(Reversed, false);
                if GLEntry.FINDSET then begin
                    GLEntry.CALCSUMS(Amount);
                    Charges := GLEntry.Amount;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var
        Members: Record Members;
        MemberInfo: Text;
        MemberInfo2: array[10] of Text;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GLEntry: Record "G/L Entry";
        Charges: Decimal;
        CompanyInformation: Record "Company Information";
}
