page 52203755 "New Emp. Appraisal Card"
{
    DeleteAllowed = false;
    InsertAllowed = true;
    PageType = Card;
    SourceTable = "Appraisal Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = true;

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
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor User Id"; Rec."Supervisor User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee User Id"; Rec."Employee User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor No"; Rec."Supervisor No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Hr UserId"; Rec."Hr UserId")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("New Emp. App. Status"; Rec."New Emp. App. Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Action Taken"; Rec."Action Taken")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Probation Extended"; Rec."Probation Extended")
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
            action("Submit for Approval")
            {
                ApplicationArea = Basic, Suite;
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                // IF CONFIRM('Do you Want to Submit the Appraisal for Approval?') THEN
                // AppraisalManagement.SubmitAppraisal(Rec);
                end;
            }
        }
    }
}
