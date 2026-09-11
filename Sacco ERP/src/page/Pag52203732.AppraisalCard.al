page 52203732 "Appraisal Card"
{
    //DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Appraisal Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = IsPageEditable;

                field("Appraisal No"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee User Id"; Rec."Employee User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Level/Grade"; Rec."Level/Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Calendar"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Start Date"; Rec."Appraisal Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor No"; Rec."Supervisor No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor Name"; Rec."Supervisor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor User Id"; Rec."Supervisor User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor Overall Comments"; Rec."Supervisor Overall Comments")
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Supervisor Rejection Comments"; Rec."Supervisor Rejection Comments")
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Overview Manager"; Rec."Overview Manager")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overview Manager Name"; Rec."Overview Manager Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overview Manager UserID"; Rec."Overview Manager UserID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Over View Manager Comments"; Rec."OverView Manager Comments")
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Overview Rejection Comments"; Rec."Overview Rejection Comments")
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Review Period"; Rec."Review Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overall Score"; Rec."Overall Score")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overall Rating"; Rec."Overall Rating")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Quarter; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(RecomendedAction)
            {
                Editable = ActionEditable;
                ShowCaption = false;
                Visible = ActionVisible;

                field("Recomended Action"; Rec."Recomended Action")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Appraisal Objectives/KRAs"; "Appraisal Objectives/KRAs")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsPageEditable;
                SubPageLink = "Appraisal No"=FIELD("No."), "Employee No"=FIELD("Employee No");
            }
            part("Appraisal Competence"; "Appraisal Competence")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsPageEditable;
                SubPageLink = "Appraisal No"=FIELD("No."), "Employee Code"=FIELD("Employee No");
            }
            part("Areas of Further Development"; "Areas of Further Development")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsPageEditable;
                SubPageLink = "Appraisal No."=FIELD("No."), "Employee No."=FIELD("Employee No");
            }
            part("Training Needs"; "Appraisal Training Needs")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Appraisal No."=FIELD("No."), "Employee No."=FIELD("Employee No");
            }
            part(Control14; "Appraisal Supervisor List")
            {
                Visible = Rec.Status = Rec.Status::Closed;
                ApplicationArea = Basic, Suite;
                SubPageLink = "No."=FIELD("No."), "Employee No"=FIELD("Employee No");
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Appraisal Print Out", true, false, Rec);
                end;
            }
        }
        area(processing)
        {
            action("Send To Line Manager")
            {
                ApplicationArea = Basic, Suite;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = SendToLineVisible;

                trigger OnAction()
                begin
                    if Rec.Sequence = 0 then begin
                        if not Confirm('Are you sure you want to send the set objectives for appraisal?')then exit;
                        AppraisalStatusChange.SendGoalSettingForApproval(Rec."No.", Rec."Employee No", true, '');
                    end;
                    if Rec.Sequence <> 0 then begin
                        if not Confirm('Are you sure you want to send it to Line Manager?')then exit;
                        AppraisalStatusChange.SendAppraisalForApproval(Rec."No.", Rec."Employee No", true, '');
                    end;
                end;
            }
            action("Send Back To Appraisee")
            {
                ApplicationArea = Basic, Suite;
                Image = Return;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = SendBackToAppraiseeVisible;

                trigger OnAction()
                begin
                    if Rec.Sequence = 0 then begin
                        if not Confirm('Are you sure you want to send it back to appraisee?')then exit;
                        AppraisalStatusChange.SendGoalSettingBackToAppraisee(Rec."No.", Rec."Employee No", true, '', '');
                    end;
                    if Rec.Sequence <> 0 then begin
                        if not Confirm('Are you sure you want to send it back to appraisee?')then exit;
                        AppraisalStatusChange.SendAppraisaBackToAppraisee(Rec."No.", Rec."Employee No", true, '', '');
                    end;
                end;
            }
            action("Send To Overview Manager")
            {
                ApplicationArea = Basic, Suite;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = SendToOverviewVisible;

                trigger OnAction()
                begin
                    if Rec.Sequence = 0 then begin
                        if not Confirm('Are you sure you want to send it back to overview manager?')then exit;
                        AppraisalStatusChange.SendGoalSettingToOverview(Rec."No.", Rec."Employee No", true, '');
                    end;
                    if Rec.Sequence <> 0 then begin
                        if not Confirm('Are you sure you want to send it back to overview manager?')then exit;
                        AppraisalStatusChange.SendAppraisalToOverViewManager(Rec."No.", Rec."Employee No", true, '');
                    end;
                end;
            }
            action("Send Back To Line Manager")
            {
                ApplicationArea = Basic, Suite;
                Image = Return;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = SendBackToLineVisible;

                trigger OnAction()
                begin
                    if(Rec.Sequence = 0)then begin
                        if not Confirm('Are you sure you want to send it back Line manager?')then exit;
                        AppraisalStatusChange.SendGoalSettingBackToLineManager(Rec."No.", Rec."Employee No", true, '', '');
                    end;
                    if(Rec.Sequence <> 0)then begin
                        if not Confirm('Are you sure you want to send it back Line manager?')then exit;
                        AppraisalStatusChange.SendAppraisaBackLineManager(Rec."No.", Rec."Employee No", true, '', '');
                    end;
                end;
            }
            action("Send To Appraisee For Agreement")
            {
                ApplicationArea = Basic, Suite;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = SendToAgreementVisible;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to send it to appraisee for agreement')then exit;
                    AppraisalStatusChange.SendAppraisalToAgreementLevel(Rec."No.", Rec."Employee No", true, '');
                end;
            }
            action(Approve)
            {
                ApplicationArea = Basic, Suite;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ApproveVisible;

                trigger OnAction()
                begin
                    if((Rec.Sequence = 0) and (Rec.Status in[Rec.Status::"Overview Manager Level"]))then begin
                        if not Confirm('Are you sure you want to approve?')then exit;
                        AppraisalStatusChange.ApproveGoalSetting(Rec."No.", Rec."Employee No", true);
                    end;
                    if((Rec.Sequence <> 0) And (Rec.Status in[Rec.Status::"Overview Manager Level"]))then begin
                        if not Confirm('Are you sure you want to approve?')then exit;
                        AppraisalStatusChange.ApproveAppraisal(Rec."No.", Rec."Employee No", true, '');
                    end;
                end;
            }
        }
    }
    trigger OnInit()
    begin
        SendBackToAppraiseeVisible:=false;
        SendBackToLineVisible:=false;
        SendToAgreementVisible:=false;
        ActionVisible:=false;
        ApproveVisible:=false;
        SendToLineVisible:=false;
        SendToOverviewVisible:=false;
        ActionEditable:=false;
        TrainingVisible:=false;
    end;
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance();
    end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance();
    end;
    trigger OnOpenPage()
    var
        varScore: Decimal;
    begin
        ControlPageAppearance();
        AppraisalObjectivesKRAs.Reset();
        AppraisalObjectivesKRAs.SetRange("Appraisal No", Rec."No.");
        AppraisalObjectivesKRAs.SetRange("Employee No", Rec."Employee No");
        if AppraisalObjectivesKRAs.FindSet then begin
            varScore:=0;
            repeat AppraisalObjectivesKRAs.CalcFields("Agreed Rating");
                varScore:=varScore + AppraisalObjectivesKRAs."Agreed Rating";
            until AppraisalObjectivesKRAs.Next = 0;
            Rec."Overall Score":=varScore;
            AppraisalRatings.Reset;
            AppraisalRatings.SetCurrentKey(Code);
            AppraisalRatings.SetAscending(Code, true);
            if AppraisalRatings.FindSet then begin
                repeat if((Rec."Overall Score" <> 0) and (Rec."Overall Score" >= AppraisalRatings."Lower Limit") and (Rec."Overall Score" <= AppraisalRatings."Upper Limit"))then Rec."Overall Rating":=AppraisalRatings.Description;
                until AppraisalRatings.Next = 0;
            end;
            Rec.Modify;
        end;
    end;
    var AppraisalStatusChange: Codeunit "Appraisal Management";
    AppraisalObjectivesKRAs: Record "Appraisal Objectives/KRAs";
    AppraisalRatings: Record "Appraisal Ratings";
    SendToLineVisible: Boolean;
    SendBackToAppraiseeVisible: Boolean;
    SendToOverviewVisible: Boolean;
    SendBackToLineVisible: Boolean;
    ApproveVisible: Boolean;
    SendToAgreementVisible: Boolean;
    TrainingVisible: Boolean;
    ActionVisible: Boolean;
    ActionEditable: Boolean;
    IsPageEditable: Boolean;
    LoginMgmt: Codeunit "User Management Ext";
    local procedure ControlPageAppearance()
    begin
        if Rec.Status in[Rec.Status::"Appraisee Level"]then SendToLineVisible:=true;
        if((Rec.Sequence = 0) and (Rec.Status in[Rec.Status::"Appraiser Level"]))then begin
            SendBackToAppraiseeVisible:=true;
            SendToOverviewVisible:=true;
            TrainingVisible:=true;
            ActionVisible:=true;
        end;
        if((Rec.Sequence <> 0) and (Rec.Status in[Rec.Status::"Appraiser Level"]) and (Rec."Appraisee Agreed" = false))then begin
            SendBackToAppraiseeVisible:=true;
            SendToAgreementVisible:=true;
            TrainingVisible:=true;
            ActionVisible:=true;
        end;
        if((Rec.Sequence <> 0) And (Rec.Status = Rec.Status::"Agreement Level"))then begin
            SendBackToLineVisible:=true;
        end;
        if((Rec.Sequence <> 0) And (Rec.Status = Rec.Status::"Appraiser Level") and (Rec."Appraisee Agreed" = true))then begin
            SendToAgreementVisible:=true;
            SendToOverviewVisible:=true;
            TrainingVisible:=true;
            ActionVisible:=true;
        end;
        if Rec.Status = Rec.Status::"Overview Manager Level" then begin
            SendBackToLineVisible:=true;
            ApproveVisible:=true;
            ActionVisible:=true;
        end;
        if((Rec.Sequence <> 0) And (Rec.Status in[Rec.Status::Closed]))then begin
            TrainingVisible:=true;
            ActionVisible:=true;
        end;
        if not LoginMgmt.IsWebServiceUser then IsPageEditable:=true
        else
            IsPageEditable:=false;
    end;
}
