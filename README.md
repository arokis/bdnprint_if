# bdn:IntermediateFormat.v2 - eXistDB Application

This repository contains the BdN IntermediateFormat-conversion application to produce several kinds of intermediate formats of the XML-Data of the DFG-Project "Bibliothek der Neologie"

# Requirements

`ant`

# Setup

- call `ant` to build the app as `build/interformat.{VERSION}.xar`
- integrate it into your eXistDB instance


# Use
  - call the IntermediateFormat API with GET -Parameter `resource`: http://localhost:{PORT}/exist/apps/interformat/rest/convert?resource={RESOURCE-URI}
  OR
  - call intermediate_format.xql via REST with the GET-Parameter `resource`: http://localhost:{PORT}/exist/rest/apps/interformat/rest/intermediate_format.xql?resource={RESOURCE-URI}

  - the resource must be from your eXist-instance context
  - if you like to store the result add method=store as get-parameter


# Changes of the Intermediate Format
  - note: All changes are done (not quite right) in the tei-namespace!

## "editorialNotes section"
  - Section as last child of tei:TEI where all note[@type="editorial"] are collected during the preprocessing. Every note[@type="editorial"] is thus ignored in its original context

## "aligned"
  - new element; all tei:hi[@rend ="right-aligned" or @rend="center-aligned"] are converted to aligned[@rend ="right-aligned" or @rend="center-aligned"]
  - name: "aligned",
  - attributes: same as tei:hi in original data

## "seg[@type='item' or @type='head' or @type='row']" vs tei:item or tei:head or tei:row
  - conversion of seg[@type='item' or @type=''head or @type='row'] into tei:item or tei:head or tei:row

## "rdgMarker"
  - new element representing scribal abbreviations (sigla)
  - name: "rdgMarker"
  - attributes: @wit (witness without '#'), @ref (reference to @id of tei:lem or tei:rdg without '#'), @type (same as tei:rdg), @mark ('open' or 'close'), @context (context of the marker - "rdg" or "lem")

## "tei:rdg" or "tei:lem"
  - new attribute: @id (generated ID during the preprocessing, serving as referenced id by the rdgMarkers)

## "tei:pb[@break="no"]"
  - new attribute: @break="no" (In cases a tei:pb is directly preceeded or followed by a character not self whitespace)

## text() and whitespace
  - All whitespaces in text() are replaced by @ to save whitespace during the processing
