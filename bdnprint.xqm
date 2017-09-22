xquery version "1.0";
module namespace bdnprint="http://www.arokis.com/xquery/libs/bdn/print";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace string="http://www.arokis.com/xquery/libs/string";
import module "http://www.arokis.com/xquery/libs/string" at "string.xqm";



(:~ 
 : bdnprint:preservedText()
 : This function preserves whitespace in a test-node by replacing 1-N Whitespacecharacters
 : by one defined preservation character
 :
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
(:declare function bdnprint:preservedText
    ($text as node(), $escape as xs:string) as item()* {

    if (
        normalize-space($text) != '' or
        $text
            [ self::node() = ' ']
            [preceding-sibling::node()[not(self::node() = text())]]
            [following-sibling::node()[not(self::node() = text())]] 
       
    ) then (
        let $t := replace($text, '[\s]+', $escape)
        return
            $t
       
    ) else ($text)
};:)


(:~  
 : @version 1.0 (2017-09-13)
 : @deprecated used by deprecaded bdnble:id()
 : @author Uwe Sikora
 :)
declare function bdnprint:pos
    ($x) {
    
    let $parent := $x/..
    for $child at $p in $parent/*
        return (if ($child is $x) then $p else ())
};


(:~  
 : @version 1.0 (2017-09-13)
 : @deprecated replaced with fn:generate-id()
 : @author Uwe Sikora
 :)
declare function bdnprint:id
    ($x) {
   
   string-join(for $n in ($x/ancestor::node(),$x) return string(bdnprint:pos($n)), "/")
};

(:~  
 : bdnprint:indent() 
 : identifies wich kind of indentation is needed for tei:p etc. 
 : 
 : XPATH: identifies the first preceding node() not self:text or blank-node
 : //body//p[preceding::node()
 :   [ not( self::text()) ] 
 :   [ not( normalize-space(self::text()) != '')][1]
 :   /name() = 'note']
 :
 :  Idea: if the first non text or blank node() is a specific node than a specific indentation needs to be assigned
 : 
 :
 : @version 0.1 (2017-09-20)
 : @author Uwe Sikora
 :)
declare function bdnprint:indent
    ($nodes as node()) as item()* {
    
    
};


(:~  
 : bdnprint:preprocessing()
 : This function is used to preprocess the bdn-tei 
 : 
 : single whitespace between to node()[not(self::text())]: //text()[ self::node() = ' '][preceding-sibling::node()[not(self::node() = text())]][following-sibling::node()[not(self::node() = text())]]
 : //textNode[preceding::textNode[1][@preserved]]
 :
 : @version 1.2 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function bdnprint:preprocessing
    ($nodes as node()*) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case text() return (
                (: This is absolutly magical! "May Her Hooves Never Be Shod":)
                if (
                    normalize-space($node) != '' or
                    $node
                        [ self::node() = ' ']
                        [preceding-sibling::node()[not(self::node() = text())]]
                        [following-sibling::node()[not(self::node() = text())]] 
                   
                ) then (
                    string:escape-whitespace($node, '&#x1f984;')
                   
                ) else ($node)
                
                (:bdnprint:preservedText($node, '&#x1f984;'):)
            )
            
            (: COMPLETE IGNORE :)
            case comment() return ((:$node:))
            
            case element(encodingDesc) return (
                bdnprint:preprocessing($node/following-sibling::node()[1])
            )
            
            case element(revisionDesc) return (
                bdnprint:preprocessing($node/following-sibling::node()[1])
            )
            
            case element(ptr) return (
                bdnprint:preprocessing($node/node())
            )
            
            (: ELEMENT IGNORE :)
            case element(choice) return (
                if ($node[child::expan and child::abbr]) then (
                    bdnprint:preprocessing($node/abbr/node())
                )
                else (
                    element {name($node)} { 
                        $node/@*,
                        bdnprint:preprocessing($node/node())
                    }
                ) 
            )
            
            case element(byline) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(docAuthor) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(persName) return (
                if ($node[ not (ancestor::index) ]) then (
                    bdnprint:preprocessing($node/node())
                ) 
                else (
                    element {name($node)} { 
                        $node/@*,
                        bdnprint:preprocessing($node/node())
                    }
                )
            )
            
            case element(docEdition) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(docImprint) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(docDate) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(ref) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(foreign) return (
                bdnprint:preprocessing($node/node())
            )
            
            case element(div) return (
                if ($node[@type = 'section-group']) then (
                    bdnprint:preprocessing($node/node())
                ) 
                else (
                    element {name($node)} { 
                        $node/@*,
                        bdnprint:preprocessing($node/node())
                    }
                )
                
            )
            
            (: CHANGE :)
            case element(rdg) return (
                element {name($node)} { 
                    $node/@*, 
                    attribute id {fn:generate-id($node)},
                    bdnprint:preprocessing($node/node())
                } 
            )
            
            case element(hi) return (
                if($node[@rend = 'right-aligned' or @rend = 'center-aligned']) then(
                    element {'aligned'} {
                        $node/@*,
                        bdnprint:preprocessing($node/node())
                    } 
                )
                else (
                    element {name($node)} { 
                        $node/@*,
                        bdnprint:preprocessing($node/node())
                    }
                )
            )
            
            case element(seg) return (
                if($node[@type = 'item']) then(
                    element {'item'} {
                        $node/@*[name() != 'type'],
                        bdnprint:preprocessing($node/node())
                    } 
                )
                else if($node[@type = 'row']) then(
                    element {'row'} {
                        $node/@*[name() != 'type'],
                        bdnprint:preprocessing($node/node())
                    } 
                )
                else (
                    element {name($node)} { 
                        $node/@*, 
                        (:attribute id {fn:generate-id($node)},:)
                        bdnprint:preprocessing($node/node())
                    }
                )
            )
            
            default return ( 
                element {name($node)} { 
                    $node/@*, 
                    (:attribute id {fn:generate-id($node)},:)
                    bdnprint:preprocessing($node/node())
                } 
            )
};


(:~  
 : bdnprint:postprocessing() 
 : - reduces all text() with preservation character to get rid of all conversion related whitespaces 
 : - kicks out all rdgMarkers an tei:rdg nodes not wanted
 :
 : @version 1.1 (2017-09-18)
 : @author Uwe Sikora
 :)
declare function bdnprint:postprocessing
    ($nodes as node()*, $escaped_whitespace as xs:string) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case text() return (
                let $norm := string:escape-and-normalize($node, $escaped_whitespace)
                (:let $reduce_expression := concat('[', $escaped_whitespace, ']+')
                let $save := replace(normalize-space($node), "[\s]+", $escaped_whitespace)
                let $reduce := replace($save, $reduce_expression, $escaped_whitespace):)
                return
                    replace($norm, $escaped_whitespace, ' ')
                    (:$norm:)
            )
            
            case comment() return $node
            
            case element(rdgMarker) return (
                if ($node[@type != 'var-structure']) then (
                    element {name($node)} {
                        $node/@*, 
                        bdnprint:postprocessing($node/node(), $escaped_whitespace)
                    }
                ) else ()
            )
            
            case element(rdg) return (
                if ($node[@type != 'var-structure']) then (
                    element {name($node)} {
                        $node/@*, 
                        bdnprint:postprocessing($node/node(), $escaped_whitespace)
                    }
                ) else (
                    element {name($node)} {
                        $node/@*, 
                        bdnprint:postprocessing($node/following-sibling::node()[1], $escaped_whitespace)
                    }
                )
            )
            
            default return (
                element {name($node)} {
                    $node/@*, 
                    bdnprint:postprocessing($node/node(), $escaped_whitespace)
                }
            )
};