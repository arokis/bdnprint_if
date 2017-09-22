xquery version "1.0";
module namespace string="http://www.arokis.com/xquery/libs/string";


(:~ 
 : string:escape-whitespace
 : This function replaces whitespaces in a text() 
 : with one defined preservation character
 :
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function string:escape-whitespace
    ($text, $escape as xs:string) as item()* {

    replace($text, '[\s]+', $escape)
};


(:~ 
 : string:normalize
 :
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function string:normalize
    ($text, $norm_character as xs:string) as item()* {
    
    let $norm_expression := concat('[', $norm_character, ']+')
    return
        replace($text, $norm_expression, $norm_character)
};


(:~ 
 : string:escape-and-normalize
 :
 : @version 1.0 (2017-09-14)
 : @author Uwe Sikora
 :)
declare function string:escape-and-normalize
    ($text as node(), $norm_character as xs:string) as item()* {
    
    let $save := string:escape-whitespace(normalize-space($text), $norm_character)
    let $reduce := string:normalize($save, $norm_character)
    return
        $reduce
};