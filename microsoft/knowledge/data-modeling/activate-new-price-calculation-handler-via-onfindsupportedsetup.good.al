enumextension 50102 "Sample Price Calc Handler Ext" extends "Price Calculation Handler"
{
    value(50102; "Sample Special Price")
    {
        Caption = 'Sample Special Price';
        Implementation = "Price Calculation" = "Sample Price Calc - Special";
    }
}

codeunit 50104 "Sample Price Calc Setup Install"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnFindSupportedSetup', '', false, false)]
    local procedure AddSampleSpecialPriceSetup(var TempPriceCalculationSetup: Record "Price Calculation Setup" temporary)
    begin
        TempPriceCalculationSetup.Init();
        TempPriceCalculationSetup.Code := 'SAMPLE-SPECIAL';
        TempPriceCalculationSetup.Method := TempPriceCalculationSetup.Method::"Lowest Price";
        TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Sale;
        TempPriceCalculationSetup."Asset Type" := TempPriceCalculationSetup."Asset Type"::" ";
        TempPriceCalculationSetup.Implementation := TempPriceCalculationSetup.Implementation::"Sample Special Price";
        TempPriceCalculationSetup.Enabled := true;
        TempPriceCalculationSetup.Default := true;
        TempPriceCalculationSetup.Insert();
    end;
}
