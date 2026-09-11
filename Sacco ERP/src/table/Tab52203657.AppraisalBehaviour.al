table 52203657 "Appraisal Behaviour"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Competence Line No"; Integer)
        {
        }
        field(3; "Employee No"; Code[20])
        {
        }
        field(4; "Appraisal No"; Code[20])
        {
        }
        field(5; "Behaviour Name"; Text[100])
        {
        }
        field(6; Applicable; Boolean)
        {
        }
        field(7; "Current Proficiency Level"; Text[30])
        {
            trigger OnLookup()
            begin
                AppraisalProficiencyLevels.RESET;
                IF PAGE.RUNMODAL(PAGE::"Appraisal Proficiency Level", AppraisalProficiencyLevels) = ACTION::LookupOK THEN "Current Proficiency Level":=AppraisalProficiencyLevels.Level;
            end;
        }
        field(8; "Expected Proficiency Level"; Text[30])
        {
            trigger OnLookup()
            begin
                AppraisalProficiencyLevels.RESET;
                IF PAGE.RUNMODAL(PAGE::"Appraisal Proficiency Level", AppraisalProficiencyLevels) = ACTION::LookupOK THEN "Expected Proficiency Level":=AppraisalProficiencyLevels.Level;
            end;
        }
        field(9; "Behaviour Description"; Text[100])
        {
        }
        field(10; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
        field(11; "Competence Category"; Text[250])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Appraisal Competence"."Competence Category" where("Line No"=field("Competence Line No"), "Appraisal No"=field("Appraisal No"), "Employee Code"=field("Employee No")));
        }
        field(20; Weight; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TotalScore:=0;
                EmployeeAppraisalBehaviour.Reset;
                EmployeeAppraisalBehaviour.SetRange("Appraisal No", Rec."Appraisal No");
                EmployeeAppraisalBehaviour.SetRange("Competence Line No", Rec."Competence Line No");
                EmployeeAppraisalBehaviour.SetFilter("Line No", '<>%1', Rec."Line No");
                if EmployeeAppraisalBehaviour.FindSet then begin
                    EmployeeAppraisalBehaviour.CalcSums(Weight);
                    TotalScore:=EmployeeAppraisalKPIs.Weight + Rec.Weight;
                end;
                EmployeeAppraisalCompetence.Reset;
                EmployeeAppraisalCompetence.SetRange("Appraisal No", Rec."Appraisal No");
                EmployeeAppraisalCompetence.SetRange("Line No", Rec."Competence Line No");
                if EmployeeAppraisalCompetence.FindFirst then if TotalScore > EmployeeAppraisalCompetence."Maximum Weigth" then Error('Score cannot be higher than %1', EmployeeAppraisalCompetence."Maximum Weigth");
            end;
        }
    }
    keys
    {
        key(Key1; "Line No", "Competence Line No", "Appraisal No", "Employee No")
        {
        }
    }
    var AppraisalReviewPeriod: Record "Appraisal Review Periods";
    AppraisalRatings: Record "Appraisal Ratings";
    AppraisalPerfomance: Record "Appraisal Perfomance";
    EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
    EmployeeAppraisalKPIs: Record "Appraisal Activities";
    TotalScore: Decimal;
    RatingAsInteger: Integer;
    TotalOverallRating: Decimal;
    OverallRatingText: Text;
    AppraisalHeader: Record "Appraisal Header";
    HumanResourcesSetup: Record "Human Resources Setup";
    RatingForCurrent: Integer;
    RatingForPassmark: Integer;
    OverallRatingInteger: Integer;
    EmployeeAppraisalCompetence: Record "Appraisal Competence";
    CompetencePercenatge: Decimal;
    KraPercentage: Decimal;
    CompetenceOverallRating: Decimal;
    CombinedRating: Decimal;
    EmployeeAppraisalBehaviour: Record "Appraisal Behaviour";
    AppraisalHeaderCopy: Record "Appraisal Header";
    AppraisalProficiencyLevels: Record "Appraisal Proficiency Levels";
    local procedure GetRating(RatingParam: Decimal): Text begin
        AppraisalRatings.Reset;
        AppraisalRatings.SetCurrentKey(Code);
        AppraisalRatings.SetAscending(Code, true);
        if AppraisalRatings.FindFirst then begin
            repeat if((RatingParam >= AppraisalRatings."Lower Limit") and (RatingParam <= AppraisalRatings."Upper Limit"))then exit(AppraisalRatings.Description);
            until AppraisalRatings.Next = 0;
        end;
    end;
}
