page 52203979 "Applicant Current Employment"
{
    PageType = ListPart;
    SourceTable = "Applicant Current Employment";
    SourceTableView = where("Currently Employment"=const(true));

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field("Currently Employment"; Rec."Currently Employment")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field("Employer Name"; Rec."Employer/Institution Name")
                {
                    ApplicationArea = All;
                }
                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }
                field("Sector Specification"; Rec."Sector Specification")
                {
                    Editable = Rec.Sector = Rec.Sector::Others;
                    ApplicationArea = All;
                }
                field("Substantive Post"; Rec."Substantive Post")
                {
                    ApplicationArea = All;
                }
                field("Employment No."; Rec."Employment No.")
                {
                    ApplicationArea = All;
                }
                field("Job Grade"; Rec."Job Grade")
                {
                    ApplicationArea = All;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                }
                field("Employment Period"; Rec."Employment Period")
                {
                    ApplicationArea = All;
                    Editable = WebServiceVisibility;
                }
                field("Terms of Service"; Rec."Terms of Service")
                {
                    ApplicationArea = All;
                }
                field("Terms of Service Specfication"; Rec."Terms of Service Specfication")
                {
                    ApplicationArea = All;
                    Editable = Rec."Terms of Service" = Rec."Terms of Service"::Others;
                }
                field("Gross Salary (KSH)"; Rec."Gross Salary (KSH)")
                {
                    ApplicationArea = All;
                }
                field("Expected Salary (KSH)"; Rec."Expected Salary (KSH)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}
