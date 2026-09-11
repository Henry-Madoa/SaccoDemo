table 52203716 "Contract Lines"
{
    fields
    {
        field(1; "Contract No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'G/L Account,Fixed Asset,Item';
            OptionMembers = "G/L Account", "Fixed Asset", Item;
        }
        field(3; No; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if RequisitionHeader.Get("Contract No.")then begin
                    if RequisitionHeader."Requisition Type" in[RequisitionHeader."Requisition Type"::"Purchase Requisition"]then begin
                        // "Planned Quantity" := ProcStoreManagement.IanGetPlannedQuantity("Global Dimension 1 Code", Type, No, "Plan No.");
                        // "Planned Amount" := ProcStoreManagement.IanGetPlannedAmount("Global Dimension 1 Code", Type, No, "Plan No.");
                        // "Requisitioned Quantity" := ProcStoreManagement.IanGetRequisitionedQuantity("Global Dimension 1 Code", Type, No, "Plan No.");
                        // "Used Amount" := ProcStoreManagement.IanGetRequisitionedAmount("Global Dimension 1 Code", Type, No, "Plan No.");
                        "Available Quantity":="Planned Quantity" - "Requisitioned Quantity";
                        "Available Amount":="Planned Amount" - "Used Amount";
                    end;
                end;
            end;
        }
        field(4; Name; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Quantity; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
                Validate("Total Amount");
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
                Validate("Total Amount");
            end;
        }
        field(8; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Total Amount" > "Available Amount" then UnPlanned:=true
                else
                    UnPlanned:=false;
            end;
        }
        field(9; "Unit of Measure"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure".Code;
        }
        field(10; "Plan No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Planned Quantity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Requisitioned Quantity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Planned Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Used Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; UnPlanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Available Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Available Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; Location; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(19; Approved; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Global Dimension 1 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Global Dimension 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(23; "Vendor To Award"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Order/Contract Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(26; "Project Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Job."No.";
        }
        field(27; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = ToBeClassified;
            TableRelation = Job;

            trigger OnValidate()
            var
                Job: Record Job;
            begin
            // TESTFIELD("Drop Shipment",FALSE);
            // TESTFIELD("Special Order",FALSE);
            // TESTFIELD("Receipt No.",'');
            // IF "Document Type" = "Document Type"::Order THEN
            //  TESTFIELD("Quantity Received",0);
            //
            // IF ReservEntryExist THEN
            //  TESTFIELD("Job No.",'');
            //
            // IF "Job No." <> xRec."Job No." THEN BEGIN
            //  VALIDATE("Job Task No.",'');
            //  VALIDATE("Job Planning Line No.",0);
            // END;
            //
            // IF "Job No." = '' THEN BEGIN
            //  CreateDim(
            //    DATABASE::Job,"Job No.",
            //    DimMgt.TypeToTableID3(Type),"No.",
            //    DATABASE::"Responsibility Center","Responsibility Center",
            //    DATABASE::"Work Center","Work Center No.");
            //  EXIT;
            // END;
            //
            // IF NOT (Type IN [Type::Item,Type::"G/L Account"]) THEN
            //  FIELDERROR("Job No.",STRSUBSTNO(Text012,FIELDCAPTION(Type),Type));
            // Job.GET("Job No.");
            // Job.TestBlocked;
            // "Job Currency Code" := Job."Currency Code";
            //
            // CreateDim(
            //  DATABASE::Job,"Job No.",
            //  DimMgt.TypeToTableID3(Type),"No.",
            //  DATABASE::"Responsibility Center","Responsibility Center",
            //  DATABASE::"Work Center","Work Center No.");
            end;
        }
        field(28; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            DataClassification = ToBeClassified;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No."=FIELD("Job No."));

            trigger OnValidate()
            begin
            //
            // IF "Job Task No." <> xRec."Job Task No." THEN BEGIN
            //  VALIDATE("Job Planning Line No.",0);
            //  IF "Document Type" = "Document Type"::Order THEN
            //    TESTFIELD("Quantity Received",0);
            // END;
            //
            // IF "Job Task No." = '' THEN BEGIN
            //  CLEAR(TempJobJnlLine);
            //  "Job Line Type" := "Job Line Type"::" ";
            //  UpdateJobPrices;
            //  CreateDim(
            //    DimMgt.TypeToTableID3(Type),"No.",
            //    DATABASE::Job,"Job No.",
            //    DATABASE::"Responsibility Center","Responsibility Center",
            //    DATABASE::"Work Center","Work Center No.");
            //  EXIT;
            // END;
            //
            // JobSetCurrencyFactor;
            // IF JobTaskIsSet THEN BEGIN
            //  CreateTempJobJnlLine(TRUE);
            //  UpdateJobPrices;
            // END;
            // UpdateDimensionsFromJobTask;
            end;
        }
        field(29; "Job Planning Line No."; Integer)
        {
            AccessByPermission = TableData Job=R;
            BlankZero = true;
            Caption = 'Job Planning Line No.';
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
            // JobPlanningLine.SETRANGE("Job No.","Job No.");
            // JobPlanningLine.SETRANGE("Job Task No.","Job Task No.");
            // JobPlanningLine.SETRANGE(Type,JobPlanningLine.Type::"G/L Account");
            // //END;
            // //JobPlanningLine.SETRANGE("No.","Account No");
            // JobPlanningLine.SETRANGE("Usage Link",TRUE);
            // JobPlanningLine.SETRANGE("System-Created Entry",FALSE);
            //
            // IF PAGE.RUNMODAL(0,JobPlanningLine) = ACTION::LookupOK THEN
            //  VALIDATE("Job Planning Line No.",JobPlanningLine."Line No.");
            end;
            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
            // IF "Job Planning Line No." <> 0 THEN BEGIN
            //  JobPlanningLine.GET("Job No.","Job Task No.","Job Planning Line No.");
            //  JobPlanningLine.TESTFIELD("Job No.","Job No.");
            //  JobPlanningLine.TESTFIELD("Job Task No.","Job Task No.");
            //  JobPlanningLine.TESTFIELD(Type,JobPlanningLine.Type::"G/L Account");
            //
            //  END;
            // JobPlanningLine.TESTFIELD("No.","No.");
            //JobPlanningLine.TESTFIELD("Usage Link",TRUE);
            //JobPlanningLine.TESTFIELD("System-Created Entry",FALSE);
            //"Job Line Type" := JobPlanningLine."Line Type" + 1;
            //VALIDATE("Job Remaining Qty.",JobPlanningLine."Remaining Qty." - "Qty. to Invoice");
            // END ELSE
            //  VALIDATE("Job Remaining Qty.",0);
            end;
        }
        // field(50001; "Grant No."; Code[20])
        // {
        //     Caption = 'Grant No.';
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Grant Header"."No.";
        // }
        // field(50002; "Objective Code"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Grant Lines".Code WHERE("Line Type" = CONST(Objective),
        //                                               "Grant No" = FIELD("Grant No."));
        // }
        // field(50003; "Output Code"; Code[20])
        // {
        //     Caption = 'Output Code';
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Grant Lines".Code WHERE("Line Type" = CONST(Output),
        //                                               "Grant No" = FIELD("Grant No."));
        // }
        // field(50004; "Outcome Code"; Code[20])
        // {
        //     Caption = 'Outcome Code';
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Grant Lines".Code WHERE("Line Type" = CONST(Outcome),
        //                                               "Grant No" = FIELD("Grant No."));
        // }
        // field(50005; "Activity Code"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Grant Lines".Code WHERE("Line Type" = CONST(Activity),
        //                                               "Grant No" = FIELD("Grant No."));
        // }
        // field(50008; "Partner Code"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     trigger OnLookup()
        //     var
        //         GrantDetailLines: Record "Grant Detail Lines";
        //     begin
        //         // GrantDetailLines.RESET;
        //         // GrantDetailLines.SETRANGE("Grant Code","Grant No.");
        //         // IF Type=Type::"G/L Account" THEN
        //         // GrantDetailLines.SETRANGE("G/L Account No",No);
        //         // GrantDetailLines.SETRANGE(Code,"Activity Code");
        //         // IF GrantDetailLines.FINDSET THEN BEGIN
        //         //  IF PAGE.RUNMODAL(0,GrantDetailLines) = ACTION::LookupOK THEN BEGIN
        //         //    VALIDATE("Partner Code",GrantDetailLines."External Partner Code");
        //         //  END;
        //         // END;
        //     end;
        // }
        field(70001; "Car Repair/Maintenance"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Vehicle Reg. No"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fixed Asset"."No." WHERE("Asset Type"=CONST("Motor Vehicle"));
        }
        field(70003; "Tender Winner"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70004; "FA Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Transfer,Lease';
            OptionMembers = Transfer, Lease;
        }
        field(70005; "Lease Period(Months=M,Years=Y)"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(70006; "Lease Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70007; "Account To Commit"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(70008; "Donor Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(70009; "Donor Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70010; "Patient Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70011; "Patient Card No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(70012; "Patient Diagnosis"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        // field(70013; "Institution Code"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = Institutions."No.";
        //     trigger OnValidate()
        //     begin
        //         // IF Institutions.GET("Institution Code") THEN
        //         //  "Institution Name":=Institutions.Name;
        //     end;
        // }
        field(70014; "Institution Name"; Text[150])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70015; "Student Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3));

            trigger OnValidate()
            begin
            // ValidateShortcutDimCode(3,"Student Code");
            end;
        }
        field(70016; "Shade Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4));

            trigger OnValidate()
            begin
            // ValidateShortcutDimCode(4,"Shade Code");
            end;
        }
        field(70017; "Animal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5));

            trigger OnValidate()
            begin
            // ValidateShortcutDimCode(5,"Animal Code");
            end;
        }
        field(70018; "Qty. to Issue"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // IF "Qty. to Issue">Quantity THEN
            //  ERROR('You can not issue more than %1 that has been Requested',Quantity);
            end;
        }
        field(70019; "Qty. after Issue"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Contract No.", "Line No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if RequisitionHeader.Get("Contract No.")then begin
            "Global Dimension 1 Code":=RequisitionHeader."Global Dimension 3 Code";
            "Global Dimension 2 Code":=RequisitionHeader."Global Dimension 2 Code";
            "Plan No.":=RequisitionHeader."Plan Name";
        end;
    end;
    var RequisitionHeader: Record "Requisition Header";
    ProcStoreManagement: Codeunit "Proc & Store Management";
}
