// panels/sdgsnare.scd - what the snare's window shows (SynthVoiceWindow).
(
var fall = { |decay| { |t| exp(t.neg * 6.9 / decay.max(0.001)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var upper = { |p| p[\sdgfreq] * p[\sdgcolor].linlin(0, 1, 1.97, 1.47) };
var hold = { |p| (p[\sdgcolor] * 0.035) + 0.002 };
var ramp = { |t| var x = (t / 0.05).clip(0, 1); 1 - ((1 - exp(-7 * x)) / (1 - exp(-7))) };
(
	colour: \gold, drum: true,
	hint: "tune - the low shell, 80 to 500 Hz; the noise length follows the decay",
	links: (sdgdecay: [\sdgnoise]),
	panes: [
		(type: \partials, w: 1.1, title: "two shells and the snares", lo: 60,
			list: { |p| [(hz: p[\sdgfreq], level: (1 - p[\sdgsnap]).sqrt.max(0.1), colour: \wave, label: "low shell"),
				(hz: upper.(p), level: ((1 - p[\sdgsnap]).sqrt * p[\sdgtone].linlin(0, 1, 0.08, 0.6) * 1.5).max(0.06), label: "upper shell")] },
			band: { |p| var t = p[\sdgtone], c = p[\sdgcolor];
				[((1400 - (c * 400)) * (2 ** (t * 1.2))).clip(200, 12000), ((6000 + (c * 3000)) * (2 ** ((t - 0.4) * 1.5))).clip(1000, 18000), p[\sdgsnap].sqrt.max(0.08), "snares"] },
			readout: { |p| "% and % · %".format(SynthVoicePanes.format(p[\sdgfreq], "Hz"), SynthVoicePanes.format(upper.(p), "Hz"),
				if(p[\sdgcolor] < 0.5) { "nearly an octave" } { "a fifth" }) }),
		(type: \env, title: "shells against noise", len: { |p| max(p[\sdgdecay], p[\sdgnoise] + hold.(p)) * 1.05 },
			curves: { |p| [
				(func: { |t| (1 - p[\sdgsnap]).sqrt * fall.(p[\sdgdecay]).(t) }, label: "shells"),
				(func: { |t| p[\sdgsnap].sqrt * if(t < hold.(p)) { 1 } { fall.(p[\sdgnoise]).(t - hold.(p)) } }, label: "snares")] },
			readout: { |p| "shells % · snares % to -60 dB".format(SynthVoicePanes.format(p[\sdgdecay], "s"), SynthVoicePanes.format(p[\sdgnoise] + hold.(p), "s")) }),
		(type: \pitch, w: 0.75, title: "the hit", len: 0.08, zero: "lands",
			func: { |t, p| (1 + ((p[\sdgpunch].midiratio - 1) * ramp.(t))).log2 * 12 },
			range: { |p| [-1, (p[\sdgpunch] * 1.15).max(4)] },
			readout: { |p| "starts % st up, lands in 50 ms".format(p[\sdgpunch].round(0.1)) })
	],
	macros: [
		(name: "brightness", text: "tone and the snares", targets: [[\sdgtone, 0.5], [\sdgsnap, 0.25]]),
		(name: "timbre", text: "punch and drive", targets: [[\sdgpunch, 0.35], [\sdgdrive, 0.4]]),
		(name: "time", text: "decay, the snares follow", targets: [[\sdgdecay, 0.4], [\sdgnoise, 0.4]]),
		(name: "movement", text: "toward the 909 and its crack", targets: [[\sdgcolor, 0.4], [\sdgpunch, 0.3]])
	],
	cards: [
		(title: "model", knobs: [(key: \sdgcolor, label: "shells", switch: ["808", "909"], values: [0, 1], sub: "blend under more")]),
		(title: "hit", knobs: [
			(key: \sdgsnap, label: "snappy", spec: ControlSpec(0, 1), box: \pct, sub: "shells ↔ snares"),
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 24, \lin, 0, 3, "st"), sub: "how far it falls")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(80, 500, \exp, 0, 172, "Hz"), sub: "the low shell", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.03, 1, \exp, 0, 0.22, "s"), sub: "to -60 dB"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgnoise, label: "snares", spec: ControlSpec(0.02, 1, \exp, 0, 0.2, "s"), sub: "follows decay"),
		(key: \sdgcolor, label: "blend", spec: ControlSpec(0, 1), box: \pct, sub: "808 ↔ 909"),
		(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1), box: \pct)])
)
)
