xquery version "3.0";
(:~  
 : UNIT TESTING Module ("test", "http://bdn.edition.de/intermediate_format/unit_testing")
 : *******************************************************************************************
 : This module defines functions to test different functions from the Intermediate Format conversion
 :
 : It includes the main module "ident"
 :
 : @version 1.0 (2018-02-05)
 : @status development
 : @author Uwe Sikora
 :)
module namespace test="http://bdn.edition.de/intermediate_format/unit_testing";

import module namespace ident = "http://bdn.edition.de/intermediate_format/identification" at "../../../modules/intermediate_format/identification.xqm";

(:############################# Modules Functions #############################:)

(:~  
 : test:branch-axis()
 : This function evaluates the left- and right-branch AXIS 
 :
 : @param $node the nodes to evaluate the left- and right-branch AXIS for
 : @return evaluation-report as item()
 : 
 : @version 1.0 (2018-02-05)
 : @status development (working)
 : @author Uwe Sikora
 :)
declare function test:branch-axis
    ( $node as node() ) as item() {
    let $left-axis := ident:left-branch-axis($node)
    let $right-axis := ident:right-branch-axis($node)
    return 
        element {"axisTest"}{
            element {"targetNode"}{$node},
            element {"axis"}{
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
        }
};


(:~  
 : test:reading-evaluation()
 : This function evaluates tei:lem and tei:app elements. It identifies the save first
 : and last node and collects readingMarkers 
 :
 : @param $reading the reading to be tested
 : @return evaluation-report as item()
 : 
 : @version 1.0 (2018-02-05)
 : @status development (working)
 : @author Uwe Sikora
 :)
declare function test:reading-evaluation
    ( $readings as node()* ) as item()* {
    
    for $reading at $nr in $readings
    let $first-save-node := ident:first-save-node($reading)
    let $last-save-node := ident:last-save-node($reading)
    return 
        element {$reading/name()}{
            $reading/@*,
            attribute {"index"} { $nr },
            element {"self"}{
                attribute {"gid"}{ generate-id($reading) },
                $reading
            },
            element {"target"}{
                attribute {"type"}{ "open" },
                attribute {"gid"}{ generate-id($first-save-node) },
                $first-save-node
            },
            element {"target"}{
                attribute {"type"}{ "close" },
                attribute {"gid"}{ generate-id($last-save-node) },
                $last-save-node
            }
        }
};