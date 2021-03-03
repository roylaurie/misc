'use strict';

import Meta from '../../asmov/meta/Meta.mjs';
import MetaModel from '../../asmov/meta/Model.mjs';

export default class Pack {
    static namepath = 'asmov/meta/Pack';

    static dataKeys = {
        namespace: 'namespace',
        version: 'version',
        organisation: 'organisation',
        copyright: 'copyright',
        license: 'license',
        pubkey: 'pubkey',
        product: 'product',
        codebase: 'codebase',
        subpacks: 'subpacks',
        platform: 'plastform',
    };

    static languages = {
        js: 'js',
        rust: 'rust',
        python: 'python',
        java: 'java',
        bash: 'bash'
    };

    static platforms = {
        js: 'js',
        rust: 'rust',
        python: 'python',
        java: 'java',
        nodejs: 'nodejs',
        browser: 'browser',
        electron: 'electron',
        dapp: 'dapp',
        linux: 'linux',
        osx: 'osx',
        windows: 'windows',
        android: 'android',
        ios: 'ios',
        xbox: 'xbox',
        playstation: 'playstation',
        nintendo: 'nintendo',
    };
        
    static architectures = {
        any: 'any',
        x32: 'x32',
        x64: 'x64',
        arm32: 'arm32',
        arm64: 'arm64'
    };

    static from(data, datasource) {
        return new Pack(data);
    }

    #namespace = null;
    #version = null;
    #organisation = null;
    #copyright = null;
    #license = null;
    #pubkey = null;
    #id = null;

    constructor(data) {
        this.#namespace = data[MetaPackage.dataKeys.namespace];
        this.#version = data[MetaPackage.dataKeys.version];
        this.#organisation = data[MetaPackage.dataKeys.organisation];
        this.#copyright = data[MetaPackage.dataKeys.copyright];
        this.#license = data[MetaPackage.dataKeys.license];
        this.#pubkey = data[MetaPackage.dataKeys.pubkey];
        this.#id = data[ModelMeta.dataKeys.id] || ModelMeta.id32(this, [this.#namespace, this.#version]);
    }

    id() {
        return this.#id;
    }

    data() {
        return {
            ModelMeta.dataKeys.namepath = Pack.namepath,
            ModelMeta.dataKeys.id = this.#id,
            MetaPackage.dataKeys.namespace: this.#namespace,
            MetaPackage.dataKeys.version: this.#version,
            MetaPackage.dataKeys.organisation: this.#organisation,
            MetaPackage.dataKeys.copyright: this.#copyright,
            MetaPackage.dataKeys.license: this.#license,
            MetaPackage.dataKeys.pubkey: this.#pubkey
        };
    }
}
