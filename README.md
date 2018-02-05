# bdn:IntermediateFormat.v2
Scripts to convert bdn-TEI into an intermediate-format dealing with reading markers

# Notes in Advance
  - The Directory "stable_old" contains the old version and is just of documentary nature
  - The Directory "oxygen" contains files for the Development in oxygen
  - The Directories "modules" and "rest" hold all files of the new Intermediate-Format version

# setup and description
## modules/intermediate_format/identification.xqm
  - This is the main module integrating the main conversion and node identification functions
  - place it in your app modules path: "/modules/intermediate_format/inter_form.xqm" 

## modules/intermediate_format/markerset.xqm
  - Functions to collect and construct markers 
  - place it in your app modules path: "/modules/intermediate_format/markerset.xqm"

## modules/intermediate_format/preprocessing.xqm
  - Contains the preprocessing routine 
  - place it in your app modules path: "/modules/intermediate_format/preprocessing.xqm" 

## modules/intermediate_format/whitespace-handling.xqm
  - Functions for whitespace-handling
  - place it in your app modules path: "/modules/intermediate_format/whitespace-handling.xqm"

## rest/intermediate_function.xql
  - This is the REST script running the conversion on a given document within eXist-DB
  - place it in your app somewhere or as suggested here in a subfolder /rest

# Running the conversion
  - call intermediate_format.xql via REST with the GET-Parameter "path" (exemplary call: "http://localhost:8080/exist/rest/apps/YOUR_APP/rest/intermediate_format.xql?path=/db/apps/bdn/data/samples/griesbach_full.xml")
  - "path" must be a XML-URI existing in your app context (There is no existence-check yet)
  - wait

# Changes of the Intermediate Format
  - note: All changes are done (not quite right) in the tei-namespace!

## "editorialNotes Section" 
  - Section as last child of tei:TEI where all note[@type="editorial"] are collected during the preprocessing. Every note[@type="editorial"] is thus ignored in its original context

## "aligned"
  - new element; all tei:hi[@rend ="right-aligned" or @rend="center-aligned"] are converted to aligned[@rend ="right-aligned" or @rend="center-aligned"]
  - name: "aligned", 
  - attributes: same as tei:hi in original data

## "seg[@type='item' or @type='head' or @type='row']" vs tei:item or tei:head or tei:row
  - conversion of seg[@type='item' or @type=''head or @type='row'] into tei:item or tei:head or tei:row

## "rdgMarker"
  - new element representing Siglae
  - name: "rdgMarker"
  - attributes: @wit(Witness without '#'), @ref(Reference to @id of tei:lem or tei:rdg without '#'), @type(same as tei:rdg), @mark('open' or 'close'), @context(Context of the Marker - "rdg" or "lem") 

## "tei:rdg" or "tei:lem"
  - new attribute: @id(generated id during the preprocessing, serving as referenced id by the rdgMarkers)

## "tei:pb[@break="no"]"
  - new attribute: @break="no"(In cases a tei:pb is directly preceeded or followed by a character not self whitespace)

## text() and whitespace
  - All whitespaces in text() are replaced by NON-BREAKING SPACE (U+00A0, &#160) to save whitespace during the processing
