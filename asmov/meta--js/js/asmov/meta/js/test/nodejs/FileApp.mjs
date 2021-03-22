'use strict';

import path from 'path';
import fileregex from 'file-regex';
import Meta from '../../Meta.mjs';

export default class TestFileApp {
    static namepath = 'asmov/meta/js/test/nodejs/App';

    static modes = {
        case: 'case',
        unit: 'unit'
    };

    static #findRegex = /^(?:|.*\/)[a-z0-9_\-]+-tests\/.*[a-zA-Z0-9\-_]+Test\.mjs$/;
    static #extRegex = /^(.*)\.[^.]+$/;

    namepath = TestFileApp.namepath;

    #mode = null;
    #rootdir = null;

    constructor(path, mode = TestFileApp.modes.case) {
        this.#mode = mode;
        this.#rootdir = path; // todo determine single file paths
    }

    async run() {
        const filepaths = await this.#findTestFiles(this.#rootdir);
        const tester = new Tester(filepaths);
        return tester.test();
    }

    async #findTestFiles(rootdir) {
        const filepaths = await fileregex(rootdir, TestFileApp.#findRegex);
        let testpaths = [];

        for (let filepath of filepaths) {
            // remove the module path root from the filepath, making it relative (like the namepath is)
            const relativeFilepath = filepath.substring(filepath.length - path.basename(filepath).length);
            // remove the extension from the name to form a valid namepath
            const namepath = relativeFilepath.match(TestFileApp.#extRegex)[1];
            testpaths.push(namepath);
        }

        return testpaths;
    }
}

Meta.link(TestFileApp, []);
