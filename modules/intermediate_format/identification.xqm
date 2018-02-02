xquery version "3.0";

module namespace ident="http://bdn.edition.de/intermediate_format/identification";
import module namespace markerset = "http://bdn.edition.de/intermediate_format/markerset" at "markerset.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";


declare variable $ident:blocklevel-elements := ('titlePage', 'titlePart', 'aligned', 'div', 'list', 'item', 'table', 'row', 'cell', 'head', 'p', 'note');

declare function ident:in-sequence
    ( $values as xs:anyAtomicType* , $sequence as xs:anyAtomicType*) as xs:boolean {
    
    $values = $sequence
};

declare function ident:is-or-are-ble
    ( $values as xs:anyAtomicType* ) as xs:boolean {
    
    $values = $ident:blocklevel-elements
};


declare function ident:first-descendants-path
    ($node as node()?) as node()* {
    
    let $first-child := (
        let $target := $node/child::node()[1]
        return
            (: PATH CONTROLL for the last-descendants-path :)
            
            (: IN CASE there is an tei:app, be ready to change the path to 
               the first tei:rdg[ppl, ptl] and its first child::node()! :)
            if ( $target[self::app] ) then (
                
                (: If tei:app has an empty tei:lem change the path to tei:lems last child() :)
                if ( empty($target/child::lem/node()) ) then (
                    $target/child::rdg[@type eq "ppl" or @type eq "ptl"][1]/node()[1]
                ) 
                
                (: If tei:app has no empty tei:lem
                   follow the normal path from tei:app :)
                else (
                    $target
                ) 
            ) 
            
            (: If there is no tei:app proceed on normal path by default :)
            else (
                $target
            )
    )
    return
        if($first-child) then ($first-child, ident:first-descendants-path($first-child)) else () 
};


declare function ident:last-descendants-path
    ($node as node()?) as node()* {
    
    let $last-child := (
        let $target := $node/child::node()[last()]
        return
            (: PATH CONTROLL for the last-descendants-path :)
            
            (: IN CASE there is an tei:app, be ready to change the path ! :)
            if ( $target[self::app] ) then (
                
                (: If tei:apps last child is a tei:rdg[ppl, ptl] change the path to this rdg and 
                   its last child() :)
                if ( $target/child::node()[last()][ self::rdg[@type eq "ppl" or @type eq "ptl"] ] ) then (
                    $target/child::node()[last()]/child::node()[last()]
                )
                
                (: If tei:app has no last child tei:rdg[ppl, ptl] and its tei:lem is not empty 
                   change the path to tei:lems last child() :)
                else if ( not(empty($target/child::lem/node())) ) then (
                    $target/lem/child::node()[last()]
                ) 
                
                (: If tei:app has no last child tei:rdg[ppl, ptl] and its tei:lem is empty 
                   follow the normal path from tei:app :)
                else (
                    $target
                ) 
            ) 
            
            (: If there is no tei:app proceed on normal path by default :)
            else (
                $target
            )
    )
    return
        if($last-child) then ($last-child, ident:last-descendants-path($last-child)) else () 
};


declare function ident:first-save-node
    ($node as node()) as node()* {
    
    let $first := ident:first-descendants-path($node)
                  [not ( ident:is-or-are-ble(self::node()/name()) )]
                  [not ( ident:is-or-are-ble( ident:first-descendants-path(self::node())/name() ) )]  
                  
    return $first[1]
};


declare function ident:last-save-node
    ($node as node()) as node()* {
                 
    let $last := ident:last-descendants-path($node)
                 [not ( ident:is-or-are-ble(self::node()/name()) )]
                 [not ( ident:is-or-are-ble( ident:last-descendants-path(self::node())/name() ) )]  
                 
    return $last[1]
};


declare function ident:identify-targets
    ($node as node()) as node()* {
                  
    let $first := ident:first-save-node($node)            
    let $last := ident:last-save-node($node)
    let $marker-set := markerset:collect-markers($node)
    let $markers := markerset:construct-marker-from-markerset("rdgMarker", "open", $marker-set)
    
    return
        element {$node/name()}{
            $node/@*,
            element {"target"}{
                attribute {"type"}{ "open" },
                attribute {"gid"}{ generate-id($first) },
                $first
            },
            element {"target"}{
                attribute {"type"}{ "close" },
                attribute {"gid"}{ generate-id($last) },
                $last
            },
            element {"marker"}{
                attribute {"type"}{ "open" },
                markerset:construct-marker-from-markerset("rdgMarker", "open", $marker-set)
            },
            element {"marker"}{
                attribute {"type"}{ "close" },
                reverse( markerset:construct-marker-from-markerset("rdgMarker", "close", $marker-set) )
            }
        }
};


declare function ident:walk
    ($nodes as node()*, $reading-sequence as item()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case text() return (
                if (normalize-space($node) eq "") then () else (
                    ident:mark-node($node, $reading-sequence)
                )
            )
            
            case element(rdg) return (
                if ( not($node/parent::app[ @type eq "structural-variance" ]) ) then (
                    let $identified-targets := ident:identify-targets($node)
                    return ident:mark-node( $node, ($reading-sequence, ident:identify-targets($node)) )
                ) else (
                    ident:mark-node($node, $reading-sequence)
                )
            )
            
            case element(lem) return (
                if ( not($node/parent::app[ @type eq "structural-variance" ]) ) then (
                    let $identified-targets := ident:identify-targets($node)
                    return ident:mark-node( $node, ($reading-sequence, ident:identify-targets($node)) )
                ) else (
                    ident:mark-node($node, $reading-sequence)
                )
            )
            
            default return ( 
                ident:mark-node($node, $reading-sequence) 
            )
};

declare function ident:mark-node
    ($node as node(), $reading-sequence as item()* ) as node()* {
    
    let $node-id := generate-id( $node )
    let $in-reading-sequence := $reading-sequence//target[@gid eq $node-id]
    return 
        if ($in-reading-sequence) then (
            let $marker := ident:fetch-marker-from-sequence($node-id, $reading-sequence)
            let $open := $marker[@type = "open"]/node()
            let $close := (for $item in reverse($marker[@type = "close"]) return $item/node())
            return(
                $open,
                if ( $node[ not(self::text()) ] ) then (
                    element{$node/name()}{
                        $node/@*,
                        ident:walk($node/node(), $reading-sequence)
                    }
                ) else (
                    $node
                ), 
                $close
           )
        ) else (
            if ( $node[ not(self::text()) ] ) then (
                element{$node/name()}{
                    $node/@*,
                    ident:walk($node/node(), $reading-sequence)
                }
            ) else (
                $node
            )
        )
};

(:declare function ident:mark-text
    ($node as node(), $reading-sequence as item()* ) as node()* {
    
    let $node-id := generate-id( $node )
    let $in-reading-sequence := $reading-sequence//target[@gid eq $node-id]
    return 
        if ($in-reading-sequence) then (
            let $marker := ident:fetch-marker-from-sequence($node-id, $reading-sequence)
            let $open := $marker[@type = "open"]/node()
            let $close := (for $item in reverse($marker[@type = "close"]) return $item/node())
            return(
                $open, $node, $close
           )
        ) else ( $node )
};:)


declare function ident:fetch-marker-from-sequence
    ($node-id as xs:string, $reading-sequence as item()* ) as node()* {
    
    for $seq-item in $reading-sequence
    let $found := $seq-item/target[@gid = $node-id]
    let $found-type := $found/string(@type)
    let $markers := $seq-item/marker[@type = $found-type]
    where $found
    return
        $markers
};


declare function ident:identify-unit-test
    ($nodes as node()*) as node()* {
    
    for $node at $nr in $nodes//node()[self::lem or self::rdg]
    let $identified-targets := ident:identify-targets($node)
    return
        element{"UTEST"}{
            attribute {"n"}{$nr},
            element {"SELF"} {$node},
            $identified-targets
        }
};