xmlport 52203430 "Import Item Journal"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
    textelement(Root)
    {
    tableelement("Item Journal Line";
    "Item Journal Line")
    {
    XmlName = 'ItemJournal';

    fieldattribute(PostDate;
    "Item Journal Line"."Posting Date")
    {
    }
    fieldattribute(Entry;
    "Item Journal Line"."Entry Type")
    {
    }
    fieldattribute(DocNo;
    "Item Journal Line"."Document No.")
    {
    }
    fieldattribute(ItemNo;
    "Item Journal Line"."Item No.")
    {
    }
    fieldattribute(LocationCode;
    "Item Journal Line"."Location Code")
    {
    }
    fieldattribute(Qty;
    "Item Journal Line".Quantity)
    {
    }
    fieldattribute(UnitAmount;
    "Item Journal Line"."Unit Amount")
    {
    }
    fieldattribute(DisAmount;
    "Item Journal Line"."Discount Amount")
    {
    }
    trigger OnBeforeInsertRecord()
    begin
        //To skip the Header of the excel
        /*if CaptionRow then begin
                                    CaptionRow := false;
                                    currXMLport.Skip();
                                end;*/
        //
        Counter:=Counter + 1;
        "Item Journal Line"."Journal Template Name":=BatchNo;
        "Item Journal Line"."Journal Batch Name":='DEFAULT';
        "Item Journal Line"."Line No.":=Counter;
    end;
    }
    }
    }
    requestpage
    {
        layout
        {
        }
        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                }
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        Counter:=0;
        CountRow:=0;
        CaptionRow:=true;
    end;
    trigger OnPostXmlPort()
    begin
        Message('Import Completed.');
    end;
    var Counter: Integer;
    ItemJournal: Record "Item Journal Line";
    BatchNo: Code[20];
    CountRow: Integer;
    CaptionRow: Boolean;
    Template: Record "Item Journal Template";
    ItemRec: Record Item;
    procedure GetHeader(var Header: Record "Item Journal Template")
    begin
        Template.Copy(Header);
        BatchNo:=Template.Name;
    end;
}
