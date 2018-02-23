xquery version "3.0";
(:~
 : PRESENTATION Module ("presentation", "http://bdn-edition.de/intermediate_format/presentation")
 : *******************************************************************************************
 : This module contains presentation functions for the intermediate format web-app
 :
 : @version 1.0 (2018-02-21)
 : @status development
 : @author Uwe Sikora
 :)
module namespace analysis="http://bdn-edition.de/intermediate_format/analysis";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace console="http://exist-db.org/xquery/console";

(:############################# Modules Functions #############################:)

(:~
 : analysis:html
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function analysis:tei-body
    ($nodes as node()*) as item()* {

    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case comment() return ( $node )
            case text() return (
                translate($node, "@", " ")
            )

            case element(tei:abbr) return ()
            
            case element(tei:aligned) return (
                element{"span"}{
                    attribute {"class"}{"aligned ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:app) return (
                element{"span"}{
                    attribute {"class"}{"app"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:body) return (
                element{"div"}{
                    attribute {"class"}{"body"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:byline) return (
                element{"div"}{
                    attribute {"class"}{"byline"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:choice) return (
                analysis:tei-body($node/node())
            )
            
            case element(tei:div) return (
                element{"div"}{
                    attribute {"class"}{"div ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:docAuthor) return (
                element{"div"}{
                    attribute {"class"}{"docAuthor ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:docDate) return (
                element{"span"}{
                    attribute {"class"}{"docDate"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:docEdition) return (
                element{"div"}{
                    attribute {"class"}{"docEdition ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:docImprint) return (
                element{"div"}{
                    attribute {"class"}{"docImprint ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:expan) return (
                element{"span"}{
                    attribute {"class"}{"expan"},
(:                    attribute {"data-tooltip"}{data($node/following-sibling::tei:abbr)},:)
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:head) return (
                let $hierarchies := $node/ancestor::node()[name() = "div" or name() = "list" or name() = "table"]
                let $count := count($hierarchies)+1
                return
                element{concat("h", $count)}{
                    attribute {"class"}{"head ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:hi) return (
                element{"span"}{
                    attribute {"class"}{"hi"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:index) return ()
            
            case element(tei:item) return (
                element{"li"}{
                    attribute {"class"}{"item ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:l) return (
                element{"span"}{
                    attribute {"class"}{"l"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:label) return (
                element{"span"}{
                    attribute {"class"}{"label"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:lb) return (
                element{"br"}{}
            )
            
            case element(tei:lem) return (
                if ($node/parent::tei:app[@type = "structural-variance"]) then (
                    analysis:tei-body($node/node())
                ) 
                else(analysis:lem($node)) 
            )
            
            case element(tei:list) return (
                element{"ul"}{
                    attribute {"class"}{"list ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:milestone) return (
                analysis:tei-body($node/node())
            )

            case element(tei:note) return (
                element{"p"}{
                    attribute {"class"}{"note ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:p) return (
                element{"span"}{
                    attribute {"class"}{"p ble"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:pb) return (
                "|", <sup>{$node/string(@wit), $node/string(@n)}</sup>
            )
            
            case element(tei:persName) return (
                element{"span"}{
                    attribute {"class"}{"persName"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:rdg) return (
                if ($node/parent::tei:app[@type = "structural-variance"]) then (
                    analysis:tei-body($node/node())
                ) 
                else(analysis:rdg($node))
            )
            
            case element(tei:rdgMarker) return (
                element {"span"}{
                    attribute {"class"}{"rdgMarker"},
                    analysis:rdgMarker($node)
                }
            )
            
            case element(tei:seg) return (
                element{"span"}{
                    attribute {"class"}{"seg"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:text) return (
                element{"div"}{
                    attribute {"class"}{"text"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:TEI) return (
                element{"div"}{
                    attribute {"class"}{"tei"},
                    analysis:tei-body($node/tei:text)
                }
            )
            
            case element(tei:titlePage) return (
                element{"div"}{
                    attribute {"class"}{"titlePage"},
                    analysis:tei-body($node/node())
                }
            )
            
            case element(tei:titlePart) return (
                element{"div"}{
                    attribute {"class"}{"titlePart ble"},
                    analysis:tei-body($node/node())
                }
            )

            default return (
                element {"span"}{
                    attribute {"style"}{"background:orange"},
                    $node/name(), ": ",
                    element{$node/name()}{
                        $node/@*,
                        analysis:tei-body($node/node())
                    }
                }
            )
};


(:~
 : analysis:rdgMarker
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function analysis:rdgMarker
    ( $marker as node() ) as item()* {
        
    let $wit := replace( $marker/string(@wit), " ", "" )
    let $type := data($marker/@type)
    let $mark := data($marker/@mark)
    let $context := data($marker/@context)
    
    return
        if ( $marker[@type="pt" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="pt open">{concat("/", $wit)}</span>
            ) 
            else (
                <span class="pt closeing">{concat($wit, "\")}</span>
            )
               
        )
        
        else if ( $marker[@type="ptl" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="ptl open">{concat("/", $wit)}</span>
            ) 
            else (
                <span class="ptl closeing">{concat($wit, "\||", $wit)}</span>
            )
               
        )
        
        else if ( $marker[@type="ptl" and @context="rdg"] ) then (
            if ($marker[@mark="open"]) then (
                <sup>{$wit}</sup>
            ) 
            else (
                <sup>{$wit}</sup>
            )
               
        )
        
        else if ( $marker[@type="pp" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="pp open">{concat("~/", $wit)}</span>
            ) 
            else (
                <span class="pp closeing">{concat($wit, "\~")}</span>
            )
               
        )
        
        else if ( $marker[@type="ppl" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="ppl open">{concat("~/", $wit)}</span>
            ) 
            else (
                <span class="ppl closeing">{concat($wit, "\~||", $wit)}</span>
            )  
        )
        
        else if ( $marker[@type="ppl" and @context="rdg"] ) then (
            if ($marker[@mark="open"]) then (
                <sup>{$wit}</sup>
            ) 
            else (
                <sup>{$wit}</sup>
            )
               
        )
        
        else if ( $marker[@type="v"] ) then (
            if ($marker[@mark="open"]) then (
            ) 
            else (
                <sup>{$wit}</sup>
            )
               
        )
        
        else if ( $marker[@type="om"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="om open">{$wit}</span>
            ) 
            else (
                <span class="om closeing">{$wit}</span>
            )
               
        )
        
        else (
            element {"span"}{
                attribute {"style"}{"background:orange"},
                $marker/name(), ": ",
                element{$marker/name()}{
                    $marker/@*,
                    analysis:tei-body($marker/node())
                }
            }
        )
};


(:~
 : analysis:rdgMarker
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function analysis:rdg
    ( $rdg as node() ) as item()* {

    let $id := data($rdg[@id])
    let $errors := if ( $rdg[@type = "v" or @type="om"] ) then () else (analysis:check-rdg-markers($id, $rdg))
    return (
        element {"span"}{
            attribute {"class"}{"reading rdg " || data($rdg/@type)},
            <span class="reading-term">tei:rdg</span>,
            <span class="error-status">
                { if ($errors) then (<span style="color: red">&#10007;</span>, console:log($errors)) else (<span style="color: green">&#10004;</span>) }
            </span>,
            <span class="reading-content">{ analysis:tei-body( $rdg/node() ) }</span>
        }
    )
};


declare function analysis:check-rdg-markers
    ( $id as xs:string, $reading as node() ) as item()* {
    
    let $open-marker := $reading//tei:rdgMarker[@mark = "open"][@ref = $id]
    let $close-marker := $reading//tei:rdgMarker[@mark = "close"][@ref = $id]
    let $error := (
        if ( not($open-marker) or not($close-marker ) ) then ($open-marker, $close-marker)
        else ()
    )
    return $error
};


(:~
 : analysis:lem
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function analysis:lem
    ( $lem as node() ) as item()* {

    let $sibling-readings := $lem/following-sibling::tei:rdg[not(@type="typo_corr" or @type="invisible-ref")]
    let $ids := distinct-values($sibling-readings/@id)
    let $errors := ( if ($lem[@type="om"] or count($lem/node()) = 0) then () else (for $id in $ids return analysis:check-lem-markers($id, $lem)) )
    return (
        element {"span"}{
            attribute {"class"}{"reading lem"},
            <span class="reading-term">tei:lem</span>,
            console:log($errors),
            <span class="error-status">{ if ($errors) then (<span style="color: red">&#10007;</span>) else (<span style="color: green">&#10004;</span>) }</span>,
            <span class="reading-content">{ analysis:tei-body( $lem/node() ) }</span>
        }
    )
};


declare function analysis:check-lem-markers
    ( $id as xs:string, $reading as node() ) as item()* {
        
    let $open-marker := $reading//tei:rdgMarker[@mark = "open" and @context = "lem"][tokenize(@ref, " ") = $id]
    let $close-marker := $reading//tei:rdgMarker[@mark = "close" and @context = "lem"][tokenize(@ref, " ") = $id]
    let $error := (
        if ( not($open-marker) or not($close-marker ) ) then ("ERROR")
        else ()
    )
    return $error
};



(:~
 : analysis:html
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function analysis:tei-header
    ($nodes as node()*) as item()* {

    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case comment() return ( $node )
            case text() return (
                $node
            )
            
            case element(tei:teiHeader) return (
                analysis:tei-header($node/node())
            )
            
            case element(tei:fileDesc) return (
                analysis:tei-header($node/node())
            )

            case element(tei:titleStmt) return (
                analysis:tei-header($node/node())
            )
            
            case element(tei:title) return (
                if ($node[@level]) then (
                    <div class="value">
                        <div><strong>title:</strong></div>
                        <div>{ analysis:tei-header($node/node()) }</div>
                    </div>
                ) else (
                    analysis:tei-header($node/node())
                )
            )


            default return ()
};
