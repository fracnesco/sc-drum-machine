// DMFMDrum - a whole drum kit from one FM voice, the Elektron way (Machinedrum EFM, Digitone FM drum, Model:Cycles): a sine carrier with a pitch sweep, a modulator with feedback and its own envelope, a noise part that can clap, and a click.
// A voice of sc-drum-machine (SynthVoice, sc-synth-kit). SuperDirt and Tidal call it sdgfmdrum;
// on its own it plays as DMFMDrum.play, or Pbind(\instrument, DMFMDrum.soloName, ...).
// Converted from SuperDirtGUI's synths/sdgfmdrum.scd: the SynthDef function is that file's, word
// for word, its last line handing the signal to output instead of DirtPan.

DMFMDrum : SynthVoice {
	*voiceName { ^\sdgfmdrum }
	*isDrum { ^true }

	*description {
		^"a whole drum kit from one FM voice, the Elektron way (Machinedrum EFM, Digitone FM drum, Model:Cycles): a sine carrier with a pitch sweep, a modulator with feedback and its own envelope, a noise part that can clap, and a click. every knob does something big, so changing one per step turns a kick into a tom into a clank."
	}

	*params {
		^[
			(name: \sdgfreq, range: "20 to 5000 Hz", text: "its pitch at note 0"),
			(name: \sdgdecay, range: "0.02 to 3 s", text: "how long the body rings"),
			(name: \sdgpunch, range: "0 to 48 semitones", text: "how far above its pitch the hit starts"),
			(name: \sdgbend, range: "0.001 to 1 s", text: "how long that drop takes"),
			(name: \sdgratio, range: "0.125 to 16 x", text: "the modulator against the carrier: 1 round, 1.41 or 2.76 a knock"),
			(name: \sdgindex, range: "0 to 25", text: "how hard it modulates at the strike: 1 warm, 4 knock, 10 and up a crash"),
			(name: \sdgcolor, range: "0 to 1", text: "how long the modulation lasts: 0 only the strike, past 0.5 it colours the tail"),
			(name: \sdgfb, range: "0 to 1", text: "modulator feedback: brighter up to 0.3, wild, then noise from about 0.9"),
			(name: \sdgmetal, range: "0 to 1", text: "a second modulator off the harmonic grid, metal and bells"),
			(name: \sdgsnap, range: "0 to 1", text: "noise against the body, 0 all body, 1 all noise"),
			(name: \sdgnoise, range: "0.01 to 2 s", text: "how long the noise rings"),
			(name: \sdgtone, range: "0 to 1", text: "the noise's colour, dark to bright"),
			(name: \sdgcount, range: "1 to 8", text: "the noise comes as this many bursts, 11 ms apart: a clap"),
			(name: \sdgclick, range: "0 to 1", text: "the click at the strike"),
			(name: \sdgdrive, range: "0 to 1", text: "saturation"),
			(name: \sdglevel, range: "-36 to 6 dB", text: "its level, 0 as measured")
		]
	}

	*presets {
		^[
			(presetName: "FM kick"),	// 0 FM kick: the def's defaults
			(presetName: "FM snare", sdgfreq: 185, sdgdecay: 0.2, sdgpunch: 8, sdgbend: 0.03, sdgratio: 1.41, sdgindex: 3,
				sdgcolor: 0.25, sdgfb: 0.35, sdgsnap: 0.55, sdgnoise: 0.2, sdgtone: 0.6, sdgclick: 0.2),	// 1 FM snare
			(presetName: "FM tom", sdgfreq: 105, sdgdecay: 0.5, sdgpunch: 10, sdgbend: 0.07, sdgratio: 1.4, sdgindex: 2.5,
				sdgcolor: 0.15, sdgfb: 0, sdgsnap: 0.05, sdgnoise: 0.08, sdgtone: 0.4, sdgclick: 0.15),	// 2 FM tom
			(presetName: "FM clap", sdgfreq: 1100, sdgdecay: 0.05, sdgpunch: 0, sdgratio: 2.37, sdgindex: 6, sdgcolor: 0.5,
				sdgfb: 0.85, sdgsnap: 0.85, sdgcount: 4, sdgnoise: 0.22, sdgtone: 0.42, sdgclick: 0),	// 3 FM clap
			(presetName: "FM metal", sdgfreq: 540, sdgdecay: 0.4, sdgpunch: 0, sdgratio: 1.48, sdgindex: 4, sdgcolor: 0.8,
				sdgfb: 0.45, sdgmetal: 0.7, sdgsnap: 0.1, sdgnoise: 0.05, sdgtone: 0.85, sdgclick: 0.1),	// 4 FM metal
			(presetName: "perc", sdgfreq: 300, sdgdecay: 0.3, sdgpunch: 4, sdgbend: 0.01, sdgratio: 2.76, sdgindex: 1.5,
				sdgcolor: 0.75, sdgfb: 0, sdgclick: 0.1),	// 5 perc
			(presetName: "FM hat", sdgfreq: 3200, sdgdecay: 0.04, sdgpunch: 0, sdgratio: 2.37, sdgindex: 8, sdgcolor: 0.5, sdgfb: 0.9, sdgmetal: 0.8, sdgsnap: 0.6, sdgnoise: 0.04, sdgtone: 0.9, sdgclick: 0.2),	// 6 FM hat
			(presetName: "FM zap", sdgfreq: 60, sdgdecay: 0.25, sdgpunch: 48, sdgbend: 0.15, sdgratio: 0.5, sdgindex: 3, sdgcolor: 0.6, sdgfb: 0.3, sdgclick: 0),	// 7 FM zap
			(presetName: "FM rim", sdgfreq: 800, sdgdecay: 0.12, sdgpunch: 0, sdgratio: 3.5, sdgindex: 6, sdgcolor: 0.3, sdgfb: 0.2, sdgsnap: 0.1, sdgnoise: 0.02, sdgtone: 0.8, sdgclick: 1),	// 8 FM rim
			(presetName: "FM hard kick", sdgfreq: 55, sdgdecay: 0.3, sdgpunch: 36, sdgbend: 0.05, sdgratio: 1, sdgindex: 3, sdgcolor: 0.05, sdgfb: 0.4, sdgclick: 0.6, sdgdrive: 0.2)	// 9 FM hard kick
		]
	}

	*graph { |output|

		^{ |out, sustain = 3.1, pan = 0.5, freq = 261.6256, accelerate = 0,
			sdgfreq = 48, sdgdecay = 0.5, sdgpunch = 30, sdgbend = 0.035,
			sdgratio = 1, sdgindex = 2.5, sdgcolor = 0.12, sdgfb = 0.15, sdgmetal = 0,
			sdgsnap = 0, sdgnoise = 0.15, sdgtone = 0.5, sdgcount = 1, sdgclick = 0.25, sdgdrive = 0, sdglevel = 0|
			var tune = freq / 261.6256;	// note 0 is the voice's own pitch
			var decay = sdgdecay.clip(0.02, 3);
			var snap = sdgsnap.clip(0, 1);
			var ntail = sdgnoise.clip(0.01, 2);
			var count = sdgcount.clip(1, 8).round;
			var nstart = (count - 1) * 0.011;	// the tail starts with the last burst
			var drive = sdgdrive.clip(0, 1);
			var sweep = EnvGen.ar(Env([sdgpunch.clip(0, 48).midiratio, 1], [sdgbend.clip(0.001, 1)], -6));
			var fc = (sdgfreq.clip(20, 5000) * tune * Line.kr(1, 1 + accelerate, decay) * sweep).clip(10, 18000);
			// CONTOUR: the index envelope is a share of the body's decay, from 4 % to longer than the body;
			// past 0.5 it also stops above 0 (the Digitone's END level), so the tail keeps its colour
			var color = sdgcolor.clip(0, 1);
			var ienv = EnvGen.ar(Env([1, (color - 0.5).max(0) * 1.2], [decay * color.linexp(0, 1, 0.04, 1.2)], -4));
			var ratio = sdgratio.clip(0.125, 16);
			// feedback squared up to 18 rad: clean brightening below 2, chaos then noise from ~15
			var mod = SinOscFB.ar(fc * ratio, sdgfb.clip(0, 1).squared * 18)
				+ (SinOsc.ar(fc * ratio * 2.7183) * sdgmetal.clip(0, 1));
			// phase 0.5pi: every hit starts on the peak, the Elektron phase reset that makes a kick hit
			var body = SinOsc.ar(fc, 0.5pi + (mod * sdgindex.clip(0, 25) * ienv));
			var benv = EnvGen.ar(Env([0, 1, 0], [0.0005, decay], [0, -4.5]));
			var bursts = (0..6).collect { |k|
				(k < (count - 1)) * EnvGen.ar(Env([0, 0, 1, 0], [k * 0.011 + 0.0001, 0.0005, 0.009], [0, 0, -4]))
			}.sum;
			var nenv = bursts + EnvGen.ar(Env([0, 0, 1, 0], [nstart + 0.0001, 0.0008, ntail], [0, 0, -5]));
			var tone = sdgtone.clip(0, 1);
			// a third of the noise is ring-modulated by the body (the Digitone's NRM): it follows the pitch
			var noise = WhiteNoise.ar * (0.7 + (0.3 * body));
			// the click's own envelope ends on an exact 0: a decaying filter alone trails off into denormals
			var click = HPF.ar(Decay2.ar(Impulse.ar(0), 0.0001, 0.0015), 1500) * EnvGen.ar(Env([1, 1, 0], [0.008, 0.004]));
			var total = max(decay, nstart + ntail) + 0.02;
			// higher pitches sound louder: the body comes down as its pitch goes up, so a kick, a tom and a
			// bell on one voice stay in balance when sdgfreq or note moves (about -3.3 dB per octave above 50 Hz)
			var level = ((sdgfreq.clip(20, 5000) * tune) / 50).max(1) ** -0.55;
			var sig, g;
			noise = LPF.ar(HPF.ar(noise, tone.linexp(0, 1, 200, 5000)), tone.linexp(0, 1, 2500, 16000));
			sig = (body * benv * level * (1 - snap).sqrt) + (noise * nenv * snap.sqrt * 1.8)
				+ (click * sdgclick.clip(0, 1) * 1.5);
			g = 1 + (drive * 8);
			// drive raises the peak-normalised level by up to 6 dB, Cycles' VOLUME+DIST above 60
			sig = sig + ((((sig * g).tanh / g.tanh * (1 - (drive * 0.5))) - sig) * (drive * 4).min(1));
			sig = LeakDC.ar(sig, 0.999);	// a sideband at 0 Hz: integer ratios put one on DC
			sig = (sig * (1 / 1.4)).tanh * 1.4;	// a soft ceiling: no setting goes over -8 dBFS at gain 1
			sig = sig * EnvGen.ar(Env([1, 1, 0], [total - 0.01, 0.01]), doneAction: 2);
			output.(out, sig * sdglevel.clip(-36, 6).dbamp, pan, nil);
		}
	}
}
