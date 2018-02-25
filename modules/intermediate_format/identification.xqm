xquery version "3.0";
(:~  
 : IDENTIFICATION Module ("ident", "http://bdn.edition.de/intermediate_format/identification")
 : *******************************************************************************************
 : This module defines functions and variables to set reading markers in tei:lem or tei:rdg elements.
 : The problem it solves is to identify non-Blocklevel-elements self not containing Blocklevel-elements
 : on their first or last decendants path to set textcritical markers required in the printed version of a
 : BdN digital edition.
 :
 : The basic idea is constructing some kind of left- and right-branch AXIS for reading nodes (tei:lem and tei:rdg) describing
 : a save axis of non-Blocklevel nodes (non-BLE) self not including BLEs on their own left- or right-branch AXIS down the tree.  
 : 
 : It includes the helping module "markerset" holding helper functions to collect and construct reading markers
 
 : @version 2.0 (2018-01-29)
 : @note This new versions identification algorithm is more flexible and much more configurable as in the old version 1
 : @status working
 : @author Uwe Sikora
 :)
module namespace ident="http://bdn-edition.de/intermediate_format/identification";
import module namespace markerset = "http://bdn-edition.de/intermediate_format/markerset" at "markerset.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";


(:############################# Modules Variables #############################:)

(:~  
 : ident:blocklevel-elements
 : Variable defining Blocklevel Elements (BLE) by name 
 : 
 : @version 2.0 (2018-01-29)
 : @author Uwe Sikora
 :)
declare variable $ident:blocklevel-elements := ('titlePage', 'titlePart', 'aligned', 'div', 'list', 'item', 'table', 'row', 'cell', 'head', 'p', 'note');

(:~  
 : ident:apparatus
 : Variable defining Apparatus Elements by name 
 : 
 : @version 1.0 (2018-02-05)
 : @author Uwe Sikora
 :)
declare variable $ident:apparatus := ('app');

(:~  
 : ident:apparatus-readings
 : Variable defining Apparatus-Child Elements by name 
 : 
 : @version 1.0 (2018-02-05)
 : @author Uwe Sikora
 :)
declare variable $ident:apparatus-readings := ('lem', 'rdg');

(:############################# Modules Functions #############################:)

(:~  
 : ident:in-sequence()
 : This function checks if nodes are includes in a sequence of nodes 
 :
 : @param $values the nodes to check against the sequence
 : @param $sequence a sequence of AtomicTypes
 : @return xs:boolean ('true' else 'false')
 : 
 : @version 2.0 (2018-01-29)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:in-sequence
    ( $values as xs:anyAtomicType* , $sequence as xs:anyAtomicType* ) as xs:boolean {
    
    $values = $sequence
};


(:~  
 : ident:is-or-are-ble()
 : This function checks if nodes are Blocklevelelements 
 :
 : @param $values the nodes to check against the sequence
 : @return xs:boolean ('true' else 'false')
 : 
 : @version 2.0 (2018-01-29)
 : @note derived function from ident:in-sequence
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:is-or-are-ble
    ( $values as xs:anyAtomicType* ) as xs:boolean {
    
    $values = $ident:blocklevel-elements
};


(:~  
 : ident:left-branch-axis()
 : This recursive function describes a pseudo axis "LEFT-BRANCH AXIS" of a given node. The left-branch axis
 : incorporates all first nodes of a subtree (aka the left branch) represented by a node and its descendants.
 : In case one of the nodes on this axis is self a tei:app the axis is rerouted from the tei:app downwards the branch 
 : according to defined parameters. 
 :
 : @param $node the nodes on the AXIS from where all following nodes and thus the AXIS itself is defined
 : @return set of node() representing the AXIS
 : 
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:left-branch-axis
    ( $node as node()? ) as node()* {
    
    let $first-child := (
        let $target := $node/child::node()[1]
        return
            (: AXIS CONTROLL of the left-branch :)
            
            (: IN CASE there is an tei:app, be ready to change the axis to 
               the first tei:rdg[ppl, ptl] and its first child::node()! :)
            if ( $target[self::app] ) then (
                
                (: If tei:app has an empty tei:lem change the axis to tei:lems last child() :)
                if ( empty($target/child::lem/node()) ) then (
                    $target/child::rdg[@type eq "ppl" or @type eq "ptl"][1]/node()[1]
                ) 
                
                (: If tei:app has no empty tei:lem
                   follow the normal axis from tei:app :)
                else (
                    $target
                ) 
            ) 
            
            (: If there is no tei:app proceed on normal axis by default :)
            else (
                $target
            )
    )
    return
        if($first-child) then ($first-child, ident:left-branch-axis($first-child)) else () 
};


(:~  
 : ident:right-branch-axis()
 : This recursive function describes a pseudo axis "RIGHT-BRANCH AXIS" of a given node. The right-branch axis
 : incorporates all last() nodes of a subtree (aka the right branch) represented by a node and its descendants.
 : In case one of the nodes on this axis is self a tei:app the axis is rerouted from the tei:app downwards the branch 
 : according to defined parameters.
 :
 : @param $node the nodes in the AXIS from where all following nodes and thus the AXIS itsel is defined
 : @return set of node() representing the AXIS
 : 
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:right-branch-axis
    ( $node as node()? ) as node()* {
    
    let $last-child := (
        let $target := $node/child::node()[last()]
        return
            (: AXIS CONTROLL for the right-branch :)
            
            (: IN CASE there is an tei:app, be ready to change the axis ! :)
            if ( $target[self::app] ) then (
                
                (: If tei:apps last child is a tei:rdg[ppl, ptl] change the axis to this rdg and 
                   its last child() :)
                if ( $target/child::node()[last()][ self::rdg[@type eq "ppl" or @type eq "ptl"] ] ) then (
                    $target/child::node()[last()]/child::node()[last()]
                )
                
                (: If tei:apps last child is a tei:rdg[pp, pt] stop here and return the tei:app :)
                else if ( $target/child::node()[last()][ self::rdg[@type eq "pp" or @type eq "pt"] ] ) then (
                    $target
                )
                
                (: If tei:app has no last child tei:rdg[ppl, ptl] and its tei:lem is not empty 
                   change the axis to tei:lems last child() :)
                else if ( not(empty($target/child::lem/node())) ) then (
                    $target/lem/child::node()[last()]
                ) 
                
                (: If tei:app has no last child tei:rdg[ppl, ptl] and its tei:lem is empty 
                   follow the normal axis from tei:app :)
                else (
                    $target
                ) 
            ) 
            
            (: If there is no tei:app proceed on normal axis by default :)
            else (
                $target
            )
    )
    return
        if($last-child) then ($last-child, ident:right-branch-axis($last-child)) else () 
};


(:~  
 : ident:first-save-node()
 : This function identifies the first-save node for a given node()
 :
 : @param $node the node of which the first save node should be identified
 : @return the first save node of a defined set of save nodes
 : 
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:first-save-node
    ( $node as node() ) as node()* {
    
    let $first := ident:left-branch-axis($node)
                  [not ( ident:is-or-are-ble(self::node()/name()) )]
                  [not ( ident:is-or-are-ble( ident:left-branch-axis(self::node())/name() ) )]  
                  
    return $first[1]
};


(:~  
 : ident:last-save-node()
 : This function identifies the last-save node for a given node()
 :
 : @param $node the node of which the last save node should be identified
 : @return the last save node of a defined set of save nodes
 : 
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:last-save-node
    ( $node as node() ) as node()* {
                 
    let $last := ident:right-branch-axis($node)
                 [not ( ident:is-or-are-ble(self::node()/name()) )]
                 [not ( ident:is-or-are-ble( ident:right-branch-axis(self::node())/name() ) )]  
                 
    return $last[1]
};


(:~  
 : ident:identify-targets()
 : This function identifies the first and last save node for a given reading (tei:lem and tei:rdg)
 : It also collect the sibling readings as shortcuts (name and attributes) to build a set
 : of reading markers for opening and closing Markers 
 :
 : @param $node the reading nodegoing to be evaluated
 : @return evaluation report for the node acording to the following form
 :  - element "rdg" or "lem" incl. copied attributes
 :      - element "target"[@type = "open"] incl. @id (generated)
 :      - element "target"[@type = "close"] incl. @id (generated)
 :      - element "marker"[@type = "open"] incl. @id (generated)
 :      - element "marker"[@type = "close"] incl. @id (generated)
 : 
 : @version 2.0 (2018-01-31)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:identify-targets
    ( $node as node() ) as node()* {
                  
    let $first := ident:first-save-node($node)            
    let $last := ident:last-save-node($node)
    let $marker-set := markerset:collect-markers($node)
    let $markers := markerset:construct-marker-from-markerset("rdgMarker", "open", $marker-set)
    
    return
        element {$node/name()}{
            $node/@*,
            element {"target"}{
                attribute {"type"}{ "open" },
                attribute {"gid"}{ generate-id($first) }(:,
                $first:)
            },
            element {"target"}{
                attribute {"type"}{ "close" },
                attribute {"gid"}{ generate-id($last) }(:,
                $last:)
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


(:~  
 : ident:walk()
 : This recursive function represents the main conversion which adds the reading markers
 : for tei:lem and tei:rdg nodes 
 :
 : @param $nodes nodes to be converted
 : @param $reading-sequence sequence holding the evaluation reports of the relevant readings in the nodes' context
 : @return converted node
 : 
 : @version 2.2 (2018-02-21)
 : @status working
 : @author Uwe Sikora, Michelle Rodzis
 :)
declare function ident:walk
    ( $nodes as node()*, $reading-sequence as item()* ) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case comment() return ()
            case text() return (
                if (normalize-space($node) eq "") then () else (
                    ident:mark-node($node, $reading-sequence)
                )
            )
            case element(teiHeader) return ( $node )
            
            (: 
                considering all tei:rdg except structural-variances and textcritical tei:rdg[@type="v"]
                Also ignore tei:rdg with types "typo_corr", "invisible-ref", "varying-target" - They don't need Markers 
            :)
            case element(rdg) return (
                if ( not(
                        $node/parent::app[ @type eq "structural-variance" ] or 
                        $node[@type="v" or @type="typo_corr" or @type="invisible-ref" or @type="varying-target"]
                        ) 
                    ) then (
                    let $identified-targets := ident:identify-targets($node)
                    return ident:mark-node( $node, ($reading-sequence, ident:identify-targets($node)) )
                ) else (
                    ident:mark-node($node, $reading-sequence)
                )
            )
            
            (: considering all tei:lem except structural-variances :)
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


(:~  
 : ident:mark-node()
 : This function checks if a given node is a identified first or last save node
 : and sets in case of positive identification sets opening and closing markers before and after the node
 :
 : @param $nodes nodes to be checked and in case of positive identification decorated with markers
 : @param $reading-sequence sequence holding the evaluation reports of the relevant readings in the nodes' context
 : @return converted node()
 : 
 : @version 2.0 (2018-02-01)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:mark-node
    ( $node as node(), $reading-sequence as item()* ) as node()* {
    
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
                
                if ($node[not(name())]) then (
                    <ERROR>{$node}</ERROR>
                ) else (
                    element{$node/name()}{
                        $node/@*,
                        ident:walk($node/node(), $reading-sequence)
                    }
                )
                
            ) else (
                $node
            )
        )
};


(:~  
 : ident:mark-text()
 : This function checks if a given text() is a identified first or last save node
 : and sets in case of positive identification sets opening and closing markers before and after the node
 :
 : @param $nodes nodes to be checked and in case of positive identification decorated with markers
 : @param $reading-sequence sequence holding the evaluation reports of the relevant readings in the nodes' context
 : @return converted node()
 : 
 : @version 2.0 (2018-02-01)
 : @status deprecated. integrated in ident:mark-node()
 : @author Uwe Sikora
 :)
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


(:~  
 : ident:fetch-marker-from-sequence()
 : Helperfunction to collect the reading markers from a given reading sequence
 :
 : @param $node-id id to be checked against the reading-sequences target-ids
 : @param $reading-sequence sequence holding the evaluation reports of the relevant readings in the nodes' context
 : @return reading markers as node()* for the node associated with node-id
 : 
 : @version 2.0 (2018-02-01)
 : @status working
 : @author Uwe Sikora
 :)
declare function ident:fetch-marker-from-sequence
    ( $node-id as xs:string, $reading-sequence as item()* ) as node()* {
    
    for $seq-item in $reading-sequence
    let $found := $seq-item/target[@gid = $node-id]
    let $found-type := $found/string(@type)
    let $markers := $seq-item/marker[@type = $found-type]
    where $found
    return
        $markers
};