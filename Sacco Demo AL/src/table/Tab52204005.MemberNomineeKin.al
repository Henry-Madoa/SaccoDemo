table 52204005 "Member Nominee/Kin"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Relative Code"; Code[10])
        {
            TableRelation = Relative;
        }
        field(3; "Identification No."; code[20])
        {
            NotBlank = false;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Identification No." <> '' then begin
                    if not UserMgmt.IsWebServiceUser then begin
                        TestField("Identification Type");
                        if "Identification Type" = "Identification Type"::"National ID" then begin
                            MemberMgmt.NationalIDValidation("Identification No.");
                            if (("Identification No." = '') and "IPRS Uneditability") then "IPRS Uneditability" := false;
                        end;
                    end;
                    Member.Reset();
                    Member.SetRange("Identification No.", "Identification No.");
                    If Member.FindFirst() then begin
                        Member.CalcFields(Signature, "Passport Size Photo");
                        Name := Member.FullName;
                        "Identification Type" := Member."Identification Type";
                        "Identification No." := Member."Identification No.";
                        "Phone No." := Member."Mobile Phone No.";
                        "Date of Birth" := Member."Date of Birth";
                        "Passport Image" := Member."Passport Size Photo";
                    end;
                    MemberNextofKins.Reset();
                    MemberNextofKins.SetRange("Source Code", Rec."Source Code");
                    MemberNextofKins.SetRange("Relative Code", Rec."Relative Code");
                    MemberNextofKins.SetRange("Document Type", Rec."Document Type");
                    MemberNextofKins.SetRange("Identification No.", Rec."Identification No.");
                    if MemberNextofKins.FindFirst then Error(StrSubstNo('%1 have already been added as %2', Rec."Identification No.", Rec.Name));
                end;
            end;
        }
        field(4; "Date of Birth"; Date)
        {
            trigger OnValidate()
            begin
                if "Date of Birth" > WorkDate then Error('Date of Birth cannot be a future date.');
                if Relatives.Get("Relative Code") then if not Relatives.Minor then if CalcDate('-18Y', Today) < "Date of Birth" then Error(StrSubstNo('The %1 has not attained the minimum age of 18years', Rec."Document Type"));
            end;
        }
        field(5; "Phone No."; code[20])
        {
        }
        field(6; "Allocation"; decimal)
        {
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            var
                TotalAllocation: Decimal;
            begin
                if not UserMgmt.IsWebServiceUser then begin
                    TotalAllocation := 0;
                    If Allocation <= 100 then begin
                        MemberNextofKins.Reset();
                        MemberNextofKins.SetRange("Source Code", Rec."Source Code");
                        MemberNextofKins.SetRange("Document Type", Rec."Document Type"::Nominee);
                        MemberNextofKins.SetFilter(Allocation, '<>%1', 0);
                        MemberNextofKins.CalcSums(Allocation);
                        TotalAllocation := MemberNextofKins.Allocation;
                        if ((TotalAllocation - xRec.Allocation) + Rec.Allocation > 100) then Error('Allocation should not exceed 100%!');
                    end
                    else
                        Error('Allocation should not exceed 100%!');
                end;
            end;
        }
        field(7; Name; Text[150])
        {
        }
        field(8; "Passport Image"; blob)
        {
            Subtype = Bitmap;
        }
        field(9; "Identification Document"; blob)
        {
            Subtype = Bitmap;
        }
        field(10; "Document Type"; Enum "Kin Type")
        {
        }
        field(11; "IPRS Uneditability"; Boolean)
        {
        }
        field(12; "Identification Type"; Enum "Identity Type")
        {
        }
        field(13; "Add As Next of Kin"; Boolean)
        {
            trigger OnValidate()
            var
                Kins: array[2] of Record "Member Nominee/Kin";
            begin
                if "Add As Next of Kin" then begin
                    TestField("Identification No.");
                    TestField("Relative Code");
                    TestField(Name);
                    TestField(Allocation);
                    if not Kins[1].Get("Source Code", "Relative Code", "Identification No.", Kins[1]."Document Type") then begin
                        Kins[2].Init();
                        Kins[2]."Source Code" := "Source Code";
                        Kins[2]."Relative Code" := "Relative Code";
                        Kins[2]."Identification Type" := "Identification Type";
                        Kins[2]."Identification No." := "Identification No.";
                        Kins[2].Name := Name;
                        Kins[2]."Date of Birth" := "Date of Birth";
                        Kins[2]."Phone No." := "Phone No.";
                        Kins[2].Insert(true);
                    end;
                end
                else begin
                    Kins[1].Reset();
                    Kins[1].SetRange("Source Code", "Source Code");
                    Kins[1].SetRange("Relative Code", "Relative Code");
                    Kins[1].SetRange("Identification No.", "Identification No.");
                    Kins[1].SetRange("Document Type", Kins[1]."Document Type"::"Next of Kin");
                    if Kins[1].FindFirst then Kins[1].Delete(true);
                end;
            end;
        }
        field(14; "Amount Paid"; Decimal)
        {
        }
    }
    keys
    {
        key(PK; "Source Code", "Relative Code", "Identification No.", "Document Type")
        {
            Clustered = true;
        }
    }
    var
        MemberNextofKins: Record "Member Nominee/Kin";
        Relatives: Record Relative;
        Member: Record Members;
        UserMgmt: Codeunit "User Management Ext";
}
