table 52203528 "Commitment Register"
{
    DrillDownPageID = "Commitment Register";
    LookupPageID = "Commitment Register";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Commitment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Budget Line"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(6; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Department';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
            //ValidateShortcutDimCode(1,"Global Dimension 1 Code");         
            /*PurchaseReqDet.RESET;
                     PurchaseReqDet.SETRANGE(PurchaseReqDet."Requistion No.", "Requisition No.");

                     IF PurchaseReqDet.FIND('-') THEN BEGIN
                         REPEAT
                             PurchaseReqDet."Global Dimension 1 Code" := "Global Dimension 1 Code";
                             PurchaseReqDet.MODIFY;
                         UNTIL PurchaseReqDet.NEXT = 0;
                     end;

                     PurchaseReqDet.VALIDATE(PurchaseReqDet."No."); */
            end;
        }
        field(7; "Commitment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", LPO, LSO, IMPREST;
        }
        field(8; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Department';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
            //ValidateShortcutDimCode(1,"Global Dimension 1 Code");           
            /*PurchaseReqDet.RESET;
                       PurchaseReqDet.SETRANGE(PurchaseReqDet."Requistion No.", "Requisition No.");

                       IF PurchaseReqDet.FIND('-') THEN BEGIN
                           REPEAT
                               PurchaseReqDet."Global Dimension 1 Code" := "Global Dimension 1 Code";
                               PurchaseReqDet.MODIFY;
                           UNTIL PurchaseReqDet.NEXT = 0;
                       end;

                       PurchaseReqDet.VALIDATE(PurchaseReqDet."No."); */
            end;
        }
        field(9; "Budget Year"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name";
        }
        field(10; "User ID"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Time Stamp"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Description; Text[150])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
        }
        key(Key2; "Budget Line", "Global Dimension 1 Code", "Global Dimension 2 Code", "Commitment Date", "Budget Year")
        {
        }
    }
    trigger OnInsert()
    begin
        "User ID":=UserId;
        "Time Stamp":=Time;
    end;
}
