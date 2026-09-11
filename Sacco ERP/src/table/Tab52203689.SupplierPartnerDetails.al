table 52203689 "Supplier Partner Details"
{
    fields
    {
        field(1; "Vendor No"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Application"."No.";

            trigger OnValidate()
            begin
                Vendor.Get("Vendor No");
            //Vendor.Status:=TRUE;
            //Vendor.MODIFY;
            end;
        }
        field(2; "Partner ID No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Partner Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Patrner Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; City; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
        }
        field(6; "Partner Occupation"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; PIN; Code[11])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Employee.Reset;
                Employee.SetRange(Status, Employee.Status::Active);
                Employee.SetRange("KRA Number", PIN);
                if Employee.FindFirst then Error('The PIN %1 has a Employee Named %2 in KCAA', PIN, Employee."Last Name");
            end;
        }
        field(8; "Mobile No.(+254)"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Female,Male';
            OptionMembers = " ", Female, Male;
        }
        field(10; Shares; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Nationality; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(12; "Passport No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Category; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Category"."Category Code";
        }
        field(14; "Created By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Created Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Modified By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Modified Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Modified Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Vendor No", "Partner ID No")
        {
        }
    }
    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        "Created By":=UserId;
        "Created Date":=WorkDate;
        "Created Time":=Time;
    end;
    trigger OnModify()
    begin
        "Modified By":=UserId;
        "Modified Date":=WorkDate;
        "Modified Time":=Time;
    end;
    var Vendor: Record "Supplier Application";
    Employee: Record Employee;
}
