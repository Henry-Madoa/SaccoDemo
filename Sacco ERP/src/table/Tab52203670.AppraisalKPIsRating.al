table 52203670 "Appraisal KPIs Rating"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "KPI Line No"; Integer)
        {
        }
        field(3; "KRA Line No"; Integer)
        {
        }
        field(4; "Appraisal No"; Code[20])
        {
            trigger OnValidate()
            begin
                if AppraisalHeader.Get(Rec."Appraisal No")then begin
                    "Review Period":=AppraisalHeader."Review Period";
                    if AppraisalKPIs.Get("KPI Line No", "Appraisal No", "Employee No", "KRA Line No")then begin
                        Weight:=AppraisalKPIs.Weight;
                    end;
                end;
            end;
        }
        field(5; "Employee No"; Code[20])
        {
        }
        field(6; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
        field(11; "Appraisee Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Appraisee Self Rating"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Appraisal Ratings";
        }
        field(13; "Appraiser Rating"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            begin
                AppraisalRatings.Reset;
                if PAGE.RunModal(PAGE::"Appraisal Ratings", AppraisalRatings) = ACTION::LookupOK then "Appraiser Rating":=AppraisalRatings.Code;
                Validate("Appraiser Rating");
            end;
            trigger OnValidate()
            begin
                if AppraisalHeader.Get(Rec."Appraisal No")then begin
                    "Review Period":=AppraisalHeader."Review Period";
                    if AppraisalKPIs.Get("KPI Line No", "Appraisal No", "Employee No", "KRA Line No")then begin
                        Weight:=AppraisalKPIs.Weight;
                    end;
                end;
                if "Appraiser Rating" = '' then begin
                    Score:=0;
                    exit;
                end;
                if AppraisalRatings.Get("Appraiser Rating")then begin
                    Score:=Round(Weight * (AppraisalRatings.Percentage / 100), 1, '=');
                end;
                Commit;
                Rec.Modify(true);
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
                    repeat CompetenceOverallRating+=EmployeeAppraisalCompetence."Overall Score";
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
                        AppraisalHeader.Modify(true);
                    end;
                end;
                if OverallRatingInteger > RatingForPassmark then begin
                    if AppraisalHeader.Get(Rec."Appraisal No")then begin
                        AppraisalHeader."Probation Recomended Action":=AppraisalHeader."Probation Recomended Action"::Confirm;
                        AppraisalHeader."Recomended Action":=AppraisalHeader."Recomended Action"::" ";
                        AppraisalHeader."Eligible for one point":=true;
                        AppraisalHeader."Overall Rating":=OverallRatingText;
                        AppraisalHeader.Modify(true);
                    end;
                end;
            end;
        }
        field(14; Agree; Boolean)
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
        field(15; "Disagreement Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Appraiser Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(19; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Overview Manager Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(21; Score; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(22; "Non Achievement Reasons"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Target/KPI Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Achieved, "Not Achieved";
        }
    }
    keys
    {
        key(Key1; "Line No", "KPI Line No", "KRA Line No", "Appraisal No", "Employee No")
        {
        }
    }
    var AppraisalRatings: Record "Appraisal Ratings";
    AppraisalKPIsRating: Record "Appraisal KPIs Rating";
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
    AppraisalKPIs: Record "Appraisal Activities";
    ReviewPeriod: Record "Appraisal Review Periods";
    local procedure GetRating(RatingParam: Decimal): Text begin
        AppraisalRatings.Reset;
        AppraisalRatings.SetCurrentKey(Code);
        AppraisalRatings.SetAscending(Code, true);
        if AppraisalRatings.FindFirst then begin
            repeat if((RatingParam >= AppraisalRatings."Lower Limit") and (RatingParam <= AppraisalRatings."Upper Limit"))then exit(AppraisalRatings.Description);
            until AppraisalRatings.Next = 0;
        end;
    end;
    trigger OnInsert()
    begin
        AppraisalKPIsRating.Reset();
        AppraisalKPIsRating.SetRange("KPI Line No", Rec."KPI Line No");
        AppraisalKPIsRating.SetRange("KRA Line No", Rec."KRA Line No");
        AppraisalKPIsRating.SetRange("Appraisal No", Rec."Appraisal No");
        AppraisalKPIsRating.SetRange("Employee No", Rec."Employee No");
        AppraisalKPIsRating.SetRange("Review Period", Rec."Review Period");
        if AppraisalKPIsRating.FindFirst()then Error('There is an existing review rating');
        ReviewPeriod.Reset();
        ReviewPeriod.SetRange(Code, "Review Period");
        if ReviewPeriod.FindFirst then begin
            if ReviewPeriod.Sequence = 0 then Error('You cannot review Objective Settings');
        end;
    end;
}
