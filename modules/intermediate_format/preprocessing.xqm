xquery version "3.0";

module namespace pre="http://bdn.edition.de/intermediate_format/preprocessing";
import module namespace whitespace = "http://bdn.edition.de/intermediate_format/whitespace_handling" at "whitespace-handling.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";


declare function pre:preprocessing-textNode
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case text() return (
                if (normalize-space($node) eq "") then () else (
                    element {"textNode"} {
                        (:attribute {"interformId"}{ generate-id($node) },:)
                        $node
                    }
                )
            )
            
            case element(TEI) return (
                element{$node/name()}{
                    $node/@*,
                    pre:preprocessing-textNode($node/node()),
                    element{"editorialNotes"}{
                        $node//note[@type eq "editorial"]
                    }
                }
            )
            
            case element(lem) return (
                element{$node/name()}{
                    $node/@*,
                    attribute {"id"}{ generate-id($node)},
                    pre:preprocessing-textNode($node/node())
                }
            )
            
            case element(rdg) return (
                element{$node/name()}{
                    $node/@*,
                    attribute {"id"}{ generate-id($node)},
                    pre:preprocessing-textNode($node/node())
                }
            )
            
            case element(note) return (
                if ($node[@type eq "editorial"]) then (
                ) else (
                    element{$node/name()}{
                        $node/@*,
                        pre:preprocessing-textNode($node/node())
                    }
                )
            )
            
            default return ( 
                element{$node/name()}{
                    $node/@*,
                    pre:preprocessing-textNode($node/node())
                }
            )
};


(: Would be great if $recursive-function would be a real function and not a node-sequence :)
declare function pre:default-element
    ( $node as node(), $recursive-function as node()* ) as item()* {

    element{$node/name()}{
        $node/@*,
        $recursive-function
    }
};

declare function pre:preprocessing
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case text() return (
                whitespace:text($node, "&#160;")
            )
            
            case comment() return ()
            
            case element(TEI) return (
                element{$node/name()}{
                    $node/@*,
                    pre:preprocessing($node/node()),
                    element{"editorialNotes"}{
                        for $editorial-note in $node//note[@type eq "editorial"]
                        return
                            pre:default-element( $editorial-note, pre:preprocessing($editorial-note/node()) )
                    }
                }
            )
            
            case element(teiHeader) return (
                element {name($node)} { 
                     $node/@*, 
                     $node/node()
                 } 
            )
            
            case element(div) return (
                if ($node[@type = 'section-group']) then (
                    pre:preprocessing($node/node())
                ) 
                else (
                    pre:default-element( $node, pre:preprocessing($node/node()) )
                )
                
            )
            
            case element(lem) return (
                element{$node/name()}{
                    $node/@*,
                    attribute {"id"}{ generate-id($node)},
                    pre:preprocessing($node/node())
                }
            )
            
            case element(rdg) return (
                element{$node/name()}{
                    $node/@*,
                    attribute {"id"}{ generate-id($node)},
                    pre:preprocessing($node/node())
                }
            )
            
            case element(note) return (
                if ( $node[@type != "editorial"] ) then (
                    pre:default-element( $node, pre:preprocessing($node/node()) )
                ) else ( )
            )
            
            case element(pb) return (
                let $preceeding-sibling := $node/preceding-sibling::node()[1]
                let $following-sibling := $node/following-sibling::node()[1]
                return
                    element {$node/name()}{
                        $node/@*,
                        if ( ends-with($preceeding-sibling, " ") eq false() and starts-with($following-sibling, " ") eq false() ) then (
                            attribute {"break"}{"no"}
                        ) else ( )(:,
                        attribute {"whitespace"}{
                            if (ends-with($preceeding-sibling, " ")) then (
                                "before"
                            ) else (),
                            if (starts-with($following-sibling, " ")) then (
                                "after"
                            ) else ()
                        }:)
                    }
            )
            
            case element(hi) return (
                if($node[@rend = 'right-aligned' or @rend = 'center-aligned']) then(
                    element {'aligned'} {
                        $node/@*,
                        pre:preprocessing($node/node())
                    } 
                )
                else (
                    pre:default-element( $node, pre:preprocessing($node/node()) )
                )
            )
            
            case element(seg) return (
                if($node[@type = 'item']) then(
                    element {'item'} {
                        $node/@*[name() != 'type'],
                        pre:preprocessing($node/node())
                    } 
                )
                else if($node[@type = 'row']) then(
                    element {'row'} {
                        $node/@*[name() != 'type'],
                        pre:preprocessing($node/node())
                    } 
                )
                else (
                    pre:default-element( $node, pre:preprocessing($node/node()) )
                )
            )
            
            default return ( 
                pre:default-element( $node, pre:preprocessing($node/node()) )
            )
};