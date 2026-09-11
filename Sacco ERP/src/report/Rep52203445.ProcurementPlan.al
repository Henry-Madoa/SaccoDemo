report 52203445 "Procurement Plan"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Procurement Plan.rdl';

    dataset
    {
        dataitem("Procurement Plan Header"; "Procurement Plans")
        {
            RequestFilterFields = "No.", "Global Dimension 1 Code", Status;

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
            column(PlanNo_ProcurementPlanHeader; "Procurement Plan Header"."No.")
            {
            }
            column(Date_ProcurementPlanHeader; "Procurement Plan Header".Date)
            {
            }
            column(ItemBudgetName_ProcurementPlanHeader; "Procurement Plan Header"."Item Budget Name")
            {
            }
            column(GlobalDimension1Code_ProcurementPlanHeader; "Procurement Plan Header"."Global Dimension 1 Code")
            {
            }
            column(DepartmentName_ProcurementPlanHeader; DepartmentName)
            {
            }
            column(RaisedBy_ProcurementPlanHeader; "Procurement Plan Header"."Employee Name")
            {
            }
            column(Status_ProcurementPlanHeader; "Procurement Plan Header".Status)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            dataitem("Procurement Plan Lines"; "Procurement Plan Lines")
            {
                DataItemLink = "Document No"=field("No.");

                column(Date_ProcuremntPlanLines; "Procurement Plan Lines".Date)
                {
                }
                column(ItemCategory_ProcuremntPlanLines; "Procurement Plan Lines"."Item Category")
                {
                }
                column(GlobalDimension1Code_ProcuremntPlanLines; "Procurement Plan Lines"."Global Dimension 1 Code")
                {
                }
                column(LocationCode_ProcuremntPlanLines; "Procurement Plan Lines"."Location Code")
                {
                }
                column(ItemBudgetName_ProcuremntPlanLines; "Procurement Plan Lines"."Item Budget Name")
                {
                }
                column(ItemNo_ProcuremntPlanLines; "Procurement Plan Lines"."No.")
                {
                }
                column(ItemDescrition_ProcuremntPlanLines; "Procurement Plan Lines".Description)
                {
                }
                column(ProcurementMethod_ProcuremntPlanLines; "Procurement Plan Lines"."Procurement Method")
                {
                }
                column(QuantityBase_ProcuremntPlanLines; "Procurement Plan Lines"."Quantity (Base)")
                {
                }
                column(UnitCostBase_ProcuremntPlanLines; "Procurement Plan Lines"."Unit Cost (Base)")
                {
                }
                column(Quantity_ProcuremntPlanLines; "Procurement Plan Lines".Quantity)
                {
                }
                column(UnitCost_ProcuremntPlanLines; "Procurement Plan Lines"."Unit Cost")
                {
                }
                column(TotalCost_ProcuremntPlanLines; "Procurement Plan Lines"."Total Cost")
                {
                }
                column(UnitofMeasure_ProcuremntPlanLines; "Procurement Plan Lines"."Unit of Measure")
                {
                }
                dataitem(Item; Item)
                {
                    DataItemLink = "No."=field("No.");

                    column(BaseUnitofMeasure_Item; "Base Unit of Measure")
                    {
                    }
                }
            }
            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    DepartmentName:=DimensionValue.Name;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=StrSubstNo('%1 %2', "Procurement Plan Header".GetFilters, "Procurement Plan Lines".GetFilters);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
}
