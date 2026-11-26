// panels/sdghat.scd - what the hi-hat's window shows (SynthVoiceWindow).
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var f808 = [205.3, 304.4, 369.6, 522.7, 540, 800], f606 = [245, 306, 365, 415, 437, 619];
var squares = { |p| var r = p[\sdgtune].midiratio; f808.collect { |f, i| f * ((f606[i] / f) ** p[\sdgcolor]) * r } };
var hp = { |p| p[\sdgtone].linexp(0, 1, 3000, 10000) * p[\sdgtune].midiratio.clip(0.25, 4).sqrt };
// the def's shape: closed falls exponentially, open fades more evenly
var shape = { |p| var c = p[\sdgdecay].explin(0.1, 1, -6, -3); { |t| var x = (t / p[\sdgdecay]).clip(0, 1); 1 - ((1 - exp(c * x)) / (1 - exp(c))) } };
var kind = { |d| if(d < 0.2) { "closed" } { if(d < 0.45) { "pedal" } { "open" } } };
(
	colour: \gold, drum: true,
	hint: "tune - semitones, the squares and half as far the filters, as note does",
	panes: [
		(type: \partials, w: 1.1, title: "six squares, or noise", lo: 150,
			list: { |p| squares.(p).collect { |f, i| 5.collect { |n| var h = (2 * n) + 1;
				(hz: f * h, level: p[\sdgmetal].max(0.06) * (0.9 / h), width: if(n == 0) { 2.5 } { 1.2 }, fade: if(n == 0) { 1 } { 0.5 }) } }.flatten },
			band: { |p| [hp.(p), 18000, (1 - p[\sdgmetal]) * 0.8, "white noise"] },
			readout: { |p| var f = squares.(p); "% squares · % to %".format(pct.(p[\sdgmetal]), SynthVoicePanes.format(f.minItem, "Hz"), SynthVoicePanes.format(f.maxItem, "Hz")) }),
		(type: \filter, mode: \hp, w: 0.8, title: "high pass", cut: { |p| hp.(p) }, q: 0.2,
			readout: { |p| "from % up".format(SynthVoicePanes.format(hp.(p), "Hz")) }),
		(type: \env, title: "closed to open", len: { |p| (p[\sdgdecay] * 1.1).max(0.12) },
			curves: { |p| [(func: shape.(p), label: "level"),
				(func: { |t| p[\sdgclick] * exp(t.neg * 4 / 0.008) * (t < 0.008).binaryValue }, label: "tick")] },
			readout: { |p| "% · % to silence".format(kind.(p[\sdgdecay]), SynthVoicePanes.format(p[\sdgdecay], "s")) })
	],
	macros: [
		(name: "brightness", text: "tone and tick", targets: [[\sdgtone, 0.5], [\sdgclick, 0.4]]),
		(name: "timbre", text: "squares to noise, grit", targets: [[\sdgmetal, -0.4], [\sdgbits, 0.4]]),
		(name: "time", text: "closed to open", targets: [[\sdgdecay, 0.5]]),
		(name: "movement", text: "toward the 606, opening", targets: [[\sdgcolor, 0.5], [\sdgdecay, 0.25]])
	],
	cards: [
		(title: "model", knobs: [(key: \sdgcolor, label: "squares", switch: ["808", "606"], values: [0, 1], sub: "blend under more")]),
		(title: "hit", knobs: [
			(key: \sdgmetal, label: "metal", spec: ControlSpec(0, 1), box: \pct, sub: "noise ↔ squares"),
			(key: \sdgclick, label: "tick", spec: ControlSpec(0, 1), box: \pct, sub: "the first 10 ms")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgtune, label: "tune", size: \big, spec: ControlSpec(-24, 24, \lin, 0, 0, "st"), sub: "semitones", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.02, 2, \exp, 0, 0.11, "s"), sub: "closed ↔ open"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgcolor, label: "blend", spec: ControlSpec(0, 1), box: \pct, sub: "808 ↔ 606"),
		(key: \sdgbits, label: "grit", spec: ControlSpec(0, 1), box: \pct, floor: "clean", sub: "the 909's bits")])
)
)
