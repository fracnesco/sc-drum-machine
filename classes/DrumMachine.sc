// =====================================================================
// DrumMachine - the fifteen drum voices of sc-drum-machine, together.
// Each is a SynthVoice (sc-synth-kit): a class with its SynthDef, its
// parameters and its presets, playable on its own or, built for SuperDirt,
// from Tidal under its old name (sdgkick ... sdgslam, SuperDirtGUI's synths/).
//
//   DrumMachine.voices;                 // [DMChaos, DMClap, ...]
//   DrumMachine.add(s);                 // every solo def on a server
//   DMKick.play((n: 1));                // one hit, preset 1
//   DMSnare.gui;                        // its window (sc-fx-kit)
//   Pbind(\instrument, DMHat.soloName, \dur, 0.25, \sdgdecay, Pseq([0.05, 0.05, 0.4], inf)).play;
//
// Levels match SuperDirt at gain 1; amp 1 is that level. pan 0 to 1, as Tidal.
// =====================================================================

DrumMachine {
	*voices { ^SynthVoice.all.select { |c| c.name.asString.beginsWith("DM") } }

	*add { |server|
		this.voices.do { |v| v.soloDef.add };
		server !? { server.sync };
	}

	*names { ^this.voices.collect(_.voiceName) }
}
