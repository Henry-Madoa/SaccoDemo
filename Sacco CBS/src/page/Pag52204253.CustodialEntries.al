page 52204253 "Custodial Entries"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Custodial Services Entries";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("Line Info")
            {
                action("Bill to Date")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Apply;

                    trigger OnAction()
                    begin
                        if CONFIRM('Do you wish to Bill Entries to %1', true, FORMAT(TODAY)) then begin
                            CustodialServicesEntries.RESET;
                            CustodialServicesEntries.SETFILTER("Posting Date", '..%1', TODAY);
                            CustodialServicesEntries.SETRANGE("Custodial No.", Rec."Custodial No.");
                            if CustodialServicesEntries.FINDFIRST then begin
                                repeat
                                    CustodialServicesEntries.Posted := true;
                                    CustodialServicesEntries.MODIFY;
                                until CustodialServicesEntries.NEXT = 0;
                            end;
                        end;
                    end;
                }
                action("Bill Selection")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Apply;

                    trigger OnAction()
                    begin
                        CustodialServicesEntries.RESET;
                        CurrPage.SETSELECTIONFILTER(CustodialServicesEntries);
                        if CustodialServicesEntries.FINDFIRST then begin
                            repeat
                                CustodialServicesEntries.Posted := true;
                                CustodialServicesEntries.MODIFY;
                            until CustodialServicesEntries.NEXT = 0;
                        end;
                    end;
                }
            }
        }
    }
    var
        CustodialServicesEntries: Record "Custodial Services Entries";
}
