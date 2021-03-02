'use strict';

import Meta from '../../asmov/meta/js/Meta.mjs';
import murmur3 from '../../ext/murmurhash3_gc.js';

export default class MetaModel {
    static namepath = 'asmov/meta/js/Model';

    static dot = new MetaModel();

    static dataKeys = {
        namepath: 'namepath',
        id: 'id'
    };

    #factories = {};
    #datasources = {};

    constructor() {
        if (typeof dot !== 'undefined') {
            throw new Error('MetaModel already initialized');
        }
    }

    registerClass(_class) {
        if (!Meta.dot.isClass(_class)) {
            throw new Error(_class, 'is not a linked class');
        } else if (typeof _class.constructor.from !== 'function' || typeof _class.prototype.data !== 'function') {
            throw new Error(_class.namepath + ' is not modellable');
        }

        this.#factories[_class.namepath] = _class.constructor.from;
    }

    static registerClass(_class) { ModelMeta.dot.registerClass(_class); }

    registered(_class) {
        return ( typeof this.#factories[_class.namepath] !== 'undefined' );
    }

    static registered(_class) { return ModelMeta.dot.registered(_class); }

    modelFrom(data, datasource) {
        const factoryMethod = this.#factories[data.namepath];
        return factoryMethod(data, datasource);
    }

    static modelFrom(data, datasource) { return ModelMeta.dot.modelFrom(data, datasource); }

    model(object) {
        if (!this.registered(object.constructor.namepath)) {
            throw new Error(object, 'is not a registered model');
        }

        return object.data();
    }

    static model(object) { return ModelMeta.dot.model(object); }

    datasource(contextNamepath) {
        if (typeof this.#datasources[contextNamepath] === 'undefined') {
            this.#datasources[contextNamepath] = new ModelDatasource(contextNamepath);
        }

        return this.#datasources[contextNamepath];
    }

    static datasource(contextNamepath) { return datasource(contextNamepath); }

    id32(_classObject, idData) {
        return murmur3(_classObject.namepath + idData.join(), 159710); 
    }

    static id32(_classObject, idData) { return ModelMeta.dot.id32(_classObject, idData); }
}

class ModelDatasource {
    static namepath = 'plur/ModelMeta//ModelDatasource';

    #contextpath = null;
    #data = {};

    constructor(contextpath) {
        this.#contextpath = contextpath;
    }

    store(classObject) {
        if (ModelMeta.dot.registered(classObject.constructor)) {
            throw new Error('Not modellable');
        } if (typeof classObject.id  !== 'function') {
            throw new Error('Cannot store data without id() method');
        }

        if (typeof this.#data[classObject.constructor.namepath] === 'undefined') {
            this.#data[classObject.constructor.namepath] = {};
        }

        this.#data[classObject.constructor.namepath][classObject.id()] = classObject;
    }

    retrieve(data) {
        if (typeof this.#data[ModelMeta.dataKeys.namepath] === 'undefined') {
            return null;
        }

        return this.#data[data[ModelMeta.dataKeys.namepath]][data[ModelMeta.dataKeys.id]] || null;
    }

    get(data) {
        const object = this.retrieve(data);
        if (object !== null) {
            return object;
        } else {
            const newObject = MetaModel.modelFrom(data, this);
            this.store(newObject);
            return object;
        }
    }
}
