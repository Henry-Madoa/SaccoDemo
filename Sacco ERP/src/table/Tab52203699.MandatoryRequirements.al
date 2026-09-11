table 52203699 "Mandatory Requirements"
{
    fields
    {
        field(1; "Reference No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requirement Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Tender Mandatory Requirements"."Mandatory Code";

            trigger OnValidate()
            begin
                if TenderMandatoryRequirements.Get("Requirement Code")then begin
                    "Requirement Description":=TenderMandatoryRequirements."Requirement Description";
                end;
            end;
        }
        field(3; "Requirement Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Max Weight"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Modify then begin
                    if ProcurementRequest.Get("Reference No")then begin
                        ProcurementRequest.TestField("Administrative-Mandatory Score");
                        TotalWeight:=CalculateWeight;
                        if TotalWeight > ProcurementRequest."Administrative-Mandatory Score" then Error('The total mandatory weight should not exceed the administrative score');
                    end;
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Reference No", "Requirement Code")
        {
        }
    }
    trigger OnInsert()
    begin
        if ProcurementRequest.Get("Reference No")then begin
            ProcurementRequest.TestField("Tender Status", ProcurementRequest."Tender Status"::New);
        end;
    end;
    var ProcurementRequest: Record "Procurement Request";
    TenderMandatoryRequirements: Record "Tender Mandatory Requirements";
    TotalWeight: Decimal;
    MandatoryRequirements: Record "Mandatory Requirements";
    local procedure CalculateWeight(): Decimal var
        MaximumWeight: Decimal;
    begin
        MandatoryRequirements.Reset;
        MandatoryRequirements.SetRange("Reference No", "Reference No");
        if MandatoryRequirements.FindSet then begin
            MandatoryRequirements.CalcSums("Max Weight");
            MaximumWeight:=MandatoryRequirements."Max Weight";
            exit(MaximumWeight);
        end;
    end;
}
