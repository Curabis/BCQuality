report 50110 "Sample Item Barcode Label"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Sample Item Barcode Label';

    dataset
    {
        dataitem(Item; Item)
        {
            column(No_; "No.") { }
            column(Barcode; BarcodeText) { }

            trigger OnAfterGetRecord()
            var
                BarcodeFontProvider: Interface "Barcode Font Provider";
            begin
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeFontProvider.ValidateInput("No.", BarcodeSymbology);
                BarcodeText := BarcodeFontProvider.EncodeFont("No.", BarcodeSymbology);
            end;
        }
    }

    var
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeText: Text;

    trigger OnInitReport()
    begin
        BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
    end;

    // Layout requirement (can't be enforced in AL, so it's stated here):
    // the Barcode column's text box must use the real, purchased font
    // name - IDAutomationHC39M for Code 39 - never an evaluation name
    // like "IDAutomationSHC39M Demo". Per Microsoft Learn, using the
    // evaluation name in a Business Central online production
    // environment means "the barcode won't render" at all.
}
