xquery version "3.0";
(:~
 : PREPROCESSING Module ("pre", "http://bdn.edition.de/intermediate_format/preprocessing")
 : *******************************************************************************************
 : This module contains the preprocessing routines for the intermediate format
 :
 : It imports the whitespace handling helper module to make some whitespace handling duricng the preprocessing

 : @version 2.0 (2018-01-29)
 : @status working
 : @author Uwe Sikora
 :)
module namespace pre="http://bdn.edition.de/intermediate_format/preprocessing";
import module namespace whitespace = "http://bdn.edition.de/intermediate_format/whitespace_handling" at "whitespace-handling.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";


(:############################# Modules Functions #############################:)

(:~
 : pre:preprocessing-textNode
 : preprocessing function which converts each text() into a xml-node "textNode". This function is a experimental fall back solution and not the main preprocessing routine!
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 1.2 (2017-10-15)
 : @status working
 : @author Uwe Sikora
 :)
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


(:~
 : pre:pre:default-element
 : function that suites as default element constructor for the preproseccing conversion.
 : It is more or less a copy function, copying the elements name and its node and recurively leeds the conversion to its child-nodes
 :
 : @param $node the node to be copied
 : @param $recursive-function the recursive function as some kind of call back to the main conversion
 : @return item()* representing the converted node
 :
 : @version 1.0 (2018-01-31)
 : @note Would be great if $recursive-function would be a real function and not a node-sequence (TO-DO)
 : @status working
 : @author Uwe Sikora
 :)
declare function pre:default-element
    ( $node as node(), $recursive-function as node()* ) as item()* {
    let $following-node := $node/following-sibling::node()[1]
    let $following-sibling := $node/following-sibling::*[1]
    return
        element{$node/name()}{
            $node/@*,
            (if($following-node[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
            and $following-sibling[self::ref or self::app or self::hi or self::bibl
            or self::foreign or self::choice or self::milestone or self::persName
            or self::choice or self::index]
            and not($node[self::index]))
            then
                attribute {"break-after"}{"yes"}
            else ()),
            $recursive-function
        }
};


(:~
 : pre:preprocessing
 : main preprocessing function.
 :
 : @param $nodes the nodes to be converted
 : @return item()* representing the converted node
 :
 : @version 2.0 (2018-02-01)
 : @status working
 : @author Uwe Sikora
 :)
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

            case element(teiHeader) return ( $node )

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
                if ( $node[@type != "editorial"] or $node[ not(@type) ] ) then (
                    pre:default-element( $node, pre:preprocessing($node/node()) )
                ) else ( )
            )

            case element(pb) return (
                let $preceding-sibling := $node/preceding-sibling::node()[1]
                let $following-sibling := $node/following-sibling::node()[1]
                let $following-element := $node/following::*[1]
                let $first := $node = $node/parent::node()/node()[not(self::text() and normalize-space(self::node()) = '')][1]
                let $ignore := ("docAuthor", "app", "index", "seg", "bibl")
                return
                    element {$node/name()}{
                        $node/@*,

                        if (
                            ( $preceding-sibling[self::text() and not(normalize-space(.) = '')] and ends-with($preceding-sibling, " ") = false() )
                            and
                            ( $following-sibling[self::text() and not(normalize-space(.) = '')] and starts-with($following-sibling, " ") = false() )
                        ) then ( attribute {"break"}{"no"} )

                        (:else if (
                                ( $preceeding-sibling[self::text() and not(normalize-space(.) = '')] and ends-with($preceeding-sibling, " ") = true() )
                                and
                                ( $following-sibling[self::text() and not(normalize-space(.) = '')] and starts-with($following-sibling, " ") = true() )
                            ) then ( attribute {"clear"}{"left"} ) :)

                        else if (
                            ( $preceding-sibling[matches(., "[\s\n\r\t]") and normalize-space(.) = ""] )
                            and
                            ( $following-sibling[matches(., "[\s\n\r\t]") and normalize-space(.) = ""] )
                        ) then (
                            attribute {"break-before"}{"yes"},
                            attribute {"break-after"}{"yes"}
                        )
                        else if (
                            $preceding-sibling[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
                        ) then (
                            attribute {"break-before"}{"yes"}
                        )
                        else if (
                            $following-sibling[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
                        ) then (
                            attribute {"break-after"}{"yes"}
                        )
                        else ( )
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
                else if($node[@type = 'head']) then(
                    element {'head'} {
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

            case element(ref) return (
                whitespace:set-additional-whitespace($node)
            )

            case element(app) return (
                whitespace:set-additional-whitespace($node)
            )

            case element(bibl) return (
                whitespace:set-additional-whitespace($node)
            )

            case element(foreign) return (
                whitespace:set-additional-whitespace($node)
            )

            case element(p) return (
                whitespace:set-additional-whitespace($node)
            )

            case element(choice) return (
                whitespace:set-additional-whitespace($node)
            )

            default return (
                pre:default-element( $node, pre:preprocessing($node/node()) )
            )
};
