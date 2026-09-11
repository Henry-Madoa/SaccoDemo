tableextension 52203433 "Maintenance Registration" extends "Maintenance Registration"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Next Service Date"; Date)
        {
            trigger OnValidate()
            begin
                //Update next service date for fixed asset
                /*if FA.Get("FA No.") then begin
                        FA."Next Service Date" := "Next Service Date";
                        FA.Modify(true);
                    end;*/
            end;
        }
    }
    var
        FA: Record "Fixed Asset";
        MainReg: Record "Maintenance Registration";
}
