table 52203433 "Leave Types"
{
    DrillDownPageID = "Leave Types Setup";
    LookupPageID = "Leave Types Setup";

    fields
    {
        field(1; "Code"; Code[40])
        {
            NotBlank = true;
        }
        field(2; Description; Text[200])
        {
        }
        field(3; Days; Decimal)
        {
        }
        field(4; "Acrue Days"; Boolean)
        {
        }
        field(5; "Unlimited Days"; Boolean)
        {
        }
        field(6; Gender; Option)
        {
            OptionMembers = Male, Female, Both;
        }
        field(7; Balance; Option)
        {
            OptionMembers = Ignore, "Carry Forward", "Convert to Cash";
        }
        field(8; "Inclusive of Holidays"; Boolean)
        {
        }
        field(9; "Inclusive of Saturday"; Boolean)
        {
        }
        field(10; "Inclusive of Sunday"; Boolean)
        {
        }
        field(11; "Off/Holidays Days Leave"; Boolean)
        {
        }
        field(12; "Max Carry Forward Days"; Decimal)
        {
        }
        field(13; "Inclusive of Non Working Days"; Boolean)
        {
        }
        field(14; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(15; "Carry Forward Allowed"; Boolean)
        {
        }
        field(16; "Fixed Days"; Boolean)
        {
        }
        field(17; "Minimum Months"; DateFormula)
        {
            Caption = 'Minimum Months of Service (e.g. 3M)';
        }
        field(18; "Is Annual Leave"; Boolean)
        {
            trigger OnValidate()
            begin
                LeaveTypes.Reset;
                LeaveTypes.SetRange("Is Annual Leave", true);
                if LeaveTypes.FindFirst then Error('Leave type %1 has already been marked as annual');
            end;
        }
        field(19; Disabled; Boolean)
        {
        }
        field(20; "Days To Accrue"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Period Length"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Leave Day Worth($$)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Leave Balance Notification"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Special Categorization"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Compasionate,Sick,Partenity,Martenity,Unpaid,Study,CPD,Compensatory';
            OptionMembers = " ", Compasionate, Sick, Partenity, Martenity, Unpaid, Study, CPD, Compensatory;
        }
        field(25; "Max Applicable Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Requires Attachment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Check Leave Balance"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Is Sick Leave"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
    var LeaveTypes: Record "Leave Types";
}
