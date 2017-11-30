# bdn:IntermediateFormat
Scripts to convert bdn-TEI into an intermediate-format dealing with reading markers

# setup and description
## stable/modules/intermediate_format/inter_form.xqm
  - This is the main module integrating the conversion functions
  - place it in your app modules path: "/modules/intermediate_format/inter_form.xqm" 

## stable/modules/string.xqm
  - This is the a helper module dealing with strings
  - place it in your app modules path: "/modules/string.xqm" 

## stable/rest/intermediate_function.xql
  - This is the a conversion script running the conversion on a given document
  - place it in your app somewhere or as suggested here: "/rest/intermediate_function.xql" 

# running the conversion
  - call intermediate_function.xql via REST with the GET-Parameter "path"
  - "path" must be a XML-URI existing in your app context (There is no exitence check yet)
  - wait

# Sample call
http://localhost:8080/exist/rest/apps/bdn/rest/intermediate_format.xql?path=/db/apps/bdn/data/samples/griesbach_full.xml
