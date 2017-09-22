(:~ 
 : This module is used to create an intermediate format (nms: "intfo") to handle the complexity of the tei-data of 
 : the DFG-project "Bibliothek der Neologie" and to provide a format that can be 
 : directly ingested into the BdN-print workflow. 
 :
 : The intermediate formats purpose is to reduce complexity with regard to following aspects: 
 : - text() is handled in the manner of whitespace preservation
 : - tei:rdg is expanded as rdgMarkers to cope with BLE (BlockLevel Elements) 
 :
 : NEW Elements and attributes from Intermediate Format:
 : - rdgMarker [ @wit="<wit from rdg>" , @ref="<ref to rdg>" , @mark="open|close" , @type="v|pp|pt|ppl|ptl", @context="lem|rdg" ]
 : - aligned [ @type="right-aligned|center-aligned" ]
 : - tei:lem [ @omit="true" ]
 :
 :
 : @author Uwe Sikora
 : @version 1.2 (2017-09-15)
 :)

declare default element namespace "http://www.tei-c.org/ns/1.0"; 
declare namespace saxon="http://saxon.sf.net/";
declare namespace intfo = "http://www.bdn-edition.de/bdnPrint/intermediate_format";


declare namespace functx = "http://www.functx.com";
import module "http://www.functx.com" at "functx.xqm";

declare namespace arokis = "http://www.arokis.com/xquery/libs/bdn/general";
import module "http://www.arokis.com/xquery/libs/bdn/general" at "arokis.xqm";

declare namespace string="http://www.arokis.com/xquery/libs/string";
import module "http://www.arokis.com/xquery/libs/string" at "string.xqm";

declare namespace bdnprint="http://www.arokis.com/xquery/libs/bdn/print";
import module "http://www.arokis.com/xquery/libs/bdn/print" at "bdnprint.xqm";


(:declare option saxon:output "indent=no";:)


(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:)
(:                       OWN Lib                        :)
(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:)

(:######################################################:)
(:################### BLE - Handling ###################:)

(:~  
 : BLE definition variable 
 : Array of elements that are BLE or elements that should be handelt as BLE
 :   
 : @version 1.0 (2017-09-13)
 : @author Uwe Sikora
 :)
declare variable $blockLevelElements := ('titlePage', 'titlePart', 'aligned', 'div', 'list', 'item', 'table', 'row', 'cell', 'head', 'p', 'note');


(:~  
 : intfo:marker() - Marker Constructor
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
declare function intfo:marker
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
            attribute ref {$marker_rdg_ref},
            attribute mark {$marker_mark},
            attribute type {$marker_rdg_type},
            attribute context {data($rdg_node/@context)}
        }
    )
};


(:~  
 : intfo:buildMarkers()
 : constructs rdgMarker elements from set of tei:rdg nodes
 :
 : @param $type The type of the marker element
 : @param nodes A set of tei:rdg elements
 : @return rdgMarker element()s for each rdg in the set
 :
 : @version 1.1 (2017-09-13)
 : @author Uwe Sikora
 :)
declare function intfo:buildMarkers
    ($type as xs:string, $nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        intfo:marker('rdgMarker', $type, $node)
};


(:~
 : intfo:firstNonBleNodeId()
 : This recursive function determines the id of the last NON-BLE
 : - starts on the first or the last node() in depth given as first argument
 : - walks up the tree by parent:node() and looks if it is BLE
 :    TRUE: it returns the id of the last NON-BLE
 :    FALSE: it goes to the next parent:node()
 : 
 : @param $node The node to check if BLE OR NON-BLE
 : @return $id The ID of the last NON-BLE
 :   
 : @version 1.1
 : @author Uwe Sikora
 :
 :  deprecated version:
 :  declare function intfo:lastNonBLE
        ($node as node()) as xs:string {
    
        if (functx:is-value-in-sequence($node/parent::node()/name(), $blockLevelElements)) then(
            $node/@id
            (\:fn:generate-id($node):\)
        ) else(
            intfo:lastNonBLE($node/parent::node())
        )
    };
 :)
declare function intfo:firstNonBleNodeId
    ($node as node()) as item() {
    
    if (functx:is-value-in-sequence($node/parent::node()/name(), $blockLevelElements)) then(
        fn:generate-id($node)
    ) 
    
    else if ($node[parent::node()[not(parent::node())]]) then (
        fn:generate-id($node)
    ) 
    
    else (
        intfo:firstNonBleNodeId($node/parent::node())
    )
};


(:~
 : intfo:expanReadings()
 : recursive function to run the rdgMarker Transformation
 : 
 : @param $node The treestructure to transform
 : @return node() The templated node() for each defined element
 :   
 : @version 1.0 (2017-09-13)
 : @author Uwe Sikora
 :)
declare function intfo:expanReadings
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case text() return $node
            
            case comment() return $node
            
            case element(lem) return (
                element {name($node)} {
                    $node/@*,
                    intfo:evaluateElementForBLE($node)
                }
            )
            
            case element(rdg) return (
                if ($node[@type = 'ppl'] or $node[@type = 'ptl']) then (
                    element {name($node)} {
                        $node/@*,
                        intfo:evaluateElementForBLE($node)
                    } 
                ) 
                else (
                    element {name($node)} {
                        $node/@*,
                        intfo:expanReadings($node/node())
                    }
                )
            )
                
            default return (
                element { name($node) } {
                    $node/@*,
                    intfo:expanReadings($node/node())
                }
            )
};


(:~
 : intfo:identifyReadings()
 : This function identifies all the readings of interest and builds a reading model
 : used to buil the markers later on
 : 
 : @param $node The node for which rdg nodes() should be identified. These can be tei:lem or tei:rdg
 : @return the reading model which contains all readings of interest including metadata but excluding their content
 :   
 : @version 1.1 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function intfo:identifyReadings
    ($node as node()*) as item()* {
    
    let $readings := (
        if ($node[self::lem]) then (
            $node/following-sibling::rdg
        ) 
        else if ($node[self::rdg]) then (
            $node
        ) 
        else ()
    )
    
    let $out := (
        for $reading in $readings
        return    
            element { name($reading) } {
                $reading/@*,
                attribute {"context"}{name($node)}
            }
    )
    
    return $out
};


(:~
 : intfo:mergeReadings()
 : This function merges all readings in the given set sharing the same tei:rdg[@type]
 : If no type was provided 'none' is set as type
 :
 : @param $readings the readings as a sequence
 : @return $node the merged readings
 :   
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function intfo:mergeReadings
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


(:~
 : intfo:evaluateElementForBLE()
 : This function evaluates the position of the first and last save node() [a node() that is not and does not contain a BLE],
 : builds a target model, which is then evaluated with the tree and
 : finally given both to setMarksInElement() to serialise the converted structure in the main tree
 : 
 : @param $node The node to process and check for marks, mainly tei:lem and tei:rdg
 : @return the converted node-set from setMarksInElement()
 :   
 : @version 1.1 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function intfo:evaluateElementForBLE
    ($node as node()*) as item()* {
    
    let $new_tree := <tree>{$node/node()}</tree>
        
    let $firstSaveNode := arokis:first-save-node-not-in-sequence($new_tree//node(), $blockLevelElements)
    let $lastSaveNode := arokis:last-save-node-not-in-sequence($new_tree//node(), $blockLevelElements)
    
    return
        if( not( empty($firstSaveNode) and empty($lastSaveNode) ) ) then (
            
            let $targets := (
                element {"targets"} {
                    
                    element {"open"} {
                        attribute id {intfo:firstNonBleNodeId($firstSaveNode)}
                    },
                    
                    element {"close"} {
                        attribute id {intfo:firstNonBleNodeId($lastSaveNode)}
                    },
                    
                    element {'readings'} {
                        (:intfo:identifyReadings($node):)
                        intfo:mergeReadings(intfo:identifyReadings($node))
                    }
                }
            )
            
            (:  Target Model:
                <targets>
                    <open id="[ID]" />
                    <close id ="[ID]" />
                    <readings>
                        <rdg ... />
                        <rdg ... />
                        ...
                    </readings>
                </targets>
            :)
            
            return (
(:                  "&#xa;FIRST: ", fn:generate-id($firstSaveNode), "&#xa;FIRST NODE: ", intfo:lastNonBLE($firstSaveNode), " &#xa;LAST: ", fn:generate-id($lastSaveNode), " LAST NODE: ", intfo:lastNonBLE($lastSaveNode):)
(:                "&#xa;FIRST: ", fn:generate-id($firstTextNode), " LAST: ", $lastTextNode, " TREE: ", $new_tree, "&#xa;FIRST NODE: ", $first, " LAST NODE: ", $last:)
                intfo:setMarksInElement($new_tree, $targets)
            )
        ) 
        else(
            attribute omit {'true'}
            (:$node:)
        )
};


(:~
 : THE function wich runs for the identified first and last target associated with the rdgMarker
 : - The first and last Target is completed with markers
 : - Every node that is not interesting gets copied
 : - if there is a further rdg or lem in the tree it is processed as a new instance with intfo:transformReadings()
 : 
 : @param $target_model The model of target nodes, that are the open/first node() and the close/last node() with ids and all readings which should be represented by markers
 : @param $nodes The node-set getting processed
 : @return the converted and finished serialised node()
 :   
 : @version 1.1 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function intfo:setMarksInElement
    ($nodes as node()*, $target_model as node()) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case text() return (
               if (fn:generate-id($node) = data($target_model/open/@id) and fn:generate-id($node) = data($target_model/close/@id)) then (
                    (:"CIRCUMFIXING: ",:)intfo:buildMarkers('open', $target_model/readings/node()), $node, intfo:buildMarkers('close', reverse($target_model/readings/node()))
               ) 
               else if (fn:generate-id($node) = data($target_model/open/@id)) then (
                    (:"FIRST: ",:)intfo:buildMarkers('open', $target_model/readings/node()), $node
               ) 
               else if (fn:generate-id($node) = data($target_model/close/@id)) then (
                    (:"LAST: ",:) $node, intfo:buildMarkers('close', reverse($target_model/readings/node()))
               )
               else (
                    (:"NOTHING: ",:) $node
               )
            )
            
            case comment() return ($node)
            
            case element(lem) return (
                intfo:expanReadings($node) 
            )
            
            case element(rdg) return (
                intfo:expanReadings($node)
            )
            
            case element(tree) return (
                intfo:setMarksInElement($node/node(), $target_model)
            )
            
            default return (
                if (fn:generate-id($node) = data($target_model/open/@id) and fn:generate-id($node) = data($target_model/close/@id)) then (
                    (:"CIRCUMFIXING: ",:)
                    intfo:buildMarkers('open', $target_model/readings/node()),
                    element { name($node) } {
                        $node/@*,
                        intfo:setMarksInElement($node/node(), $target_model)
                    },
                    intfo:buildMarkers('close', reverse($target_model/readings/node()))
                )
                
                else if (fn:generate-id($node) = data($target_model/open/@id)) then (
                    (:"FIRST: ",:)
                    intfo:buildMarkers('open', $target_model/readings/node()),
                    element { name($node) } {
                        $node/@*,
                        intfo:setMarksInElement($node/node(), $target_model)
                    }
                ) 
                
                else if (fn:generate-id($node) = data($target_model/close/@id)) then (
                    (:"LAST: ",:)
                    element { name($node) } {
                        $node/@*,
                        intfo:setMarksInElement($node/node(), $target_model)
                    },
                    intfo:buildMarkers('close', reverse($target_model/readings/node()))
                
                ) 
                
                else((:"NOTHING: ", :)
                    element { name($node) } {
                        $node/@*,
                        intfo:setMarksInElement($node/node(), $target_model)
                    }
                )
            )
};


(:################# END BLE - Handling #################:)
(:######################################################:)

(:                         ***                          :)

(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:)
(:                       WORKFLOW                       :)
(:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:)

let $doc := .
let $preprocessed := bdnprint:preprocessing($doc/TEI)
let $readingMarkers := intfo:expanReadings($preprocessed)
let $postprocessed := bdnprint:postprocessing($readingMarkers, '&#x1f984;')

return
    $postprocessed
    (:intfo:cleanUp($readingMarkers, '&#x3040;'):)
    (:intfo:transformReadings($doc/TEI):)
    (:let $target := (
        <targets>
            <open id="1" />
            <close id ="2" />
            <readings>
                <rdg type="v" wit="a" id="r1"/>
                <rdg type="v" wit="b" id="r23" />
                <rdg type="om" wit="c" id="r51" />
                <rdg wit="d" id="r514" />
            </readings>
        </targets>
    )
    return
        intfo:mergeReadings($target/readings/node()):)
        
(:    let $target := (
        <div>
            <readings>
                <note>
                     <milestone/>
                     <seg><hi><t>u</t></hi></seg>
                     <p>das ist</p> <t>keine</t> dritte
                     <list>
                        <item>Liste<ptr/></item>
                     </list>
                  </note>
            </readings>
            <note>
                <rdg type="v" wit="a" id="r1"/>
                <rdg type="v" wit="b" id="r23" />
                <rdg type="om" wit="c" id="r51" />
                <rdg wit="d" id="r514" >
                    zhgjghjgh
                    <u>jhgjghg</u>
                </rdg>
            </note>
        </div>
    )
    return
        intfo:BLEcheck($target/readings[1]/note/seg, $blockLevelElements):)