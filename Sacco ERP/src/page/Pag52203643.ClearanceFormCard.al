page 52203643 "Clearance Form Card"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Exit Clearance Form";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = not IsPageEditable;

                field("Form No"; Rec."Form No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exit No"; Rec."Exit No")
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
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Dues; Rec.Dues)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("HOD Comments"; Rec."HOD Comments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor Comments"; Rec."Supervisor Comments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("HR Comments"; Rec."HR Comments")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(ExitClearanceFormLines; "Exit Clearance Form Lines")
            {
                UpdatePropagation = Both;
                Editable = not IsPageEditable;
                SubPageLink = "Exit No"=FIELD("Exit No"), "Employee No"=FIELD("Employee No");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(Send)
            {
                action("Send To Sections")
                {
                    ApplicationArea = BasicHR;
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to send it to Sections?')then exit;
                        EmployeeExitManagement.SendExitClearanceFormToSections(Rec."Exit No", Rec."Form No", true, '');
                    end;
                }
                action(Clear)
                {
                    ApplicationArea = BasicHR;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Enabled = not Rec.Cleared;

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to clear the employee?')then exit;
                        EmployeeExitManagement.ClearSection(Rec."Exit No", Rec."Form No", true, '');
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;
    var EmployeeExitManagement: Codeunit "Employee Exit Management";
    LoginMgmt: Codeunit "User Management Ext";
    IsPageEditable: Boolean;
    local procedure SetControlAppearance()
    begin
        if LoginMgmt.IsWebServiceUser then IsPageEditable:=true
        else
            IsPageEditable:=false;
    end;
}
