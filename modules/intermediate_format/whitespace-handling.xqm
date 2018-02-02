xquery version "3.0";

module namespace whitespace="http://bdn.edition.de/intermediate_format/whitespace_handling";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare function whitespace:text
    ( $text as text()*, $escape-char as xs:string? ) as text()* {
    
    let $normalized := normalize-space($text)
    let $single-whitespace-between-nodes := $text
                                            [ self::node() = ' ']
                                            [preceding-sibling::node()[not(self::node() = text())]]
                                            [following-sibling::node()[not(self::node() = text())]]
    return
        if ( $normalized != "" or $single-whitespace-between-nodes) then (
            
            if ($escape-char) then (
                whitespace:escape-text($text, $escape-char) 
            ) else ( whitespace:escape-text($text, " ") )
            
        ) 
        else ()
};

(:~ 
 : string:escape-whitespace
 : This function replaces whitespaces in a text() 
 : with one defined preservation character
 :
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function whitespace:escape-text
    ($text, $escape as xs:string) as text()* {

    text {replace($text, '[\s]+', $escape)}
};
