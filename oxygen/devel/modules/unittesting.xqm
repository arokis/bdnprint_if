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
module namespace test="http://bdn-edition.de/intermediate_format/unit_testing";

import module namespace ident = "http://bdn-edition.de/intermediate_format/identification" at "../../../modules/intermediate_format/identification.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

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
    ( $nodes as node()* ) as item()* {
    
    for $reading at $nr in $nodes//node()[self::tei:lem or self::tei:rdg]
    let $first-save-target := ident:first-save-node($reading)
    let $last-save-target := ident:last-save-node($reading)
    return 
        element {$reading/name()}{
            $reading/@*,
            attribute {"nr"} { $nr },
            element {"self"}{
                attribute {"gid"}{ generate-id($reading) },
                $reading
            },
            element {"evaluation"}{
                element {"first"}{ 
                    attribute {"gid"}{ generate-id($first-save-target) },
                    $first-save-target 
                },
                element {"last"}{ 
                    attribute {"gid"}{ generate-id($last-save-target) },
                    $last-save-target 
                }
            }
        }
};


(:~  
 : test:identify-target()
 : unit-test-function to eval the main identification functionality of the ident module on all tei:lem and tei:readings of a given xml-tree
 :
 : @param $nodes xml-tree to be tested
 : @return test report for each tei:lem and tei:reading as node()*
 : 
 : @version 2.1 (2018-02-05)
 : @status working
 : @note meant to test the identification algorithm
 : @author Uwe Sikora
 :)
declare function test:identify-target
    ( $nodes as node()* ) as node()* {
    
    for $node at $nr in $nodes//node()[self::tei:lem or self::tei:rdg]
    let $identified-targets := ident:identify-targets($node)
    return
        element{"UTEST"}{
            attribute {"n"}{$nr},
            element {"SELF"} {$node},
            $identified-targets
        }
};