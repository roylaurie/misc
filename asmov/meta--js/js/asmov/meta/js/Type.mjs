'use strict';

export default class MetaType {
    static namepath = 'asmov/meta/js/Type';
    static traitname = 'Type';

    /* singleton */
    static #dot = new MetaType();
    static get dot { return MetaType.#dot; }

    static staticTraits = {
        namepath: 'namepath',
    };

    static staticMethodTraits = {};

    static methodTraits = {};

    static dataTraits = {};


    #types = new Map();

    constructor() {
        if (typeof MetaType.dot !== 'undefined') {
            throw new Error('MetaType already initialized.');
        }
    }

    conforms(metatype) {
        if (typeof metatype[MetaType.staticTraits.namepath] !== 'string') {
            throw new Error(metatype, 'missing namepath');
        } 
    }

    /** Registers a class with the MetaType library. Validates basic interace. Linked against a namespace defining MetaTypePack. **/
    link(metatype) {
        this.conforms(metatype);
        if (this.linked(metatype)) {
            throw new Error(`${metatype.namepath} already linked'`);
        }

        this.#types.set(metatype.namepath, metatype);
    }

    /** Determines whethere a class has been linked to the MetaType library or not. **/
    linked(metatype) {
        return this.#types.has(metatype[MetaType.dataKeys.namepath]);
    }

    conformsLink(metatype) {
        if (!this.linked(metatype)) {
            throw new Error(`${metatype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    /** Retrieves the class linked for the given namespace **/
    get(namepath) { 
        return this.#types[namepath]
    }

    conform(metatype) {
        this.conformsLink(metatype);
        return;
    }
}

MetaTrait.dot.link(MetaType);
MetaType.dot.link(MetaType);
