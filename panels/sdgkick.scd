// panels/sdgkick.scd - what the kick's window shows (SynthVoiceWindow).
(
var fall = { |decay| { |t| exp(t.neg * 6.9 / decay.max(0.001)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
(
	colour: \gold, drum: true,
	hint: "tune - 30 to 120 Hz on a log curve, shown with its note; the sweep follows the decay",
	links: (sdgdecay: [\sdgbend]),
	panes: [
		(type: \pitch, title: "the drop", len: { |p| (p[\sdgbend] * 2.5).clip(0.05, 1.5) }, func: { |t, p| p[\sdgpunch] * exp(t.neg * 5 / p[\sdgbend].max(0.001)) },
			range: { |p| [-2, (p[\sdgpunch] * 1.15).max(4)] }, zero: "lands",
			readout: { |p| "% st, over % of the decay = %".format(p[\sdgpunch].round(0.1), pct.(p[\sdgbend] / p[\sdgdecay]), SynthVoicePanes.format(p[\sdgbend], "s")) }),
		(type: \wave, w: 0.8, title: "body", func: { |ph, p| var s = sin(ph * 2pi), tri = (2 / pi) * asin(s);
			var w = blend(s, (tri * 1.4).tanh / 0.88, p[\sdgcolor]); (w * (1 + (p[\sdgdrive] * 7))).tanh / (1 + (p[\sdgdrive] * 7)).tanh },
			ref: { |ph| sin(ph * 2pi) }, refLabel: "808 sine", label: "909 triangle, drive", readout: { |p| hz.(p[\sdgfreq]) }),
		(type: \env, title: "body and beater", len: { |p| p[\sdgdecay] * 1.05 },
			curves: { |p| [(func: fall.(p[\sdgdecay]), label: "body"), (func: { |t| p[\sdgclick] * fall.(0.012).(t) }, label: "click")] },
			readout: { |p| "% to -60 dB".format(SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "tone and click", targets: [[\sdgtone, 0.5], [\sdgclick, 0.4]]),
		(name: "timbre", text: "punch and drive", targets: [[\sdgpunch, 0.35], [\sdgdrive, 0.3]]),
		(name: "time", text: "decay, the sweep follows", targets: [[\sdgdecay, 0.4], [\sdgbend, 0.4]]),
		(name: "movement", text: "how far and slow it falls", targets: [[\sdgpunch, 0.3], [\sdgbend, 0.5]])
	],
	cards: [
		(title: "model", knobs: [(key: \sdgcolor, label: "body", switch: ["808", "909"], values: [0, 1], sub: "blend under more")]),
		(title: "hit", knobs: [
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 48, \lin, 0, 12, "st"), sub: "how far it falls"),
			(key: \sdgclick, label: "click", spec: ControlSpec(0, 1), box: \pct, sub: "the beater")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(30, 120, \exp, 0, 49.5, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.05, 3, \exp, 0, 1.6, "s"), sub: "to -60 dB"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgbend, label: "sweep", spec: ControlSpec(0.001, 1, \exp, 0, 0.03, "s"), sub: "follows decay"),
		(key: \sdgcolor, label: "blend", spec: ControlSpec(0, 1), box: \pct, sub: "808 ↔ 909"),
		(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1), box: \pct)])
)
)
