page 52204139 "Channel Loan Applications"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    CardPageId = "Channel Loan Application";
    SourceTable = "Channel Loan Application";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Application No"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Repayment Start Date"; Rec."Repayment Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Installments; Rec.Installments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Repayment End Date"; Rec."Repayment End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applied Amount"; Rec."Applied Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment Method"; Rec."Interest Repayment Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Paid"; Rec."Principal Paid")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Balance"; Rec."Principal Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Paid"; Rec."Interest Paid")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Balance"; Rec."Interest Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Defaulted Days"; Rec."Defaulted Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Classification"; Rec."Loan Classification")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Arrears"; Rec."Total Arrears")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Arrears"; Rec."Principal Arrears")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Arrears"; Rec."Interest Arrears")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Defaulted Installments"; Rec."Defaulted Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Change-Principal"; Rec."Net Change-Principal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sales Representative"; Rec."Sales Representative")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sales Representative Name"; Rec."Sales Representative Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Account"; Rec."Loan Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Disbursed; Rec.Disbursed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Portal Status"; Rec."Portal Status")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No.");
            }
        }
    }
    procedure SetParameters(DocumentType: option "Loan Batch"; DocumentNo: Code[20])
    var
    begin
        GlobalDocumentNo := DocumentNo;
        GlobalDocumentType := DocumentType;
    end;

    var
        GlobalDocumentNo: code[20];
        GlobalDocumentType: option "Loan Batch";
}
