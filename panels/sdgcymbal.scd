// panels/sdgcymbal.scd - what the cymbal's window shows (SynthVoiceWindow).
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var ratios = #[1, 1.4828, 1.8003, 2.5461, 2.6303, 3.8969];
// one segment of an Env from a to b with curve c, x 0..1
var seg = { |x, a, b, c| x = x.clip(0, 1); if(c.abs < 0.001) { a + ((b - a) * x) } { a + ((b - a) * (1 - exp(c * x)) / (1 - exp(c))) } };
var swell = { |p| p[\sdgbloom].linexp(0, 1, 0.001, 2) };
var wash = { |p| var s = swell.(p), a = 0.0008 + (s * 0.7), d = p[\sdgdecay]; { |t|
	case { t < a } { seg.(t / a, 0, 1, 0) } { t < (a + 0.06) } { seg.((t - a) / 0.06, 1, 0.45, -3) } { seg.((t - a - 0.06) / d, 0.45, 0, -4) } } };
var bell = { |p| var a = 0.001 + (swell.(p) * 0.5); { |t| if(t < a) { t / a } { seg.((t - a) / p[\sdgdecay], 1, 0, -4.5) } } };
var bright = { |p| var s = swell.(p); { |t| if(t < s) { seg.(t / s, 0.12, 1, 3) } { seg.((t - s) / p[\sdgdecay], 1, 0.3, -3) } } };
(
	colour: \gold, drum: true,
	hint: "tune - 40 Hz to 2 kHz: the squares start here, the bell an octave up",
	panes: [
		(type: \partials, w: 1.1, title: "wash and bell", lo: 40,
			list: { |p| var f = p[\sdgfreq], w = (1 - p[\sdgcolor]).sqrt, m = p[\sdgmetal].sqrt;
				ratios.collect { |r| (hz: f * r, level: (w * 0.75).max(0.05)) }
				++ [[0, 1], [2, 3], [4, 5]].collect { |pr| [(ratios[pr[0]] + ratios[pr[1]]), (ratios[pr[1]] - ratios[pr[0]])] }.flatten
					.collect { |r| (hz: f * r, level: (w * m * 0.45).max(0.03), fade: 0.6, width: 1.5) }
				++ [(hz: (f * 2).min(8000), level: p[\sdgcolor].sqrt.max(0.08), colour: \wave, label: "bell")] },
			band: { |p| [p[\sdgtone].linexp(0, 1, 1200, 6000), p[\sdgtone].linexp(0, 1, 5000, 19000), ((1 - p[\sdgmetal]) * (1 - p[\sdgcolor])).sqrt * 0.8, "noise"] },
			readout: { |p| "squares from % · % bell".format(SynthVoicePanes.format(p[\sdgfreq], "Hz"), pct.(p[\sdgcolor])) }),
		(type: \fm, w: 0.9, title: "the bell", span: 12, ratio: { |p| p[\sdgratio] }, index: { |p| p[\sdgindex] }, carrierLabel: "an octave up",
			readout: { |p| "x% · index % · on %".format(p[\sdgratio].round(0.01), p[\sdgindex].round(0.1), hz.((p[\sdgfreq] * 2).min(8000))) }),
		(type: \env, title: "strike, swell and ring", len: { |p| (swell.(p) + 0.07 + p[\sdgdecay]) * 1.02 },
			curves: { |p| [
				(func: { |t| (1 - p[\sdgcolor]).sqrt * wash.(p).(t) }, label: "wash"),
				(func: { |t| p[\sdgcolor].sqrt * bell.(p).(t) }, label: "bell"),
				(func: bright.(p), label: "brightness", colour: \dim)] },
			readout: { |p| if(p[\sdgbloom] < 0.02) { "struck · rings %".format(SynthVoicePanes.format(p[\sdgdecay], "s")) } {
				"swells in % · rings %".format(SynthVoicePanes.format(swell.(p), "s"), SynthVoicePanes.format(p[\sdgdecay], "s")) } })
	],
	macros: [
		(name: "brightness", text: "tone and stick", targets: [[\sdgtone, 0.5], [\sdgclick, 0.4]]),
		(name: "timbre", text: "more metal, a harder bell", targets: [[\sdgmetal, 0.4], [\sdgindex, 0.35]]),
		(name: "time", text: "how long it rings", targets: [[\sdgdecay, 0.45]]),
		(name: "movement", text: "it swells in, wider", targets: [[\sdgbloom, 0.5], [\sdgspread, 0.3]])
	],
	cards: [
		(title: "hit", knobs: [
			(key: \sdgcolor, label: "bell", spec: ControlSpec(0, 1), box: \pct, sub: "crash ↔ bell"),
			(key: \sdgmetal, label: "metal", spec: ControlSpec(0, 1), box: \pct, sub: "noise ↔ squares")]),
		(title: "bell", knobs: [
			(key: \sdgratio, label: "ratio", steps: [0.5, 1, 1.41, 2, 2.2, 2.32, 2.7, 2.76, 3, 3.5, 4, 5, 6, 7, 8], sub: "of the bell"),
			(key: \sdgindex, label: "index", spec: ControlSpec(0, 12, \amp, 0, 3), dec: 1, sub: "how hard")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(40, 2000, \exp, 0, 300, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.1, 8, \exp, 0, 3, "s"), sub: "how long it rings"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgbloom, label: "bloom", spec: ControlSpec(0, 1), box: \pct, floor: "struck", sub: "swells in"),
		(key: \sdgclick, label: "stick", spec: ControlSpec(0, 1), box: \pct, sub: "the tick"),
		(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1), box: \pct, sub: "a china"),
		(key: \sdgspread, label: "spread", spec: ControlSpec(0, 1), box: \pct, sub: "stereo")])
)
)
