page 52203539 "New Contract Lines"
{
    PageType = ListPart;
    SourceTable = "Contract Change Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Contract Code"; Rec."Contract Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Period"; Rec."Contract Period")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Probation Period"; Rec."Probation Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Probation Notice Period"; Rec."Probation Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Title"; Rec."Employee Title")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Line Manager"; Rec."Line Manager")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Manager Name"; Rec."Manager Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Pointer; Rec.Pointer)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Salary; Rec.Salary)
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
            group(Conditions)
            {
                action("Contract Grants")
                {
                    ApplicationArea = BasicHR;
                    Enabled = GrantEnabled;
                    Image = Bank;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "New Employee Donors";
                    RunPageLink = "Employee No"=FIELD("Employee No"), "Contract Line No"=FIELD("Line No"), "Contract Code"=FIELD("Contract Code"), "Change No"=FIELD("Change No");
                }
            }
        }
    }
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
    var GrantEnabled: Boolean;
    local procedure ControlAppearance()
    begin
        if Rec."Contract End Date" <> 0D then GrantEnabled:=true
        else
            GrantEnabled:=false;
    end;
}
