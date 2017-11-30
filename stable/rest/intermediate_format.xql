xquery version "3.1";


declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace interform = "xmldb:exist:///db/apps/bdn/modules/intermediate_format/inter_form.xqm" at "xmldb:exist:///db/apps/bdn/modules/intermediate_format/inter_form.xqm";

(: http://localhost:8080/exist/rest/apps/bdn/rest/intermediate_format.xql :)
declare variable $doc-path := request:get-parameter("path", ());    

let $doc := doc($doc-path)

return (
    interform:build-intermediate-format($doc//tei:TEI)
)