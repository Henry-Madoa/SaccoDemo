page 52203806 "Store Requisition Subform"
{
    Caption = 'Store Requisition Subform';
    PageType = ListPart;
    SourceTable = "Requisition Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No; Rec."No.")
                {
                    ApplicationArea = All;

                    //  Editable = Qtyrequested;
                    trigger OnValidate()
                    begin
                    //      FnShowLease;
                    end;
                }
                field(Name; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = Qtyrequested;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = Qtyrequested;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = Qtyrequested;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Qtyrequested;
                }
                field("Available Quantity"; Rec."Available Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Requested';
                    Editable = Qtyrequested;
                }
                field("Asset No."; Rec."Asset No.")
                {
                    ApplicationArea = All;
                }
                // field("Part No."; Rec."Part No.")
                // {
                //     ApplicationArea = All;
                // }
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
                field("Qty. to Issue"; Rec."Qty. to Issue")
                {
                    ApplicationArea = All;
                    Editable = QtytoIssue;
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = All;
                }
            }
            group("Lease Details")
            {
                Visible = ShowLease;

                field("FA Transaction Type"; Rec."FA Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Lease Period(Months=M,Years=Y)"; Rec."Lease Period(Months=M,Years=Y)")
                {
                    ApplicationArea = All;
                }
                field("Lease Start Date"; Rec."Lease Start Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnAfterGetCurrRecord()
    begin
        FnShowLease;
        FnShowQty(Rec."Requisition No");
        FnShowIssue;
    end;
    trigger OnOpenPage()
    begin
        FnShowQty(Rec."Requisition No");
        FnShowIssue;
    end;
    var ShowLease: Boolean;
    Qtyrequested: Boolean;
    QtytoIssue: Boolean;
    RequisitionHeader: Record "Requisition Header";
    local procedure FnShowLease()
    begin
        ShowLease:=false;
        if Rec.Type = Rec.Type::"Fixed Asset" then ShowLease:=true;
    end;
    local procedure FnShowQty(DocN: Code[20])
    begin
        Qtyrequested:=false;
        if RequisitionHeader.Get(Rec."Requisition No")then begin
            if RequisitionHeader.Status = RequisitionHeader.Status::Open then Qtyrequested:=true;
        end;
    end;
    local procedure FnShowIssue()
    begin
        QtytoIssue:=false;
        if RequisitionHeader.Get(Rec."Requisition No")then begin
            if RequisitionHeader.Status = RequisitionHeader.Status::Approved then QtytoIssue:=true;
        end;
    end;
}
