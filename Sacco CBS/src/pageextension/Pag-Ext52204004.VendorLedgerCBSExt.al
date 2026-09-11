pageextension 52204004 "Vendor Ledger CBS Ext." extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
            field("Member No."; Rec."Member No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Member Posting Type"; Rec."Product Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Loan No."; Rec."Loan No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Transaction Type"; Rec."Sacco Transaction Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
            action("Delete Entry")
            {
                trigger OnAction()
                var
                    BankLedger: Record "Bank Account Ledger Entry";
                    VendorLedger: Record "Vendor Ledger Entry";
                    DetLedger: Record "Detailed Vendor Ledg. Entry";
                    GLEntry: Record "G/L Entry";
                begin
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", Rec."Document No.");
                    if GLEntry.FindSet() then GLEntry.DeleteAll();
                    VendorLedger.Reset();
                    VendorLedger.SetRange("Document No.", Rec."Document No.");
                    if VendorLedger.FindSet() then VendorLedger.DeleteAll();
                    DetLedger.Reset();
                    DetLedger.SetRange("Document No.", Rec."Document No.");
                    if DetLedger.FindSet() then DetLedger.DeleteAll();
                    BankLedger.Reset();
                    BankLedger.SetRange("Document No.", Rec."Document No.");
                    if BankLedger.FindSet() then BankLedger.DeleteAll();
                end;
            }
        }
    }
}
