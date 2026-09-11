report 52203549 "FA - Program-Department"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/FA - Program-Department.rdlc';

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
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
            column(No_FixedAsset; "Fixed Asset"."No.")
            {
            }
            column(Description_FixedAsset; "Fixed Asset".Description)
            {
            }
            column(FAPostingGroup_FixedAsset; "Fixed Asset"."FA Posting Group")
            {
            }
            column(GlobalDimension1Code_FixedAsset; "Fixed Asset"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_FixedAsset; "Fixed Asset"."Global Dimension 2 Code")
            {
            }
            column(FABookValue; FABookValue)
            {
            }
            column(DepartmentName; DepartmentName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                FADepreciationBook.Reset;
                FADepreciationBook.SetRange("FA No.", "Fixed Asset"."No.");
                if FADepreciationBook.FindFirst then begin
                    FADepreciationBook.CalcFields("Book Value");
                    FABookValue:=FADepreciationBook."Book Value";
                end;
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Fixed Asset"."Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    DepartmentName:=DimensionValue.Name;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
    end;
    var CompanyInformation: Record "Company Information";
    FADepreciationBook: Record "FA Depreciation Book";
    FABookValue: Decimal;
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
}
