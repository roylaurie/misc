'use strict';

import EventGame from './EventGame.mjs';
import Game from './Game.mjs';

export default class EventGameState extends EventGame {
    constructor(game, timestamp) {
        super(game, timestamp);
    }
}
