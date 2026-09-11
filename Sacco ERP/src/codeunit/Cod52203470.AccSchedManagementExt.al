codeunit 52203470 "AccSchedManagement Ext"
{
    var AccSchedMgt: Codeunit "AccSchedManagement";
    CallLevel: Integer;
    Text012: Label 'You have entered an illegal value or a nonexistent row number.';
    Text013: Label 'You have entered an illegal value or a nonexistent column number.';
    Text016: Label '%1\\ %2 %3 %4.', Locked = true;
    Text017: Label 'The error occurred when the program tried to calculate:\';
    Text018: Label 'Acc. Sched. Line: Row No. = %1, Line No. = %2, Totaling = %3\', Comment = '%1 = Row No., %2= Line No., %3 = Totaling';
    Text019: Label 'Acc. Sched. Column: Column No. = %1, Line No. = %2, Formula  = %3', Comment = '%1 = Column No., %2= Line No., %3 = Formula';
    Text020: Label 'Because of circular references, the program cannot calculate a formula.';
    Text022: Label 'You cannot have more than %1 lines with %2 of %3.';
    Text023: Label 'Formulas ending with a percent sign require %2 %1 on a line before it.';
    BasePercentLine: array[50]of Integer;
    DivisionError: Boolean;
    CallingAccSchedLineID: Integer;
    CallingColumnLayoutID: Integer;
    procedure EvaluateExpression(IsAccSchedLineExpression: Boolean; Expression: Text; AccSchedLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean): Decimal var
        AccSchedLine2: Record "Acc. Schedule Line";
        Result: Decimal;
        Parantheses: Integer;
        Operator: Char;
        LeftOperand: Text;
        RightOperand: Text;
        LeftResult: Decimal;
        RightResult: Decimal;
        i: Integer;
        IsExpression: Boolean;
        IsFilter: Boolean;
        Operators: Text[8];
        OperatorNo: Integer;
        AccSchedLineID: Integer;
        MaxLevel: Integer;
    begin
        Result:=0;
        MaxLevel:=25;
        CallLevel:=CallLevel + 1;
        if CallLevel > MaxLevel then ShowError(Text020, AccSchedLine, ColumnLayout);
        Expression:=DelChr(Expression, '<>', ' ');
        if StrLen(Expression) > 0 then begin
            Parantheses:=0;
            IsExpression:=false;
            Operators:='+-*/^%';
            OperatorNo:=1;
            repeat i:=StrLen(Expression);
                repeat if Expression[i] = '(' then Parantheses:=Parantheses + 1
                    else if Expression[i] = ')' then Parantheses:=Parantheses - 1;
                    if(Parantheses = 0) and (Expression[i] = Operators[OperatorNo])then IsExpression:=true
                    else
                        i:=i - 1;
                until IsExpression or (i <= 0);
                if not IsExpression then OperatorNo:=OperatorNo + 1;
            until(OperatorNo > StrLen(Operators)) or IsExpression;
            if IsExpression then begin
                if i > 1 then LeftOperand:=CopyStr(Expression, 1, i - 1)
                else
                    LeftOperand:='';
                if i < StrLen(Expression)then RightOperand:=CopyStr(Expression, i + 1)
                else
                    RightOperand:='';
                Operator:=Expression[i];
                LeftResult:=EvaluateExpression(IsAccSchedLineExpression, LeftOperand, AccSchedLine, ColumnLayout, CalcAddCurr);
                if(RightOperand = '') and (Operator = '%') and not IsAccSchedLineExpression and (AccSchedLine."Totaling Type" <> AccSchedLine."Totaling Type"::"Set Base For Percent")then begin
                    AccSchedLine2.Copy(AccSchedLine);
                    AccSchedLine2."Line No.":=GetBasePercentLine(AccSchedLine, ColumnLayout);
                    AccSchedLine2.Find;
                    RightResult:=EvaluateExpression(IsAccSchedLineExpression, LeftOperand, AccSchedLine2, ColumnLayout, CalcAddCurr);
                end
                else
                    RightResult:=EvaluateExpression(IsAccSchedLineExpression, RightOperand, AccSchedLine, ColumnLayout, CalcAddCurr);
                case Operator of '^': Result:=Power(LeftResult, RightResult);
                '%': if RightResult = 0 then begin
                        Result:=0;
                        DivisionError:=true;
                    end
                    else
                        Result:=100 * LeftResult / RightResult;
                '*': Result:=LeftResult * RightResult;
                '/': if RightResult = 0 then begin
                        Result:=0;
                        DivisionError:=true;
                    end
                    else
                        Result:=LeftResult / RightResult;
                '+': Result:=LeftResult + RightResult;
                '-': Result:=LeftResult - RightResult;
                end;
            end
            else if(Expression[1] = '(') and (Expression[StrLen(Expression)] = ')')then Result:=EvaluateExpression(IsAccSchedLineExpression, CopyStr(Expression, 2, StrLen(Expression) - 2), AccSchedLine, ColumnLayout, CalcAddCurr)
                else
                begin
                    IsFilter:=(StrPos(Expression, '..') + StrPos(Expression, '|') + StrPos(Expression, '<') + StrPos(Expression, '>') + StrPos(Expression, '&') + StrPos(Expression, '=') > 0);
                    if(StrLen(Expression) > 10) and (not IsFilter)then Evaluate(Result, Expression)
                    else if IsAccSchedLineExpression then begin
                            AccSchedLine.SetRange("Schedule Name", AccSchedLine."Schedule Name");
                            AccSchedLine.SetFilter("Row No.", Expression);
                            AccSchedLineID:=AccSchedLine."Line No.";
                            if AccSchedLine.Find('-')then repeat if AccSchedLine."Line No." <> AccSchedLineID then Result:=Result + AccSchedMgt.CalcCellValue(AccSchedLine, ColumnLayout, CalcAddCurr);
                                until AccSchedLine.Next = 0
                            else if IsFilter or (not Evaluate(Result, Expression))then ShowError(Text012, AccSchedLine, ColumnLayout);
                        end
                        else
                        begin
                            ColumnLayout.SetRange("Column Layout Name", ColumnLayout."Column Layout Name");
                            ColumnLayout.SetFilter("Column No.", Expression);
                            AccSchedLineID:=ColumnLayout."Line No.";
                            if ColumnLayout.Find('-')then repeat if ColumnLayout."Line No." <> AccSchedLineID then Result:=Result + AccSchedMgt.CalcCellValue(AccSchedLine, ColumnLayout, CalcAddCurr);
                                until ColumnLayout.Next = 0
                            else if IsFilter or (not Evaluate(Result, Expression))then ShowError(Text013, AccSchedLine, ColumnLayout);
                        end;
                end;
        end;
        CallLevel:=CallLevel - 1;
        exit(Result);
    end;
    local procedure ShowError(MessageLine: Text[100]; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout")
    begin
        AccSchedLine.SetRange("Schedule Name", AccSchedLine."Schedule Name");
        AccSchedLine.SetRange("Line No.", CallingAccSchedLineID);
        if AccSchedLine.FindFirst then;
        ColumnLayout.SetRange("Column Layout Name", ColumnLayout."Column Layout Name");
        ColumnLayout.SetRange("Line No.", CallingColumnLayoutID);
        if ColumnLayout.FindFirst then;
        Error(Text016, MessageLine, Text017, StrSubstNo(Text018, AccSchedLine."Row No.", AccSchedLine."Line No.", AccSchedLine.Totaling), StrSubstNo(Text019, ColumnLayout."Column No.", ColumnLayout."Line No.", ColumnLayout.Formula));
    end;
    local procedure InitBasePercents(AccSchedLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout")
    var
        BaseIdx: Integer;
    begin
        Clear(BasePercentLine);
        BaseIdx:=0;
        with AccSchedLine do begin
            SetRange("Schedule Name", "Schedule Name");
            if Find('-')then repeat if "Totaling Type" = "Totaling Type"::"Set Base For Percent" then begin
                        BaseIdx:=BaseIdx + 1;
                        if BaseIdx > ArrayLen(BasePercentLine)then ShowError(StrSubstNo(Text022, ArrayLen(BasePercentLine), FieldCaption("Totaling Type"), "Totaling Type"), AccSchedLine, ColumnLayout);
                        BasePercentLine[BaseIdx]:="Line No.";
                    end;
                until Next = 0;
        end;
        if BaseIdx = 0 then begin
            AccSchedLine."Totaling Type":=AccSchedLine."Totaling Type"::"Set Base For Percent";
            ShowError(StrSubstNo(Text023, AccSchedLine.FieldCaption("Totaling Type"), AccSchedLine."Totaling Type"), AccSchedLine, ColumnLayout);
        end;
    end;
    local procedure GetBasePercentLine(AccSchedLine: Record "Acc. Schedule Line"; ColumnLayout: Record "Column Layout"): Integer var
        BaseIdx: Integer;
    begin
        if BasePercentLine[1] = 0 then InitBasePercents(AccSchedLine, ColumnLayout);
        BaseIdx:=ArrayLen(BasePercentLine);
        repeat if BasePercentLine[BaseIdx] <> 0 then if BasePercentLine[BaseIdx] < AccSchedLine."Line No." then exit(BasePercentLine[BaseIdx]);
            BaseIdx:=BaseIdx - 1;
        until BaseIdx = 0;
        AccSchedLine."Totaling Type":=AccSchedLine."Totaling Type"::"Set Base For Percent";
        ShowError(StrSubstNo(Text023, AccSchedLine.FieldCaption("Totaling Type"), AccSchedLine."Totaling Type"), AccSchedLine, ColumnLayout);
    end;
}
