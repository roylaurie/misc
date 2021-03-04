'use strict';

import MetaTrait from './Type.mjs';
import murmur3 from '../../../ext/murmurhash3_gc.js';

export default class MetaModel {
    static namepath = 'asmov/meta/js/Model';

    static staticMethodTraits = {
        from: 'from'
    };

    static methodTraits = {
        data: 'data',
        id: 'id'
    }

    static dataTraits = {
        namepath: 'namepath',
        id: 'id',
    }

    static #dot = new MetaModel();
    static get dot { return MetaModel.#dot; };

    #modeltypes = new Map();

    constructor() {
        if (typeof dot !== 'undefined') {
            throw new Error('MetaModel already initialized');
        }
    }

    link(modeltype) {
        this.conforms(modeltype);
        MetaTrait.conformsLink(modeltype);
        this.#modeltypes.set(modeltype.namepath, modeltype.constructor.from);
    }

    linked(modeltype) {
        return this.#modeltypes.has([modeltype[MetaTrait.staticTraits.namepath]]);
    }

    conforms(modeltype) {
        MetaTrait.dot.conforms(modeltype);
        MetaTrait.conformsTrait(modeltype, MetaTrait.dot.schemas.staticMethodTrait, MetaModel.staticMethodTraits.from);
        MetaTrait.conformsTrait(modeltype, MetaTrait.dot.schemas.methodTrait, MetaModel.methodTraits.data);
        MetaTrait.conformsTrait(modeltype, MetaTrait.dot.schemas.methodTrait, MetaModel.methodTraits.id);
        return;
    }

    conformsDataTrait(data, trait) {
        if (typeof data[trait] === 'undefined') {
            throw new Error(`Data '${data[MetaModel.dataTraits.namepath]}' + ' lacks a '${trait}' key`);
        }

        return;
    }

    conformsDataIdentity(data) {
        this.conformsDataTrait(data, MetaModel.dataTraits.namepath);
        this.conformsDataTrait(data, MetaModel.dataTraits.id);
    }

    from(data, datasource) {
        const namepath = data[MetaModel.dataTraits.namepath];
        const factoryMethod = this.#modeltypes.get(namepath);
        if (typeof factoryMethod === 'undefined') {
            throw new Error(`Data could not be factoried for namepath '${namepath}`);
        }

        return factoryMethod(data, datasource);
    }

    data(modeltype) {
        this.conformsLink(modeltype);
        return modeltype.data();
    }

    identity(modeltype) {
        this.conformsLink(modeltype);
        return Object.freeze({
            MetaModel.dataTraits.namepath: modeltype.namepath, 
            MetaModel.dataTraits.id: modeltype.id()
        });
    }

    dataIdentity(data) {
        this.conformsDataIdentity(data);
        return Object.freeze({
            MetaModel.dataTraits.namepath: data.namepath, 
            MetaModel.dataTraits.id: data.id
        });
    }
}

MetaTrait.dot.link(MetaModel);
MetaTType.dot.link(MetaModel);
