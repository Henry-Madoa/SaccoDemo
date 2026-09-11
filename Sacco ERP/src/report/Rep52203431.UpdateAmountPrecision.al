report 52203431 "Update Amount Precision"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    group("Current")
                    {
                        Editable = false;

                        field(RoundingType_From; RoundingType_From)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Type';
                        }
                        field(AmountRoundingPrecision_From; AmountRoundingPrecision_From)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Amount Rounding Precision';
                        }
                    }
                    group("Update To:")
                    {
                        field(RoundingType; RoundingType)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Type';
                        }
                        field(AmountRoundingPrecision; AmountRoundingPrecision)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Amount Rounding Precision';
                        }
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        GeneralLedgerSetup."Rounding Type":=RoundingType;
        // GeneralLedgerSetup.Validate("Amount Rounding Precision", AmountRoundingPrecision);
        // GeneralLedgerSetup.Modify(true);
        GeneralLedgerSetup."Amount Rounding Precision":=AmountRoundingPrecision;
        GeneralLedgerSetup.Modify;
        Message('Precision Updated');
    end;
    procedure UpdateCurrent(GLSetup: Record "General Ledger Setup")
    begin
        RoundingType_From:=GLSetup."Rounding Type";
        AmountRoundingPrecision_From:=GLSetup."Amount Rounding Precision";
    end;
    var GeneralLedgerSetup: Record "General Ledger Setup";
    AmountRoundingPrecision: Decimal;
    RoundingType: Option Nearest, Up, Down;
    AmountRoundingPrecision_From: Decimal;
    RoundingType_From: Option Nearest, Up, Down;
}
