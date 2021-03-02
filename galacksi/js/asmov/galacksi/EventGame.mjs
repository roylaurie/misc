'use strict';

import Event from './Event.mjs';
import Game from './Game.mjs';

export default class EventGame extends Event {
    static namepath = 'asmov/galacksi/EventGame';

    static dataKeys = {
        game: 'game'
    };

    #game = null;

    constructor(game, timestamp) {
        super(timestamp);
        this.#game = game;
    }

    getGame() {
        return this.#game;
    }

    data() {
        return super.data().concat({
            EventGame.dataKeys.game: this.#game.data()
        });
    }
}
