report 52203484 "WHT Analysis"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/WHT Analysis.rdl';

    dataset
    {
        dataitem(Payments; "Payment Voucher")
        {
            DataItemTableView = WHERE(Posted=CONST(true));
            PrintOnlyIfDetail = true;

            column(Title; Title)
            {
            }
            column(LOGO; CompInfo.Picture)
            {
            }
            column(ChequeNo; Payments."Cheque Number")
            {
            }
            column(PVNo; Payments."No.")
            {
            }
            column(TIN; TIN)
            {
            }
            column(TxDate; Payments.Date)
            {
            }
            column(Name; Name)
            {
            }
            column(Address; Address)
            {
            }
            dataitem("PV Lines"; "Payment Voucher Lines")
            {
                DataItemLink = "No."=FIELD("No.");
                DataItemTableView = WHERE("WHT Amount One"=FILTER(<>0));
                RequestFilterFields = "Global Dimension 1 Code", "Global Dimension 2 Code";

                column(SN; Counter)
                {
                }
                column(Description; "PV Lines".Description)
                {
                }
                column(ContractAmount; "PV Lines".Amount)
                {
                }
                column(WHTRate; WHTRate)
                {
                }
                column(WHTAmount; "PV Lines"."WHT Amount One")
                {
                }
                column(State; "PV Lines"."Global Dimension 2 Code")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    Counter:=Counter + 1;
                    WHTRate:=Round("PV Lines"."WHT Amount One" / "PV Lines".Amount * 100, 1);
                    if Supplier.Get("PV Lines"."Account No")then begin
                        TIN:=Supplier."VAT Registration No.";
                        Name:=Supplier.Name;
                        Address:=Supplier.Address;
                    end;
                end;
            }
            trigger OnPreDataItem()
            begin
                Payments.SetRange(Date, StartDate, EndDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("As at Date"; EndDate)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        Counter:=0;
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        if EndDate = 0D then Error('Please specify the Date.');
        StartDate:=DMY2Date(1, 1, Date2DMY(EndDate, 3));
        Title:=StrSubstNo(Text000, UpperCase(Format(EndDate, 0, 4)));
    end;
    var PVLines: Record "Payment Voucher Lines";
    PV: Record "Payment Voucher";
    Counter: Integer;
    ChequeNo: Code[20];
    TIN: Code[20];
    Name: Text;
    Address: Text;
    ContractAmount: Decimal;
    Supplier: Record Vendor;
    WHTRate: Decimal;
    CompInfo: Record "Company Information";
    EndDate: Date;
    StartDate: Date;
    Text000: Label 'WITHOLDING TAX PAYABLE AS AT %1';
    Title: Text;
}
