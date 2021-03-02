'use strict';

import Meta from '../../asmov/meta/js/Meta.mjs';
import murmur3 from '../../ext/murmurhash3_gc.js';

export default class MetaModel {
    static namepath = 'asmov/meta/js/Model';

    static dot = new MetaModel();

    #factories = {};
    #datasources = {};

    constructor() {
        if (typeof dot !== 'undefined') {
            throw new Error('MetaModel already initialized');
        }
    }

    link(_class) {
        if (!Meta.dot.isClass(_class)) {
            throw new Error(_class, 'is not a linked class');
        } else if (typeof _class.constructor.from !== 'function' || typeof _class.prototype.data !== 'function') {
            throw new Error(_class.namepath + ' is not modellable');
        }

        this.#factories[_class.namepath] = _class.constructor.from;
    }

    static link(_class) { MetaModel.dot.registerClass(_class); }

    linked(_class) {
        return ( typeof this.#factories[_class.namepath] !== 'undefined' );
    }

    static linked(_class) { return MetaModel.dot.registered(_class); }

    from(data, datasource) {
        const factoryMethod = this.#factories[data[Meta.dataKeys.namepath]];
        return factoryMethod(data, datasource);
    }

    static from(data, datasource) { return MetaModel.dot.modelFrom(data, datasource); }

    data(classObject) {
        if (!this.registered(classObject.constructor.namepath)) {
            throw new Error(classObject, 'is not a registered model');
        }

        return classObject.data();
    }

    static data(classObject) { return MetaModel.dot.data(classObject); }

    datasource(contextNamepath) {
        if (typeof this.#datasources[contextNamepath] === 'undefined') {
            this.#datasources[contextNamepath] = new ModelDatasource(contextNamepath);
        }

        return this.#datasources[contextNamepath];
    }

    static datasource(contextNamepath) { return datasource(contextNamepath); }

    identify(classObject, idData) {
        return murmur3(classObject.namepath + idData.join(), 159710); 
    }

    static identify(classObject, idData) { return MetaModel.dot.identify(classObject, idData); }

    identity(classObject) {
        return {
            Meta.dataKeys.namepath: classObject.namepath,
            MetaModel.dataKeys.id: classObject.id()
        };
    }

    static identity(classObject) { return MetaModel.dot.identity(classObject); }
}

class ModelDatasource {
    static namepath = 'asmov/meta/js/Model//ModelDatasource';

    #contextpath = null;
    #data = {};

    constructor(contextpath) {
        this.#contextpath = contextpath;
    }

    store(classObject) {
        if (MetaModel.dot.registered(classObject.constructor)) {
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
        if (typeof this.#data[MetaModel.dataKeys.namepath] === 'undefined') {
            return null;
        }

        return this.#data[data[MetaModel.dataKeys.namepath]][data[MetaModel.dataKeys.id]] || null;
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
