pageextension 52203469 "G/L Budget Entry" extends "G/L Budget Entries"
{
    layout
    {
        // Add changes to page layout here
        modify(Amount)
        {
            trigger OnAssistEdit()
            begin
                BudgetPlanLines.Reset();
                BudgetPlanLines.SetRange("Global Dimension 1 Code", Rec."Global Dimension 1 Code");
                BudgetPlanLines.SetRange("Global Dimension 2 Code", Rec."Global Dimension 2 Code");
                BudgetPlanLines.SetRange("Budget Line Account", Rec."G/L Account No.");
                Page.Run(Page::"Budget Plan Lines", BudgetPlanLines);
            end;
        }
    }
    var
        BudgetPlanLines: Record "Budget Plan Lines";
}
