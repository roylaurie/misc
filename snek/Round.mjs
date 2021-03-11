'use strict';

import Dice from './Dice.mjs';

export default class Round {
    static phases = {
        betting: 'betting',
        establishing: 'establishing',
        rolling: 'rolling',
        settling: 'settling',
        complete: 'complete'
    };

    #dice = new Dice();
    #bets = [];
    #point = 0;
    #phase = Round.phases.betting;
    #players = [];
    #rng = null;

    constructor(rng, workingBets) {
        this.#bets.push(workingBets);
        this.#rng = rng;
    }

    place(bet) {
        bets.push(bet);
    }

    takedown(bet) {
        this.#bets.splice(this.#bets.indexOf(bet), 1); 
    }

    #close() {
        this.#phase = Round.phases.establishing;
    }

    #roll() {
        const number = this.#dice.roll();
        let round = this;

        switch (this.#phase) {
        case Round.phases.establishing:
            if (number === 7 || number === 11) {
                const workingBets = this.#settle(number);
                round = new Round(this.#rng, workingBets);
            } else if (number === 2) {
                const workingBets = this.#settle(number);
                round = new Round(this.#rng, workingBets);
            } else {
                this.#point = number;
                this.#phase = Round.phases.rolling;
            }
            break;
        case Round.phases.rolling:
            if (number === 7) {
                const workingBets = this.#settle(number);
                round = new Round(this.#rng, workingBets);
            } else if (number === this.#point) {
                this.#phase = Round.phases.rolling;
                const workingBets = this.#settle(number);
                round = new Round(this.#rng, workingBets);
            } else {
                break; 
            }
            break;
        default:
            throw new Error();
        }
    }

    play() {
        switch(this.#phase) {
        case Round.phases.betting:
        break;

        case Round.phases.establishing:
            this.#roll();
        break;

        case Round.phases.rolling:
            this.#roll();
        break;

        case Round.phases.settling:
        case Round.phases.complete:
        default:
            throw new Error();

        }

        return this.#phase;
    }

    #settle(number) {
        let workingBets = [];

        for (let bet of this.#bets) {
            const payout = bet.payout(number);
            player.pay(payout);

            const nextBet = bet.next(number);
            if (nextBet) {
                workingBets.push(nextBet);
            } else {
                const amount = bet.amount():
                if (amount > 0 && payout < amount) {
                    player.pay(amount - payout);
                }
            }
        }

        return workingBets;
    }
}
