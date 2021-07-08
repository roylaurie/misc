#!/usr/bin/env node
'use strict'; // ecma.version 2021

import fs from 'fs/promises';
import util from 'util';

import Ajv from 'ajv';

const JSON_SCHEMA_FILEPATH = '../../json/schema/cfg/namespace.cfg.schema.json'
const JSON_DATA_FILEPATH = '../../json/cfg/namespace.cfg.json'

const SCHEMA_NAME="namespace";

async function loadSchema(name, filepath) {
    const jsonSchema = JSON.parse((await fs.readFile(filepath)).toString());

    // load json schema into ajv
    const ajv = new Ajv();
    ajv.addSchema(jsonSchema, name);
    return ajv;
}

async function validateData(ajv, name, filepath) {
    const validateFunc = ajv.getSchema(name);
    const jsondata = JSON.parse(await fs.readFile(filepath));
    if (!validateFunc(jsondata)) {
        throw new Error("Unable to parse invalid JSON. " + inspect(validateFunc.errors));
    }

    return jsondata;
}

function buildKV(data) {
    // define a key-value array that accepts either strings or arrays of strings as values. namespace is key.
    const kv = {};

    // walk json schema object. for each definition
    //   compile the namespace string for each definition context
    //   store the appropriate value (string or array<string>) for the definition by its namespace

    const packageNamespace = data.package.name;
    const packagePrefix = 'package.' + packageNamespace  + '.';
    kv[packagePrefix + 'namespaces'] = Object.keys(data.package.namespaces);

    for (const namespace in data.package.namespaces) {
        const namespaceData = data.package.namespaces[namespace];
        let prefix = packagePrefix + 'namespaces.' + namespace + '.';
        kv[prefix + 'desc'] = namespaceData.desc;
        kv[prefix + 'operations'] = Object.keys(namespaceData.operations);

        for (const operation in namespaceData.operations) {
            const operationData = namespaceData.operations[operation];
            prefix += 'operations.' + operation + '.';
            kv[prefix + 'desc'] = operationData.desc;
            kv[prefix + 'parameters'] = Object.keys(operationData.parameters);

            for (const parameter in operationData.parameters) {
                const parameterData = operationData.parameters[parameter];
                prefix += 'parameters.' + parameter + '.';
                kv[prefix + 'desc'] = parameterData.desc;
                kv[prefix + 'position'] = parameterData.position.toString();
                kv[prefix + 'required'] = parameterData.required.toString();
            }
        }
    }

    return kv;
}

function printBashCfg(kv) {
    const lines = [];

    // for each key-value pair: write a bash config statement to the bash output file, based on type
    for (const key in kv) {
        const value = kv[key];
        const type = typeof value === 'string' ? 'string' : 'array';
        let line = 'frogcfg_set_key ' + type + ' "' + key + '"';

        if (type === 'array') {
            for (const val of value) {
                line += ' "' + val + '"';
            }
        } else { // string
            line += ' "' + value + '"';
        }

        console.log(line);
    }
}

function printBashHeader() {
    console.log('#!/bin/bash\nset -o allexport -o errexit -o privileged -o pipefail -o nounset\n');
}

function printBashFooter(packageNamespace) {
    console.log('\nFROG_PACKAGE_NAMESPACE="' + packageNamespace + '"');
}

function inspect(obj) {
    return util.inspect(obj, false, null, true);
}

function logobj(subject, obj) {
    console.log(subject, util.inspect(obj, false, null, true));
}

async function main() {
    // script arguments: json schema filename, json data filename, bash output filename

    // validate json data against ajv
    const ajv = await loadSchema(SCHEMA_NAME, JSON_SCHEMA_FILEPATH);
    const data = await validateData(ajv, SCHEMA_NAME, JSON_DATA_FILEPATH);

    // define a js object representation of the json schema using either ajv or json parsing
    const schema = ajv.getSchema(SCHEMA_NAME).schema

    const packageNamespace = data.package.name;
    // build the key-value config based on data
    const kv = buildKV(data);

    // write bash src to output
    printBashHeader();
    printBashCfg(kv);
    printBashFooter(packageNamespace);
}

await main();