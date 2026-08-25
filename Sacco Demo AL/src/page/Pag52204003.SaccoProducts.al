page 52204003 "Sacco Products"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = "Sacco Product";
    SourceTable = "Sacco Products";
    SourceTableView = SORTING(Category, Indentation);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                field(Indentation; Rec.Indentation)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = DescriptionStyle;
                }
                field("Product Posting Type"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Contribution"; Rec."Minimum Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Print Sequence"; Rec."Print Sequence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Installments"; Rec."Minimum Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Installments"; Rec."Maximum Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Hide on Statement"; Rec."Hide on Statement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Recovery Priority"; Rec."Loan Recovery Priority")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Charges)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SuggestFinancialCharge;
                RunObject = page "Product Charge Setup";
                RunPageLink = "Source Code" = field(Code);
                Visible = (not HasChildren and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account"));
            }
            action("Linked Products")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = LinkAccount;
                RunObject = page "Linked Products";
                RunPageLink = "Source Code" = field(Code);
                Scope = Repeater;
                Ellipsis = true;
                Visible = (not HasChildren and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account"));
            }
            action(Update)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = UpdateDescription;
                Enabled = not HasChildren;
                Scope = Repeater;
                Ellipsis = true;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.UpdateMemberAccounts(Rec.Code);
                end;
            }
            action("Update Salary Based")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = UpdateUnitCost;
                Enabled = not HasChildren;
                Scope = Repeater;
                Ellipsis = true;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.Update_Salary_Based;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        If Rec.Category = '' then begin
            Rec.Indentation := 0;
            Rec.Modify;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    local procedure SetControlAppearance()
    begin
        HasChildren := Rec.Code = Rec.Category;
        if HasChildren then
            DescriptionStyle := 'Strong'
        else
            DescriptionStyle := 'Standard';
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    var
        DescriptionStyle: Text;
        HasChildren: Boolean;
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
}
