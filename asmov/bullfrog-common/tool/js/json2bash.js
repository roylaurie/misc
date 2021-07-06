'use strict';

import Ajv from 'ajv'

function main() {
    // script arguments: json schema filename, json data filename, bash output filename

    // load json schema into ajv

    // validate json data against ajv

    // define a js object representation of the json schema using either ajv or json parsing

    // define a key-value array that accepts either strings or arrays of strings as values. namespace is key.

    // walk json schema object. for each definition
    //   compile the namespace string for each definition context
    //   store the appropriate value (string or array<string>) for the definition by its namespace

    // write the skeleton header to the output bash file

    // for each key-value pair: write a bash config statement to the bash output file, based on type

    // write the skeleton footer to the output bash file

    // end
}

main();