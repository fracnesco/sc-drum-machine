// panels/sdgtom.scd - what the tom's window shows (SynthVoiceWindow).
(
var fall = { |decay| { |t| exp(t.neg * 6.9 / decay.max(0.001)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
// the def's pitch ramp: Env([1, 0], [bend], -7)
var ramp = { |t, bend| var x = (t / bend.max(0.001)).clip(0, 1); 1 - ((1 - exp(-7 * x)) / (1 - exp(-7))) };
(
	colour: \gold, drum: true,
	hint: "tune - 40 to 600 Hz on a log curve, shown with its note; the settle follows the decay",
	links: (sdgdecay: [\sdgbend]),
	panes: [
		(type: \pitch, title: "the skin settles", len: { |p| (p[\sdgbend] * 1.4).clip(0.02, 1.5) }, zero: "lands",
			func: { |t, p| (1 + ((p[\sdgpunch].midiratio - 1) * ramp.(t, p[\sdgbend]))).log2 * 12 },
			range: { |p| [-1, (p[\sdgpunch] * 1.15).max(4)] },
			readout: { |p| "% st up, settles in %".format(p[\sdgpunch].round(0.1), SynthVoicePanes.format(p[\sdgbend], "s")) }),
		(type: \wave, w: 0.8, title: "body", func: { |ph, p| var c = cos(ph * 2pi), h5 = p[\sdgtone].linlin(0, 1, 0.012, 0.04);
			var tri = (c + (cos(ph * 6pi) / 9) + (cos(ph * 10pi) * h5)) / (1.111 + h5); blend(c, tri, p[\sdgcolor]) },
			ref: { |ph| cos(ph * 2pi) }, refLabel: "808 sine", label: "909 triangle", readout: { |p| hz.(p[\sdgfreq]) }),
		(type: \env, title: "skin, noise and stick", len: { |p| p[\sdgdecay] * 1.25 },
			curves: { |p| [(func: fall.(p[\sdgdecay]), label: "skin"),
				(func: { |t| p[\sdgsnap] * if(t < 0.002) { t / 0.002 } { fall.(p[\sdgdecay] * 1.2).(t - 0.002) } }, label: "noise"),
				(func: { |t| p[\sdgclick] * fall.(0.006).(t) }, label: "stick", colour: \dim)] },
			readout: { |p| "% to -60 dB".format(SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "tone and stick", targets: [[\sdgtone, 0.5], [\sdgclick, 0.4]]),
		(name: "timbre", text: "toward the 909, more noise", targets: [[\sdgcolor, 0.5], [\sdgsnap, 0.3]]),
		(name: "time", text: "decay, the settle follows", targets: [[\sdgdecay, 0.4], [\sdgbend, 0.4]]),
		(name: "movement", text: "how far and slow it settles", targets: [[\sdgpunch, 0.35], [\sdgbend, 0.5]])
	],
	cards: [
		(title: "model", knobs: [(key: \sdgcolor, label: "body", switch: ["808", "909"], values: [0, 1], sub: "blend under more")]),
		(title: "hit", knobs: [
			(key: \sdgpunch, label: "punch", spec: ControlSpec(0, 24, \lin, 0, 4, "st"), sub: "how far it falls"),
			(key: \sdgclick, label: "stick", spec: ControlSpec(0, 1), box: \pct, sub: "the click")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(40, 600, \exp, 0, 90, "Hz"), sub: "Hz and its note", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.05, 2, \exp, 0, 0.6, "s"), sub: "to -60 dB"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgbend, label: "settle", spec: ControlSpec(0.001, 1, \exp, 0, 0.08, "s"), sub: "follows decay"),
		(key: \sdgsnap, label: "noise", spec: ControlSpec(0, 1), box: \pct, sub: "under the skin"),
		(key: \sdgcolor, label: "blend", spec: ControlSpec(0, 1), box: \pct, sub: "808 ↔ 909")])
)
)
