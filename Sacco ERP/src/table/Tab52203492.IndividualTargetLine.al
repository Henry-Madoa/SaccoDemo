table 52203492 "Individual Target Line"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No"; Code[50])
        {
            TableRelation = "Individual Targets Header"."Appraisal No";
        }
        field(3; "Perspective Code"; Integer)
        {
            trigger OnValidate()
            begin
                CalcFields("Perspective Description");
            end;
        }
        field(4; "Perspective Description"; Text[250])
        {
        // CalcFormula = Lookup(Table39003999.Field2 WHERE (Field1=FIELD("Perspective Code")));
        // FieldClass = FlowField;
        }
        field(5; "Targeted Score"; Decimal)
        {
            trigger OnValidate()
            begin
                "Unachieved Targets":="Targeted Score" - "Achieved Score";
                Change:="Targeted Score" - Baseline;
            end;
        }
        field(6; "Perspective Type"; Option)
        {
            OptionCaption = ' ,Service Delivery,Financial Stewardship,Training and Development,Customer and Sales';
            OptionMembers = " ", "Service Delivery", "Financial Stewardship", "Training and Development", "Customer and Sales";
        }
        field(7; "Achieved Score"; Decimal)
        {
            trigger OnValidate()
            begin
                "Unachieved Targets":="Targeted Score" - "Achieved Score";
                if("Targeted Score" <> 0) and ("Achieved Score" <> 0)then Score:=(("Achieved Score" / "Targeted Score") * 100)end;
        }
        field(8; "Unachieved Targets"; Decimal)
        {
        }
        field(9; "Appraisee Comments"; Text[250])
        {
        }
        field(10; Objective; Text[250])
        {
        }
        field(11; "Company Target"; Code[50])
        {
        }
        field(12; "Start Date"; Date)
        {
        }
        field(13; "End Date"; Date)
        {
        }
        field(14; "Self Rating"; Decimal)
        {
            MaxValue = 5;
        }
        field(15; "Supervisor Rating"; Decimal)
        {
            MaxValue = 5;
        }
        field(16; "Agreed Rating"; Decimal)
        {
            MaxValue = 5;

            trigger OnValidate()
            begin
                BSCHead.Reset;
                BSCHead.SetRange(BSCHead."Appraisal No", "Appraisal No");
                if BSCHead.Find('-')then begin
                    BSCHead.CalcFields("Finance Rating", "Customer Rating", "Training Rating", "Service Rating", Customer, Training, Service, Finance);
                    if(BSCHead."Finance Rating" <> 0) and (BSCHead.Finance <> 0)then BSCHead."Finance Perc Score":=(BSCHead."Finance Rating" * 25) / (BSCHead.Finance * 5);
                    if(BSCHead."Customer Rating" <> 0) and (BSCHead.Customer <> 0)then BSCHead."Customer Perc Score":=(BSCHead."Customer Rating" * 25) / (BSCHead.Customer * 5);
                    if(BSCHead."Training Rating" <> 0) and (BSCHead.Training <> 0)then BSCHead."Training Perc Score":=(BSCHead."Training Rating" * 25) / (BSCHead.Training * 5);
                    if(BSCHead."Service Rating" <> 0) and (BSCHead.Service <> 0)then BSCHead."Service Perc Score":=(BSCHead."Service Rating" * 25) / (BSCHead.Service * 5);
                    BSCHead."Overall Perc Score":=BSCHead."Finance Perc Score" + BSCHead."Customer Perc Score" + BSCHead."Training Perc Score" + BSCHead."Service Perc Score";
                    BSCHead.Modify;
                end end;
        }
        field(17; "Appraisal Period"; Code[20])
        {
        }
        field(18; "Appraisal Type"; Option)
        {
            OptionCaption = 'Target Setting,Quarter 1,Appraisal Review,Quarter 3,End Year Appraisal';
            OptionMembers = "Target Setting", "Quarter 1", "Appraisal Review", "Quarter 3", "End Year Appraisal";
        }
        field(19; Status; Option)
        {
            OptionCaption = 'Open,Pending Approval,Discussed,Approved,Posted';
            OptionMembers = Open, "Pending Approval", Discussed, Approved, Posted;
        }
        field(20; "Appraiser Comments"; Text[250])
        {
        }
        field(21; "Review Line Reference"; Text[30])
        {
        }
        field(22; Score; Decimal)
        {
        }
        field(23; test; Text[30])
        {
        }
        field(24; Strategy; Text[250])
        {
        }
        field(25; Measures; Text[250])
        {
        }
        field(26; Baseline; Decimal)
        {
        }
        field(27; Change; Decimal)
        {
        }
        field(28; "Agreed Mid Year Rating"; Decimal)
        {
        }
        field(29; "Agreed End Year Rating"; Decimal)
        {
            trigger OnValidate()
            begin
                "Agreed Rating":="Agreed End Year Rating";
            end;
        }
        field(30; "Mid Year Self Rating"; Decimal)
        {
        }
        field(31; "Mid Year Supervisor Rating"; Decimal)
        {
        }
        field(32; "Quarter 1"; Decimal)
        {
        }
        field(33; "Quarter 3"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Line No", "Appraisal No", "Perspective Code")
        {
        }
    }
    var BSCHead: Record "Individual Targets Header";
}
