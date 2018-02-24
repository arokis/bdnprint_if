# bdn:IntermediateFormat.v2 - eXistDB Application

This repos contains the BdN IntermediateFormat-conversion Application to produce several kinds of intermediate formats of the XML-Data of the DFG-Project "Bibliothek der Neologie" 

# Requirements

`ant`

# Setup

- Call `ant` to build the app as `build/interformat.{VERSION}.xar` 
- integrate it into your eXistDB instance

# Modules
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

# Use
  - call the IntermediateFormat API with GET -Parameter `resource`: http://localhost:{PORT}/exist/apps/interformat/rest/convert?resource={RESOURCE-URI}
  OR
  - call intermediate_format.xql via REST with the GET-Parameter `resource`: http://localhost:{PORT}/exist/rest/apps/interformat/rest/intermediate_format.xql?resource={RESOURCE-URI}

  - the resource must be from your eXist-instance context
  - If you like to store the result add method=store as get-parameter
  

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
