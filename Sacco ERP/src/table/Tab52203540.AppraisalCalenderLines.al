table 52203540 "Appraisal Calender Lines"
{
    fields
    {
        field(1; "Calender Code"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "End Date" <> 0D then begin
                    StartMonthName:=Format("Start Date", 0, '<Month Text>');
                    EndMonthName:=Format("End Date", 0, '<Month Text>');
                    StartDateYear:=Format(Date2DMY("Start Date", 3));
                    EndDateYear:=Format(Date2DMY("End Date", 3));
                    if StartDateYear = EndDateYear then begin
                        if StartMonthName = EndMonthName then "Period Name":=StartMonthName + '-' + StartDateYear;
                        if StartMonthName <> EndMonthName then "Period Name":=StartMonthName + '/' + EndMonthName + '-' + StartDateYear end;
                    if StartDateYear <> EndDateYear then begin
                        if StartMonthName = EndMonthName then "Period Name":=StartMonthName + '-' + StartDateYear;
                        if StartMonthName <> EndMonthName then "Period Name":=StartMonthName + '-' + StartDateYear + '/' + EndMonthName + '-' + StartDateYear end;
                end
                else
                    "Period Name":='';
            end;
        }
        field(4; "Current Period"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Closed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Closed On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Closed By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Opened; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Opened On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Opened By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Period Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Calender Code")
        {
        }
    }
    var StartMonthName: Text;
    EndMonthName: Text;
    StartDateYear: Text;
    EndDateYear: Text;
}
