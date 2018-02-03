xquery version "3.0";
(:~  
 : MARKERSET Module ("markerset", "http://bdn.edition.de/intermediate_format/markerset")
 : *******************************************************************************************
 : This module is a helper module and defines functions to collect and construct reading markers
 :
 : @version 2.0 (2018-01-29)
 : @status working
 : @author Uwe Sikora
 :)
module namespace markerset="http://bdn.edition.de/intermediate_format/markerset";
declare default element namespace "http://www.tei-c.org/ns/1.0";


(:############################# Modules Functions #############################:)

(:~  
 : markerset:collect-markers()
 : This function collect markers for a given reading.
 : It destinguishes tei:lem and tei:rdg. In case of tei:lem it collects all sibling tei:rdgs. In case of tei:rdg it collect itself.
 :
 : @param $reading the reading node to collect readings for
 : @return node() representing a markerset of readings for the given node
 : 
 : @version 2.0 (2018-01-29)
 : @status working
 : @author Uwe Sikora
 :)
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


(:~  
 : markerset:merge-markers()
 : This function merges markers in a given set by the same type. It orders the merged markers according to an explicit ordering.
 :
 : @param $markerset node() including the markers that should be merged
 : @return node()* representing the merged markerset
 : 
 : @version 2.0 (2018-01-29)
 : @status working
 : @author Uwe Sikora
 :)
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
 : markerset:marker()
 : Constructor function which creates the marker element with name, mark-type and references 
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


(:~  
 : markerset:construct-marker-from-markerset
 : Helping function to construct markers for a sequence of markersets
 :
 : @param $name The name of the marker element
 : @param $marker-type The mark type e.g. open or close
 : @param $marker-set The markersets for which reading markers shall be coonstructed
 : @return item()* representing the constructed rdgMarker sets
 :
 : @version 1.0 (2018-02-29)
 : @author Uwe Sikora
 :)
declare function markerset:construct-marker-from-markerset
    ( $name as xs:string, $marker-type as xs:string, $marker-set as node()* ) as item()* {
    
    for $marker in $marker-set/node()
    return (
        markerset:marker($name, $marker-type, $marker)
    )
};