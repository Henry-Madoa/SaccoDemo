table 52203709 "Quotation Bidders"
{
    fields
    {
        field(1; "Reference No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vendor No."; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No." WHERE("Supplier Category"=FIELD("Vendor Category"), Blocked=CONST(" "));

            trigger OnValidate()
            begin
                if Vendor.Get("Vendor No.")then begin
                    "Vendor Name":=Vendor.Name;
                    "E-mail Address":=Vendor."E-Mail";
                    "Phone No":=Vendor."Phone No.";
                end
                else
                begin
                    "Vendor Name":='';
                    "E-mail Address":='';
                    "Phone No":='';
                end;
            end;
        }
        field(3; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "E-mail Address"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Phone No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Vendor Category"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Total Quoted Amount"; Decimal)
        {
            CalcFormula = Sum("Quotation Vendors Bids"."Quoted Amount" WHERE("Vendor No"=FIELD("Vendor No."), "Quote No"=FIELD("Reference No")));
            FieldClass = FlowField;

            trigger OnLookup()
            begin
                QuotationVendorsBids.Reset;
                QuotationVendorsBids.SetRange("Quote No", "Reference No");
                QuotationVendorsBids.SetRange("Vendor No", "Vendor No.");
                PAGE.RunModal(67037, QuotationVendorsBids);
            end;
        }
        field(8; "Email Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Requisition No."; Code[30])
        {
            CalcFormula = Lookup("Procurement Request"."Requisiton No" WHERE("No."=FIELD("Reference No")));
            FieldClass = FlowField;
        }
        field(10; "Committee Selection Count"; Integer)
        {
            CalcFormula = Count("RFQ Committee Evaluation" WHERE("RFQ No."=FIELD("Reference No"), "Vendor No."=FIELD("Vendor No."), Award=CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Delivery Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Reference No", "Vendor No.", "Vendor Category")
        {
        }
    }
    trigger OnDelete()
    begin
        QuotationBidders.Reset;
        QuotationBidders.SetRange("Reference No", "Reference No");
        QuotationBidders.SetRange("Email Sent", true);
        if QuotationBidders.FindFirst then Error('You cannot delete entries when emails have been sent to vendors');
    end;
    var Vendor: Record Vendor;
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    QuotationBidders: Record "Quotation Bidders";
}
