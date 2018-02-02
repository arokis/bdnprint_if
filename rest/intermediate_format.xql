xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace functx="http://www.functx.com";
import module namespace pre="http://bdn.edition.de/intermediate_format/preprocessing" at "xmldb:exist:///db/apps/interform/modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn.edition.de/intermediate_format/identification" at "xmldb:exist:///db/apps/interform/modules/intermediate_format/identification.xqm";


declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";

(: http://localhost:8080/exist/rest/apps/interform/rest/intermediate_format.xql :)
(:   :declare variable $doc-path := request:get-parameter("path", ());   :) 
declare variable $doc-path := "/apps/interform/data/sample1.xml";
let $doc := doc($doc-path)
let $preprocessed-data := pre:preprocessing($doc/tei:TEI)
return (
    ident:walk($preprocessed-data, ())
)