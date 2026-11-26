// DMCymbal - cymbals, gongs and bells: a wash of six square waves at the 808's out-of-tune ratios, multiplied in pairs and mixed with noise, under an FM bell that gives the ping.
// A voice of sc-drum-machine (SynthVoice, sc-synth-kit). SuperDirt and Tidal call it sdgcymbal;
// on its own it plays as DMCymbal.play, or Pbind(\instrument, DMCymbal.soloName, ...).
// Converted from SuperDirtGUI's synths/sdgcymbal.scd: the SynthDef function is that file's, word
// for word, its last line handing the signal to output instead of DirtPan.

DMCymbal : SynthVoice {
	*voiceName { ^\sdgcymbal }
	*isDrum { ^true }

	*description {
		^"cymbals, gongs and bells: a wash of six square waves at the 808's out-of-tune ratios, multiplied in pairs and mixed with noise, under an FM bell that gives the ping. the wash darkens as it rings, and can swell in."
	}

	*params {
		^[
			(name: \sdgfreq, range: "40 to 2000 Hz", text: "its pitch at note 0: the squares start here, the bell an octave up"),
			(name: \sdgdecay, range: "0.1 to 8 s", text: "how long it rings"),
			(name: \sdgcolor, range: "0 to 1", text: "wash against bell: 0 a crash, 0.4 a ride, 1 a bell"),
			(name: \sdgmetal, range: "0 to 1", text: "0 the wash is noise, 1 pure metal; a second, wilder modulator on the bell"),
			(name: \sdgtone, range: "0 to 1", text: "dark to bright"),
			(name: \sdgbloom, range: "0 to 1", text: "how slowly it swells in: 0 struck, 1 a two-second swell like a gong roll"),
			(name: \sdgratio, range: "0.5 to 8 x", text: "the bell's modulator against its pitch: 1.41 a bell, 2.2 sheet metal"),
			(name: \sdgindex, range: "0 to 12", text: "how hard the bell modulates at its brightest"),
			(name: \sdgclick, range: "0 to 1", text: "the stick's tick at the strike"),
			(name: \sdgdrive, range: "0 to 1", text: "saturation: trashier, a china"),
			(name: \sdgspread, range: "0 to 1", text: "stereo width of the wash"),
			(name: \sdglevel, range: "-36 to 6 dB", text: "its level, 0 as measured")
		]
	}

	*presets {
		^[
			(presetName: "ride"),	// 0 ride: the def's defaults
			(presetName: "crash", sdgfreq: 230, sdgdecay: 2.5, sdgcolor: 0.08, sdgmetal: 0.3, sdgtone: 0.75, sdgclick: 0.5,
				sdgindex: 5, sdgspread: 0.9),	// 1 crash
			(presetName: "china", sdgfreq: 380, sdgdecay: 1.6, sdgcolor: 0.15, sdgmetal: 0.8, sdgtone: 0.4, sdgclick: 0.4,
				sdgdrive: 0.7, sdgratio: 2.7, sdgindex: 6),	// 2 china
			(presetName: "gong", sdgfreq: 45, sdgdecay: 6, sdgcolor: 0.8, sdgmetal: 0.6, sdgtone: 0.2, sdgbloom: 0.35,
				sdgratio: 2.2, sdgindex: 4, sdgclick: 0, sdgspread: 0.8),	// 3 gong
			(presetName: "bell", sdgfreq: 260, sdgdecay: 2.5, sdgcolor: 1, sdgmetal: 0.2, sdgratio: 1.41, sdgindex: 2.5,
				sdgclick: 0.1),	// 4 bell
			(presetName: "splash", sdgfreq: 400, sdgdecay: 0.9, sdgcolor: 0.05, sdgmetal: 0.3, sdgtone: 0.85, sdgclick: 0.6, sdgindex: 5, sdgspread: 0.8),	// 5 splash
			(presetName: "sizzle ride", sdgfreq: 320, sdgdecay: 4, sdgcolor: 0.35, sdgmetal: 0.4, sdgtone: 0.7, sdgclick: 0.3, sdgdrive: 0.2, sdgspread: 0.7),	// 6 sizzle ride
			(presetName: "swell", sdgfreq: 250, sdgdecay: 3, sdgcolor: 0.1, sdgmetal: 0.3, sdgtone: 0.7, sdgbloom: 1, sdgindex: 5, sdgclick: 0, sdgspread: 0.9),	// 7 swell
			(presetName: "dark crash", sdgfreq: 180, sdgdecay: 3, sdgcolor: 0.05, sdgmetal: 0.4, sdgtone: 0.3, sdgclick: 0.4, sdgindex: 4, sdgspread: 0.9),	// 8 dark crash
			(presetName: "singing bowl", sdgfreq: 440, sdgdecay: 8, sdgcolor: 1, sdgmetal: 0.1, sdgratio: 2.76, sdgindex: 1, sdgclick: 0.05, sdgbloom: 0.15)	// 9 singing bowl
		]
	}

	*graph { |output|

		^{ |out, sustain = 10.5, pan = 0.5, freq = 261.6256, accelerate = 0,
			sdgfreq = 300, sdgdecay = 3, sdgcolor = 0.4, sdgmetal = 0.6, sdgtone = 0.6, sdgbloom = 0,
			sdgratio = 1.41, sdgindex = 3, sdgclick = 0.3, sdgdrive = 0, sdgspread = 0.6, sdglevel = 0|
			var tune = freq / 261.6256;	// note 0 is the voice's own pitch
			var decay = sdgdecay.clip(0.1, 8);
			var color = sdgcolor.clip(0, 1);
			var metal = sdgmetal.clip(0, 1);
			var tone = sdgtone.clip(0, 1);
			var spread = sdgspread.clip(0, 1);
			var bloom = sdgbloom.clip(0, 1);
			var swell = bloom.linexp(0, 1, 0.001, 2);	// how long it takes to reach full brightness
			var total = swell + 0.07 + decay + 0.02;
			var f = sdgfreq.clip(40, 2000) * tune * Line.kr(1, 1 + accelerate, decay);
			// six squares at the 808 cymbal's ratios (205.3, 304.4, 369.6, 522.7, 540, 800 Hz)
			var sq = [1, 1.4828, 1.8003, 2.5461, 2.6303, 3.8969].collect { |r| Pulse.ar((f * r).min(16000)) };
			// multiplied in pairs: sums and differences, denser than the squares; the other side pairs them otherwise
			var rmL = ((sq[0] * sq[1]) + (sq[2] * sq[3]) + (sq[4] * sq[5])) * 0.6;
			var rmR = ((sq[0] * sq[3]) + (sq[1] * sq[4]) + (sq[2] * sq[5])) * 0.6;
			var nA = WhiteNoise.ar, nB = WhiteNoise.ar;
			var noise = [nA, (nA * (1 - spread)) + (nB * spread)] * (0.5 + (rmL * 0.5));	// noise with a metal grain
			var rm = [rmL, (rmL * (1 - spread)) + (rmR * spread)];
			var wash = (noise * (1 - metal).sqrt) + (rm * metal.sqrt);
			// the wash is brightest just after the strike and darkens as it rings (or swells first, with sdgbloom)
			var cut = EnvGen.ar(Env([0.12, 1, 0.3], [swell, decay], [3, -3])) * tone.linexp(0, 1, 5000, 19000);
			var wenv = EnvGen.ar(Env([0, 1, 0.45, 0], [0.0008 + (swell * 0.7), 0.06, decay], [0, -3, -4]));
			// the bell: FM with its brightness decaying faster than the note, like a struck bell (Chowning)
			var fp = (f * 2).min(8000);
			var ienv = EnvGen.ar(Env([0, 1, 0.12], [0.0005 + swell, decay * 0.6], [2, -4]));
			var mod = (SinOsc.ar(fp * sdgratio.clip(0.5, 8)) + (SinOsc.ar(fp * sdgratio.clip(0.5, 8) * 2.32) * metal * 0.7))
				* sdgindex.clip(0, 12) * ienv;
			var bell = SinOsc.ar(fp, mod) * EnvGen.ar(Env([0, 1, 0], [0.001 + (swell * 0.5), decay], [0, -4.5]));
			var click = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.ar(Env([0, 1, 0], [0.0003, 0.006], [0, -4]));
			var sig, g;
			wash = HPF.ar(HPF.ar(wash, tone.linexp(0, 1, 1200, 6000)), 900);
			wash = LPF.ar(wash, cut.clip(300, 19000)) * wenv;
			bell = HPF.ar(bell, fp * 0.7);	// the sidebands folded below the bell's pitch only muddy it
			sig = (wash * (1 - color).sqrt * 1.3) + (bell * color.sqrt * 0.2) + (click * sdgclick.clip(0, 1) * 0.6);
			// drive squashes the strike and leaves the quiet tail at its level (+3.5 dB at 1), so a long
			// cymbal grows trashier, not much louder
			g = 1 + (sdgdrive.clip(0, 1) * 10);
			sig = (sig * g).tanh / g * (1 + (sdgdrive.clip(0, 1) * 0.5));
			sig = HPF.ar(sig, (fp * 0.35).max(30));
			sig = (sig * (1 / 1.4)).tanh * 1.4;	// a soft ceiling: no setting goes over -8 dBFS at gain 1
			sig = sig * EnvGen.ar(Env([1, 1, 0], [total - 0.01, 0.01]), doneAction: 2);
			output.(out, sig * sdglevel.clip(-36, 6).dbamp, pan, nil);
		}
	}
}
