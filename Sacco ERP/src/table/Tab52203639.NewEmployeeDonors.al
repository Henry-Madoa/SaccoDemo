table 52203639 "New Employee Donors"
{
    Caption = 'New Employee Grants';
    DrillDownPageID = "Employee Donors";
    LookupPageID = "Employee Donors";

    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Donor Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Donor List"."Donor Code" WHERE(Status=CONST(Active));

            trigger OnValidate()
            begin
                if Donors.Get("Donor Code")then begin
                    "Donor Name":=Donors."Donor Name";
                    //  "Grant Start Date":=Donors."Grant Start Date";
                    //  "Grant End Date":=Donors."Grant End Date";
                    "Grant Activity":=Donors."Grant Activity";
                    "Grant Type":=Donors."Grant Type";
                end;
                // END ELSE BEGIN
                //  "Donor Name":='';
                //  "Grant Start Date":=0D;
                //  "Grant End Date":=0D;
                //  end;            ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", Rec."Change No");
                ContractChangeLines.SetRange("Line No", "Contract Line No");
                if ContractChangeLines.FindFirst then begin
                    "Grant Start Date":=ContractChangeLines."Contract Start Date";
                    "Grant End Date":=ContractChangeLines."Contract End Date";
                end;
            end;
        }
        field(3; "Donor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Contract Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Contract Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Grant Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Grant Start Date" = 0D then exit; //  Donors.RESET;
                //  Donors.SETRANGE("Donor Code",Rec."Donor Code");
                //  IF Donors.FINDFIRST THEN
                //   BEGIN
                //     IF "Grant Start Date"<Donors."Grant Start Date" THEN
                //       ERROR('Grant start date cannot be less than %1',Donors."Grant Start Date");
                //   end;
                ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", Rec."Change No");
                ContractChangeLines.SetRange("Line No", "Contract Line No");
                if ContractChangeLines.FindFirst then begin
                    if ContractChangeLines."Contract Start Date" < "Grant Start Date" then Error('Grant start date cannot be less than %1', ContractChangeLines."Contract Start Date");
                    if ContractChangeLines."Contract End Date" < "Grant Start Date" then Error('Grant start date cannot be higher than %1', ContractChangeLines."Contract End Date");
                    if("Grant Start Date" >= ContractChangeLines."Contract Start Date") and ("Grant Start Date" < ContractChangeLines."Contract End Date")then "Grant Status":="Grant Status"::Active
                    else
                        "Grant Status":="Grant Status"::Inactive;
                end;
            end;
        }
        field(8; "Grant End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Grant End Date" = 0D then exit;
                Rec.Testfield("Grant Start Date");
                if "Grant Start Date" > "Grant End Date" then ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", Rec."Change No");
                ContractChangeLines.SetRange("Line No", "Contract Line No");
                ContractChangeLines.SetRange(Status, ContractChangeLines.Status::New);
                if ContractChangeLines.FindFirst then begin
                    if ContractChangeLines."Contract End Date" < "Grant End Date" then Error('Grant end date cannot be less than %1', ContractChangeLines."Contract End Date");
                end; // Donors.RESET;
            // Donors.SETRANGE("Donor Code",Rec."Donor Code");
            // IF Donors.FINDFIRST THEN
            //  BEGIN
            //    IF "Grant End Date">Donors."Grant End Date" THEN
            //      ERROR('Grant end date cannot be higher than %1',Donors."Grant End Date");
            //  end;
            end;
        }
        field(9; "Grant Activity"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Grant Activities";
        }
        field(10; "Grant Type"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Grant Types";
        }
        field(11; "Grant Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Active,Expired,Inactive';
            OptionMembers = " ", Active, Expired, Inactive;
        }
        field(70000; "Change No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Donor Code", "Contract Line No", "Contract Code", "Change No", "Line No")
        {
        }
    }
    var Donors: Record "Donor List";
    ContractChangeLines: Record "Contract Change Lines";
}
