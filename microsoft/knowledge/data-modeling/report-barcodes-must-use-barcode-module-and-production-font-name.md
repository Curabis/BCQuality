---
bc-version: [all]
domain: data-modeling
keywords: [barcode, qr-code, barcode-font-provider, report-layout, saas, idautomation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate report barcodes through the Barcode module, with the production font name

## Description

Business Central's barcode support lives in the System Application's
`Barcode` module (`src/System Application/App/Barcode`), not in a
project's own code: `interface "Barcode Font Provider"` /
`"Barcode Font Provider 2D"`, `enum "Barcode Symbology"` /
`"Barcode Symbology 2D"` (Code39, Code128, EAN-13, QR-Code, Data Matrix,
and more), and built-in implementations
(`codeunit 9215 "IDAutomation 1D Provider"`,
`codeunit 9221 "IDAutomation 2D Provider"`). A report encodes a data
string into a barcode string via this API; the layout then displays that
string using a barcode *font*.

On Business Central online, this is available with no setup at all:
"With Business Central online, the IDAutomation fonts are automatically
available as part of the service. So you can start adding barcodes to
reports right away." (Microsoft Learn, "Adding Barcodes to Reports") —
unlike on-premises, where the fonts must be purchased and installed on
the server.

That ease hides a SaaS-specific trap in the one manual step the API
doesn't cover: naming the actual font in the report layout. IDAutomation
ships both a purchased font and a same-looking evaluation font per
version (Code 39: `IDAutomationHC39M` purchased vs.
`IDAutomationSHC39M Demo` evaluation). Per Microsoft Learn ("Barcode
Fonts with Business Central Online"): "When you're applying barcode font
in the report layout for a Business Central online production
environment, be sure to use the purchased font name; not the evaluation
font name. If you use the evaluation font name, the barcode won't
render." Getting the font name wrong doesn't distort the barcode — it
produces nothing, in a step that lives in the layout file, not in AL, so
no compiler or reviewer catches it by reading the report object. Nothing
in the cited documentation says what an evaluation font name does outside
a production environment — the claim here is scoped exactly as
Microsoft states it: wrong in production, full stop.

## Best Practice

Encode through the real API — declare the provider via its interface and
enum, then call `ValidateInput`/`EncodeFont` — and treat naming the
production font in the layout as an equally required part of the same
task, not an afterthought left to whoever happens to touch the `.docx`/
`.rdl` file. For a two-dimensional symbology other than Maxicode, the
font name to specify is literally `IDAutomation2D` (Maxicode itself uses
`IDAutomation2D MaxiCode`); for a one-dimensional symbology, use the
purchased version name for that specific font (e.g. `IDAutomationHC39M`
for Code 39), never a name containing `Demo`.

See sample: [`report-barcodes-must-use-barcode-module-and-production-font-name.good.al`](report-barcodes-must-use-barcode-module-and-production-font-name.good.al).

## Anti Pattern

Constructing a barcode string by hand — string concatenation, manual
delimiters — instead of going through the Barcode module's provider
interface. It can look right (asterisks around a value, resembling
Code 39) while carrying none of the platform's actual character-set
handling or checksum logic, so it's wrong regardless of which font is
later applied to it.

A second version of the same underlying mistake: encoding correctly
through the real API, but naming the evaluation font instead of the
purchased one in the layout. Both produce a report that looks complete
in review and testing and fails silently — the first because the encoded
data was never a real barcode, the second because Business Central
online refuses to render it at all.

See sample: [`report-barcodes-must-use-barcode-module-and-production-font-name.bad.al`](report-barcodes-must-use-barcode-module-and-production-font-name.bad.al).

## Source

BCApps System Application (`src/System Application/App/Barcode/src/`):
`Barcode Provider/Font/BarcodeFontProvider.Interface.al`
(`ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology")`,
`EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"): Text`),
`Barcode Provider/Font/BarcodeFontProvider.Enum.al`
(`value(0; IDAutomation1D)`), `Barcode Provider/BarcodeSymbology.Enum.al`
(`value(100; Code39)`). Real BaseApp usage:
`src/Layers/W1/BaseApp/Inventory/Item/ItemGTINLabel.Report.al`
(`report 6625 "Item GTIN Label"`, lines 44-64).

Microsoft Learn: "Adding Barcodes to Reports"
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-report-add-barcodes)
and "Barcode Fonts with Business Central Online"
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-report-barcode-fonts)
— both quoted verbatim above.
