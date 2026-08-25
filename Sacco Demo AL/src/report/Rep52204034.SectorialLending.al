report 52204034 "Sectorial Lending"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Sectorial Lending.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter";
            DataItemTableView = where("Loan Type" = filter("New Loan"));
            column(Sector_Code; "Sector Code")
            {
            }
            column(Sub_Sector_Code; "Sub Sector Code")
            {
            }
            column(Sub_Susector_Code; "Sub-Subsector Code")
            {
            }
            column(Net_Change_Principal; "Net Change-Principal")
            {
            }
            column(SectorName; SectorName)
            {
            }
            column(SubSectorName; SubSectorName)
            {
            }
            column(SubSubSectorName; SubSubSectorName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                SectorName := '';
                SubSectorName := '';
                SubSubSectorName := '';
                if Sectors.Get(Loans."Sector Code") then SectorName := Sectors."Sector Name";
                if SubSector.Get(Loans."Sector Code", Loans."Sub Sector Code") then SubSectorName := SubSector."Sub Sector Name";
                if SubSubSector.Get(Loans."Sector Code", Loans."Sub Sector Code", Loans."Sub-Subsector Code") then SubSubSectorName := SubSubSector."Sub-Subsector Description";
            end;
        }
    }
    var
        SectorName, SubSectorName, SubSubSectorName : Text[200];
        Sectors: Record "Economic Sectors";
        SubSubSector: Record "Economic Sub-subsector";
        SubSector: Record "Economic Subsectors";
}
