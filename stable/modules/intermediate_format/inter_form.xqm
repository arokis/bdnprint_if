xquery version "3.1";

module namespace interform="xmldb:exist:///db/apps/bdn/modules/intermediate_format/inter_form.xqm";

import module namespace functx="http://www.functx.com";
import module namespace string = "xmldb:exist:///db/apps/bdn/modules/string.xqm" at "xmldb:exist:///db/apps/bdn/modules/string.xqm";
declare default element namespace "http://www.tei-c.org/ns/1.0";



(:~  
 : interform:preprocessing()
 : This function is used to preprocess the bdn-tei 
 : 
 : single whitespace between to node()[not(self::text())]: //text()[ self::node() = ' '][preceding-sibling::node()[not(self::node() = text())]][following-sibling::node()[not(self::node() = text())]]
 : //textNode[preceding::textNode[1][@preserved]]
 :
 : @version 1.2 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function interform:preprocessing
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case text() return (
                (: This is absolutly magical! "May Her Hooves Never Be Shod":)
                if (
                    normalize-space($node) != '' or
                    $node
                        [ self::node() = ' ']
                        [preceding-sibling::node()[not(self::node() = text())]]
                        [following-sibling::node()[not(self::node() = text())]] 
                   
                ) then (
                    element {"textNode"}{
                        interform:set-id($node),
                        string:escape-whitespace($node, '&#x1f984;')
                    }
                   
                ) else ()
                
                (:interform:preservedText($node, '&#x1f984;'):)
            )
            
            (: COMPLETE IGNORE :)
            case comment() return ((:$node:))
            
            case element(teiHeader) return (
                element {name($node)} { 
                     $node/@*, 
                     $node/node()
                 } 
            )
            
            (:
            case element(encodingDesc) return (
                interform:preprocessing($node/following-sibling::node()[1])
            )
            
            case element(revisionDesc) return (
                interform:preprocessing($node/following-sibling::node()[1])
            )
            :)
            (:case element(ptr) return (
                interform:preprocessing($node/node())
            ):)
            
            (: ELEMENT IGNORE :)
            (:case element(choice) return (
                if ($node[child::expan and child::abbr]) then (
                    interform:preprocessing($node/abbr/node())
                )
                else (
                    element {name($node)} { 
                        $node/@*,
                        interform:preprocessing($node/node())
                    }
                ) 
            ):)
            
            (:
            case element(byline) return (
                interform:preprocessing($node/node())
            )
            
            case element(docAuthor) return (
                interform:preprocessing($node/node())
            )
            
            case element(persName) return (
                if ($node[ not (ancestor::index) ]) then (
                    interform:preprocessing($node/node())
                ) 
                else (
                    interform:preprocessing-default($node)
                )
            )
            
            case element(docEdition) return (
                interform:preprocessing($node/node())
            )
            
            case element(docImprint) return (
                interform:preprocessing($node/node())
            )
            
            case element(docDate) return (
                interform:preprocessing($node/node())
            )
            :)
            
            (:case element(ref) return (
                interform:preprocessing($node/node())
            ):)
            
            (:case element(foreign) return (
                interform:preprocessing($node/node())
            ):)
            
            case element(div) return (
                if ($node[@type = 'section-group']) then (
                    interform:preprocessing($node/node())
                ) 
                else (
                    interform:preprocessing-default($node)
                )
                
            )
            
            (: CHANGE :)
            case element(rdg) return (
                interform:preprocessing-default($node) 
            )
            
            case element(hi) return (
                if($node[@rend = 'right-aligned' or @rend = 'center-aligned']) then(
                    element {'aligned'} {
                        $node/@*,
                        interform:set-id($node),
                        interform:preprocessing($node/node())
                    } 
                )
                else (
                    interform:preprocessing-default($node)
                )
            )
            
            case element(seg) return (
                if($node[@type = 'item']) then(
                    element {'item'} {
                        $node/@*[name() != 'type'],
                        interform:set-id($node),
                        interform:preprocessing($node/node())
                    } 
                )
                else if($node[@type = 'row']) then(
                    element {'row'} {
                        $node/@*[name() != 'type'],
                        interform:set-id($node),
                        interform:preprocessing($node/node())
                    } 
                )
                else (
                    interform:preprocessing-default($node) 
                )
            )
            
            default return ( 
                interform:preprocessing-default($node)
            )
};

declare function interform:preprocessing-default
    ($node as node()) as item()* {
    
    element {name($node)} { 
        $node/@*, 
        interform:set-id($node),
        interform:preprocessing($node/node())
    }  
};

declare function interform:set-id
    ($node as node()) as item()* {
    
    if ($node/ancestor-or-self::app) then (
        attribute id {fn:generate-id($node)}   
    ) 
    else ()
};

(:~  
 : interform:postprocessing() 
 : - reduces all text() with preservation character to get rid of all conversion related whitespaces 
 : - kicks out all rdgMarkers an tei:rdg nodes not wanted
 :
 : @version 1.1 (2017-09-18)
 : @author Uwe Sikora
 :)
declare function interform:postprocessing
    ($nodes as node()*, $escaped_whitespace as xs:string) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case text() return (
                let $norm := string:escape-and-normalize($node, $escaped_whitespace)
                (:let $reduce_expression := concat('[', $escaped_whitespace, ']+')
                let $save := replace(normalize-space($node), "[\s]+", $escaped_whitespace)
                let $reduce := replace($save, $reduce_expression, $escaped_whitespace):)
                return
                    replace($norm, $escaped_whitespace, ' ')
                    (:$norm:)
            )
            
            case comment() return $node
            
            case element(rdgMarker) return (
                if ($node[@type != 'var-structure']) then (
                    element {name($node)} {
                        $node/@*, 
                        interform:postprocessing($node/node(), $escaped_whitespace)
                    }
                ) else ()
            )
            
            case element(rdg) return (
                if ($node[@type != 'var-structure']) then (
                    element {name($node)} {
                        $node/@*, 
                        interform:postprocessing($node/node(), $escaped_whitespace)
                    }
                ) else (
                    element {name($node)} {
                        $node/@*, 
                        interform:postprocessing($node/following-sibling::node()[1], $escaped_whitespace)
                    }
                )
            )
            
            default return (
                element {name($node)} {
                    $node/@*, 
                    interform:postprocessing($node/node(), $escaped_whitespace)
                }
            )
};

(: ##############################################################################################################
 :      Intermediate Format: Main Conversion routine
 :      ********************************************
 : 
 :      -
 :      -
 : ############################################################################################################## :)

declare variable $interform:appElements := ('app', 'lem', 'rdg');
declare variable $interform:blockLevelElements := ('titlePage', 'titlePart', 'aligned', 'div', 'list', 'item', 'table', 'row', 'cell', 'head', 'p', 'note');
 
declare function interform:build-intermediate-format
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    let $preprocessing := interform:preprocessing($node)
    let $app-index := interform:app-index($preprocessing)
    let $map := interform:marker-targets($app-index)
    return
        interform:transform-map($preprocessing, $map)
};


declare function interform:transform-map
    ($nodes as node()*, $map) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ($node)
            case text() return (
                let $norm := string:escape-and-normalize($node, '&#x1f984;')
                return
                    replace($norm, '&#x1f984;', '&#x20;')
            )
            
            case comment() return ($node)
            
            case element(lem) return (
                if ( (count($node/node()) < 1) and $node[not(@type)]) then (
                    element {"lem"}{
                       $node/@*[not(name(.) eq "id")],
                       attribute {"type"}{"om"}
                    }
                ) else (
                    element {name($node)}{
                        $node/@*[not(name(.) eq "id")],
                        interform:transform-map($node/node(), $map)
                    }
                )
            )
            
            case element(textNode) return (
                let $marks := interform:get-marks($node, $map)
                return (
                    $marks[self::open]/node(),
                    interform:transform-map($node/node(), $map),
                    $marks[self::close]/node()
                )
            )
            
            default return (
                let $marks := interform:get-marks($node, $map)
                return (
                    $marks[self::open]/node(),
                    element {name($node)}{
                        if ( $node[ not(self::rdg) ] ) then ($node/@*[not(name(.) eq "id")]) else ($node/@*),
                        interform:transform-map($node/node(), $map)
                    },
                    $marks[self::close]/node()
                )
            )
};
(: **************************************************************************************************************
 :      APP-Index Conversion
 : ************************************************************************************************************** :)

declare function interform:app-index
    ($nodes as node()*) as item()* {
    
    let $apps := $nodes//app
    let $index := (
        for $node at $nr in $apps
        let $childs := $node/node()
        let $entry := ( 
            
            element {"entry"}{
                attribute {"n"}{$nr},
                (:element{"COMPARE"}{$node},:)
                element{"childs"} {
                    for $child in $childs
                    return (
                        interform:index-app-child($child, ($interform:blockLevelElements, $interform:appElements), $nr)
                    )
                }
            }
         )
         return
        $entry
     )
     
     return <index>{$index}</index>
     
};


declare function interform:index-app-child
    ($node as node()*, $sequence as item()*, $app-index as xs:integer) as item()* {
    
    element {name($node)}{
        $node/@*,
        element {"position"}{
            let $first := interform:first-or-last-save-node("first", $node//node(), ($sequence))
            let $last := interform:first-or-last-save-node("last", $node//node(), ($sequence))
            return (
                if ($first) then (
                    element{"first"}{
                        attribute {"target"}{$first/string(@id)},
                        attribute {"name"}{name($first)},
                        $first
                    }
                ) else (),
                if ($last) then (
                    element{"last"}{
                        attribute {"target"}{$last/string(@id)},
                        attribute {"name"}{name($last)},
                        $last
                    }
                ) else ()
            )
        },
        element {"markers"}{
            attribute {"index"}{$app-index},
            if ($node[self::lem]) then (
                attribute {"count"}{count($node/following-sibling::node())},
                for $sibling in $node/following-sibling::node()
                return(
                    element {name($sibling)} {
                        $sibling/@*, 
                        attribute {"context"}{"lem"}
                    }
                )
            ) 
            else if ($node[self::rdg]) then (
                element {name($node)} {
                    $node/@*,
                    attribute {"context"}{"rdg"}
                }
            )
            else ()
        }
        
    }
};


(:~ 
 : interform:first-or-last-save-node
 : This function identifies the first or last save node() with regard to a given sequence of element names.
 : When the first or last node is identified it bubbles the tree up to determine the first uncritical ancestor 
 : 
 : NOTE: works
 :
 : @version 1.0 (2017-11-15)
 : @author Uwe Sikora
 :)
declare function interform:first-or-last-save-node
    ($position as xs:string, $nodes as node()*, $sequence as item()*) {
    
    let $node-set := $nodes
            [not( self::text() )]
            [not( interform:are-nodes-in-sequence(descendant-or-self::node(), $sequence) )]
    
    let $target := ( 
        if ($position eq "first") then (
            let $first := functx:first-node($node-set)
            return
                interform:bubble-sequence($first, $sequence)
        ) 
        else if ($position eq "last") then (
            let $last := functx:last-node($node-set)
            (: let $ancestor := $last/ancestor-or-self::node()[ not (interform:are-nodes-in-sequence(descendant-or-self::node(), $sequence)) ]:)
            return
              interform:bubble-sequence($last, $sequence)
        ) else ()
    )
    
    return (    
        $target
    )
};


(:~ 
 : interform:bubble-sequence
 : This function bubbles up from a given node to identify the nearest uncritical ancestor with regard to a given sequence of node-names.
 : If the parent node's name of the given node is already in the sequence there is no need to bubble up since it is already the save node
 : we are looking for
 : 
 : NOTE: works
 :
 : @version 1.0 (2017-11-15)
 : @author Uwe Sikora
 :)
declare function interform:bubble-sequence
    ($node as node()?, $sequence) as item()* {
    
    if( functx:is-value-in-sequence(name($node/parent::node()), $sequence) ) then (
         $node
    ) 
    else (
        $node/ancestor::node()[ functx:is-value-in-sequence(name(parent::node()), $sequence) ][1]
        (:<t count="{ count($node/parent::node()) }" parent="{name($node/parent::node())}">
            <orig>{$node}</orig>
            <ancestor>
                { $node/ancestor::node()[ functx:is-value-in-sequence(name(parent::node()), $sequence) ][1] }
            </ancestor>
        </t>:)
    )
};


(:~  
 : interform:are-nodes-in-sequence()
 : This function checks if a node() from a given nodeset is or contains named Elements in a sequence. 
 : In this case it returns 'true' else 'false' 
 :
 : @param $nodes the nodes() to check for BLEs
 : @param $bleElements a list of defined BLEs
 : @return xs:boolean ('true' else 'false')
 : 
 : @version 1.1 (2017-09-22)
 : @status working
 : @author Uwe Sikora
 :)
declare function interform:are-nodes-in-sequence
    ($nodes as node()*, $sequence as item()*) as xs:boolean{
    
    some $node in $nodes
    satisfies
        if(functx:is-value-in-sequence($node/name(), $sequence)) then(
            fn:true()
        ) 
        
        else (
            fn:false()
        )
};

(: **************************************************************************************************************
 :      Target Mapping Conversion
 : ************************************************************************************************************** :)

declare function interform:marker-targets
    ($app-index) {
    
    let $targets := $app-index//node()[self::first or self::last]
    let $ids := distinct-values( $targets/string(@target) )
    let $map := map:merge(
        for $id in $ids
        let $targets-by-id := $targets[@target eq $id]
        return 
            map:entry($id , 
                element {"target"} {
                    attribute {"id"}{$id},
                    (:element {"COMPARE"}{
                        $targets-by-id/ancestor::node()[self::lem or self::rdg]/parent::node()/parent::node()
                    },:)
                    element {"targetNode"}{
                        $targets-by-id[1]/node()
                    },
                    element {"markers"}{
(:                        element {"open"}{interform:first-marker-set($id, $app-index)},:)
(:                        element {"close"}{interform:last-marker-set($id, $app-index)}:)
                        element {"open"}{interform:create-marker-sets($targets-by-id[self::first], "open")},
                        element {"close"}{ reverse(interform:create-marker-sets($targets-by-id[self::last], "close")) }
                    }
               }
           )
    )
    
    return 
        ($map)

};


(:~  
 : interform:create-marker-sets
 : This function creates marker sets for each given target. The input needs to be the last- or first-nodes().
 : Afterwards the single readings are merged for each set and rdgMarkers are build
 :
 : @param $marker-set the nodes() representing a set of Markers
 : @param $marker-type the type of the marker ("open" or "close")
 : @return set of element("rdgMarker")*
 : 
 : @version 1.1 (2017-09-22)
 : @status working
 : @author Uwe Sikora
 :)
declare function interform:create-marker-sets
    ( $marker-set as node()* , $marker-type as xs:string) as item()* {
    
    let $targets := (
        for $item in $marker-set
        let $entry-index := $item/ancestor::entry/string(@n)
        let $markers :=  $item/parent::position/following-sibling::markers/node()
        let $merged := interform:merge-readings($markers[not(@type eq "v")])
        order by $entry-index ascending
        return 
            interform:build-markers($marker-type, $merged)
    )
    
    return $targets
};


(:~  
 : interform:build-markers()
 : constructs rdgMarker elements from set of tei:rdg nodes
 :
 : @param $type The type of the marker element
 : @param nodes A set of tei:rdg elements
 : @return rdgMarker element()s for each rdg in the set
 :
 : @version 1.1 (2017-09-13)
 : @author Uwe Sikora
 :)
declare function interform:build-markers
    ($type as xs:string, $nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        interform:marker('rdgMarker', $type, $node)
};


(:~  
 : interform:marker() - Marker Constructor
 : Constructor function whch creates the marker element with name, mark-type and references 
 :
 : @param $name The name of the marker element
 : @param $mark The mark type e.g. open or close
 : @param $rdg_node The node which is marked
 : @return element() the marker element
 :
 : @version 1.1 (2017-09-13)
 : @author Uwe Sikora
 :)
declare function interform:marker
    ($name as xs:string, $mark as xs:string, $rdg_node as node()) as element(){
    
    let $marker_name := $name
    let $marker_mark := $mark
    let $marker_rdg_type := data($rdg_node/@type)
    let $marker_rdg_ref := data($rdg_node/@id)
    let $marker_rdg_wit := replace(data($rdg_node/@wit), '#', '')
    return (
        element {$marker_name} {
            (:attribute bdnp_parent {$node/parent::node()/name()}, :)
            attribute wit {$marker_rdg_wit},
            attribute type {$marker_rdg_type},
            attribute ref {$marker_rdg_ref},
            attribute mark {$marker_mark},
            attribute context {$rdg_node/@context}
        }
    )
};


(:~
 : interform:merge-readings()
 : This function merges all readings in the given set sharing the same tei:rdg[@type]
 : If no type was provided 'none' is set as type
 :
 : @param $readings the readings as a sequence
 : @return $node the merged readings
 :   
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function interform:merge-readings
    ($readings as node()*) as item()* {
    
    let $targets := (
        for $reading in $readings
        return
            if ($reading[@type]) then (
                $reading
            ) 
            else (
                element { name($reading) } {
                    $reading/@*,
                    attribute type {'none'}
                }
            )
    )
    
    return (   
        for $type in distinct-values($targets/@type)
        let $rdgs := $targets[@type = $type]
        return
            element {"rdg"}{
                attribute wit {$rdgs/@wit},
                attribute id {$rdgs/@id},
                attribute context {distinct-values($rdgs/@context)},
                attribute type {$type}
            }
    )
};

declare function interform:get-marks
    ($node as node(), $map) as item()* {
    
    if (data($node/@id) and map:contains( $map, data($node/@id)) ) then (
        let $map-item := $map(data($node/@id))
        let $open-marks := $map-item/*:markers/*:open
        let $close-marks := $map-item/*:markers/*:close
        
        return (
           $open-marks,
            $close-marks
        ) 
    ) else ()
};