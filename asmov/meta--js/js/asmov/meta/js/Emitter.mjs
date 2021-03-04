'use strict';

import Meta from '../../../asmov/meta/js/Meta.mjs';
import MetaJSPack from '../../../asmov/meta/js/MetaPack.mjs';

export default class MetaEmit {
    static namepath = 'asmov/meta/js/Emit';

    static dot = new MetaEmit();

    #providers = new Map();

    constructor() {
        // singleton enforcement
        if (typeof Meta.dot !== 'undefined') {
            throw new Error('Meta already initialized.');
        }
    }

    link(metaclass) {
        this.conforms(metaclass);
        this.#providers.set(metaclass.namepath, metaclass);
    }

    static link(metaclass) { return MetaEmit.dot.link(metaclass); }

    linked(metaclass) {
        return this.#providers.has(metaclass.namepath);
    }

    static linked(metaclass) { return MetaEmit.dot.linked(metaclass); }

    conforms(metaclass) {
        Meta.conforms(metaclass);

        if (typeof metaclass.prototype.listener === 'undefined') {
            throw new Error(`${metaclass.namepath} lacks a listener() method`);
        }
    }

    static conforms(metaclass) { return MetaEmit.dot.conforms(metaclass); }
}

Meta.Class.link(MetaEmit);
Meta.Codebase.link(MetaEmit, MetaJSPack);

class MetaEmitter {
    static namepath = 'asmov/meta/js/Emitter';

    static emissions = {
        object: 'object'
        data: 'data',
    };

    #listeners = new Map();
    #provider = null;
    #emissionType =  null;
    #defaultSubscriber = null;
    #defaultListener = null;

    constructor(provider, emissionType = MetaEmitter.emissions.object) {
        MetaEmitter.validateProvider(provider);
        this.#provider = new WeakRef(provider);
        this.#emissionType = Meta.select(emissionType, emissions);
        this.#defaultListener = new Listener(this);
        this.#defaultPublisher = new Publisher(this);
    }

    listen(subscriber, metaclass, callback) {
        const namepath = metaclass.namepath;

        if (typeof this.#provider === 'undefined') {
            return this.destroy();
        }

        if (!this.#listeners.has(namepath)) {
            this.#listeners.set(namepath, new WeakMap());
        }

        if (!this.#listeners.get(namepath).has(subscriber)) {
            this.#listeners.get(namepath).set(subscriber, callback);
        } else {
            throw new Error(subscriber.namepath + 'is already listening to ' + metaclass.namepath);
        }
    }

    unsubscribe(subscriber, metaclass = null) {
        if (metaclass !== null) {
            this.#listeners.get(metaclass.namepath).delete(subscriber) {
        } else {
            for (let namepath in this.#listeners) {
                this.#listeners.get(namepath).delete(subscriber);
            }
        }
    }

    emit(emission) {
        const namepath = emission.namepath;
        const listeners = this.#listeners.get(namepath);

        if (typeof this.#provider === 'undefined') {
            return this.destroy();
        } else if (typeof listeners === 'undefined') {
            return;
        }

        for (let listener in listeners) {
            let callback = listeners[listener];
            callback.call(listener, emission, this.#provider.deref(), emissionType); 
        }
    }

    destroy() {
        this.#listeners = null;
        this.#provider = null;
        this.#emissionType = null;
        this.#defaultPublisher = null;
        this.#defaultSubscriber = null;
        return;
    }

    subscriber() {
        return this.#defaultSubscriber;
    }

    publisher() {
        return this.#defaultPublisher;
    }
}

Meta.link(MetaJSPack, Emitter);


class Publisher {
    static namepath = 'asmov/meta/js/Emitter//Publisher';
        
    this.#emitter = emitter;

    constructor(emitter) {
        this.#emitter = emitter;
    }

    emit(emission) {
        this.#emitter.emit(emission);
    }
}

Meta.link(MetaJSPack, Publisher);


class Subscriber {
    static namepath = 'asmov/meta/js/Emitter//Subscriber';

    this.#emitter = emitter;

    constructor(emitter) {
        this.#emitter = emitter;
    }

    listen(listener, metaclass) {
        return this.#emitter.listen (listener, metaclass);
    }

    unsubscribe(listener, metaclass = null) {
        this.#emitter.unsubscribe(listener, metaclass);
    }
}

Meta.link(MetaJSPack, Subscriber);

Meta.link(MetaJSPack, MetaEmitter);
