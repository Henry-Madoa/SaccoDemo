table 52203648 "Appraisal Objectives/KRAs"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No"; Code[20])
        {
        }
        field(3; "Employee No"; Code[10])
        {
        }
        field(4; "KRA/Objective"; Text[250])
        {
        }
        field(5; "Perfomance Level"; Text[30])
        {
            trigger OnLookup()
            begin
            /*AppraisalPerfomance.RESET;
                    IF PAGE.RUNMODAL(PAGE::"Perfomance Level",AppraisalPerfomance) = ACTION::LookupOK THEN
                      "Perfomance Level":=AppraisalPerfomance."Perfomace Level";*/
            end;
        }
        field(6; "Perfomance Comment"; Text[30])
        {
        }
        field(7; "Appraisee Self Rating"; Text[30])
        {
            trigger OnLookup()
            begin
                AppraisalRatings.Reset;
                if PAGE.RunModal(PAGE::"Appraisal Ratings", AppraisalRatings) = ACTION::LookupOK then "Appraisee Self Rating":=AppraisalRatings.Code;
            end;
        }
        field(8; "Appraiser Rating"; Text[30])
        {
            trigger OnLookup()
            begin
                AppraisalRatings.Reset;
                if PAGE.RunModal(PAGE::"Appraisal Ratings", AppraisalRatings) = ACTION::LookupOK then "Appraiser Rating":=AppraisalRatings.Code;
            end;
        }
        field(9; "Agreed Rating"; Decimal)
        {
            CalcFormula = Sum("Appraisal KPIs Rating".Score WHERE("Appraisal No"=FIELD("Appraisal No"), "Employee No"=FIELD("Employee No"), "KRA Line No"=FIELD("Line No"), "Review Period"=field("Review Period")));
            FieldClass = FlowField;
        }
        field(10; "Rating Comments"; Text[250])
        {
        }
        field(11; "Employee Comments"; Text[250])
        {
        }
        field(12; "Perspective/Pillar"; Code[20])
        {
            TableRelation = "Appraisal Perspectives";
        }
        field(19; "Total Weigth"; Decimal)
        {
            CalcFormula = Sum("Appraisal Activities".Weight WHERE("Kra Line No"=FIELD("Line No"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(20; "Maximum Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; Score; Decimal)
        {
            CalcFormula = Sum("Appraisal KPIs Rating".Score WHERE("Appraisal No"=FIELD("Appraisal No"), "Employee No"=FIELD("Employee No"), "KRA Line No"=FIELD("Line No"), "Review Period"=field("Review Period")));
            FieldClass = FlowField;
        }
        field(22; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Line No", "Appraisal No", "Employee No")
        {
        }
    }
    trigger OnInsert()
    begin
    /*EmployeeAppraisalKRAs.RESET;
            EmployeeAppraisalKRAs.SETRANGE("Appraisal No",Rec."Appraisal No");
            EmployeeAppraisalKRAs.SETRANGE("Employee No",Rec."Employee No");
            EmployeeAppraisalKRAs.SETASCENDING("Line No",TRUE);
            EmployeeAppraisalKRAs.SETCURRENTKEY("Line No");
            EmployeeAppraisalKRAs.SETFILTER("Line No",'>%1',Rec."Line No");
            IF EmployeeAppraisalKRAs.FINDSET THEN
              BEGIN
                REPEAT
                  EmployeeAppraisalKRAs.TESTFIELD("Maximum Weight");
                  EmployeeAppraisalKRAs.CALCFIELDS("Total Weigth");
                  IF EmployeeAppraisalKRAs."Total Weigth"<>EmployeeAppraisalKRAs."Maximum Weight" THEN
                    ERROR('You cannot create a new KRA until you complete the previous one');
                UNTIL EmployeeAppraisalKRAs.NEXT=0;
              end;*/
    end;
    var AppraisalRatings: Record "Appraisal Ratings";
    AppraisalPerfomance: Record "Appraisal Perfomance";
    EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
    HumanResourcesSetup: Record "Human Resources Setup";
    AppraisalHeader: Record "Appraisal Header";
}
