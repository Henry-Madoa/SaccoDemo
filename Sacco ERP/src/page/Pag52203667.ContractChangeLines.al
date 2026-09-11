page 52203667 "Contract Change Lines"
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
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Period"; Rec."Contract Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Employee Title"; Rec."Employee Title")
                {
                    ApplicationArea = Basic, Suite;
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
                    Editable = true;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field(Salary; Rec.Salary)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("New Salary"; Rec."New Salary")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Code"; Rec."Job Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("History Conditions")
            {
                Enabled = OldGrantEnabled;

                action("Grant Details")
                {
                    ApplicationArea = BasicHR;
                    Image = Hierarchy;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    RunObject = Page "Employee Donors";
                    RunPageLink = "Contract Line No"=FIELD("Line No"), "Employee No"=FIELD("Employee No");
                }
            }
            group("New Conditions")
            {
                Enabled = GrantEnabled;

                action("New Grant Details")
                {
                    ApplicationArea = BasicHR;
                    Image = Hierarchy;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "New Employee Donors";
                    RunPageLink = "Employee No"=FIELD("Employee No"), "Contract Line No"=FIELD("Line No"), "Contract Code"=FIELD("Contract Code");
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.Status:=Rec.Status::New;
    end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance end;
    var GrantEnabled: Boolean;
    OldGrantEnabled: Boolean;
    local procedure ControlPageAppearance()
    begin
        if(Rec."Contract End Date" <> 0D) and (Rec.Status in[Rec.Status::New])then GrantEnabled:=true
        else
            GrantEnabled:=false;
        if(Rec."Contract End Date" <> 0D) and (Rec.Status in[Rec.Status::Current])then OldGrantEnabled:=true
        else
            OldGrantEnabled:=false;
    end;
}
