page 52203647 "Exit Mode"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    //SourceTable = TableName;
    RefreshOnActivate = true;
    Caption = 'Employee Exit Mode';

    layout
    {
        area(Content)
        {
            usercontrol(Chart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic, Suite;

                trigger AddInReady()
                var
                    Buffer: Record "Business Chart Buffer";
                    TerminationGround: Record "Grounds for Termination";
                    Employee: Record Employee;
                    Teminated: Integer;
                    Retired: Integer;
                    Resigned: Integer;
                    i: Integer;
                begin
                    Buffer.Initialize();
                    Buffer.AddMeasure('Employees', 0, Buffer."Data Type"::Integer, Buffer."Chart Type"::Column);
                    buffer.SetXAxis('Termination Grounds', Buffer."Data Type"::String);
                    TerminationGround.Reset();
                    TerminationGround.SetRange(Code, Employee."Grounds for Term. Code");
                    if TerminationGround.FindSet()then repeat Employee.Reset();
                            Employee.SetRange("Grounds for Term. Code", 'TERMINATE');
                            Teminated:=Employee.Count;
                            Employee.Reset();
                            Employee.SetRange("Grounds for Term. Code", 'RESIGN');
                            Resigned:=Employee.Count;
                            Employee.Reset();
                            Employee.SetRange("Grounds for Term. Code", 'RETIRE');
                            Retired:=Employee.Count;
                            Buffer.AddColumn(TerminationGround.Description);
                            IF Teminated <> 0 then Buffer.SetValueByIndex(0, i, Resigned);
                            if Resigned <> 0 then Buffer.SetValueByIndex(0, i, Teminated);
                            if Retired <> 0 then Buffer.SetValueByIndex(0, i, Retired);
                            i+=1;
                        until TerminationGround.Next() = 0;
                    Buffer.Update(CurrPage.Chart);
                end;
            }
        }
    }
}
