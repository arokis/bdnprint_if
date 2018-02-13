xquery version "3.0";
(:~
 : WHITESPACE Module ("whitespace", "http://bdn.edition.de/intermediate_format/whitespace_handling")
 : *******************************************************************************************
 : This module contains the functions to handle different whitespace operations on text
 :
 : @version 1.0 (2018-01-02)
 : @status working
 : @author Uwe Sikora
 :)
module namespace whitespace="http://bdn.edition.de/intermediate_format/whitespace_handling";
import module namespace pre="http://bdn.edition.de/intermediate_format/preprocessing" at "preprocessing.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";


(:############################# Modules Functions #############################:)

(:~
 : whitespace:text()
 : This function handles whitespace in defined text() nodes
 :
 : @param $text the text-node to be converted
 : @param $escape-char a optional escape-character replacing all whitespace characters
 : @return text()* representing the escaped text()
 :
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function whitespace:text
    ( $text as text()*, $escape-char as xs:string? ) as text()* {

    let $normalized := normalize-space($text)
    let $whitespace-node := $text[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
    let $single-whitespace-between-nodes := $text = ' '
    return
        if ( not($whitespace-node) or $single-whitespace-between-nodes) then (

            if ($escape-char) then (
                whitespace:escape-text($text, "#")
            ) else ( whitespace:escape-text($text, " ") )

        )
        else ()

};


(:~
 : whitespace:escape-text()
 : This function replaces whitespaces in a text()
 : with a defined preservation character
 :
 : @param $text the text-node to be converted
 : @param $escape the escape-character replacing all whitespace characters
 : @return text()* representing the escaped text()
 :
 : @version 2.0 (2018-01-30)
 : @status working
 : @author Uwe Sikora
 :)
declare function whitespace:escape-text
    ( $text, $escape as xs:string ) as text()* {

    text {replace($text, '[\s]+', $escape)}
};

(:~
 : whitespace:set-additional-whitespace()
 : This function creates a "break-after"-attribute for a node, that has to be
 : followed by a whitespace in PDF.
 :
 :
 : @param $node the current node
 : @return node() the new node with an attribute where necessary
 :
 : @version 1.0 (2018-02-13)
 : @status working
 : @author Michelle Rodzis
 :)
declare function whitespace:set-additional-whitespace($node as node()) as node() {
    let $following-node := $node/following-sibling::node()[1]
    let $following-sibling := $node/following-sibling::*[1]
    return element {$node/name()}{
        $node/@*,
        (if($following-node[matches(., "[\s\n\r\t]") and normalize-space(.) = ""]
        and $following-sibling[self::ref or self::app or self::hi or self::bibl
        or self::foreign or self::choice or self::milestone or self::persName
        or self::choice or self::index])
        then
            attribute {"break-after"}{"yes"}
        else ()),
        pre:preprocessing($node/node())
    }
};
