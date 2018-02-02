# bdn:IntermediateFormat
Scripts to convert bdn-TEI into an intermediate-format dealing with reading markers

# Notes in Advance
  - The Directory "stable_old" contains the old version and is just of documentary nature
  - The Directory "oxygen" contains files for the Development in oxygen
  - The Directories "modules" and "rest" hold all files of the new Intermediate-Format version

# setup and description
## modules/intermediate_format/identification.xqm
  - This is the main module integrating the main conversion and node identification functions
  - place it in your app modules path: "/modules/intermediate_format/inter_form.xqm" 

## modules/intermediate_format/markerset.xqm
  - Functions to collect and construct markers 
  - place it in your app modules path: "/modules/intermediate_format/markerset.xqm"

## modules/intermediate_format/preprocessing.xqm
  - Contains the preprocessing routine 
  - place it in your app modules path: "/modules/intermediate_format/preprocessing.xqm" 

## modules/intermediate_format/whitespace-handling.xqm
  - Functions for whitespace-handling
  - place it in your app modules path: "/modules/intermediate_format/whitespace-handling.xqm"

## rest/intermediate_function.xql
  - This is the REST script running the conversion on a given document within eXist-DB
  - place it in your app somewhere or as suggested here in a subfolder /rest  

# running the conversion
  - call intermediate_format.xql via REST with the GET-Parameter "path"
  - "path" must be a XML-URI existing in your app context (There is no exitence check yet)
  - wait

# Sample call
http://localhost:8080/exist/rest/apps/YOUR_APP/rest/intermediate_format.xql?path=/db/apps/bdn/data/samples/griesbach_full.xml
