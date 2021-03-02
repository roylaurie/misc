'use strict';

import EventGameState from './EventGameState.mjs';
import Game from './Game.mjs';
import Round from './Round.mjs';

export default class EventGameRound extends EventGameState {
    static namepath = 'asmov/galacksi/EventGameRound';

    static dataKeys = {
        round: 'round'
    };

    #round = null;

    constructor(game, round, timestamp) {
        super(game, timestamp);
        this.#round = round;
    }

    getRound() {
        return this.#round;
    }

    data() {
        return super.data().concat({
            EventGameRound.dataKeys.round: this.#round.data()
        });
    };
}


