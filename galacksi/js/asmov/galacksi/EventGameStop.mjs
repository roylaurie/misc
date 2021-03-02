'use strict';

import EventGame from './EventGame.mjs';
import EventGameState from './EventGameState.mjs';
import Game from './Game.mjs';

export default class EventGameEnd extends EventGameState {
    static namepath = 'asmov/galacksi/EventGameEnd';

    static from(data, datasource) {
        return new EventGameEnd(datasource.get(Game, data[EventGame.dataKeys.game]), data[Event.dataKeys.timestamp]);
    }

    constructor(game, timestamp) {
        super(game, timestamp);
    }
}
