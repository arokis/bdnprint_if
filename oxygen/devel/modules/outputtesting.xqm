xquery version "3.0";
(:~  
 : OUTPUT TESTING Module ("test", "http://bdn.edition.de/intermediate_format/output_testing")
 : *******************************************************************************************
 : This module defines functions to test the output of the Intermediate Format conversion
 :
 : @version 1.0 (2018-02-06)
 : @status development
 : @author Uwe Sikora
 :)
module namespace output="http://bdn.edition.de/intermediate_format/output_testing";
(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:############################# Modules Functions #############################:)

(:~  
 : output:marker-evaluation()
 : This function evaluates the reading markers output 
 :
 : @param $nodes the nodes to be evaluated
 : @return evaluation-report as item()
 : 
 : @version 1.0 (2018-02-05)
 : @status development (working)
 : @author Uwe Sikora
 :)
declare function output:marker-evaluation
    ( $nodes as node()* ) as item()* {
    
    let $reading-markers := $nodes//tei:rdgMarker
    let $marker-types := distinct-values( $reading-markers/string(@type) )
    let $opening-markers := $reading-markers[@mark eq "open"]
    let $closing-markers := $reading-markers[@mark eq "close"]
    let $opening-count := count($opening-markers)
    let $closing-count := count($closing-markers)
    let $diff := count( $reading-markers ) - ($opening-count + $closing-count)
        
    return (
        element {"markerEvaluation"}{
            attribute {"total"}{ count( $reading-markers ) },
            attribute {"diff"}{ $diff },
            element {"markerTypes"}{
                for $type in $marker-types
                order by $type
                return element {"item"}{ $type }
            },
            element {"openMarkers"}{ 
                attribute {"sum"} { $opening-count },
                let $errors := output:corresponding-markers($opening-markers, $closing-markers)
                return
                if ($errors) then (
                    element {"correspondenceError"}{
                        $errors        
                    }
                ) else (
                    attribute {"status"}{"okay"}
                )
            },
            element {"closeMarkers"}{ 
                attribute {"sum"} { $closing-count },
                let $errors := output:corresponding-markers($closing-markers, $opening-markers)
                return
                if ($errors) then (
                    element {"correspondenceError"}{
                        $errors        
                    }
                ) else (
                    attribute {"status"}{"okay"}
                )
            }
        }
    )
};


(:~  
 : output:corresponding-markers
 : This function checks if each opening or closing marker has a corresponding marker
 :
 : @param $check-sequence the sequence to check
 : @param $corresponding-sequence the sequence to check against
 : @return error as item()
 : 
 : @version 1.0 (2018-02-05)
 : @status development (working)
 : @author Uwe Sikora
 :)
declare function output:corresponding-markers
    ( $check-sequence as node()*, $corresponding-sequence as node()* ) as item()* {
    

    for $element in $check-sequence
    return output:corresponding-marker($element, $corresponding-sequence)
};


declare function output:corresponding-marker
    ( $marker as node(), $corresponding-sequence as node()* ) as item()* {
    
    let $ref := $marker/string(@ref)
    let $context := $marker/string(@context)
    let $corresp := $corresponding-sequence[@ref = $ref and @context = $context]
    return 
        if ( not($corresp) or count($corresp) != 1 ) then (
            <error correspCount="{count($corresp)}" type="no_corresponding_marker">{$marker}</error>
        ) 
        else ()
        
};

