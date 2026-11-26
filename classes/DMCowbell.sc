// DMCowbell - a cowbell: the 808's two square waves a fifth-ish apart through a filter, loud for the first few milliseconds and then a ringing tail.
// A voice of sc-drum-machine (SynthVoice, sc-synth-kit). SuperDirt and Tidal call it sdgcowbell;
// on its own it plays as DMCowbell.play, or Pbind(\instrument, DMCowbell.soloName, ...).
// Converted from SuperDirtGUI's synths/sdgcowbell.scd: the SynthDef function is that file's, word
// for word, its last line handing the signal to output instead of DirtPan.

DMCowbell : SynthVoice {
	*voiceName { ^\sdgcowbell }
	*isDrum { ^true }

	*description {
		^"a cowbell: the 808's two square waves a fifth-ish apart through a filter, loud for the first few milliseconds and then a ringing tail. agogo and bell by preset; ring the two together for clank."
	}

	*params {
		^[
			(name: \sdgdecay, range: "0.05 to 3 s", text: "how long the tail rings"),
			(name: \sdgtone, range: "0 to 1", text: "dark to bright: 0 nearly two sines, 1 the squares' edges"),
			(name: \sdgcolor, range: "0.05 to 1", text: "the upper tone, 1 + color times the lower: 0.48 the 808, 1 an octave"),
			(name: \sdgmetal, range: "0 to 1", text: "the two rung against each other: 0 a clean pair, 1 clank"),
			(name: \sdgclick, range: "0 to 1", text: "how far the first 12 ms stand out over the tail"),
			(name: \sdgtune, range: "-24 to 24 semitones", text: "tunes it like note does, on top of note"),
			(name: \sdglevel, range: "-36 to 6 dB", text: "its level, 0 as measured")
		]
	}

	*presets {
		^[
			(presetName: "808", sdgdecay: 0.6, sdgtone: 0.45, sdgcolor: 0.476, sdgmetal: 0, sdgclick: 0.85),	// 0 808
			(presetName: "808 short", sdgdecay: 0.18, sdgtone: 0.55, sdgcolor: 0.476, sdgmetal: 0, sdgclick: 0.75),	// 1 808 short
			(presetName: "agogo", sdgdecay: 0.35, sdgtone: 0.1, sdgcolor: 1, sdgmetal: 0, sdgclick: 0.5),	// 2 agogo
			(presetName: "bell", sdgdecay: 1.2, sdgtone: 0.15, sdgcolor: 0.76, sdgmetal: 0.35, sdgclick: 0.7),	// 3 bell
			(presetName: "clank", sdgdecay: 0.3, sdgtone: 0.8, sdgcolor: 0.42, sdgmetal: 0.75, sdgclick: 0.85),	// 4 clank
			(presetName: "808 long", sdgdecay: 0.9, sdgtone: 0.3, sdgcolor: 0.476, sdgmetal: 0.05, sdgclick: 0.9),	// 5 808 long
			(presetName: "fifth", sdgdecay: 0.45, sdgtone: 0.3, sdgcolor: 0.5, sdgmetal: 0.1, sdgclick: 0.85),	// 6 fifth
			(presetName: "tin can", sdgdecay: 0.3, sdgtone: 0.9, sdgcolor: 0.3, sdgmetal: 0.9, sdgclick: 1),	// 7 tin can
			(presetName: "gamelan", sdgdecay: 1, sdgtone: 0.05, sdgcolor: 0.18, sdgmetal: 0.5, sdgclick: 0.55),	// 8 gamelan
			(presetName: "two-tone", sdgdecay: 0.3, sdgtone: 0.5, sdgcolor: 0.26, sdgmetal: 0.2, sdgclick: 0.5)	// 9 two-tone
		]
	}

	*graph { |output|

		^{ |out, sustain = 3.2, pan = 0.5, freq = 261.6256, accelerate = 0,
			sdgdecay = 0.6, sdgtone = 0.45, sdgcolor = 0.476, sdgmetal = 0, sdgclick = 0.85,
			sdgtune = 0, sdglevel = 0|
			var tune = freq / 261.6256 * sdgtune.clip(-24, 24).midiratio;	// note 0 is the 808's own pitch
			var decay = sdgdecay.clip(0.05, 3);
			var tone = sdgtone.clip(0, 1);
			var metal = sdgmetal.clip(0, 1);
			var click = sdgclick.clip(0, 1);
			var nyq = SampleRate.ir * 0.45;
			// measured on Dirt-Samples' 808 CB: 558 and 824 Hz, the upper one 12 dB louder
			var f1 = (558 * tune * Line.kr(1, 1 + accelerate, decay)).clip(20, nyq * 0.5);
			var f2 = f1 * (1 + sdgcolor.clip(0.05, 1));
			var a = Pulse.ar(f1, 0.48), b = Pulse.ar(f2, 0.48);
			var lp = (tone.linexp(0, 1, 1000, 9000) * tune.clip(0.25, 4).sqrt).min(nyq);
			// the 808's VCA: an abrupt first drop for the attack, then the tail (service notes, R82/C34)
			var env = EnvGen.ar(Env([0, 1, 1 - (click * 0.9), 0], [0.0005, 0.012, decay], [0, -3, -5]),
				doneAction: 2);
			var sig = ((a * 0.3) + b) * (1 - metal) + (a * b * metal * 2.5);
			sig = LPF.ar(LPF.ar(sig, lp), lp);
			// the ring's difference tone sits under the lower square: keep it out, it turns clank to gong
			sig = HPF.ar(HPF.ar(sig, (f1 * 0.7).max(150)), (f1 * 0.7).max(150));
			sig = LeakDC.ar(sig) * env * 1.6;
			sig = (sig * 0.5).tanh * 2;	// only the extremes reach this
			output.(out, sig * sdglevel.clip(-36, 6).dbamp, pan, nil);
		}
	}
}
