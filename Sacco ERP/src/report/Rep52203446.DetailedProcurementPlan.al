report 52203446 "Detailed Procurement Plan"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Detailed Procurement Plan.rdl';

    dataset
    {
        dataitem("Item Budget Name"; "Item Budget Name")
        {
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
            column(Name_ItemBudgetName; "Item Budget Name".Name)
            {
            }
            column(Description_ItemBudgetName; "Item Budget Name".Description)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            dataitem("Procurement Plan Header"; "Procurement Plans")
            {
                DataItemLink = "Item Budget Name"=field(Name);

                column(PlanNo_ProcurementPlanHeader; "Procurement Plan Header"."No.")
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
                    column(LocationCode_ProcuremsntPlanLines; "Procurement Plan Lines"."Location Code")
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
                    column(Quantity_ProcuremntPlanLines; "Procurement Plan Lines"."Quantity (Base)")
                    {
                    }
                    column(UnitCost_ProcuremntPlanLines; "Procurement Plan Lines"."Unit Cost (Base)")
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
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=StrSubstNo('%1 %2 %3', "Item Budget Name".GetFilters, "Procurement Plan Header".GetFilters, "Procurement Plan Lines".GetFilters);
                "Item Budget Name".SetFilter(Name, CurrentBudgetName);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Item Budget Name"; CurrentBudgetName)
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Item Budget Name".Name;
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    CurrentBudgetName: Code[10];
}
