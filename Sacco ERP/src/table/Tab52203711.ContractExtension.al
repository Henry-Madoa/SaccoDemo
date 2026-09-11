table 52203711 "Contract Extension"
{
    DrillDownPageID = "Contract Extension List";
    LookupPageID = "Contract Extension List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Contract No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Contract Header"."No." WHERE("Contract Status"=CONST(Signed));

            trigger OnValidate()
            begin
                if xRec."Contract No." <> Rec."Contract No." then begin
                    ContractExtensionMilestone.Reset;
                    ContractExtensionMilestone.SetRange("Extension No", Rec."No.");
                    if ContractExtensionMilestone.FindSet then ContractExtensionMilestone.DeleteAll;
                end;
                if ContractHeader.Get("Contract No.")then begin
                    "Contract Title":=ContractHeader."Tender Title";
                    "Initial Period":=ContractHeader."Contract period";
                    "Initial End Date":=ContractHeader."Contract End Date";
                    ContractMilestone.Reset;
                    ContractMilestone.SetRange("Order Created", false);
                    ContractMilestone.SetRange("Contract No", "Contract No.");
                    if ContractMilestone.FindSet then begin
                        repeat ContractExtensionMilestone.Init;
                            ContractExtensionMilestone.TransferFields(ContractMilestone);
                            ContractExtensionMilestone."Extension No":=Rec."No.";
                            ContractExtensionMilestone.Insert;
                        until ContractMilestone.Next = 0;
                    end;
                end;
            end;
        }
        field(3; "Contract Title"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then "Employee Name":=Employee.FullName;
            end;
        }
        field(7; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Initial End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Initial Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Extension Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Extension Period") <> '' then "New End Date":=CalcDate("Extension Period", "Initial End Date")
                else
                    "New End Date":=0D;
            end;
        }
        field(12; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "New End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(15; "Extension No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchPayablesSetup.Get;
            PurchPayablesSetup.TestField("Contract Extension Nos");
            NoSeriesManagement.InitSeries(PurchPayablesSetup."Contract Extension Nos", "No. Series", 0D, "No.", "No. Series");
        end;
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Employee No.");
            Validate("Employee No", UserSetup."Employee No.");
        end;
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    var PurchPayablesSetup: Record "Purchases & Payables Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    ContractHeader: Record "Contract Header";
    ContractMilestone: Record "Contract Milestone";
    UserSetup: Record "User Setup";
    ContractExtensionMilestone: Record "Contract Extension Milestone";
    Employee: Record Employee;
}
