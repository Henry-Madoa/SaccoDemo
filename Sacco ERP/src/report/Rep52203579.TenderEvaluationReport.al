report 52203579 "Tender Evaluation Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Tender Evaluation Report.rdlc';

    dataset
    {
        dataitem("Tender Suppliers"; "Tender Suppliers")
        {
            column(ReferenceNo_TenderSuppliers; "Tender Suppliers"."Reference No")
            {
            }
            column(VendorName_TenderSuppliers; "Tender Suppliers"."Vendor Name")
            {
            }
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(TechnicalScore_TenderSuppliers; "Tender Suppliers"."Technical Score")
            {
            }
            column(PassedMandatory_TenderSuppliers; "Tender Suppliers"."Passed Mandatory")
            {
            }
            column(PassedTechnical_TenderSuppliers; "Tender Suppliers"."Passed Technical")
            {
            }
            dataitem("Supplier Mandatory Evaluation"; "Supplier Mandatory Evaluation")
            {
                DataItemLink = "Reference No"=FIELD("Reference No"), "Vendor Name"=FIELD("Vendor Name");

                column(ReferenceNo_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Reference No")
                {
                }
                column(RequirementCode_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Requirement Code")
                {
                }
                column(RequirementDescription_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Requirement Description")
                {
                }
                column(EvaluatorID_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Evaluator ID")
                {
                }
                column(EvaluatorNo_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Evaluator No.")
                {
                }
                column(EvaluatorName_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Evaluator Name")
                {
                }
                column(VendorName_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation"."Vendor Name")
                {
                }
                column(Complied_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation".Complied)
                {
                }
                column(Comment_SupplierMandatoryEvaluation; "Supplier Mandatory Evaluation".Comment)
                {
                }
            }
            dataitem("Supplier Technical Evaluation"; "Supplier Technical Evaluation")
            {
                DataItemLink = "Reference No"=FIELD("Reference No"), "Vendor Name"=FIELD("Vendor Name");

                column(ReferenceNo_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Reference No")
                {
                }
                column(RequirementCode_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Requirement Code")
                {
                }
                column(RequirementDescription_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Requirement Description")
                {
                }
                column(EvaluatorID_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Evaluator ID")
                {
                }
                column(EvaluatorNo_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Evaluator No.")
                {
                }
                column(EvaluatorName_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Evaluator Name")
                {
                }
                column(VendorName_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Vendor Name")
                {
                }
                column(Score_SupplierTechnicalEvaluation; "Supplier Technical Evaluation".Score)
                {
                }
                column(Comment_SupplierTechnicalEvaluation; "Supplier Technical Evaluation".Comment)
                {
                }
                column(MaxScore_SupplierTechnicalEvaluation; "Supplier Technical Evaluation"."Max Score")
                {
                }
            }
            dataitem("Financial Evaluation"; "Financial Evaluation")
            {
                DataItemLink = "Reference No."=FIELD("Reference No"), "Vendor Name"=FIELD("Vendor Name");

                column(ReferenceNo_FinancialEvaluation; "Financial Evaluation"."Reference No.")
                {
                }
                column(VendorName_FinancialEvaluation; "Financial Evaluation"."Vendor Name")
                {
                }
                column(QuotedAmount_FinancialEvaluation; "Financial Evaluation"."Quoted Amount")
                {
                }
                column(Award_FinancialEvaluation; "Financial Evaluation".Award)
                {
                }
                column(TechnicalScore_FinancialEvaluation; "Financial Evaluation"."Technical Score")
                {
                }
                column(FinancialScore_FinancialEvaluation; "Financial Evaluation"."Financial Score")
                {
                }
                column(TotalScore_FinancialEvaluation; "Financial Evaluation"."Total Score")
                {
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var corec: Record "Company Information";
    CompanyInformation: Record "Company Information";
}
