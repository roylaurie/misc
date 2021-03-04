'use strict';

import MetaTrait from './Trait.mjs';
import MetaType from './Type.mjs';

export default class MetaNamespace {
    static namepath = 'asmov/meta/js/Namespace';
    static traitname = 'Namespace';

    static staticTraits = {
        namespace: 'namespace'
    };

    static methodTraits = {
        parent: 'parent'
    };

    static staticMethodTraits = {};
    static dataTraits = {};

    static dot = new MetaNamespace();

    #nametypes= new Map();
    #metatypes = new Map();

    constructor() {
        if (typeof MetaNamespace.dot !== 'undefined') {
            throw new Error('MetaNamespace already initialized.');
        }
    }

    confirm(nametype) {
        MetaType.dot.confirm(nametype);
        MetaTrait.dot.confirmTrait(nametype, MetaNamespace);
        return;
    }

    link(nametype) {
        this.confirm(nametype);
        if (this.linked(nametype)) {
            throw new Error(`${namespace.namepath} already has link() to MetaNamespace`);
        } else if (this.scoped(nametype)) {
            throw new Error(`${namespace.namepath} already join()'ed to a namespace`);
        }


        this.#nametypes.set(nametype.namespace, nametype);
        this.#metatypes.set(nametype.namepath, nametype);
    }

    linked(nametype) {
        return this.#nametypes.has(nametype[MetaType.staticTraits.namepath]);
    }

    confirmLink(nametype) {
        if (!this.linked(nametype)) {
            throw new Error(`${nametype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    conform(nametype) {
        this.confirm(nametype);
        this.confirmLink(nametype);
        return;
    }

    get(namespace) {
        if (!this.#nametypes.has(namespace)) {
            throw new Error(`${namespace} namespace unknown`);
        }

        return this.#nametypes.get(namespace);
    }

    use(metatype, nametype) {
        MetaType.dot.confirmLink(metatype);
        this.confirmLink(nametype);
            
        if (this.scoped(metatype, nametype)) {
            throw new Error(`${metatype.namepath} already has link() to MetaNamespace`);
        }

        this.#metatypes.set(metatype.namepath, nametype); 
    }

    scoped(metatype) {
        return this.#metatypes.has(metatype[MetaType.staticTraits.namepath]);
    }

    namespace(metatype) {
        if(!this.#metatypes.has(metatype[MetaType.staticTraits.namepath])) {
            throw new Error(`${metatype[MetaType.staticTraits.namepath]} does not use() a namespace`);
        }

        return this.#metatypes.get(metatype[MetaType.staticTraits.namepath]);
    }
}

MetaTrait.dot.link(MetaNamespace);
MetaType.dot.link(MetaNamespace);


