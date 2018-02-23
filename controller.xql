xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

import module namespace console="http://exist-db.org/xquery/console";

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if ( starts-with($exist:path, "/rest/convert") ) then 
    (: forwards to the intermediate_format.xql in the rest-dir :)
    let $resource := request:get-parameter("resource", ())
    let $uri := request:get-parameter("uri", ())
    let $mode := request:get-parameter("mode", ())
    let $log := (<log root="/rest/convert"><resource>{$resource}</resource><uri>{$uri}</uri><mode>{$mode}</mode></log>)
    return (
        console:log($log),
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/rest/intermediate_format.xql"/>
            <set-attribute name="resource" value="{$resource}"/>
            <set-attribute name="uri" value="{$uri}"/>
            <set-attribute name="mode" value="{$mode}"/>
        </dispatch>
    )
    
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
(: Resource paths starting with $resources are loaded from the apps resources dir :)
else if (contains($exist:path, "/$resources/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/{substring-after($exist:path, '/$resources/')}">
            <set-header name="Cache-Control" value="max-age=0, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>