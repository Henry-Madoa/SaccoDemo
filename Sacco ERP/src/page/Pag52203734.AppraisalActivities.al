page 52203734 "Appraisal Activities"
{
    DeleteAllowed = true;
    InsertAllowed = true;
    PageType = List;
    SourceTable = "Appraisal Activities";
    DataCaptionFields = "Kra/Objective";

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
                field("Kra Line No"; Rec."Kra Line No")
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
                field("Kra/Objective"; Rec."Kra/Objective")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Activity; Rec.Activity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target/KPI"; Rec."Target/KPI")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target/KPI Status"; Rec."Target/KPI Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target Justification"; Rec."Target Justification")
                {
                    Editable = Rec."Target/KPI Status" = Rec."Target/KPI Status"::"Not Achieved";
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("KPIs Results")
            {
                Image = Position;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                RunObject = page "Appraisal KPIs Rating";
                RunPageLink = "KPI Line No"=field("Line No"), "KRA Line No"=field("Kra Line No"), "Appraisal No"=field("Appraisal No"), "Employee No"=field("Employee No");
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        COntrolAppearance;
    end;
    trigger OnAfterGetRecord()
    begin
        COntrolAppearance;
    end;
    trigger OnOpenPage()
    begin
        COntrolAppearance();
    end;
    var Text0001: Label 'Are you sure you want to Re Open?';
    Text0002: Label 'Are you sure you want to Submit?';
    IsSubmitted: Boolean;
    EmployeeAppraisalKPIs: Record "Appraisal Activities";
    ObjEditable: Boolean;
    MYUserEditable: Boolean;
    MyVisible: Boolean;
    EyUserVisible: Boolean;
    MySupEditable: Boolean;
    EySupEditable: Boolean;
    AgreementEditable: Boolean;
    MYUserVisible: Boolean;
    EyUserEditable: Boolean;
    MySupVisible: Boolean;
    EySupVisible: Boolean;
    AgreementVisible: Boolean;
    local procedure COntrolAppearance()
    var
        AppraisalHeader: Record "Appraisal Header";
    begin
        MYUserVisible:=true;
        EyUserVisible:=true;
        MySupVisible:=true;
        EySupVisible:=true;
        AgreementVisible:=true;
        EyUserVisible:=true;
        EySupVisible:=true;
        AgreementVisible:=true;
        if AppraisalHeader.Get(Rec."Appraisal No")then begin
            if((AppraisalHeader.Sequence = 0) and (AppraisalHeader.Status in[AppraisalHeader.Status::"Appraisee Level"]))then ObjEditable:=true
            else
                ObjEditable:=false;
            if AppraisalHeader.Status in[AppraisalHeader.Status::"Appraisee Level"]then MYUserEditable:=true
            else
                MYUserEditable:=false;
            if AppraisalHeader.Status in[AppraisalHeader.Status::"Appraiser Level", AppraisalHeader.Status::"Overview Manager Level"]then MySupEditable:=true
            else
                MySupEditable:=false;
            if AppraisalHeader.Status in[AppraisalHeader.Status::"Appraisee Level"]then EyUserEditable:=true
            else
                EyUserEditable:=false;
            if AppraisalHeader.Status in[AppraisalHeader.Status::"Appraiser Level", AppraisalHeader.Status::"Overview Manager Level"]then EySupEditable:=true
            else
                EySupEditable:=false;
            if AppraisalHeader.Status in[AppraisalHeader.Status::"Agreement Level"]then AgreementEditable:=true
            else
                AgreementEditable:=false;
            if((AppraisalHeader.Sequence = 0) and (not(AppraisalHeader.Status in[AppraisalHeader.Status::Closed])))then begin
                MYUserVisible:=false;
                EyUserVisible:=false;
                MySupVisible:=false;
                EySupVisible:=false;
                AgreementVisible:=false;
            end;
            if not(AppraisalHeader.Status in[AppraisalHeader.Status::Closed])then begin
                EyUserVisible:=false;
                EySupVisible:=false;
                AgreementVisible:=false;
            end;
            if not(AppraisalHeader.Status in[AppraisalHeader.Status::"Agreement Level", AppraisalHeader.Status::Closed, AppraisalHeader.Status::"Appraiser Level", AppraisalHeader.Status::"Overview Manager Level"])then begin
                AgreementVisible:=false;
            end;
        end;
    end;
}
