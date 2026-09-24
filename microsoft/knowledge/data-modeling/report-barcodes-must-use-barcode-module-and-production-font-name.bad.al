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
            begin
                // WRONG: hand-rolled "encoding" instead of the Barcode
                // module's provider/encoder API. This produces a string
                // that looks like a Code 39 barcode (asterisk delimiters)
                // but carries none of the platform's actual character-set
                // or checksum handling - wrong regardless of which font
                // is applied to it in the layout.
                BarcodeText := '*' + "No." + '*';
            end;
        }
    }

    var
        BarcodeText: Text;
}
