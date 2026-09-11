page 52203672 "CoC Delegation Dialog"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("Employee No"; EmployeeNo)
            {
                TableRelation = Employee."No.";
            }
        }
    }
    var EmployeeNo: Code[20];
    procedure GetEmployeeNo(): Code[20]begin
        exit(EmployeeNo);
    end;
}
