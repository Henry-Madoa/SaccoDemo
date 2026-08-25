page 52204136 "Channel Guarantor Requests"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Guarantor Requests";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                //Editable = isWebService;
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ID No"; Rec."ID No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Principal"; Rec."Loan Principal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Submitted"; Rec."Loan Submitted")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(AppliedAmount; Rec.AppliedAmount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Applicant; Rec.Applicant)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(ApplicantName; Rec.ApplicantName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Accepted"; Rec."Amount Accepted")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Responded On"; Rec."Responded On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Deposits"; Rec."Available Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Self Guarantee"; Rec."Available Self Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";

    trigger OnAfterGetRecord()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;
}
