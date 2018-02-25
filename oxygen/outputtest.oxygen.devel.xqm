xquery version "3.0";


declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace output = "http://bdn-edition.de/intermediate_format/output_testing" at "devel/modules/outputtesting.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
(:declare option saxon:output "indent=no";:)


let $doc := .

return (
    output:marker-evaluation($doc)
)