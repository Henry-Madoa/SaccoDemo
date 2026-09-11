page 52203851 "RFP Lines Subform"
{
    PageType = ListPart;
    SourceTable = "Procurement Request Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            // field("Car Repair/Maintenance"; Rec."Car Repair/Maintenance")
            // {
            //     ApplicationArea = All;
            //     Editable = false;
            // }
            // field("Vehicle Reg. No"; Rec."Vehicle Reg. No")
            // {
            //     ApplicationArea = All;
            //     Editable = false;
            // }
            }
        }
    }
    actions
    {
    }
}
