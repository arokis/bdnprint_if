xquery version "3.0";

module namespace markerset="http://bdn.edition.de/intermediate_format/markerset";
declare default element namespace "http://www.tei-c.org/ns/1.0";


declare function markerset:collect-markers
    ( $reading as node()* ) as item() {
    
    let $markers := (
        if ($reading[self::lem]) then (
            attribute {"count"}{count($reading/following-sibling::rdg)},
            for $sibling in $reading/following-sibling::rdg
            return(
                element {name($sibling)} {
                    $sibling/@*, 
                    attribute {"context"}{"lem"}
                }
            )
        ) 
        else if ($reading[self::rdg]) then (
            element {name($reading)} {
                $reading/@*,
                attribute {"context"}{"rdg"}
            }
        )
        else ()
    )
    return
        element {"markerset"}{
            markerset:merge-markers($markers)
            (:$markers:)
        }
};


declare function markerset:merge-markers
    ( $markerset as node()* ) as item()* {
    
    let $order := ("om","ppl", "ptl", "pp", "pt" , "v")
    let $reading-types := distinct-values( $markerset[self::rdg or self::lem]/string(@type) )
        
    return (   
        attribute {"order"}{distinct-values( ($order, $reading-types) ) },
        for $type in distinct-values( ($order, $reading-types) )
        let $rdgs := $markerset[@type = $type]
        return
            if ($rdgs) then (
                element {"rdg"}{
                    attribute wit {$rdgs/@wit},
                    attribute id {$rdgs/@id},
                    attribute context {distinct-values($rdgs/@context)},
                    attribute type {$type}
                }
            ) else ()
            
    )
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
declare function markerset:marker
    ($name as xs:string, $type as xs:string, $reading as node()) as element(){

    element {$name} {
        (:attribute bdnp_parent {$node/parent::node()/name()}, :)
        attribute wit { replace(data($reading/@wit), '#', '') },
        attribute type { data($reading/@type) },
        attribute ref { data($reading/@id) },
        attribute mark { $type },
        attribute context { $reading/@context }
    }
};


declare function markerset:construct-marker-from-markerset
    ( $name as xs:string, $marker-type as xs:string, $marker-set as node()* ) as item()* {
    
    for $marker in $marker-set/node()
    return (
        markerset:marker($name, $marker-type, $marker)
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
 :)
 
 
(: **************************************************************************************************************
 :      Target Mapping Conversion
 : ************************************************************************************************************** :)

(:declare function interform:marker-targets
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
                    (\:element {"COMPARE"}{
                        $targets-by-id/ancestor::node()[self::lem or self::rdg]/parent::node()/parent::node()
                    },:\)
                    element {"targetNode"}{
                        $targets-by-id[1]/node()
                    },
                    element {"markers"}{
(\:                        element {"open"}{interform:first-marker-set($id, $app-index)},:\)
(\:                        element {"close"}{interform:last-marker-set($id, $app-index)}:\)
                        element {"open"}{interform:create-marker-sets($targets-by-id[self::first], "open")},
                        element {"close"}{ reverse(interform:create-marker-sets($targets-by-id[self::last], "close")) }
                    }
               }
           )
    )
    
    return 
        ($map)

};:)


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
(:declare function interform:create-marker-sets
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
};:)


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
(:declare function interform:build-markers
    ($type as xs:string, $nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        interform:marker('rdgMarker', $type, $node)
};:)





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
(:declare function interform:merge-readings
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
};:)

(:declare function interform:get-marks
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
};:)