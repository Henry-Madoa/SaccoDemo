tableextension 52203451 "JobPlanning Line" extends "Job Planning Line"
{
    fields
    {
        field(50423; "Posting Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Approved,Approval Pending,Committed,Disapproved,,,,,Fulfilled,Canceled';
            OptionMembers = New,Approved,"Approval Pending",Committed,Disapproved,,,,,Fulfilled,Canceled;
        }
        field(50424; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(50425; Reversed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
