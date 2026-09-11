page 52203740 "Appraisal Setup List"
{
    CardPageID = "Appraisal Ratings";
    PageType = List;
    SourceTable = "Appraisal Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Appraisal Code"; Rec."Appraisal Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Description"; Rec."Appraisal Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Running Period"; Rec."Running Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max KRA Weight"; Rec."Max KRA Weight")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Appraisals"; Rec."Total Appraisals")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approved Appraisals"; Rec."Approved Appraisals")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
