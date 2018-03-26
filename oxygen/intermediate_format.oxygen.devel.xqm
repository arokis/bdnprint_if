xquery version "3.0";


declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace markerset = "http://bdn-edition.de/intermediate_format/markerset" at "../modules/intermediate_format/markerset.xqm";
import module namespace pre = "http://bdn-edition.de/intermediate_format/preprocessing" at "../modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn-edition.de/intermediate_format/identification" at "../modules/intermediate_format/identification.xqm";
import module namespace test = "http://bdn-edition.de/intermediate_format/unit_testing" at "devel/modules/unittesting.xqm";
(:declare namespace target = "http://www.interform.com/target_index";
import module "http://www.interform.com/target_index" at "targetindex.xqm";
:)


declare namespace tei = "http://www.tei-c.org/ns/1.0";
(:declare option saxon:output "indent=no";:)


declare function local:app-index
    ( $apps as node()* ) as item()* {
    
    let $entries := ( 
        for $app at $nr in $apps
        let $readings := $app/child::node()[self::lem or self::rdg]
        return 
            element {$app/name()}{
                attribute {"n"}{$nr},
                local:check-readings($readings)
            }
    )
    return element {"appIndex"}{ attribute {"count"}{ count($entries) }, $entries }
};


(:declare function local:target-in-index
    ( $target-id as xs:string?, $app-index as node() ) as item()* {
    
    if ( $target-id ) then (
        let $readings := $app-index//node()[self::first or self::last][@target = $target-id]
        return 
            $readings
    ) else (  )
    
};:)


declare function local:controll-app
    ($app as node()) as item()* {
    
    let $self := $app
    let $readings := $app/child::node()[self::lem or self::rdg]
    return 
        element {$app/name()}{
            $app/@*,
            local:check-readings($readings)
        }
};

(: WORKS :)
declare function local:first-descendants
    ($node as node()?) as node()* {
    
    let $first-child := $node/child::node()[1][not(self::text())]
    return
        if($first-child) then ($first-child, local:first-descendants($first-child)) else () 
};


(: WORKS :)
declare function local:last-descendants
    ($node as node()?) as node()* {
    
    let $last-child := (
        let $target := $node/child::node()[last()][not(self::text())]
        return
            if ($target[self::app]) then (
                (: Possibility to jump into rdg[type="ppl, ptl, pp, pt"]:)
                $target/lem
            ) 
            else (
                $target
            )
    )
    return
        if($last-child) then ($last-child, local:last-descendants($last-child)) else () 
};


declare function local:check-readings
    ( $readings as node()* ) as item()* {
    
    for $reading in $readings
    return local:check-reading($reading)
};



declare function local:check-reading
    ( $reading as node() ) as item()* {
    
    let $first-save-node := local:first-descendants($reading)[ local:is-save-first-node(self::node()) ][1]
    let $last-save-node := local:last-descendants($reading)[ local:is-save-last-node(self::node()) ][1]
    return 
        element {$reading/name()}{
            $reading/@*,
            (:element {"SELF"}{
                $reading
            },:)
            if ( $reading[ not(@type eq "om" or empty($reading/node()))  ] ) then (
                if ($first-save-node eq $last-save-node) then (
                    element{"target"}{
                        (:attribute {"id"}{ $first-save-node/string(@interformId) },:)
                        attribute {"gid"}{ generate-id( $first-save-node ) },
                        attribute {"type"} {"open close"},
                        $first-save-node
                    }
                ) else (
                    element {"target"}{
                        (:attribute {"id"}{ $first-save-node/string(@interformId) },:)
                        attribute {"gid"}{ generate-id( $first-save-node ) },
                        attribute {"type"} {"open"},
                        $first-save-node
                    },
                    element {"target"}{ 
                        (:attribute {"id"}{ $last-save-node/string(@interformId) },:)
                        attribute {"gid"}{ generate-id( $last-save-node ) },
                        attribute {"type"} {"close"},
                        $last-save-node
                    }
                ),
                markerset:collect-markers($reading)
            ) else ()
        }
};


declare function local:is-save-first-node
    ($node as node()) as xs:boolean {
    let $first-descendants := local:first-descendants($node)
    let $has-save-first-descendants := not ( ident:in-sequence($first-descendants/name(), $ident:blocklevel-elements) )
    let $self-ble := functx:is-value-in-sequence( $node/name(), $ident:blocklevel-elements )
    return 
        if ($has-save-first-descendants and not ($self-ble)) then (true()) else (false())
};


declare function local:is-save-last-node
    ($node as node()) as xs:boolean {
    let $last-descendants := local:last-descendants($node)
    let $has-save-last-descendants := not ( ident:in-sequence($last-descendants/name(), $ident:blocklevel-elements) )
    let $self-ble := functx:is-value-in-sequence( $node/name(), $ident:blocklevel-elements )
    return 
        if ($has-save-last-descendants and not ($self-ble)) then (true()) else (false())
};


let $doc := .
let $pre := pre:preprocessing($doc/node())
(:let $pre := pre:preprocessing($doc/node())
let $app-index := local:app-index( $pre//app[not(@type)] )
let $target-index := target:index($app-index):)
let $test := 
    <test>
        <app>
               <lem><item><app>
                        <lem/>
                        <rdg wit="#c" type="pt"><milestone unit="p" edRef="#c" type="structure"
                              /><seg xml:id="var_1_51_p3_1">Unter den Neueren:</seg></rdg>
                     </app><milestone unit="line" edRef="#c" type="structure"/><seg
                        xml:id="var_1_51_p3_item1"><index indexName="persons">
                           <term>Mosheim, Johann Lorenz von</term>
                        </index><persName ref="#textgrid:250j4"><hi>Joh. Lorenz von</hi><app>
                              <lem><hi>Mosheims</hi></lem>
                              <rdg wit="#c" type="v"><hi>Mosheim</hi></rdg>
                           </app></persName> kurze Anweisung, die Gottesgelahrtheit vernünftig zu
                        erlernen – – zum Druck befördert von <index indexName="persons">
                           <term>Windheim, Christian Ernst von</term>
                        </index><hi><persName ref="#textgrid:250j5">Christian Ernst von
                              Windheim</persName></hi>, Helmstädt 1756.<ptr target="#textgrid:250j7"
                        /> in <choice>
                           <abbr>gr.</abbr>
                           <expan>groß</expan>
                        </choice> 8.</seg></item></lem>
               <rdg wit="#a" type="om"/>
            </app>
    </test>

let $lem := $test/app/lem
return (
    (:ident:left-nodes-path($test),:)
    (:test:branch-axis($test):)
    (:test:reading-evaluation($test):)
    (:test:reading-evaluation($pre):)
    (:test:identify-target($test):)
    (:test:branch-axis($test):)

    
    (:test:reading-evaluation($pre):)
    
    (:ident:left-branch-axis($lem):)
    (:ident:first-save-node($lem):)
    (:ident:walk($test, ()):)
    
    (:$pre:)
    ident:walk($pre, ())
(:    $target-index:)
    (:local:target-in-index("d0t36", $app-index),:)
    (:target:conversion-by-target-index($pre, $target-index):)
)