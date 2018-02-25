xquery version "3.1";
(:~  
 : INTERMEDIATEFORMAT Utils Module ("ifutils", "http://bdn.edition.de/intermediate_format/utils")
 : *******************************************************************************************
 : This modules defines helpfull functions used all over the app
 : 
 : @version 1.0 (2018-02-23)
 : @status developing
 : @author Uwe Sikora
 :)
module namespace ifutils="http://bdn-edition.de/intermediate_format/utils";
import module namespace http = "http://expath.org/ns/http-client";

(:############################# Modules Variables #############################:)


(:############################# Modules Functions #############################:)

(:~  
 : ifutils:exists()
 : This function checks if a resource exists in a directory
 :
 : @param $uri the uri of a resource
 : @return xs:boolean ('true' else 'false')
 : 
 : @version 1.0 (2018-03-23)
 : @status working
 : @author Uwe Sikora
 :)
declare function ifutils:exists
    ( $uri as xs:string ) {
    
    let $files := (for $i in collection(replace($uri, '(.+)/.+$', '$1')) return base-uri($i))
    return $uri = $files
};


(:~  
 : ifutils:get-resource()
 : This function gets a resource from the database or from a online source 
 :
 : @param $uri the uri of a resource
 : @return document-node
 : 
 : @version 1.0 (2018-03-23)
 : @status developing
 : @author Uwe Sikora
 :)
declare function ifutils:get-resource
    ( $uri as xs:string ) {
    
    let $resource := (
        if ( ifutils:exists($uri) ) then (
            doc($uri)
        )
        else () 
    )
    
    return $resource
};


(:~  
 : ifutils:ls()
 : This function lists all documents from a collection
 :
 : @param $collection the path of a collection
 : @return all document-base-uris from the collection
 : 
 : @version 1.0 (2018-03-23)
 : @status developing
 : @author Uwe Sikora
 :)
declare function ifutils:ls
    ( $collection as xs:string ) {
    
    for $doc in collection($collection)
    return base-uri($doc)
};


(:~  
 : ifutils:request()
 : This http wrapper function models a request 
 :
 : @param $uri the uri of a resource
 : @param $method the http method
 : @param $username the username
 : @param $password the password
 : @return http-response
 : 
 : @version 1.0 (2018-03-23)
 : @status developing
 : @author Uwe Sikora
 :)
declare function ifutils:request
    ($url as xs:string, $method as xs:string, $username as xs:string?, $password as xs:string? ) {
    
    let $req := <http:request href="{ $url }"
                            method="{ $method }"
                            username="{ $username }"
                            password="{ $password }"
                            auth-method="basic"
                            send-authorization="true"/> 
    return http:send-request($req)    
};