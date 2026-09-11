page 52203717 "Payroll Vital Setup"
{
    PageType = Card;
    SourceTable = "Payroll Vital Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Tax Relief"; Rec."Tax Relief")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Relief %"; Rec."Insurance Relief %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max Relief"; Rec."Max Relief")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mortgage Relief"; Rec."Mortgage Relief")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max Pension Contribution"; Rec."Max Pension Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax On Excess Pension"; Rec."Tax On Excess Pension")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Market Rate"; Rec."Loan Market Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Corporate Rate"; Rec."Loan Corporate Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Taxable Pay (Normal)"; Rec."Taxable Pay (Normal)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Taxable Pay (Agricultural)"; Rec."Taxable Pay (Agricultural)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Statutories Exclusion"; Rec."Statutories Exclusion")
                {
                    ToolTip = 'Earning Codes to Exclude on Statutories Computations   such as SHIF and Housing Levy';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("SHIF %"; Rec."SHIF %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SHIF Based on"; Rec."SHIF Based on")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Enable SHIF Relief"; Rec."Enable SHIF Relief")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SHIF Relief %"; Rec."SHIF Relief %")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Enable SHIF Relief";
                }
                field("NSSF Employer Factor"; Rec."NSSF Employer Factor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Benefit Threshold"; Rec."Benefit Threshold")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NSSF Based on"; Rec."NSSF Based on")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Value Posting"; Rec."Value Posting")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Disbled Tax Limit"; Rec."Disbled Tax Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Relief Amount"; Rec."Minimum Relief Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Secondary Tax Percentage"; Rec."Secondary Tax Percentage")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mortgage Relief Percentage"; Rec."Mortgage Relief Percentage")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Market Rate"; Rec."Market Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Gratuity %"; Rec."Gratuity %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NHF %"; Rec."NHF %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Activate NHF"; Rec."Activate NHF")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NHF Based On"; Rec."NHF Based On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("OOI Deduction"; Rec."OOI Deduction")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Secondary Employee Tax %"; Rec."Secondary Employee Tax %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Weekdays Multiplier"; Rec."Weekdays Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Working Days"; Rec."Monthly Working Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Weekend Multiplier"; Rec."Weekend Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Cut off Date"; Rec."Payroll Cut off Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
