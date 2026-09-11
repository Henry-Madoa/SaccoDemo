xmlport 52203432 "Budget"
{
    Format = VariableText;
    Direction = Both;
    UseRequestPage = true;

    schema
    {
    textelement(Root)
    {
    tableelement(BudgetPlanLines;
    "Budget Plan Lines")
    {
    XmlName = 'ImportBudgetLines';

    fieldelement(DocNo;
    BudgetPlanLines."Document No")
    {
    }
    fieldelement(Date;
    BudgetPlanLines.Date)
    {
    }
    fieldelement(Account;
    BudgetPlanLines."Budget Line Account")
    {
    }
    fieldelement(Description;
    BudgetPlanLines.Description)
    {
    }
    fieldelement(PeriodType;
    BudgetPlanLines."Period Type")
    {
    }
    fieldelement(Amount;
    BudgetPlanLines.Amount)
    {
    }
    }
    }
    }
    // requestpage
    // {
    //     layout
    //     {
    //         area(content)
    //         {
    //             group(GroupName)
    //             {
    //                 field(Name; SourceExpression)
    //                 {
    //                 }
    //             }
    //         }
    //     }
    //     actions
    //     {
    //         area(processing)
    //         {
    //             action(ActionName)
    //             {
    //             }
    //         }
    //     }
    // }
    var myInt: Integer;
    trigger OnPostXmlPort();
    begin
        MESSAGE('Uploaded Successfully');
    end;
    trigger OnPreXmlPort()
    begin
        ClearAll();
    end;
}
