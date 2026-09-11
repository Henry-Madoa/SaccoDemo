page 52203913 "Procurement Plan Initiation"
{
    PageType = List;
    SourceTable = "Procurement Plan Initiation";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plan Name"; Rec."Plan Name")
                {
                    ApplicationArea = All;
                    Editable = PlanNameEditable;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    ApplicationArea = All;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Initiate Plan")
            {
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Initiated, false);
                    Rec.TestField("Plan Name");
                    Rec.TestField("Current Budget");
                    Rec.TestField("Financial Year");
                    if not Confirm('Are you sure you want to initiate procurement plan?')then exit;
                    ProcStoreManagement.IanInitateProcurementplan(Rec);
                end;
            }
        }
    }
    var UserSetup: Record "User setup";
    trigger OnAfterGetCurrRecord()
    begin
        IanControlPageAppearance;
        UserSetup.GET(USERID);
        IF NOT UserSetup."Procurement Admin" THEN BEGIN
            Rec.SetRange("Employee No", UserSetup."Employee No.");
        end;
    end;
    trigger OnAfterGetRecord()
    begin
        IanControlPageAppearance;
    end;
    trigger OnOpenPage()
    begin
        IanControlPageAppearance;
        UserSetup.GET(USERID);
        IF NOT UserSetup."Procurement Admin" THEN BEGIN
            Rec.SetRange("Employee No", UserSetup."Employee No.");
        end;
    end;
    var ProcStoreManagement: Codeunit "Proc & Store Management";
    PlanNameEditable: Boolean;
    local procedure IanControlPageAppearance()
    begin
        if Rec.Initiated then PlanNameEditable:=false
        else
            PlanNameEditable:=true;
    end;
}
