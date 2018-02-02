xquery version "3.0";

module namespace target="http://www.interform.com/target_index";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace markerset = "http://www.interform.com/markerset";
import module "http://www.interform.com/markerset" at "markerset.xqm";

declare function target:index
    ( $app-index as node() ) as item()* {
    
    let $targets := $app-index//target
    let $targets-ids := distinct-values($targets/@gid)
    for $id in $targets-ids
    let $findings := $targets[@gid eq $id]
    let $target := target:group-target-by-id($id, $targets)
    return
       $target
};

declare function target:group-target-by-id
    ( $target-id as xs:string?, $targets as node()* ) as item()* {
    
    let $target-cluster := $targets[@gid eq $target-id]
    let $target-name := $target-cluster/child::node()/name()[1]
    let $markerset := target:collect-target-markersets($target-cluster)
    return
        element {"target"}{
            attribute {"id"}{$target-id},
            attribute {"name"}{$target-name[1]},
            $markerset
        }
    
};

declare function target:collect-target-markersets
    ( $target-cluster ) as item()* {
    
    for $finding in $target-cluster
    let $marker-type := $finding/@type
    let $reading := $finding/parent::node()
    let $reading-shortcut := element { $reading/name() }{ $reading/@* }
    let $hierarchy := $reading/parent::app/string(@n)
    let $markerset := $reading/markerset
    return 
        element { "markerset" }{
            attribute { "hierarchy" }{ $hierarchy },
            attribute { "type" }{ $marker-type },
            target:compose-markers($markerset, $marker-type)
        }
    
};

declare function target:compose-markers
    ( $markerset, $marker-type ) as item()* {
    
    if ( $marker-type eq "open" ) then (
        target:compose-open-markers($markerset)
    ) 
    else if ( $marker-type eq "close" ) then (
        target:compose-close-markers($markerset)
    )
    else if ( $marker-type eq "open close" ) then (
        target:compose-open-markers($markerset),
        target:compose-close-markers($markerset)
    )
    else (
        $markerset
    )
    
};

declare function target:compose-open-markers
    ( $markerset ) as item()* {
    
    let $markers := (
        for $marker in $markerset/node()
        return
            markerset:marker("rdgMarker", "open", $marker)
    )
    
    return element{"open"}{
        $markers
    } 
};

declare function target:compose-close-markers
    ( $markerset ) as item()* {
    
    let $markers := (
        for $marker in $markerset/node()
        return
            markerset:marker("rdgMarker", "close", $marker)
    )
    
    return element{"close"}{
        reverse($markers)
    } 
};

declare function target:conversion-by-target-index
    ( $nodes as node()*, $target-index as item()* ) as item()* {
    
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            case text() return ($node)
            case comment() return ((:$node:))
            default return ( 
                let $found := $target-index[@id eq generate-id($node)]
                return
                    if ($found) then (
                        let $open := $found//open/node()
                        let $close-set := (
                            for $set in $found/markerset
                            order by $set/string(@hierarchy) descending
                            return
                                <h>{$set}</h>
                        )
                        
                        let $close := $close-set//close/node()
                        return (
                            $open,
                            element {$node/name()}{
                                (:attribute {"gid"}{ generate-id($node) },:)
                                $node/@*,
                                target:conversion-by-target-index($node/node(), $target-index) 
                            },
                            $close
                    )
                    ) else ( 
                        element {$node/name()}{
                            $node/@*,
                            target:conversion-by-target-index($node/node(), $target-index) 
                        }
                    )
            )
};