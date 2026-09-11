page 52204132 "Employer"
{
    PageType = Card;
    SourceTable = Employers;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll No. Mandatory"; Rec."Payroll No. Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                }
                group("&&Domicile")
                {
                    ShowCaption = false;
                    Visible = Rec.Nationality = Rec.Nationality::Diaspora;

                    field(Domicile; Rec.Domicile)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Country Name"; Rec."Country Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Account"; Rec."Checkoff Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Account"; Rec."Salary Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Suspense Account"; Rec."Suspense Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Payroll Details"; "Employer Payroll Details")
            {
                Caption = 'Payroll Details';
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employer Code" = field(Code);
                SubPageView = WHERE(Processed = CONST(false));
            }
            part("Payroll History"; "Employer Payroll Details")
            {
                Caption = 'Payroll History';
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employer Code" = field(Code);
                SubPageView = WHERE(Processed = CONST(true));
            }
            part(Stations; "Employer Stations")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employer Code" = field(Code);
            }
            part(Departments; "Employer Departments")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employer Code" = field(Code);
            }
            part("Loan Documents"; "Loan Documents")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employer Code" = field(Code);
            }
            group(Statistics)
            {
                field("Not Paid Up Members"; Rec."Not Paid Up Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Active Members"; Rec."Active Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inactive Members"; Rec."Inactive Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Dormant Members"; Rec."Dormant Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withdrawn Members"; Rec."Withdrawn Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deceased Members"; Rec."Deceased Members")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Closed Members"; Rec."Closed Members")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
