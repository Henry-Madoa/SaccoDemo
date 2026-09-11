page 52203442 "HR Leave Jnl. Template List"
{
    Caption = 'Leave Jnl. Template List';
    Editable = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Template';
    SourceTable = "Leave Journal Template";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Form ID"; Rec."Form ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Form Name"; Rec."Form Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
