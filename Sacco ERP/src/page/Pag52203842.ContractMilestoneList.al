page 52203842 "Contract Milestone List"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Contract Milestone";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Milestone Code"; Rec."Milestone Code")
                {
                    ApplicationArea = All;
                }
                field("Milestone Description"; Rec."Milestone Description")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field(Period; Rec.Period)
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
                field("Is Percentage"; Rec."Is Percentage")
                {
                    ApplicationArea = All;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = All;
                }
                field("Fixed Amount"; Rec."Fixed Amount")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Name"; Rec."Item Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Order")
            {
                Image = "Order";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField("Order Created", false);
                    if Rec."Is Percentage" then Rec.TestField(Percentage);
                    if Rec."Fixed Amount" then Rec.TestField(Amount);
                    if not Confirm('Are you sure you want to create an order form ' + Format(Rec."Milestone Code") + ' ?')then exit;
                    if ContractHeader.Get(Rec."Contract No")then OrderNo:=ProcStoreManagement.IanCreatePurchaseHeader(ContractHeader."Vendor No.", ContractHeader."Tender No.", ContractHeader."Requisition No", '', ContractHeader."Tender No.", Rec."Contract No", false, '', '', '', Rec."Milestone Description", ContractHeader."Delivery Period (Days)");
                    if OrderNo = '' then exit;
                    ContractLines.Reset;
                    ContractLines.SetRange("Line No.", Rec."Line No");
                    if ContractLines.FindFirst then begin
                        if Rec."Is Percentage" then AmountToPost:=Rec.Percentage / 100 * (ContractLines."Total Amount");
                        if Rec."Fixed Amount" then AmountToPost:=Rec.Amount;
                        //    ProcStoreManagement.IanCreatePurchaseLines( (OrderNo,ContractLines.Type,ContractLines.No,1,
                        //                                                AmountToPost,ContractLines.Location,ContractLines."Vehicle Reg. No",
                        //                                                ContractLines."Car Repair/Maintenance");
                        ProcStoreManagement.IanCreatePurchaseLines(OrderNo, ContractLines.Type, ContractLines.No, 1, AmountToPost, ContractLines.Location, ContractLines."Global Dimension 1 Code", ContractLines."Global Dimension 2 Code", ContractLines.Description, 0, ContractLines."Project Code", ContractLines."Donor Code", '', '', '', '', '', '', ContractLines."Unit of Measure");
                    end;
                    if OrderNo <> '' then begin
                        Rec."Order Created":=true;
                        if Rec.Modify(true)then Message('Order No [%1] has been created ', OrderNo);
                    end;
                end;
            }
            action("Completion Certificate")
            {
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("Milestone Code", Rec."Milestone Code");
                    Rec.SetRange("Contract No", Rec."Contract No");
                    REPORT.Run(53051, true, false, Rec);
                end;
            }
            action("Milestone Extensions")
            {
                Image = ExtendedDataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Milestone Extension Entries";
                RunPageLink = "Contract No"=FIELD("Contract No"), "Milestone Code"=FIELD("Milestone Code");
            }
            action("Interim Payment Certificate")
            {
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to print the interim payment certificate?')then exit;
                    ContractMilestone.Reset;
                    ContractMilestone.SetRange("Contract No", Rec."Contract No");
                    ContractMilestone.SetRange("Milestone Code", Rec."Milestone Code");
                    if ContractMilestone.FindFirst then begin
                        REPORT.RunModal(53098, true, false, ContractMilestone);
                    end;
                // Rec.RESET;
                // Rec.SETRANGE("Milestone Code",Rec."Milestone Code");
                // Rec.SETRANGE("Contract No",Rec."Contract No");
                // REPORT.RUN(53051,TRUE,FALSE,Rec);
                end;
            }
        }
    }
    var ProcStoreManagement: Codeunit "Proc & Store Management";
    OrderNo: Code[50];
    ContractHeader: Record "Contract Header";
    ContractLines: Record "Contract Lines";
    AmountToPost: Decimal;
    ContractMilestone: Record "Contract Milestone";
}
