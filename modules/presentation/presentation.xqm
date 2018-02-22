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
module namespace presentation="http://bdn-edition.de/intermediate_format/presentation";

declare namespace tei="http://www.tei-c.org/ns/1.0";


(:############################# Modules Functions #############################:)

(:~
 : presentation:html
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function presentation:tei-body
    ($nodes as node()*) as item()* {

    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case comment() return ( $node )
            case text() return (
                $node
            )

            case element(tei:abbr) return ()
            
            case element(tei:aligned) return (
                element{"span"}{
                    attribute {"class"}{"aligned ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:app) return (
                element{"span"}{
                    attribute {"class"}{"app"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:body) return (
                element{"div"}{
                    attribute {"class"}{"body"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:byline) return (
                element{"div"}{
                    attribute {"class"}{"byline"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:choice) return (
                presentation:tei-body($node/node())
            )
            
            case element(tei:div) return (
                element{"div"}{
                    attribute {"class"}{"div ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:docAuthor) return (
                element{"div"}{
                    attribute {"class"}{"docAuthor ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:docDate) return (
                element{"span"}{
                    attribute {"class"}{"docDate"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:docEdition) return (
                element{"div"}{
                    attribute {"class"}{"docEdition ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:docImprint) return (
                element{"div"}{
                    attribute {"class"}{"docImprint ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:expan) return (
                element{"span"}{
                    attribute {"class"}{"expan"},
(:                    attribute {"data-tooltip"}{data($node/following-sibling::tei:abbr)},:)
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:head) return (
                let $hierarchies := $node/ancestor::node()[name() = "div" or name() = "list" or name() = "table"]
                let $count := count($hierarchies)+1
                return
                element{concat("h", $count)}{
                    attribute {"class"}{"head ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:hi) return (
                element{"span"}{
                    attribute {"class"}{"hi"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:index) return ()
            
            case element(tei:item) return (
                element{"li"}{
                    attribute {"class"}{"item ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:l) return (
                element{"span"}{
                    attribute {"class"}{"l"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:label) return (
                element{"span"}{
                    attribute {"class"}{"label"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:lb) return (
                element{"br"}{}
            )
            
            case element(tei:lem) return (
                element{"span"}{
                    attribute {"class"}{"lem"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:list) return (
                element{"ul"}{
                    attribute {"class"}{"list ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:milestone) return (
                presentation:tei-body($node/node())
            )

            case element(tei:note) return (
                element{"p"}{
                    attribute {"class"}{"note ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:p) return (
                element{"span"}{
                    attribute {"class"}{"p ble"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:pb) return (
                "|", <sup>{$node/string(@wit), $node/string(@n)}</sup>
            )
            
            case element(tei:persName) return (
                element{"span"}{
                    attribute {"class"}{"persName"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:rdg) return (
(:                presentation:rdg($node):)
                element{"span"}{
                    attribute {"class"}{"rdg"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:rdgMarker) return (
                element {"span"}{
                    attribute {"class"}{"rdgMarker"},
                    presentation:rdgMarker($node)
                }
            )
            
            case element(tei:seg) return (
                element{"span"}{
                    attribute {"class"}{"seg"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:text) return (
                element{"div"}{
                    attribute {"class"}{"text"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:TEI) return (
                element{"div"}{
                    attribute {"class"}{"tei"},
                    presentation:tei-body($node/tei:text)
                }
            )
            
            case element(tei:titlePage) return (
                element{"div"}{
                    attribute {"class"}{"titlePage"},
                    presentation:tei-body($node/node())
                }
            )
            
            case element(tei:titlePart) return (
                element{"div"}{
                    attribute {"class"}{"titlePart ble"},
                    presentation:tei-body($node/node())
                }
            )

            default return (
                element {"span"}{
                    attribute {"style"}{"background:orange"},
                    $node/name(), ": ",
                    element{$node/name()}{
                        $node/@*,
                        presentation:tei-body($node/node())
                    }
                }
            )
};


(:~
 : presentation:rdgMarker
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function presentation:rdgMarker
    ( $marker as node() ) as item()* {
        
    let $wit := replace( $marker/string(@wit), " ", "" )
    let $type := data($marker/@type)
    let $mark := data($marker/@mark)
    let $context := data($marker/@context)
    
    return
        if ( $marker[@type="pt" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="pt open lem">{concat("/", $wit)}</span>
            ) 
            else (
                <span class="pt closeing lem">{concat($wit, "\")}</span>
            )
               
        )
        
        else if ( $marker[@type="ptl" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="ptl open lem">{concat("/", $wit)}</span>
            ) 
            else (
                <span class="ptl closeing lem">{concat($wit, "\||", $wit)}</span>
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
                <span class="pp open lem">{concat("~/", $wit)}</span>
            ) 
            else (
                <span class="pp closeing lem">{concat($wit, "\~")}</span>
            )
               
        )
        
        else if ( $marker[@type="ppl" and @context="lem"] ) then (
            if ($marker[@mark="open"]) then (
                <span class="ppl open lem">{concat("~/", $wit)}</span>
            ) 
            else (
                <span class="ppl closeing lem">{concat($wit, "\~||", $wit)}</span>
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
                    presentation:tei-body($marker/node())
                }
            }
        )
};


(:~
 : presentation:rdgMarker
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function presentation:rdg
    ( $rdg as node() ) as item()* {

    if ( $rdg[@type = "pt" or @type = "pp" or @type = "v" or @type="om"] ) then (   
    )
    
    else (
        presentation:tei-body($rdg/node())
    )
};



(:~
 : presentation:html
 : html presentation of an intermediate-format xml document
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
declare function presentation:tei-header
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
                presentation:tei-header($node/node())
            )
            
            case element(tei:fileDesc) return (
                presentation:tei-header($node/node())
            )

            case element(tei:titleStmt) return (
                presentation:tei-header($node/node())
            )
            
            case element(tei:title) return (
                if ($node[@level]) then (
                    <div class="value">
                        <div><strong>title:</strong></div>
                        <div>{ presentation:tei-header($node/node()) }</div>
                    </div>
                ) else (
                    presentation:tei-header($node/node())
                )
            )


            default return ()
};
