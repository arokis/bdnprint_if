xquery version "3.0";


declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace markerset = "http://bdn.edition.de/intermediate_format/markerset" at "../modules/intermediate_format/markerset.xqm";
import module namespace pre = "http://bdn.edition.de/intermediate_format/preprocessing" at "../modules/intermediate_format/preprocessing.xqm";
import module namespace ident = "http://bdn.edition.de/intermediate_format/identification" at "../modules/intermediate_format/identification.xqm";

(:declare namespace target = "http://www.interform.com/target_index";
import module "http://www.interform.com/target_index" at "targetindex.xqm";
:)


declare namespace tei = "http://www.tei-c.org/ns/1.0";
(:declare option saxon:output "indent=no";:)


declare variable $apparatus := ('app');
declare variable $apparatus-childs := ('lem', 'rdg');
declare variable $blocklevel-elements := ('titlePage', 'titlePart', 'aligned', 'div', 'list', 'item', 'table', 'row', 'cell', 'head', 'p', 'note');


declare function local:in-sequence
    ( $values as xs:anyAtomicType* , $sequence as xs:anyAtomicType* ) as xs:boolean {
    
    $values = $sequence
};


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
    let $has-save-first-descendants := not ( local:in-sequence($first-descendants/name(), $blocklevel-elements) )
    let $self-ble := functx:is-value-in-sequence( $node/name(), $blocklevel-elements )
    return 
        if ($has-save-first-descendants and not ($self-ble)) then (true()) else (false())
};

declare function local:is-save-last-node
    ($node as node()) as xs:boolean {
    let $last-descendants := local:last-descendants($node)
    let $has-save-last-descendants := not ( local:in-sequence($last-descendants/name(), $blocklevel-elements) )
    let $self-ble := functx:is-value-in-sequence( $node/name(), $blocklevel-elements )
    return 
        if ($has-save-last-descendants and not ($self-ble)) then (true()) else (false())
};

declare function local:axis-test
    ( $node as node() ) as item() {
    let $left-axis := ident:left-branch-axis($node)
    let $right-axis := ident:right-branch-axis($node)
    return 
        element {"axisTest"}{
            element {"node"}{$node},
            (:element {"test"}{
                 attribute {"index"}{fn:index-of($left-axis, $left-axis[4])},
                 fn:index-of($left-axis, $left-axis[ ident:is-or-are-ble(self::node()/name()) ][last()])
            },:)
            element {"leftAxis"}{
                attribute {"names"}{$left-axis/name()},
                for $item at $nr in $left-axis
                return 
                    element {"item"}{
                        attribute {"n"}{$nr},
                        attribute {"gid"}{generate-id($item)},
                        $item
                    }
            },
            element {"rightAxis"}{
                attribute {"names"}{$right-axis/name()},
                for $item at $nr in $right-axis
                return 
                    element {"item"}{
                        attribute {"n"}{$nr},
                        attribute {"gid"}{generate-id($item)},
                        $item
                    }
            }
        }
};


let $doc := .
let $pre := pre:preprocessing($doc/node())
(:let $pre := pre:preprocessing($doc/node())
let $app-index := local:app-index( $pre//app[not(@type)] )
let $target-index := target:index($app-index):)
let $test := <test>
    <div>
        <head>
            <app>
                <lem>Überschrift</lem>
                <rdg wit="#a" type="v">überschrift</rdg>
            </app>
        </head>
        <p>Erster Absatz</p>
        <p>Zweiter Absatz</p>
        <note>
            <app>
                <lem>Anmerkung</lem>
                <rdg wit="#a" type="v">anmerkung</rdg>
                <rdg wit="#b" type="ppl"><div>DIV anmerkung</div></rdg>
                <rdg wit="#c" type="v"><div>DIV2 anmerkung</div></rdg>
            </app>
        </note>
    </div>
</test>
return (
    (:ident:left-nodes-path($test),:)
    (:local:axis-test($test):)
    (:ident:identify-unit-test($pre):)
    (:$pre:)
    ident:walk($pre, ())
(:    $target-index:)
    (:local:target-in-index("d0t36", $app-index),:)
    (:target:conversion-by-target-index($pre, $target-index):)
)