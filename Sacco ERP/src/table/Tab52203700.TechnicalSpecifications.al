table 52203700 "Technical Specifications"
{
    fields
    {
        field(1; "Reference No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requirement Code"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Requirement Specification"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Max Weigth"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Modify then begin
                    if ProcurementRequest.Get("Reference No.")then begin
                        ProcurementRequest.TestField("Technical Scores");
                        TotalWeight:=CalculateWeight;
                        if TotalWeight > ProcurementRequest."Technical Scores" then Error('The total technical weight should not exceed the overall technical score');
                    end;
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Reference No.", "Requirement Code")
        {
        }
    }
    trigger OnInsert()
    begin
        if ProcurementRequest.Get("Reference No.")then begin
            ProcurementRequest.TestField("Tender Status", ProcurementRequest."Tender Status"::New);
        end;
    end;
    var ProcurementRequest: Record "Procurement Request";
    TotalWeight: Decimal;
    TechnicalSpecifications: Record "Technical Specifications";
    local procedure CalculateWeight(): Decimal var
        MaximumWeight: Decimal;
    begin
        TechnicalSpecifications.Reset;
        TechnicalSpecifications.SetRange("Reference No.", "Reference No.");
        if TechnicalSpecifications.FindSet then begin
            TechnicalSpecifications.CalcSums("Max Weigth");
            MaximumWeight:=TechnicalSpecifications."Max Weigth";
            exit(MaximumWeight);
        end;
    end;
}
