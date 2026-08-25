tableextension 52204004 "Det Vendor Ledg Entry CBS Ext." extends "Detailed Vendor Ledg. Entry"
{
    fields
    {
        field(52204000; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
            Editable = false;
        }
        field(52204001; "Sacco Transaction Type"; Enum "Sacco Transaction Type")
        {
            Editable = false;
        }
        field(52204002; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
        field(52204003; "Loan No."; Code[20])
        {
            Editable = false;
        }
        field(52204004; "Transaction Time"; Time)
        {
            Editable = false;
        }
        //Fred Added 
        field(52204005; "Loan Product Code"; code[30])
        {
            FieldClass = Normal;
            //CalcFormula = lookup("Loan Application"."Product Code" where("Application No" = field("Loan No.")));
            Editable = false;
            Caption = 'Loan Product';

            trigger OnValidate()
            var
                ObjLoanApp: Record Loans;
            begin
                ObjLoanApp.reset;
                ObjLoanApp.SetRange("No.", "Loan No.");
                if ObjLoanApp.findset then begin
                    "Loan Product Name" := ObjLoanApp."Product Description";
                end;
            end;
        }
        field(52204006; "Loan Product Name"; text[250])
        {
            Editable = false;
        }
    }
}
