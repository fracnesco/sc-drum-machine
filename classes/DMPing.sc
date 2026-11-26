// DMPing - pinged resonant filters: one click rings three tuned resonators at once, and their pitch sweeps as they ring.
// A voice of sc-drum-machine (SynthVoice, sc-synth-kit). SuperDirt and Tidal call it sdgping;
// on its own it plays as DMPing.play, or Pbind(\instrument, DMPing.soloName, ...).
// Converted from SuperDirtGUI's synths/sdgping.scd: the SynthDef function is that file's, word
// for word, its last line handing the signal to output instead of DirtPan.

DMPing : SynthVoice {
	*voiceName { ^\sdgping }
	*isDrum { ^true }

	*description {
		^"pinged resonant filters: one click rings three tuned resonators at once, and their pitch sweeps as they ring. blips, droplets, metallic ticks, wood and rubber."
	}

	*params {
		^[
			(name: \sdgfreq, range: "40 to 12000 Hz", text: "the main resonator's pitch at note 0"),
			(name: \sdgdecay, range: "0.005 to 2 s", text: "how long it rings"),
			(name: \sdgpunch, range: "-24 to 48 semitones", text: "where the pitch starts: above it falls, below it rises (a droplet)"),
			(name: \sdgbend, range: "0.001 to 1 s", text: "how long the pitch takes to arrive"),
			(name: \sdgmetal, range: "0 to 1", text: "the other two resonators: 0 harmonic (2, 3), 1 a struck bar (2.76, 5.4)"),
			(name: \sdgtone, range: "0 to 1", text: "0 a soft mallet and a dark ring, 1 a hard click and bright partials"),
			(name: \sdgindex, range: "0 to 8", text: "FM on the main resonator: 0 a pure ping, up to a clangy blip"),
			(name: \sdgratio, range: "0.25 to 8", text: "the FM's modulator, as a ratio of the pitch"),
			(name: \sdgcolor, range: "0 to 1", text: "rattle: the resonators are hit again and again while they ring"),
			(name: \sdgclick, range: "0 to 1", text: "a short noisy tick on top"),
			(name: \sdgfmtime, range: "0.05 to 2", text: "how long the FM's brightness lasts, as a share of the decay"),
			(name: \sdglevel, range: "-36 to 6 dB", text: "its level, 0 as measured")
		]
	}

	*presets {
		^[
			(presetName: "blip", sdgfreq: 1200, sdgdecay: 0.09, sdgpunch: 12, sdgbend: 0.025, sdgmetal: 0.15, sdgtone: 0.8),	// 0 blip
			(presetName: "droplet", sdgfreq: 700, sdgdecay: 0.07, sdgpunch: -14, sdgbend: 0.06, sdgmetal: 0, sdgtone: 0.3),	// 1 droplet
			(presetName: "metal tick", sdgfreq: 3400, sdgdecay: 0.05, sdgpunch: 3, sdgbend: 0.004, sdgmetal: 1, sdgtone: 1, sdgclick: 0.4),	// 2 metal tick
			(presetName: "wood", sdgfreq: 820, sdgdecay: 0.08, sdgpunch: 2, sdgbend: 0.005, sdgmetal: 0.7, sdgtone: 0.5),	// 3 wood
			(presetName: "zap", sdgfreq: 1800, sdgdecay: 0.22, sdgpunch: 30, sdgbend: 0.09, sdgmetal: 0.4, sdgtone: 0.9, sdgindex: 2.5, sdgratio: 1.41),	// 4 zap
			(presetName: "rubber", sdgfreq: 260, sdgdecay: 0.18, sdgpunch: 5, sdgbend: 0.02, sdgmetal: 0.3, sdgtone: 0.5, sdgcolor: 0.6),	// 5 rubber
			(presetName: "sonar", sdgfreq: 1500, sdgdecay: 1.2, sdgpunch: 0, sdgmetal: 0, sdgtone: 0.3, sdgindex: 0),	// 6 sonar
			(presetName: "laser", sdgfreq: 900, sdgdecay: 0.3, sdgpunch: 48, sdgbend: 0.2, sdgmetal: 0.2, sdgtone: 1, sdgindex: 4, sdgratio: 2),	// 7 laser
			(presetName: "bar", sdgfreq: 523.25, sdgdecay: 0.3, sdgpunch: 0, sdgmetal: 1, sdgtone: 0.35),	// 8 bar
			(presetName: "glitch rattle", sdgfreq: 2500, sdgdecay: 0.12, sdgpunch: 7, sdgbend: 0.01, sdgmetal: 0.6, sdgtone: 0.65, sdgcolor: 0.4, sdgclick: 0.5)	// 9 glitch rattle
		]
	}

	*graph { |output|

		^{ |out, sustain = 3, pan = 0.5, freq = 261.6256, accelerate = 0,
			sdgfreq = 1200, sdgdecay = 0.09, sdgpunch = 12, sdgbend = 0.025, sdgmetal = 0.15,
			sdgtone = 0.8, sdgindex = 0, sdgratio = 1.41, sdgcolor = 0, sdgclick = 0,
			sdgfmtime = 0.5, sdglevel = 0|
			var tune = freq / 261.6256;	// note 0 is the voice's own pitch
			var dec = sdgdecay.clip(0.005, 2);
			var tone = sdgtone.clip(0, 1);
			var metal = sdgmetal.clip(0, 1);
			var index = sdgindex.clip(0, 8);
			var rattle = sdgcolor.clip(0, 1);
			var nyq = SampleRate.ir * 0.45;
			var env = EnvGen.ar(Env([1, 1, 0], [dec * 1.3 + 0.01, 0.005]), doneAction: 2);
			var sweep = EnvGen.ar(Env([sdgpunch.clip(-24, 48).midiratio, 1], [sdgbend.clip(0.001, 1)], \exp));
			// clipped after the sweep: past Nyquist the FM sine would fold back down, to DC at worst
			var pitch = (sdgfreq.clip(40, 12000) * tune * sweep * Line.kr(1, 1 + accelerate, dec)).clip(20, nyq);
			// a struck free bar's modes against plain harmonics, met halfway geometrically
			var ratios = [1, 2 * (1.38 ** metal), 3 * (1.8 ** metal)];
			var amps = [1, 0.25 + (tone * 0.45), 0.08 + (tone * 0.35)];
			var decays = dec * [1, 0.55, 0.3];
			// a one-sample click rings every partial; a smooth pulse as long as 0.7 periods is a soft
			// mallet that rings the main one as hard and the upper ones much less. both have unit area
			var width = (0.7 / (sdgfreq.clip(40, 12000) * tune * sdgpunch.clip(0, 48).midiratio)).clip(SampleDur.ir * 4, 0.02);
			var mallet = EnvGen.ar(Env.sine(width)) * (2 / (width * SampleRate.ir));
			var exc = (Impulse.ar(0) * tone) + (mallet * (1 - tone))
				+ (Dust.ar(30 + (rattle * 250)) * EnvGen.ar(Env.perc(0.002, dec * 0.6)) * rattle * 0.35);
			var rings = ratios.collect { |r, i|
				Ringz.ar(exc, (pitch * r).clip(20, nyq), decays[i]) * amps[i]
			};
			// FM on the main resonator: a decaying FM sine standing in for it (Ringz only retunes once a block)
			var fmEnv = EnvGen.ar(Env([1, 0.001], [dec], \exp));
			var fm = SinOsc.ar(pitch, (SinOsc.ar((pitch * sdgratio.clip(0.25, 8)).min(nyq)) * index
				* EnvGen.ar(Env([1, 0.05], [dec * sdgfmtime.clip(0.05, 2)], \exp))) + 0.5pi) * fmEnv * 2;
			// a whole-number ratio puts a sideband on 0 Hz (DC 0.018 at sdgratio 1). it lasts as long as the
			// ring, too short for LeakDC, which only smears it: a high pass under the pitch takes it
			var main = XFade2.ar(rings[0], HPF.ar(fm, (pitch * 0.3).max(20)), (index.min(1) * 2 - 1));
			// a click starts every partial at its peak at once, a mallet does not
			var sig = (main + rings[1] + rings[2]) * 0.8 / (1 + (tone * (amps[1] + amps[2])));
			sig = sig + (HPF.ar(WhiteNoise.ar, 2500) * EnvGen.ar(Env.perc(0.0002, 0.003)) * sdgclick.clip(0, 1) * 0.6);
			sig = sig.tanh;	// a noise burst or a rattle can ring a Ringz past 2
			output.(out, sig * sdglevel.clip(-36, 6).dbamp, pan, env);
		}
	}
}
