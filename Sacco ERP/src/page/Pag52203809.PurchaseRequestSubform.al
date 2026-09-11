page 52203809 "Purchase Request Subform"
{
    PageType = ListPart;
    SourceTable = "Requisition Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                    // case Rec.Type of
                    //     Rec.Type::"Fixed Asset":
                    //         begin
                    //             EditNo := false;
                    //             EditName := true
                    //         end;
                    //     Rec.Type::"G/L Account":
                    //         begin
                    //             EditNo := true;
                    //             EditName := false;
                    //         end;
                    //     Rec.Type::Item:
                    //         begin
                    //             EditNo := true;
                    //             EditName := false;
                    //         end;
                    // end;
                    end;
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Name/Description';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Part Number';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Estimate Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Estimate Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                // field("Grant No."; Rec."Grant No.")
                // {
                //     ApplicationArea = All;
                // }
                // field("Objective Code"; Rec."Objective Code")
                // {
                //     ApplicationArea = All;
                // }
                // field("Activity Code"; Rec."Activity Code")
                // {
                //     ApplicationArea = All;
                // }
                // field("Partner Code"; Rec."Partner Code")
                // {
                //     ApplicationArea = All;
                // }
                field("Commitment Amount"; Rec."Commitment Amount")
                {
                    ApplicationArea = All;
                }
                field("Budget Amount"; Rec."Budget Amount")
                {
                    ApplicationArea = All;
                }
                field("Used Amount"; Rec."Used Amount")
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnAfterGetRecord()
    begin
    //        ShowShortcutDimCode(ShortcutDimCode);
    end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
    //        ShowShortcutDimCode(ShortcutDimCode);
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Validate(Type);
    end;
    trigger OnOpenPage()
    begin
    // EditNo := true;
    // case Rec.Type of
    //     Rec.Type::"Fixed Asset":
    //         begin
    //             EditNo := false;
    //             EditName := true
    //         end;
    //     Rec.Type::Service:
    //         begin
    //             EditNo := true;
    //             EditName := false;
    //         end;
    //     Rec.Type::Item:
    //         begin
    //             EditNo := true;
    //             EditName := false;
    //         end;
    // end;
    end;
    var RequisitionLines: Record "Requisition Lines";
    EditNo: Boolean;
    EditName: Boolean;
    ShortcutDimCode: array[8]of Code[20];
    local procedure ValidateSaveShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        //        ValidateShortcutDimCode(FieldNumber,ShortcutDimCode);
        CurrPage.SaveRecord;
    end;
    procedure SetVisibility()
    var
        RequisitionHeader: Record "Requisition Header";
        IsVisible: Boolean;
    begin
        RequisitionHeader.Reset;
        RequisitionHeader.SetRange("No.", Rec."Requisition No");
        if RequisitionHeader.FindFirst then begin
        // if RequisitionHeader."Transaction Type" = RequisitionHeader."Transaction Type"::Fees then
        //     IsVisible := true;
        end;
    end;
}
