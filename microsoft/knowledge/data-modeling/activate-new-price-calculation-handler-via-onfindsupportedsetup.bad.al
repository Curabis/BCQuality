enumextension 50102 "Sample Price Calc Handler Ext" extends "Price Calculation Handler"
{
    value(50102; "Sample Special Price")
    {
        Caption = 'Sample Special Price';
        Implementation = "Price Calculation" = "Sample Price Calc - Special";
    }
}

// WRONG: no subscriber to Price Calculation Mgt.'s OnFindSupportedSetup.
// "Sample Special Price" is a real, working implementation of the Price
// Calculation interface - it simply has no Price Calculation Setup row
// naming it, so Price Calculation Mgt. never selects it for any sale,
// purchase, or job line. It ships invisible until someone notices and
// configures a setup row for it by hand.
