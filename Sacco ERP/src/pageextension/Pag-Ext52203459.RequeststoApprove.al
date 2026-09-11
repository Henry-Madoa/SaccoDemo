pageextension 52203459 "Requests to Approve" extends "Requests to Approve"
{
    layout
    {
        // Add changes to page layout here
        modify(ToApprove)
        {
            trigger OnAssistEdit()
            begin
                Rec.ShowRecord;
            end;
        }
    }
    actions
    {
        // Add changes to page actions here
        modify(Approve)
        {
            Enabled = false;
        }
        modify(Reject)
        {
            Enabled = false;
        }
        modify(Delegate)
        {
            Enabled = false;
        }
    }
}
