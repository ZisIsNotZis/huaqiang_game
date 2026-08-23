import test from "node:test";
import assert from "node:assert/strict";

import { ACTIONS, createGame, performAction } from "../src/event-state.js";

test("public evidence unlocks a nonviolent demand", () => {
  let game = createGame();
  game = performAction(game, ACTIONS.INSPECT_SCALE);
  game = performAction(game, ACTIONS.INVITE_WITNESS);
  game = performAction(game, ACTIONS.ASK_FOR_WEIGHT);
  game = performAction(game, ACTIONS.EXPOSE_MAGNET);

  assert.equal(game.phase, "pressure");
  assert.equal(game.npc.merchant.support, 1);
  assert.deepEqual(game.availableActions, [ACTIONS.DEMAND_REFUND]);

  game = performAction(game, ACTIONS.DEMAND_REFUND);

  assert.equal(game.phase, "resolved");
  assert.equal(game.result.outcome, "concession");
  assert.equal(game.result.violenceStarted, false);
});

test("spatial preparation unlocks escape after an early accusation", () => {
  let game = createGame();
  game = performAction(game, ACTIONS.PARK_FOR_EXIT);
  game = performAction(game, ACTIONS.BLOCK_HELPER_PATH);
  game = performAction(game, ACTIONS.ACCUSE_EARLY);

  assert.equal(game.phase, "conflict");
  assert.deepEqual(game.availableActions, [ACTIONS.PUSH_AND_ESCAPE]);

  game = performAction(game, ACTIONS.PUSH_AND_ESCAPE);

  assert.equal(game.result.outcome, "controlled_escape");
  assert.equal(game.result.violenceStarted, true);
});

test("an unavailable action is rejected with an explainable error", () => {
  const game = createGame();

  assert.throws(
    () => performAction(game, ACTIONS.DEMAND_REFUND),
    /Action is not currently available: demand_refund/,
  );
});
