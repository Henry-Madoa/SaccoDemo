page 52203724 "Salary Scale Pointers"
{
    PageType = ListPart;
    SourceTable = "Salary Scale Pointers";
    SourceTableView = SORTING(Sequence)ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Scale; Rec.Scale)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Pointer; Rec.Pointer)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Basic Pay"; Rec."Basic Pay")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sequence; Rec.Sequence)
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
            action("Income & Deduction Configuartion")
            {
                ApplicationArea = Basic, Suite;
                Image = Column;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Income/Deduction Configuarion";
                RunPageLink = Scale=FIELD(Scale), Pointer=FIELD(Pointer);
            }
        }
    }
}
