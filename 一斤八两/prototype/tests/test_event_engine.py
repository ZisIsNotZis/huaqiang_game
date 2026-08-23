import unittest

from yijinbaliang.event_engine import Action, play_scenario


class EventEngineTests(unittest.TestCase):
    def test_public_evidence_can_end_the_event_without_a_fight(self):
        result = play_scenario(
            [
                Action.INSPECT_SCALE,
                Action.INVITE_WITNESS,
                Action.ASK_FOR_WEIGHT,
                Action.EXPOSE_MAGNET,
                Action.DEMAND_REFUND,
            ]
        )

        self.assertEqual("concession", result.outcome)
        self.assertFalse(result.violence_started)
        self.assertEqual(frozenset({"scale_magnet", "false_weight"}), result.proven_facts)
        self.assertEqual(
            frozenset({"scale_magnet", "false_weight"}),
            result.witness_knowledge,
        )
        self.assertEqual(
            "摊主在邻铺见证下被揭穿使用磁铁增重，退钱并收摊。",
            result.street_story,
        )
        self.assertEqual(
            "交易纠纷中发现作弊秤具，双方未发生肢体冲突。",
            result.police_story,
        )

    def test_exposing_the_scale_without_a_witness_triggers_intimidation(self):
        result = play_scenario(
            [
                Action.INSPECT_SCALE,
                Action.ASK_FOR_WEIGHT,
                Action.EXPOSE_MAGNET,
                Action.DEMAND_REFUND,
            ]
        )

        self.assertEqual("intimidated_exit", result.outcome)
        self.assertFalse(result.violence_started)
        self.assertEqual("有人指着秤说有问题，随后被摊主一伙赶走。", result.street_story)

    def test_blocking_the_helper_makes_a_defensive_escape_possible(self):
        result = play_scenario(
            [
                Action.PARK_FOR_EXIT,
                Action.BLOCK_HELPER_PATH,
                Action.CONFRONT_WITHOUT_PROOF,
                Action.PUSH_AND_ESCAPE,
            ]
        )

        self.assertEqual("controlled_escape", result.outcome)
        self.assertTrue(result.violence_started)
        self.assertEqual("摊主先围人，双方推搡后顾客骑车离开。", result.street_story)
        self.assertEqual("买卖纠纷引发推搡，无人报告持械。", result.police_story)

    def test_attacking_first_loses_both_public_narratives(self):
        result = play_scenario(
            [
                Action.BRING_KNIFE,
                Action.ATTACK_FIRST,
            ]
        )

        self.assertEqual("violent_dominance", result.outcome)
        self.assertTrue(result.violence_started)
        self.assertEqual("外来人带刀砸摊，摊主成了受害者。", result.street_story)
        self.assertEqual("嫌疑人预先携带刀具并首先攻击。", result.police_story)


if __name__ == "__main__":
    unittest.main()
