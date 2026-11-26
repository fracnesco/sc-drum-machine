// DMPlastic - hyper-real material percussion: bubbles, latex, squeaks, plastic knocks and drips.
// A voice of sc-drum-machine (SynthVoice, sc-synth-kit). SuperDirt and Tidal call it sdgplastic;
// on its own it plays as DMPlastic.play, or Pbind(\instrument, DMPlastic.soloName, ...).
// Converted from SuperDirtGUI's synths/sdgplastic.scd: the SynthDef function is that file's, word
// for word, its last line handing the signal to output instead of DirtPan.

DMPlastic : SynthVoice {
	*voiceName { ^\sdgplastic }
	*isDrum { ^true }

	*description {
		^"hyper-real material percussion: bubbles, latex, squeaks, plastic knocks and drips. a sine whose pitch moves a long way very fast, bent by fm and folding, through a resonant filter that follows it, and squashed at the end."
	}

	*params {
		^[
			(name: \sdgfreq, range: "30 to 9000 Hz", text: "the pitch, before note"),
			(name: \sdgdecay, range: "0.005 to 2 s", text: "how long it rings"),
			(name: \sdgatk, range: "0.0005 to 0.5 s", text: "how it starts: a rub swells, a snap does not"),
			(name: \sdgpunch, range: "0 to 48 semitones", text: "how far above its pitch it starts: a snap"),
			(name: \sdgbend, range: "0.001 to 1 s", text: "how long that fall takes"),
			(name: \sdgrise, range: "0 to 36 semitones", text: "how far it rises as it dies: a bubble"),
			(name: \sdgwobble, range: "0 to 1", text: "a wobble in pitch that dies away, rubber"),
			(name: \sdgslip, range: "0 to 1", text: "catches and slips, the stick-slip of a squeak"),
			(name: \sdgcolor, range: "0 to 1", text: "how fast the wobble and the slips go, 6 to 160 Hz"),
			(name: \sdgratio, range: "0.25 to 8 x", text: "fm: the modulator against the pitch"),
			(name: \sdgindex, range: "0 to 10", text: "fm: how much, falling over the hit"),
			(name: \sdgwavefold, range: "0 to 1", text: "folding: shine"),
			(name: \sdgq, range: "0 to 1", text: "resonance of the filter; high, it pings"),
			(name: \sdgtone, range: "0 to 1", text: "the filter, from the pitch to 16 times it"),
			(name: \sdgclick, range: "0 to 1", text: "a knock: the strike's own hollow modes"),
			(name: \sdgdrive, range: "0 to 1", text: "how hard it is squashed at the end"),
			(name: \sdglevel, range: "-36 to 6 dB", text: "its level, 0 as measured")
		]
	}

	*presets {
		^[
			(presetName: "bubble", sdgfreq: 600, sdgdecay: 0.07, sdgrise: 14),                                        // 0 bubble
			(presetName: "latex snap", sdgfreq: 220, sdgdecay: 0.22, sdgpunch: 24, sdgbend: 0.035, sdgrise: 0,
				sdgwobble: 0.5, sdgcolor: 0.45, sdgratio: 2, sdgindex: 1.5, sdgwavefold: 0.4,
				sdgq: 0.6, sdgtone: 0.4, sdgclick: 0.4, sdgdrive: 0.5),                         // 1 latex snap
			(presetName: "squeak", sdgfreq: 2200, sdgdecay: 0.16, sdgatk: 0.03, sdgrise: 3, sdgslip: 0.8,
				sdgcolor: 0.6, sdgq: 0.5, sdgtone: 0.1, sdgdrive: 0.3),                          // 2 squeak
			(presetName: "plastic clank", sdgfreq: 380, sdgdecay: 0.05, sdgpunch: 12, sdgbend: 0.008, sdgrise: 0,
				sdgratio: 1.73, sdgindex: 3, sdgwavefold: 0.2, sdgq: 0.85, sdgtone: 0.3,
				sdgclick: 1, sdgdrive: 0.6),                                                    // 3 plastic clank
			(presetName: "drip", sdgfreq: 1000, sdgdecay: 0.03, sdgrise: 24, sdgq: 0.3, sdgclick: 0.1),             // 4 drip
			(presetName: "rubber", sdgfreq: 140, sdgdecay: 0.45, sdgatk: 0.01, sdgrise: 7, sdgwobble: 0.8,
				sdgslip: 0.5, sdgcolor: 0.3, sdgwavefold: 0.5, sdgq: 0.4, sdgtone: 0.5,
				sdgdrive: 0.5),                                                                  // 5 rubber
			(presetName: "cork pop", sdgfreq: 400, sdgdecay: 0.04, sdgpunch: 36, sdgbend: 0.01, sdgrise: 0, sdgq: 0.7, sdgtone: 0.6, sdgclick: 0.8, sdgdrive: 0.4),	// 6 cork pop
			(presetName: "balloon rub", sdgfreq: 300, sdgdecay: 0.6, sdgatk: 0.08, sdgrise: 2, sdgslip: 1, sdgcolor: 0.25, sdgq: 0.3, sdgtone: 0.3, sdgdrive: 0.4),	// 7 balloon rub
			(presetName: "boing", sdgfreq: 180, sdgdecay: 0.8, sdgrise: 12, sdgwobble: 1, sdgcolor: 0.15, sdgq: 0.5, sdgtone: 0.4),	// 8 boing
			(presetName: "bottle tap", sdgfreq: 1500, sdgdecay: 0.12, sdgrise: 0, sdgratio: 2.76, sdgindex: 2, sdgwavefold: 0.3, sdgq: 0.85, sdgtone: 0.6, sdgclick: 0.3)	// 9 bottle tap
		]
	}

	*graph { |output|

		^{ |out, sustain = 2.6, pan = 0.5, freq = 261.6256, accelerate = 0,
			sdgfreq = 600, sdgdecay = 0.07, sdgatk = 0.0005, sdgpunch = 0, sdgbend = 0.02,
			sdgrise = 14, sdgwobble = 0, sdgslip = 0, sdgcolor = 0.5, sdgratio = 1.5,
			sdgindex = 0, sdgwavefold = 0, sdgq = 0.2, sdgtone = 0.5, sdgclick = 0, sdgdrive = 0.2, sdglevel = 0|
			var tune = freq / 261.6256;	// note 0 is the voice's own pitch
			var decay = sdgdecay.clip(0.005, 2), atk = sdgatk.clip(0.0005, 0.5);
			var env = EnvGen.ar(Env.perc(atk, decay, 1, -5), doneAction: 2);
			var rate = sdgcolor.clip(0, 1).linexp(0, 1, 6, 160);
			var slip = sdgslip.clip(0, 1);
			var base = sdgfreq.clip(30, 9000) * tune;
			var wob = SinOsc.ar(rate * LFNoise1.kr(7).range(0.9, 1.1))
				* sdgwobble.clip(0, 1) * EnvGen.ar(Env.perc(0.002, atk + (decay * 0.8), 1, -3));
			// stick-slip: the surface catches and lets go at an uneven rate
			var slips = Lag.ar(LFPulse.ar(rate * LFNoise1.kr(30).range(0.8, 1.25), 0, 0.3), 0.0005);
			var pitch = base * Line.kr(1, 1 + accelerate, atk + decay)
				* EnvGen.ar(Env([sdgpunch.clip(0, 48).midiratio, 1], [sdgbend.clip(0.001, 1)], -6))
				* EnvGen.ar(Env([1, 1, sdgrise.clip(0, 36).midiratio], [atk, decay], 3))	// rises as it dies
				* (2 ** (wob * 0.5))	// up to half an octave either way
				* (1 + (slips * slip * 0.06));
			var ienv = EnvGen.ar(Env.perc(0.0005, (decay * 0.6).max(0.004), 1, -5));
			var drive = sdgdrive.clip(0, 1).linexp(0, 1, 1.2, 16);
			var q = sdgq.clip(0, 1), sig, knock;
			pitch = pitch.clip(20, 16000);
			sig = SinOsc.ar(pitch, SinOsc.ar((pitch * sdgratio.clip(0.25, 8)).min(20000)) * sdgindex.clip(0, 10) * ienv);
			sig = sig * (1 - (slip * (1 - slips) * 0.85));
			sig = (sig * (1 + (sdgwavefold.clip(0, 1) * 5))).fold2(1) * (1 + (sdgwavefold.clip(0, 1) * 0.8));	// folding moves energy up, where the filter takes some
			// the knock: a click on three hollow, quickly damped modes, then the filter pings on it too
			knock = Ringz.ar(Impulse.ar(0), (base * [1.0, 2.31, 3.93]).clip(20, 16000), [0.03, 0.018, 0.01]).sum * 0.35;
			sig = sig + (knock * sdgclick.clip(0, 1));
			sig = MoogFF.ar(sig, (pitch * (2 ** (sdgtone.clip(0, 1) * 4))).clip(30, 18000), q * 3.5) * (1 + (q * 1.5));
			sig = HPF.ar(sig, (base * 0.5).clip(25, 2000));	// the knock's thump and any dc go
			sig = (sig * drive).tanh / drive.tanh;
			// a short hit is played hotter, so that the knob changes length more than loudness
			sig = sig * 0.45 * (0.15 / (atk + decay)).clip(1, 6).sqrt;
			output.(out, sig * sdglevel.clip(-36, 6).dbamp, pan, env);
		}
	}
}
