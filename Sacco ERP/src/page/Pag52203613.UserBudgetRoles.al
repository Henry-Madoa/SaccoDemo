page 52203613 "User Budget Roles"
{
    // version BUDGETDeleteAllowed = false;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "User Budget Roles";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLSetup.Get;
                        DimValues.Reset;
                        DimValues.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        DimValues.SetRange(Blocked, false);
                        if PAGE.RunModal(537, DimValues) = ACTION::LookupOK then begin
                            if DimValues."Dimension Value Type" <> DimValues."Dimension Value Type"::Standard then exit;
                            if Rec."Global Dimension 1 Code" = '' then Rec."Global Dimension 1 Code":=DimValues.Code
                            else
                                Rec."Global Dimension 1 Code":=Rec."Global Dimension 1 Code" + '|' + DimValues.Code;
                        end;
                    end;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLSetup.Get;
                        DimValues.Reset;
                        DimValues.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                        DimValues.SetRange(Blocked, false);
                        if PAGE.RunModal(537, DimValues) = ACTION::LookupOK then begin
                            if DimValues."Dimension Value Type" <> DimValues."Dimension Value Type"::Standard then exit;
                            if Rec."Global Dimension 2 Code" = '' then Rec."Global Dimension 2 Code":=DimValues.Code
                            else
                                Rec."Global Dimension 2 Code":=Rec."Global Dimension 2 Code" + '|' + DimValues.Code;
                        end;
                    end;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLSetup.Get;
                        DimValues.Reset;
                        DimValues.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
                        DimValues.SetRange(Blocked, false);
                        if PAGE.RunModal(537, DimValues) = ACTION::LookupOK then begin
                            if DimValues."Dimension Value Type" <> DimValues."Dimension Value Type"::Standard then exit;
                            if Rec."Global Dimension 3 Code" = '' then Rec."Global Dimension 3 Code":=DimValues.Code
                            else
                                Rec."Global Dimension 3 Code":=Rec."Global Dimension 3 Code" + '|' + DimValues.Code;
                        end;
                    end;
                }
                field("Budget Acounts Range"; Rec."Budget Acounts Range")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLAcc.Reset;
                        GLAcc.SetRange("Account Type", GLAcc."Account Type"::Posting);
                        GLAcc.SetRange(Blocked, false);
                        if PAGE.RunModal(16, GLAcc) = ACTION::LookupOK then begin
                            if GLAcc."Account Type" <> GLAcc."Account Type"::Posting then exit;
                            if Rec."Budget Acounts Range" = '' then Rec."Budget Acounts Range":=GLAcc."No."
                            else
                                Rec."Budget Acounts Range":=Rec."Budget Acounts Range" + '..' + GLAcc."No.";
                        end;
                    end;
                }
            }
        }
    }
    var DimValues: Record "Dimension Value";
    GLSetup: Record "General Ledger Setup";
    GLAcc: Record "G/L Account";
}
