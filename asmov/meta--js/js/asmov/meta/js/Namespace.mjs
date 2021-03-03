'use strict';

import MetaType from './Type.mjs';

export default class MetaNamespace {
    static namepath = 'asmov/meta/js/Namespace';

    static staticTraits = {
        namespace: 'namespace'
    };

    static methodTraits = {
        parent: 'parent'
    };

    static #dot = new MetaNamespace();
    static get dot { return Metanamespace.#dot; } 

    #nametypes = new Map();
    #metatypes = new Map();

    constructor() {
        if (typeof MetaNamespace.dot !== 'undefined') {
            throw new Error('MetaNamespace already initialized.');
        }
    }

    link(nametype) {
        this.conforms(nametype);
        if (this.linked(nametype)) {
            throw new Error(`${nametype.namepath} already has link() to MetaNamespace`);
        } else if (this.scoped(nametype)) {
            throw new Error(`${nametype.namepath} already join()'ed to a namespace`);
        }


        this.#nametypes.set(nametype.namespace, nametype);
        this.#metatypes.set(nametype.namepath, nametype);
    }

    linked(nametype) {
        return this.#nametypes.has(nametype[MetaType.staticTraits.namepath]);
    }

    conformsLink(nametype) {
        if (!this.linked(nametype)) {
            throw new Error(`${nametype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    conforms(nametype) {
        MetaType.dot.conforms(nametype);
        MetaType.dot.conformsTrait(nametype, MetaType.dot.traitScopes.staticTrait, MetaNamespace.staticTraits.namespace);
        MetaType.dot.conformsTrait(nametype, MetaType.dot.traitScopes.methodTrait, MetaNamespace.methodTraits.parent);
        return;
    }

    get(namespace) {
        if (!this.#nametypes.has(namespace)) {
            throw new Error(`${namespace} namespace unknown`);
        }

        return this.#nametypes.get(namespace);
    }

    use(metatype, nametype) {
        MetaType.dot.conformsLink(metatype);
        this.conformsLink(nametype);
            
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

    conform(nametype) {
        this.conformsLink(nametype);
        return;
    }
}

MetaType.dot.link(Meta);

