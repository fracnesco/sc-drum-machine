# sc-drum-machine

**Fifteen drum voices - 808 and 909 kick, snare, clap, hat and tom, rim, cowbell, cymbal, an FM drum, a modal drum, pings, chaos, a ratchet roll, plastic hits and a slam - each with ten presets, for SuperDirt and Tidal or played on their own.** A SuperCollider extension.

```supercollider
DrumMachine.add(s);
DMKick.play((n: 1));                     // the 909 kick
DMSnare.gui;                             // its window: display, macros, morph, vary, presets as pads
```

Each voice is a class built on [sc-synth-kit](https://github.com/fracnesco/sc-synth-kit): its SynthDef, its parameters
with their ranges, its presets. In Tidal they keep the names they have in
[SuperDirtGUI](https://github.com/fracnesco/superdirt-gui) - `sdgkick` ... `sdgslam` - and sound exactly as they did there:
every preset was rendered offline from the old files and from the classes, and they are sample-identical. On their own,
a hit is as loud as SuperDirt plays it at gain 1 (`amp` 1), `pan` goes 0 to 1, `note` tunes a voice in semitones from its
own pitch, and a hit lasts as long as the drum rings.

| class | Tidal | what it is |
|---|---|---|
| DMKick | sdgkick | a sine that drops onto its pitch and rings, 808 to 909 |
| DMSnare | sdgsnare | two tuned shells and a burst of noise, 808 to 909 |
| DMClap | sdgclap | noise through a band pass, struck as a few bursts |
| DMHat | sdghat | the 808's six squares or noise, closed to open |
| DMTom | sdgtom | a tuned skin that starts sharp and settles |
| DMRim | sdgrim | rimshot, claves, woodblock |
| DMCowbell | sdgcowbell | the 808's two squares, agogo and bell |
| DMCymbal | sdgcymbal | a wash of six squares under an FM bell |
| DMFMDrum | sdgfmdrum | a whole kit from one FM voice, the Elektron way |
| DMModal | sdgmodal | a struck object: ten resonant modes, skin to plate |
| DMPing | sdgping | pinged resonant filters: blips, droplets, ticks |
| DMChaos | sdgchaos | chaotic noise percussion |
| DMRatchet | sdgratchet | a roll in one event |
| DMPlastic | sdgplastic | bubbles, latex, squeaks |
| DMSlam | sdgslam | a driven dive, a clang and a gated burst |

```supercollider
Pbind(\instrument, DMHat.soloName, \dur, 0.25, \sdgdecay, Pseq([0.05, 0.05, 0.4], inf)).play;
DMKick.params;          // what each knob does, and its range
DMKick.presetNames;
```

## What it needs

[sc-synth-kit](https://github.com/fracnesco/sc-synth-kit) (the quark pulls it in). The windows need
[sc-fx-kit](https://github.com/fracnesco/sc-fx-kit); without it the voices play and there are no windows. The voices use
core SuperCollider UGens only.

## Install

As a quark, hands-off:

```supercollider
Quarks.install("https://github.com/fracnesco/sc-drum-machine.git");
thisProcess.recompile;
```

Or, for a clone you edit, link sc-synth-kit first, then evaluate the first block of this repository's `install.scd`: it
links the folder as `DrumMachine`. Recompile. One or the other, not both: two copies on the class path is a duplicate class
error. `ln -s` is macOS and Linux; on Windows, use the quark.

SuperDirtGUI installs this quark itself and hands the voices to SuperDirt under their Tidal names.

## Check that it took

```supercollider
DrumMachine.voices;     // fifteen classes
```

## Files

| file | what it is |
|---|---|
| `classes/DrumMachine.sc` | the fifteen together: voices, names, add |
| `classes/DM*.sc` | one voice each: its SynthDef function, parameters and presets |
| `panels/*.scd` | what each voice's window shows |
| `install.scd` | link the clone into the extensions folder, check, unlink |
| `HelpSource/Classes/DrumMachine.schelp` | the help file |

## Issues

https://github.com/fracnesco/sc-drum-machine/issues

## License

MIT
