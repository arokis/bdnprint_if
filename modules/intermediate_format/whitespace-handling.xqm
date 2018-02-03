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
