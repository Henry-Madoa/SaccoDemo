page 52203733 "Appraisal Objectives/KRAs"
{
    DeleteAllowed = true;
    InsertAllowed = true;
    PageType = ListPart;
    SourceTable = "Appraisal Objectives/KRAs";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Visible = false;
                }
                field("Appraisal No"; Rec."Appraisal No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Perspective/Pillar"; Rec."Perspective/Pillar")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("KRA/Objective"; Rec."KRA/Objective")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Weight"; Rec."Maximum Weight")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Weigth"; Rec."Total Weigth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Agreed Rating"; Rec."Agreed Rating")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Activity")
            {
                ApplicationArea = Basic, Suite;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Appraisal Activities";
                RunPageLink = "Kra Line No"=FIELD("Line No"), "Appraisal No"=FIELD("Appraisal No"), "Employee No"=FIELD("Employee No");
            }
            action("Overview Manager Comments")
            {
                ApplicationArea = Basic, Suite;
                Image = Comment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "OverView Manager Comments";
                RunPageLink = "Employee No"=FIELD("Employee No"), "Appraisal No"=FIELD("Appraisal No");
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ControlAppearance end;
    trigger OnAfterGetRecord()
    begin
        ControlAppearance end;
    trigger OnOpenPage()
    begin
        ControlAppearance;
    end;
    var KraEditable: Boolean;
    PIPVisible: Boolean;
    PIPEditable: Boolean;
    local procedure ControlAppearance()
    var
        AppraisalHeader: Record "Appraisal Header";
    begin
        if AppraisalHeader.Get(Rec."Appraisal No")then begin
            if((AppraisalHeader.Sequence = 0) and (AppraisalHeader.Status in[AppraisalHeader.Status::"Appraisee Level"]))then KraEditable:=true
            else
                KraEditable:=false;
            if((AppraisalHeader.Sequence = 4) and (AppraisalHeader.Status in[AppraisalHeader.Status::"Agreement Level"]))then PIPEditable:=true
            else
                PIPEditable:=false;
            if((AppraisalHeader.Sequence = 4) and not(AppraisalHeader.Status in[AppraisalHeader.Status::"Agreement Level", AppraisalHeader.Status::Closed]))then PIPVisible:=false
            else
                PIPVisible:=true;
        end;
    end;
}
