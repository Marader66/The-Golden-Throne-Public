// combat_hooks.nut — wires StackLib's Combat-kind reset triggers into BB's
// combat lifecycle.
//
// v0.1.2: switched from hooking entity/tactical/actor (abstract base, doesn't
// have onCombatStarted defined — caused "the index 'onCombatStarted' does not
// exist" crash on BB load) to hooking states/tactical_state.onShow / onHide.
// tactical_state fires those exactly once per combat, so we wipe the entire
// CombatStore at boundaries — same effect, no per-actor invocation needed.

::mods_hookExactClass("states/tactical_state", function (o) {
    local oldOnShow = o.onShow;
    o.onShow = function () {
        // Wipe every actor's Combat stacks at combat-start. New combat starts
        // clean. Persistent stacks (World.Flags-backed) untouched.
        try {
            foreach (key, stacks in ::StackLib.CombatStore) {
                local toWipe = [];
                foreach (id, _ in stacks) {
                    local def = (id in ::StackLib.Defs) ? ::StackLib.Defs[id] : null;
                    if (def == null || def.Kind != ::StackLib.Kind.Combat) continue;
                    if (def.ResetOn != null && def.ResetOn.find("combatStart") != null) {
                        toWipe.push(id);
                    }
                }
                foreach (id in toWipe) delete stacks[id];
            }
        } catch (e) {
            ::logWarning("[StackLib] combatStart wipe threw: " + e);
        }
        oldOnShow();
    };

    local oldOnHide = o.onHide;
    o.onHide = function () {
        oldOnHide();
        // Wipe Combat stacks with combatEnd reset. Most stacks reset on both
        // boundaries so this is the more common cleanup.
        try {
            foreach (key, stacks in ::StackLib.CombatStore) {
                local toWipe = [];
                foreach (id, _ in stacks) {
                    local def = (id in ::StackLib.Defs) ? ::StackLib.Defs[id] : null;
                    if (def == null || def.Kind != ::StackLib.Kind.Combat) continue;
                    if (def.ResetOn != null && def.ResetOn.find("combatEnd") != null) {
                        toWipe.push(id);
                    }
                }
                foreach (id in toWipe) delete stacks[id];
            }
        } catch (e) {
            ::logWarning("[StackLib] combatEnd wipe threw: " + e);
        }
    };
});
