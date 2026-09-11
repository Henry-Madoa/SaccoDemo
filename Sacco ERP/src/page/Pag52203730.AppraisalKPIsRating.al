page 52203730 "Appraisal KPIs Rating"
{
    PageType = List;
    SourceTable = "Appraisal KPIs Rating";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Kpi Line No"; Rec."KPI Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Kra Line No"; Rec."KRA Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal No"; Rec."Appraisal No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Review Period"; Rec."Review Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target/KPI Status"; Rec."Target/KPI Status")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiseeEditing;
                    ShowMandatory = true;
                }
                field("Non Achievement Reasons"; Rec."Non Achievement Reasons")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiseeEditing;
                    ShowMandatory = true;
                }
                field("Appraisee Self Rating"; Rec."Appraisee Self Rating")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiseeEditing;
                    ShowMandatory = true;
                }
                field("Appraisee Comments"; Rec."Appraisee Comments")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiseeEditing;
                    ShowMandatory = true;
                }
                field("Appraiser Rating"; Rec."Appraiser Rating")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiserEditing;
                    ShowMandatory = true;
                }
                field("Appraiser Comments"; Rec."Appraiser Comments")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AppraiserEditing;
                    ShowMandatory = true;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Agree; Rec.Agree)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AgreementEditing;
                }
                field("Disagreement Comments"; Rec."Disagreement Comments")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AgreementEditing and Rec.Agree = false;
                    ShowMandatory = true;
                }
                field("Overview Manager Comments"; Rec."Overview Manager Comments")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = OverviewEditing;
                    ShowMandatory = true;
                }
            }
        }
    }
    trigger OnInit()
    begin
        AppraiseeEditing:=false;
        AppraiserEditing:=false;
        OverviewEditing:=false;
        AgreementEditing:=false;
    end;
    trigger OnAfterGetCurrRecord()
    begin
        ControlAppearance;
    end;
    trigger OnAfterGetRecord()
    begin
        ControlAppearance;
    end;
    trigger OnOpenPage()
    begin
        ControlAppearance;
    end;
    var ReviewPeriods: Record "Appraisal Review Periods";
    AppraiseeEditing: Boolean;
    AppraiserEditing: Boolean;
    OverviewEditing: Boolean;
    AgreementEditing: Boolean;
    AppraisalHeader: Record "Appraisal Header";
    local procedure ControlAppearance()
    begin
        if AppraisalHeader.Get(Rec."Appraisal No")then begin
            if AppraisalHeader.Status = AppraisalHeader.Status::"Appraisee Level" then AppraiseeEditing:=true
            else if AppraisalHeader.Status = AppraisalHeader.Status::"Appraiser Level" then AppraiserEditing:=true
                else if AppraisalHeader.Status = AppraisalHeader.Status::"Overview Manager Level" then OverviewEditing:=true
                    else if AppraisalHeader.Status = AppraisalHeader.Status::"Agreement Level" then AgreementEditing:=true;
        end;
    end;
}
