'use strict';

import MetaTrait from './Trait.mjs';
import MetaType from './Type.mjs';

/* TODO:
Template replacement terms:
  CLASS_NAME The class name. E.g., SimpleTrait
  NAMEPATH The namepath of this class. E.g., myorg/stuff/simple/Trait
  TRAIT_NAME The trait name for the class. E.g., Simple
  LINKTYPE The term to refer to types of this trait. E.g., metatype
  LINKTYPES The name of the variable to store the traits linked in. E.g., metatypes
*/

export default class CLASS_NAME {
    static namepath = 'NAMEPATH';
    static traitname = 'TRAIT_NAME';

    static staticTraits = {};
    static staticMethodTraits = {};
    static methodTraits = { };
    static dataTraits = {};

    static dot = new CLASS_NAME();

    #LINKTYPES = new Map();

    constructor() {
        if (typeof CLASS_NAME.dot !== 'undefined') {
            throw new Error('CLASS_NAME already initialized.');
        }
    }

    confirm(LINKTYPE) {
        MetaType.dot.confirm(LINKTYPE);
        MetaModel.dot.confirm(LINKTYPE);
        MetaTrait.dot.confirmTrait(LINKTYPE, CLASS_NAME);
    }

    link(LINKTYPE) {
        this.confirm(LINKTYPE);
        this.#LINKTYPES.set(LINKTYPE.namepath, LINKTYPE);
    }


    linked(LINKTYPE) {
        return this.#LINKTYPES.has(LINKTYPE.namepath);
    }

    confirmLink(nametype) {
        if (!this.linked(nametype)) {
            throw new Error(`${nametype.namepath} is not link()'ed to MetaType`);
        }

        return;
    }

    conform(LINKTYPE) {
        this.confirm(LINKTYPE);
        this.confirmLink(LINKTYPE);
        return;
    }

    get(namepath) {
        if (!this.#LINKTYPES.has(namepath)) {
            throw new Error(`${namepath} namepath unknown`);
        }

        return this.#LINKTYPES.get(namepath);
    }
}

MetaTrait.dot.link(CLASS_NAME);
MetaType.dot.link(CLASS_NAME);

