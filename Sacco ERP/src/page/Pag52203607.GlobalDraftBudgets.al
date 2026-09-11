page 52203607 "Global Draft Budgets"
{
    // version BUDGETCaption = 'Draft Budget Names';
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    PageType = List;
    SourceTable = "G/L Budget Name";
    SourceTableView = WHERE(Status=CONST(Open));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Name; Rec.Name)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the general ledger budget.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the general ledger budget name.';
                }
                field("Budget Dimension 1 Code"; Rec."Budget Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a code for a budget dimension. You can specify four additional dimensions on each budget that you create.';
                }
                field("Budget Dimension 2 Code"; Rec."Budget Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a code for a budget dimension. You can specify four additional dimensions on each budget that you create.';
                }
                field("Budget Dimension 3 Code"; Rec."Budget Dimension 3 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a code for a budget dimension. You can specify four additional dimensions on each budget that you create.';
                }
                field("Budget Dimension 4 Code"; Rec."Budget Dimension 4 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a code for a budget dimension. You can specify four additional dimensions on each budget that you create.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies that entries cannot be created for the budget. ';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(EditBudget)
            {
                ApplicationArea = Suite;
                Caption = 'Edit Budget';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                ToolTip = 'Specify budgets that you can create in the general ledger application area. If you need several different budgets, you can create several budget names.';

                trigger OnAction()
                var
                    Budget: Page "Global Draft Budget View";
                begin
                    Budget.SetBudgetName(Rec.Name);
                    Budget.Run;
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status:=Rec.Status::Open;
    end;
    procedure GetSelectionFilter(): Text var
        GLBudgetName: Record "G/L Budget Name";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(GLBudgetName);
        exit(SelectionFilterManagement.GetSelectionFilterForGLBudgetName(GLBudgetName));
    end;
}
