table 52203671 "Appraisal Behaviour Rating"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Behaviour Line No"; Integer)
        {
        }
        field(3; "Competence Line No"; Integer)
        {
        }
        field(4; "Appraisal No"; Code[20])
        {
            trigger OnValidate()
            begin
                if AppraisalHeader.Get(Rec."Appraisal No")then begin
                    "Review Period":=AppraisalHeader."Review Period";
                end;
                if AppraisalBehaviour.Get("Behaviour Line No", "Competence Line No", "Appraisal No", "Employee No")then begin
                    Weight:=AppraisalBehaviour.Weight;
                end;
            end;
        }
        field(5; "Employee No"; Code[20])
        {
        }
        field(6; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
        field(8; "Appraisee Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Appraisee Self Rating"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Appraisal Ratings";
        }
        field(10; "Appraiser Rating"; Code[20])
        {
            trigger OnLookup()
            begin
                AppraisalRatings.Reset;
                if PAGE.RunModal(PAGE::"Appraisal Ratings", AppraisalRatings) = ACTION::LookupOK then "Appraiser Rating":=AppraisalRatings.Code;
                Validate("Appraiser Rating");
            end;
            trigger OnValidate()
            begin
                if "Appraiser Rating" = '' then begin
                    Score:=0;
                    exit;
                end;
                if AppraisalRatings.Get("Appraiser Rating")then begin
                    Score:=Round(Weight * (AppraisalRatings.Percentage / 100), 1, '=');
                end;
                Rec.Modify(true);
                Commit;
                EmployeeAppraisalCompetence.Reset;
                EmployeeAppraisalCompetence.SetRange("Appraisal No", Rec."Appraisal No");
                if EmployeeAppraisalCompetence.FindSet then begin
                    repeat EmployeeAppraisalCompetence.CalcFields("Overall Score");
                        TotalOverallRating+=EmployeeAppraisalCompetence."Overall Score";
                    until EmployeeAppraisalCompetence.Next = 0;
                end;
                EmployeeAppraisalKRAs.SetAutoCalcFields("Agreed Rating");
                EmployeeAppraisalKRAs.Reset;
                EmployeeAppraisalKRAs.SetRange("Appraisal No", Rec."Appraisal No");
                if EmployeeAppraisalKRAs.FindSet then begin
                    repeat TotalOverallRating+=EmployeeAppraisalKRAs."Agreed Rating";
                    until EmployeeAppraisalKRAs.Next = 0;
                end;
                EmployeeAppraisalCompetence.SetAutoCalcFields("Overall Score");
                EmployeeAppraisalCompetence.Reset;
                EmployeeAppraisalCompetence.SetRange("Appraisal No", Rec."Appraisal No");
                EmployeeAppraisalCompetence.SetRange("Employee Code", Rec."Employee No");
                if EmployeeAppraisalCompetence.FindSet then begin
                    repeat EmployeeAppraisalCompetence.CalcFields("Overall Score");
                        CompetenceOverallRating+=EmployeeAppraisalCompetence."Overall Score";
                    until EmployeeAppraisalCompetence.Next = 0;
                end;
                HumanResourcesSetup.Get;
                KraPercentage:=(HumanResourcesSetup."KRA Percentage" / 100) * TotalOverallRating;
                CompetencePercenatge:=(HumanResourcesSetup."Competencies Percentage" / 100) * CompetenceOverallRating;
                CombinedRating:=TotalOverallRating + CompetenceOverallRating;
                HumanResourcesSetup.Get;
                Evaluate(RatingForPassmark, HumanResourcesSetup."One Point Eligibility");
                AppraisalRatings.Reset;
                AppraisalRatings.SetRange(Description, OverallRatingText);
                if AppraisalRatings.FindFirst then OverallRatingInteger:=AppraisalRatings.Percentage;
                RatingForCurrent:=0;
                AppraisalRatings.Reset;
                AppraisalRatings.SetRange(Code, Rec."Appraiser Rating");
                if AppraisalRatings.FindFirst then RatingForCurrent:=AppraisalRatings.Percentage;
                if OverallRatingInteger <= RatingForPassmark then begin
                    if AppraisalHeader.Get(Rec."Appraisal No")then begin
                        AppraisalHeader."Recomended Action":=AppraisalHeader."Recomended Action"::"Perfomance Improvement";
                        AppraisalHeader."Eligible for one point":=false;
                    end;
                end;
                if OverallRatingInteger > RatingForPassmark then begin
                    if AppraisalHeader.Get(Rec."Appraisal No")then begin
                        AppraisalHeader."Recomended Action":=AppraisalHeader."Recomended Action"::" ";
                        AppraisalHeader."Eligible for one point":=true;
                    end;
                end;
            end;
        }
        field(11; Score; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; Agree; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if AppraisalHeader.Get(Rec."Appraisal No")then begin
                    if Agree = true then begin
                        AppraisalHeader."Appraisee Agreed":=true;
                        "Disagreement Comments":='';
                    end
                    else
                        AppraisalHeader."Appraisee Agreed":=false;
                    AppraisalHeader.Modify(true);
                end;
            end;
        }
        field(13; "Disagreement Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Appraiser Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Overview Manager Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Non Achievement Reasons"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Target Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Achieved, "Not Achieved";
        }
        field(18; "Target Justification"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No", "Behaviour Line No", "Competence Line No", "Appraisal No", "Employee No")
        {
        }
    }
    var AppraisalRatings: Record "Appraisal Ratings";
    EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
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
    AppraisalBehaviour: Record "Appraisal Behaviour";
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
