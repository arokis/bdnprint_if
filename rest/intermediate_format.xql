xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace pre="http://bdn.edition.de/intermediate_format/preprocessing" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn.edition.de/intermediate_format/identification" at "xmldb:exist:///db/apps/interformat/modules/intermediate_format/identification.xqm";
import module namespace config = "http://bdn-edition.de/intermediate_format/config" at "xmldb:exist:///db/apps/interformat/modules/config.xqm";
import module namespace ifutils="http://bdn.edition.de/intermediate_format/utils" at "xmldb:exist:///db/apps/interformat/modules/ifutils.xqm";
import module namespace console="http://exist-db.org/xquery/console";

(: http://localhost:8080/exist/rest/apps/interformat/rest/intermediate_format.xql :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";

declare variable $resource-uri := request:get-parameter("resource", ("/db/apps/interformat/data/samples/samples.xml"));
declare variable $uri := request:get-parameter("uri", ());
declare variable $mode := request:get-parameter("mode", ());

let $doc := ifutils:get-resource($resource-uri)
let $preprocessed-data := pre:preprocessing($doc/tei:TEI)
let $intermediate-format := ident:walk($preprocessed-data, ())
let $store := if ($mode = "store") then (
        let $filename := concat(replace($resource-uri, '.+/(.+)$', '$1'), ".out")
        return (
            console:log("stored resource " || xmldb:store($config:data-root || "/output", $filename, $intermediate-format))
        )
    ) else ()

return (
    $intermediate-format
)