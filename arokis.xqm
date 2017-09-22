xquery version "1.0";
module namespace arokis="http://www.arokis.com/xquery/libs/bdn/general";
declare default element namespace "http://www.tei-c.org/ns/1.0";


declare namespace functx = "http://www.functx.com";
import module "http://www.functx.com" at "functx.xqm";


(:~  
 : arokis:are-nodes-in-sequence()
 : This function checks if a node() from a given nodeset is or contains named Elements in a sequence. 
 : In this case it returns 'true' else 'false' 
 :
 : @param $nodes the nodes() to check for BLEs
 : @param $bleElements a list of defined BLEs
 : @return xs:boolean ('true' else 'false')
 : 
 : @version 1.1 (2017-09-22)
 : @status working
 : @author Uwe Sikora
 :)
declare function arokis:are-nodes-in-sequence
    ($nodes as node()*, $sequence as item()*) as xs:boolean{
    
    some $node in $nodes
    satisfies
        if(functx:is-value-in-sequence($node/name(), $sequence)) then(
            fn:true()
        ) 
        
        else (
            fn:false()
        )
};



declare function arokis:first-save-node-not-in-sequence
    ($nodes as node()*, $sequence as item()*) {
    
    functx:first-node(
            $nodes
                [not( self::text() and normalize-space(.) = '' )]
                [not( arokis:are-nodes-in-sequence(descendant-or-self::node(), $sequence) )]
     )
     
};



declare function arokis:last-save-node-not-in-sequence
    ($nodes as node()*, $sequence as item()*) {
    
    functx:last-node(
            $nodes
                [not( self::text() and normalize-space(.) = '' )]
                [not( arokis:are-nodes-in-sequence(descendant-or-self::node(), $sequence) )]
     )
};

